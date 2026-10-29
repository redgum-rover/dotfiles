# BHP Bedrock Guardrail — Enforcement & Tier Context

Context for the org-level Amazon Bedrock Guardrail enforcement work in
`terraform-organization-mgmt`. Source docs:
- `docs/BEDROCK_GUARDRAIL_ENFORCEMENT_PLAN.md` (background — how enforcement works)
- `docs/BEDROCK_GUARDRAIL_REMEDIATION_PLAN.md` (forward plan: A3/B4/B5/B6/C8)
- `BEDROCK_GUARDRAIL_INCIDENT_2026-09-10.md` (in the *old* repo — root cause)

Org ID `o-fzgnmf48lx` · Mgmt account `174264307355` (prod) · Test org `083334183455`.

## AWS access

Use the SSO profiles described in `aws-sso-access.md` (this replaces the `*.env` files).
ViewOnly is the default. Any Admin profile needs explicit user approval.

## VALIDATED EVIDENCE — 2026-10-05 (live tests, all three accounts)

Credentials for all 3 accounts now exist as local `*.env` files in the repo
(gitignored as of this date — they were **not** ignored before, which was a
credential-commit risk): `master-org.env` (174264307355, ViewOnly),
`test-org.env` (083334183455, Admin), `test-account.env` (**545788340810**,
Admin — the prod member test account in `ou-genai-agt-tst`).

### API field trap — `crossRegionDetails`, not `crossRegionConfig`

`get-guardrail` returns CRIS under **`crossRegionDetails`**. The Terraform
argument is `cross_region_config`, so querying `--query crossRegionConfig`
returns `null` even when CRIS is present. This produced a false "prod has no
CRIS" conclusion on 2026-10-01. **Prod DOES have CRIS** — confirmed on DRAFT
*and* enforced versions (apse2 v7 → `au.guardrail.v1:0`, use1 v5 →
`us.guardrail.v1:0`). The long-standing "CLASSIC + CRIS working in prod" claim
is correct.

**Consequence: do NOT gate `cross_region_config` on `tier == "STANDARD"`.**
Prod is CLASSIC + CRIS, so gating would strip CRIS from prod. The original
conflict-resolution decision (keep CRIS unconditional) was right.

### Cross-account ApplyGuardrail — PROVEN WORKING (first time ever)

From member account `545788340810` against the prod guardrails:

| Test | Result |
|---|---|
| apse2, enforced v7 | **success**, `action: NONE` |
| us-east-1, enforced v5, ×12 calls | **12/12 success** |
| apse2, **DRAFT** version | **success** — DRAFT is addressable cross-account |

So RBP + cross-account authorisation works. Caveat: the test account has
AdministratorAccess, so this proves the *RBP* side, not that real workload roles
carry `bedrock:ApplyGuardrail`.

**DRAFT being callable cross-account is the key enabler:** prod's DRAFT can be
flipped to STANDARD and validated from the member account while all enforced
accounts stay pinned to v7. Config changes only reach traffic when the
`aws_bedrock_guardrail_version.description` string changes.

### The 2026-09-10 incident reproduced, and STANDARD proven to fix it

Controlled A/B — identical 150,000-char payload (150 text units), same guardrail:

| Tier | Result |
|---|---|
| prod apse2 **CLASSIC** v7 | `ThrottlingException ... 150 text units exceeds maximum allowed (106 text units) for the denied topic policy (Classic tier)` — SDK retried twice, still failed |
| tst apse2 **CLASSIC** v3 | same failure (control) |
| tst apse2 **STANDARD** v6 | **accepted**, `topicPolicyUnits: 150` |

STANDARD ceiling confirmed empirically: **390 units accepted, 450 rejected** →
the 400-unit cap is real. Retries provably cannot help (the error is a size
rejection wearing a throttling error code).

Denied topics still enforce on STANDARD: `medical_diagnosis` returned
`GUARDRAIL_INTERVENED` / `BLOCKED`, re-confirming that
`bedrock_enforcement_action = NONE` does **not** make topics detect-only.

### Missing burst RBPs = latent, load-triggered prod exposure

Prod use1 (v5, enforced) has CRIS via `us.guardrail.v1:0`, whose destinations are
us-east-1 / us-east-2 / us-west-2. The **us-east-2 and us-west-2 profile RBPs are
still missing** in prod. 12 consecutive us-east-1 calls all succeeded, so AWS
keeps low-volume traffic in-region; the gap only bites when CRIS actually bursts
— i.e. under load, exactly when it hurts most. Fixing it is a **production fix**,
not pre-positioning.

### Test org cannot do runtime validation — ever, until accounts are vended

`list-accounts` in 083334183455 returns **exactly one** account: the management
account itself. All 7 GenAI OUs have 0 accounts. Cross-account testing is
structurally impossible there, which is why the prod member test account is the
only viable validation vehicle.

### Prod enforcement scope (2026-10-05)

52 accounts: `ou-genai-agt-npe` 35, `ou-genai-agt-exp` 14, `ou-genai-agt-tst` 1,
`ou-cdn-npe` 2 (plus a redundant account-level attachment on 545788340810, which
already sits inside agt-tst — a deliberate test hook, not drift).
**Not** attached: `ou-genai-agt-prd` **16**, `ou-genai-app-npe-private` **31**,
`ou-genai-app-prd-private` 7, `ou-genai-app-tst-private` 0 = 54 accounts.
Note `ou-genai-agt-prd` is unguarded while agt-npe/exp/tst are guarded.

---



## Guardrail tiers and the input-size cap

The denied-**topic** policy has a far lower per-request input cap than every
other policy type. Moving CLASSIC → STANDARD raises that cap:

| Quota | CLASSIC | STANDARD | Region |
|---|---|---|---|
| Topic policy max input (`L-DD0273B7` CLASSIC / `L-3B60C1ED` STANDARD) | **106** units | **400** units | ap-southeast-2 |
| Topic policy max input | **200** units | **1000** units | us-east-1 |
| Content policy max input (`L-B90A0AF2`) | 1000 units | — | both |

- **1 text unit = 1,000 characters.**
- **apse2 increase: 106 → 400 (~3.77×, +294 units, ~106k → ~400k chars).**
- **us-east-1 increase: 200 → 1000 (5×, +800 units).**
- Only the *topic* check is capped this low; content/PII/word policies allow
  1,000 units even on CLASSIC.
- STANDARD is a capacity increase, **not** an unbounded fix — approved-models
  SCP permits 1M-token models by wildcard, so 400k chars is still partial.

## Operating regions and CRIS destinations (verified 2026-10-01)

BHP operates **only** in `ap-southeast-2` and `us-east-1`. CRIS burst destinations
are AWS-defined per profile, *not* determined by where we deploy
(docs: guardrails-cross-region-support.html):

| Profile | Source | Destination Regions |
|---|---|---|
| `au.guardrail.v1:0` | ap-southeast-2 | **ap-southeast-2 only** |
| `us.guardrail.v1:0` | us-east-1 | **us-east-1, us-east-2, us-west-2** |

- **apse2 CRIS never leaves the region** → STANDARD + CRIS in apse2 is in-region
  and fixes the 106→400 topic input cap where it actually bites.
- **us-east-1 CRIS routes evaluation to us-east-2 + us-west-2**, outside the two
  approved regions. Guardrail evaluation inspects prompt/response content, so this
  is a data-residency question, and it is invisible to the region-lock baseline
  SCPs because the routing is AWS-internal, not an API call from the account.

### DECIDED 2026-10-01: Option B — keep CRIS in both regions

- **6 RBPs in scope** (not 3): 2 guardrails + `au.guardrail.v1:0` (apse2) +
  `us.guardrail.v1:0` in us-east-1, us-east-2, us-west-2.
- Rationale: keeps STANDARD available in us-east-1 and leaves prod's working
  CLASSIC + CRIS untouched.
- **Accepted residency position:** us-east-1 guardrail evaluation may be processed
  in us-east-2 / us-west-2. Formal sign-off from the data residency / privacy owner
  is still owed, to be recorded against the GenAI HLD/TSA.
- The merged code already implements this (CRIS unconditional in both regions), so
  **no Terraform change to the guardrail resources is required** — the outstanding
  work is creating the 6 RBPs.

## RBPs can be managed in Terraform via `awscc`

- `aws` provider 6.66.0: **no** `aws_bedrock_guardrail_resource_policy` (PR #48697
  still unreleased). `aws_bedrockagentcore_resource_policy` is a different service.
- `awscc` 1.104.0: **`awscc_bedrock_resource_policy`** — `resource_arn` accepts
  "the Bedrock Guardrail **or Guardrail Profile** resource" + `policy_document`,
  so one resource type covers all RBPs.
- Backing CFN type `AWS::Bedrock::ResourcePolicy` verified **LIVE / FULLY_MUTABLE**
  in ap-southeast-2, us-east-1, us-east-2, us-west-2.
- Test org: create fresh (all empty). Prod: 4 exist by hand → need `import`.
- Also exists: `awscc_bedrock_enforced_guardrail_configuration` — *account-level*
  enforced config (not the Organizations policy); different mechanism.

## Two distinct CLASSIC-tier topic-policy quotas (do not confuse)

The denied-topic policy has **two** separate CLASSIC-tier limits, both surfacing
as `ThrottlingException` / `ModelThrottledException`. They are different problems
with different fixes:

| | Input-size cap | Throughput cap |
|---|---|---|
| Caps | Max text units in a **single** request | Text units **per second** (TUPS) |
| Quota | `L-DD0273B7` (CLASSIC) / `L-3B60C1ED` (STANDARD) | separate per-second TUPS quota |
| Error text | generic throttling; request is oversize | `"...text units per second limit exceeded"`, `"Too many requests sent to ApplyGuardrail"` |
| Retry helps? | **No** — same oversize payload always fails | **Yes** — rate-based, drains with backoff |
| The 2026-09-10 incident | this one (106-unit apse2 cap) | — |

Observed throughput error verbatim:
`Too many requests sent to ApplyGuardrail: On-demand ApplyGuardrail denied topic
policy (Classic tier) text units per second limit exceeded.`

Both are on the *topic* check, both say CLASSIC, both throttle — easy to
conflate. `messages: comprehensive` worsens **both** (re-scans whole
conversation each turn → more units per request AND per second).

Mitigations for the **throughput** (TUPS) error:
1. Exponential backoff + jitter (retries genuinely help here, unlike the size cap).
2. Service Quota increase on the topic-policy TUPS quota (per-account, per-region).
3. `messages: selective` instead of `comprehensive` (stops per-turn full re-scan).
4. STANDARD tier raises throughput too — but requires CRIS; STANDARD + CRIS
   cross-account still untested (A3).
5. Smooth request rate / reduce concurrency if bursts spike the per-second bucket.

### Verified quota codes (live-checked 2026-09-24, acct 493746473120)

Denied-**topic** policy TUPS (the quota behind the throughput error):

| Tier | Quota code | apse2 | us-east-1 | Adjustable |
|---|---|---|---|---|
| CLASSIC | `L-124DCF3D` | 25 u/s | 50 u/s | Yes |
| STANDARD | `L-5755FAB6` | 25 u/s | 200 u/s | Yes |

- 1 text unit = 1,000 chars. apse2 CLASSIC default = 25 u/s (~25k chars/s).
- **apse2: moving CLASSIC→STANDARD does NOT raise this TUPS quota** — both
  default to 25 in apse2 (confirmed via `get-aws-default-service-quota`). The
  tier flip only helps TUPS in us-east-1 (50→200) and some EU/US regions.
  This is the opposite of the input-*size* cap (`L-DD0273B7`/`L-3B60C1ED`),
  where STANDARD *does* raise apse2 106→400.
- In apse2 the real fix for the throughput error is a quota increase on
  `L-124DCF3D` (or `messages: selective`), not the tier flip.
- Do not confuse with the *content-filter* TUPS quota `L-01F3CD81`
  (apse2 25 / us-east-1 200) — different policy check.

## Why it caused the 2026-09-10 incident

- Callers in apse2 got `ThrottlingException` → `ModelThrottledException`. It was
  **not** capacity throttling — it was the 106-unit topic-input cap on CLASSIC,
  at AWS default, never raised.
- `messages: comprehensive` re-scans the whole conversation each turn, so
  sessions trip the cap mid-conversation → looks intermittent.
- A size rejection masquerades as a capacity problem, so SDK retries never succeed.

## Key constraints when changing tier

- **STANDARD requires `cross_region_config` (CRIS).** Flipping tier = "flip tier
  + add CRIS" in `aws_bedrock_guardrail.tf` (both `apse2` and `use1` guardrails).
  - apse2 guardrail → profile `au.guardrail.v1:0` (stays in ap-southeast-2)
  - use1 guardrail → profile `us.guardrail.v1:0` (bursts to us-east-1/2, us-west-2)
- **CLASSIC + CRIS** cross-account is **PROVEN** as of 2026-10-05 — real
  `ApplyGuardrail` calls from member account 545788340810 against prod apse2 v7
  and use1 v5 (12/12) all succeeded. Not just "believed working".
- **STANDARD + CRIS cross-account is STILL the one untested combination.** The
  2026-10-05 STANDARD tests were run from the test-org *management* account
  against its own guardrail, so they validate the **tier/size behaviour** but
  **not** the cross-account authorisation path. Prod is CLASSIC, so prod's
  passing cross-account tests do not cover STANDARD.
  **How to close it:** flip prod DRAFT to STANDARD (no description change, so
  nothing republishes), then call `ApplyGuardrail --guardrail-version DRAFT`
  from 545788340810 in both Regions. DRAFT is confirmed addressable
  cross-account, so this validates STANDARD + CRIS with all 52 enforced
  accounts still pinned to the CLASSIC v7/v5 versions.
- Provider issue #45915 historically gated topic `input_action`/`output_action`;
  confirm the pinned provider supports STANDARD topic tiers before flipping.
- Config key in the org Bedrock policy schema must be `config_1` (not `org_guardrail`).

## Enforcement mechanics (how it authorises)

- Guardrails are **regional** and **management-account owned** → two guardrails
  (`apse2` + `use1`) via `aws.master_apse2` / `aws.master_use1` providers.
- Org policy = the mandate; each member-account call makes a **cross-account**
  `ApplyGuardrail`, needing BOTH:
  1. a resource-based policy (RBP) on the guardrail granting the org
     `bedrock:ApplyGuardrail`, and
  2. member-account IAM allowing `bedrock:ApplyGuardrail` (owner unconfirmed —
     gates go-live, not managed in this repo).
- Skip either → `AccessDenied` on `InvokeModel`/`Converse`.
- Org policy must reference the **numeric** guardrail version, not DRAFT. Any
  config change must also bump `aws_bedrock_guardrail_version` description.
- **6 RBPs total:** 2 guardrails + 4 profile objects (`au.guardrail.v1:0` in
  apse2; `us.guardrail.v1:0` in us-east-1, us-east-2, us-west-2 — the last two
  are currently missing).

## Current state in this repo

**Updated 2026-09-29** after merging `main` into `feature-HYDCLOUD-91910` and
applying to the test org (`083334183455`, pipeline 2892116467).

- Guardrail tier: `var.bedrock_guardrail_tier` — tst = **STANDARD**, prd = CLASSIC.
- `cross_region_config` (CRIS) is applied **unconditionally**, independent of the
  tier. Gating it on STANDARD would strip CRIS from prd (CLASSIC), which has run
  CLASSIC + CRIS cross-account since 2026-08-31.
- Enforcement JSON `messages: comprehensive` (the setting that made it bite).
- **`policy_attachments_bedrock` is NO LONGER null everywhere.** `main` declares
  `cflz-gr-bedrock-guardrail-enforcement` (type `BEDROCK_POLICY`) attached to
  **4 OUs**: `ou-genai-agt-npe`, `ou-genai-agt-exp`, `ou-genai-agt-tst`,
  `ou-cdn-npe` — the same four that went live in the old repo and caused the
  2026-09-10 incident. The comments in `aws_org_policies_config.yaml` still claim
  "ENFORCEMENT NOT ... null on every OU" and are stale/contradictory.
- Content filters are pinned to `BLOCK` and deliberately ignore
  `var.bedrock_enforcement_action`. Denied topics cannot honour it at all — the
  provider's `topic_policy_config.topics_config` exposes no
  `input_action`/`output_action` (hashicorp/terraform-provider-aws#45916), so
  Bedrock applies its server-side default. So `bedrock_enforcement_action = NONE`
  does **not** mean "detect-only overall".

### Gate status (verified live, test org, 2026-10-01 — direct CLI access)

**A3 was REVERTED.** Our apply (pipeline 2892116467, 2026-09-29 06:48) set
STANDARD + published version 4. `feature-vpc-teardown-scp-exemption` (MR !12)
then auto-applied **3 more times** (last 2026-09-30 10:22). That branch is
main-based and `main` has **no `bedrock_guardrail_tier` variable** — it hardcodes
`tier_name = "CLASSIC"`. So it reset the tier and published version 5.

Live test-org state (`083334183455`), verified by direct API calls:

| Item | Live value |
|---|---|
| Guardrails | `bhp-org-guardrail` only — apse2 `idzx2k32fch0`, use1 `1l20fquy4rrh` (the `-test` pair from MR !13 was destroyed by our apply) |
| content/topic tier | **CLASSIC** (our STANDARD reverted) |
| CRIS | present — `au.guardrail.v1:0` / `us.guardrail.v1:0` |
| Published versions | 2, 3, 4 (ours), **5 (live, from !12)** |
| Org policy | `cflz-gr-bedrock-guardrail-enforcement` `p-55rf69tkw3`, type `BEDROCK_POLICY`, pins `...:5` |
| `messages` | **`comprehensive`** (system: `selective`); `included_models: ALL` minus 3 embedding models |
| Denied topics | `medical_diagnosis` — the exact topic that triggered the incident |
| Attachments | **4 OUs**: ou-cdn-npe, ou-genai-agt-npe, ou-genai-agt-tst, ou-genai-agt-exp |
| **All 6 RBPs** | **UPDATE 2026-10-01 (later same day): CREATED and verified live.** All 6 `awscc_bedrock_resource_policy` resources applied via tst pipeline (`2899588177`/`2899589567`, commit `d595c62`) and independently confirmed non-empty via direct `aws bedrock get-resource-policy` calls. Enforcement is now attached AND authorised in the test org — the attached-but-unauthorised gap is closed. See `HANDOVER-bedrock-guardrail-rbp.md` §0 for full detail (ARNs, verification table). **Outstanding: no child/member account exists in any of the 4 enforced OUs yet, so cross-account `ApplyGuardrail` has still not been exercised end-to-end — that is the real go/no-go test and remains blocked on account provisioning, not on RBPs.** |

So the test org previously reproduced the **incident configuration** (CLASSIC +
`comprehensive` + `medical_diagnosis`) with enforcement live on 4 OUs and **zero
RBPs** → member-account cross-account `ApplyGuardrail` would have failed
`AccessDenied`. As of 2026-10-01 the RBP side of that gap is closed; the
member-account-side verification is still pending account creation.

Quotas confirmed in the test org itself (apse2): topic input CLASSIC `L-DD0273B7`
= **106**, STANDARD `L-3B60C1ED` = **400**; topic TUPS CLASSIC `L-124DCF3D` = **25**,
STANDARD `L-5755FAB6` = **25** — re-confirming STANDARD does not raise TUPS in apse2.

Script defects (still open):
- **B6 is a confirmed false negative** — it reports "policy not found in org"
  although `list-policies --filter BEDROCK_POLICY` returns `p-55rf69tkw3` and
  `list-targets-for-policy` returns exactly the 4 declared OUs.
- **B5 never runs a real check:** `servicequotas:GetAWSDefaultServiceQuota` is
  explicitly denied by `arn:aws:iam::083334183455:policy/terraform` (cap → 0), and
  it calls `aws bedrock-runtime apply-guardrail`, absent from the pinned
  aws-cli 2.15.14 (only `invoke-model`).
- **CI DAG bug:** both verify jobs `needs: plan`, so they race `apply` and read
  `terraform output` before state is written. Should be `needs: apply`.
- Note `get-resource-policy` returns the key **`resourcePolicy`** (value `"{}"`
  when absent) — scripts keying on `policy` will misparse.

### tst pipeline mechanics (post-main-merge)

- `apply` is **automatic** (main removed `when: manual`); `destroy` is disabled
  for tst. Prod is now Terraform Cloud via `.cicd/tfc_run.py`.
- tst state is a **single shared state** (`terraform-organization-mgmt_tst`) for
  all branches — applying one branch reverts other branches' applied work.

## Sequence to enable enforcement (gated, do not skip)

1. A3: apply STANDARD + CRIS in test org; validate cross-account
   `ApplyGuardrail` both regions. Decide STANDARD vs CLASSIC + fallback.
2. B4: all 6 RBPs exist and reconciliation passes.
3. Grant member-account `bedrock:ApplyGuardrail` IAM (cross-team dependency).
4. B5: size-regression test passes for the version to be enforced, both regions.
5. Attach to **one** OU with `bedrock_enforcement_action = NONE` (detect), watch
   CloudTrail for `AccessDenied`, then widen.
6. Flip to `BLOCK` only after a detect-mode soak.

If STANDARD + CRIS fails cross-account again, fallbacks are: raise `L-DD0273B7`
per-account, switch `messages: selective`, or drop the topic policy — recorded
as an explicit decision, never silently reverted.
