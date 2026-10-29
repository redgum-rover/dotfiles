# BHP AWS Organization & OU Structure

**Organization ID:** o-fzgnmf48lx
**Management Account:** 174264307355 (BHP-Master-Billing-Account)
**Root ID:** r-nwee

## Policy Types Enabled

| Policy Type | Status |
|---|---|
| Service Control Policy (SCP) | Enabled |
| Tag Policy | Enabled |
| Backup Policy | Enabled |
| AI Services Opt Out Policy | Enabled |

## OU Hierarchy with Account Counts

```
Root (r-nwee) — 2 accounts directly at root
├── audit (ou-nwee-07lzexj3) — 0 accounts
├── core (ou-nwee-ijlv9igl) — 19 accounts
├── test (ou-nwee-1lcyp8x6) — 5 accounts
│   ├── npe (ou-nwee-ml1tzgfp) — 0 accounts
│   └── prd (ou-nwee-0rlkt310) — 0 accounts
├── ou-app-npe-private (ou-nwee-1wq82lpu) — 271 accounts
├── ou-app-npe-public (ou-nwee-klv4zp3x) — 17 accounts
├── ou-app-prd-private (ou-nwee-u8mmmlaa) — 173 accounts
├── ou-app-prd-public (ou-nwee-szupfz4q) — 11 accounts
├── ou-app-pov-all (ou-nwee-i4fpzhuh) — 8 accounts
├── ou-app-exp (ou-nwee-cvcd5qyf) — 4 accounts
├── ou-exception-npe-all (ou-nwee-zjxb0wdl) — 2 accounts
├── ou-exception-npe-minerals_cloud (ou-nwee-9ip0zyt6) — 3 accounts
├── ou-exception-prd-all (ou-nwee-urueyvqi) — 1 account
├── ou-exception-prd-minerals_cloud (ou-nwee-t39nvjd3) — 0 accounts
├── ou-bma (ou-nwee-lnw4oq03) — 0 accounts
│   ├── ou-bma-npe-private (ou-nwee-q6uae5qd) — 0 accounts
│   ├── ou-bma-npe-public (ou-nwee-jd3ybm0p) — 0 accounts
│   ├── ou-bma-prd-private (ou-nwee-ejdovkz6) — 0 accounts
│   └── ou-bma-prd-public (ou-nwee-zuhkojpa) — 0 accounts
├── ou-cusa (ou-nwee-32q6qhsa) — 0 accounts
│   ├── ou-cusa-npe-private (ou-nwee-1mxt1mki) — 0 accounts
│   ├── ou-cusa-npe-public (ou-nwee-ecngwwjm) — 0 accounts
│   ├── ou-cusa-prd-private (ou-nwee-55ie0jmf) — 5 accounts
│   └── ou-cusa-prd-public (ou-nwee-zcap3mi9) — 0 accounts
├── ou-eg (ou-nwee-y7mrzhdi) — 0 accounts
│   ├── ou-eg-npe-private (ou-nwee-8s37n2a2) — 1 account
│   ├── ou-eg-npe-public (ou-nwee-1jdc54pm) — 0 accounts
│   ├── ou-eg-prd-private (ou-nwee-yhvuup56) — 18 accounts
│   └── ou-eg-prd-public (ou-nwee-56yzy7pq) — 5 accounts
├── ou-mei (ou-nwee-qz8i1z1f) — 0 accounts
│   ├── ou-mei-npe-private (ou-nwee-yiziavwe) — 0 accounts
│   ├── ou-mei-npe-public (ou-nwee-639mv5lb) — 0 accounts
│   ├── ou-mei-prd-private (ou-nwee-ciydfq7o) — 7 accounts
│   └── ou-mei-prd-public (ou-nwee-5k8yzfff) — 1 account
├── ou-pn (ou-nwee-zbymzyre) — 0 accounts
│   ├── ou-pn-npe-private (ou-nwee-iw7v1wf7) — 0 accounts
│   ├── ou-pn-npe-public (ou-nwee-ksyzeeja) — 0 accounts
│   ├── ou-pn-prd-private (ou-nwee-7x5x8mtx) — 2 accounts
│   └── ou-pn-prd-public (ou-nwee-4fn3p2jt) — 0 accounts
├── ou-ptsh (ou-nwee-flaao43s) — 0 accounts
│   ├── ou-ptsh-npe-private (ou-nwee-frucsej2) — 0 accounts
│   ├── ou-ptsh-npe-public (ou-nwee-toh4xoos) — 0 accounts
│   ├── ou-ptsh-prd-private (ou-nwee-azflc7s4) — 0 accounts
│   └── ou-ptsh-prd-public (ou-nwee-tm8o9ogb) — 0 accounts
├── ou-waio (ou-nwee-r9ayb73d) — 0 accounts
│   ├── ou-waio-npe-private (ou-nwee-6swr9hjb) — 0 accounts
│   ├── ou-waio-npe-public (ou-nwee-crznziu7) — 0 accounts
│   ├── ou-waio-prd-private (ou-nwee-vh36chec) — 3 accounts
│   └── ou-waio-prd-public (ou-nwee-st402z2b) — 0 accounts
├── ou-contactctr (ou-nwee-oocdau4w) — 0 accounts
│   ├── ou-contactctr-npe (ou-nwee-eh9s6kvd) — 2 accounts
│   └── ou-contactctr-prd (ou-nwee-ekvayxcm) — 0 accounts
├── ou-genai (ou-nwee-5orois7z) — 0 accounts
│   ├── ou-genai-app-npe-private (ou-nwee-fgiogkj8) — 30 accounts
│   ├── ou-genai-app-prd-private (ou-nwee-dwvguei8) — 7 accounts
│   ├── ou-genai-app-tst-private (ou-nwee-t8i3k113) — 0 accounts
│   ├── ou-genai-agt-npe (ou-nwee-3phk0gv6) — 7 accounts
│   ├── ou-genai-agt-prd (ou-nwee-z44b1hv0) — 0 accounts
│   └── ou-genai-agt-exp (ou-nwee-irroq2ar) — 2 accounts
└── ou-tpsvcs (ou-nwee-7cfhn81b) — 0 accounts
    ├── ou-tpsvcs-npe (ou-nwee-awf79rf1) — 0 accounts
    └── ou-tpsvcs-prd (ou-nwee-l5ts3bha) — 2 accounts
```

## Account Count Summary

| OU | Total Accounts (incl. children) |
|---|---|
| **ou-app-npe-private** | **271** |
| **ou-app-prd-private** | **173** |
| **ou-genai** (all children) | **46** |
| **ou-eg** (all children) | **24** |
| core | 19 |
| ou-app-npe-public | 17 |
| ou-app-prd-public | 11 |
| **ou-mei** (all children) | **8** |
| ou-app-pov-all | 8 |
| test | 5 |
| ou-cusa (all children) | 5 |
| ou-app-exp | 4 |
| ou-exception-npe-minerals_cloud | 3 |
| ou-waio (all children) | 3 |
| ou-exception-npe-all | 2 |
| ou-contactctr (all children) | 2 |
| ou-tpsvcs (all children) | 2 |
| ou-pn (all children) | 2 |
| Root (direct) | 2 |
| ou-exception-prd-all | 1 |
| **ou-bma** (all children) | **0** |
| **ou-ptsh** (all children) | **0** |
| ou-exception-prd-minerals_cloud | 0 |
| audit | 0 |
| **Total** | **~608** |

## Organization Policies

### Service Control Policies (SCPs)

28 SCPs are defined. They fall into 5 categories:

#### 1. Approved Services (Allowlists)

These SCPs restrict which AWS services accounts can use. They are environment-specific:

| Policy | Attached To | Purpose |
|---|---|---|
| `cflz-gr-scp-npe-all-approved_services` | All 16 NPE leaf OUs | Limits services in non-production |
| `cflz-gr-scp-prd-all-approved_services` | All 16 PRD leaf OUs | Limits services in production |
| `cflz-gr-scp-tst-all-approved_services` | test OU | Limits services in test |
| `cflz-gr-scp-exp-all-approved_services` | ou-app-exp | Limits services in experimental |
| `cflz-gr-scp-npe-contactcenter-approved_services` | ou-contactctr-npe | Contact Centre NPE service allowlist |
| `cflz-gr-scp-prd-contactcenter-approved_services` | ou-contactctr-prd | Contact Centre PRD service allowlist |
| `cflz-gr-scp-npe-tpsvcs-approved_services` | ou-tpsvcs-npe | Third-party services NPE allowlist |
| `cflz-gr-scp-prd-tpsvcs-approved_services` | ou-tpsvcs-prd | Third-party services PRD allowlist |
| `cflz-gr-scp-npe-genai-approved_services` | ou-genai-app-npe-private | GenAI app NPE service allowlist |
| `cflz-gr-scp-prd-genai-approved_services` | ou-genai-app-prd-private | GenAI app PRD service allowlist |
| `cflz-gr-scp-tst-all-approved_services_genai` | ou-genai-app-tst-private | GenAI test service allowlist |
| `cflz-gr-scp-npe-genai_agt-approved_services` | ou-genai-agt-npe | GenAI Agent NPE allowlist |
| `cflz-gr-scp-prd-genai_agt-approved_services` | ou-genai-agt-prd | GenAI Agent PRD allowlist |
| `cflz-gr-scp-exp-genai_agt-approved_services` | ou-genai-agt-exp | GenAI Agent Explore allowlist |

#### 2. Baseline Policies (Encryption & Region Restrictions)

| Policy | Attached To | Purpose |
|---|---|---|
| `cflz-gr-scp-all-private-baseline` | All private OUs (26 OUs) | Enforce encryption, limit regions for private accounts |
| `cflz-gr-scp-all-public-baseline` | All public OUs (16 OUs) | Enforce encryption, limit regions for public accounts |
| `cflz-gr-scp-tst-private-baseline` | test OU | Test-specific private baseline |

#### 3. Network Protection

| Policy | Attached To | Purpose |
|---|---|---|
| `cflz-gr-scp-npe-all-protect_network` | All 15 NPE leaf OUs + ou-app-exp | Prevent changes to network resources in NPE |
| `cflz-gr-scp-prd-all-protect_network` | All 12 PRD leaf OUs | Prevent changes to network resources in PRD |
| `cflz-gr-scp-tst-all-protect_network` | test OU | Prevent network changes in test |

#### 4. Config/Guardrail Protection

| Policy | Attached To | Purpose |
|---|---|---|
| `cflz-gr-scp-all-all-protect_config` | 18 top-level OUs (all spoke OUs) | Prevent modification of AWS Config, guardrail resources |
| `cflz-gr-scp-tst-all-protect_config` | test OU | Same for test |

#### 5. GenAI Service & Model Restrictions

Bedrock and AgentCore are **only enabled in the GenAI OU** — they are explicitly denied in all other OUs via the approved services SCPs.

| OU Type | Bedrock | AgentCore | SCP |
|---|---|---|---|
| Standard accounts (ou-app-*) | ❌ Denied | ❌ Denied | `*-all-approved_services` (bedrock not in NotAction) |
| GenAI app accounts (ou-genai-app-*) | ✅ Allowed | ❌ Denied | `*-genai-approved_services` (bedrock:* in NotAction) |
| GenAI agent accounts (ou-genai-agt-*) | ✅ Allowed | ✅ Allowed | `*-genai_agt-approved_services` (bedrock:* + bedrock-agentcore:* in NotAction) |

Additionally, the approved foundation models are restricted:

| Policy | Attached To | Purpose |
|---|---|---|
| `cflz-gr-scp-all-genai-approved_models` | ou-genai-agt-exp, ou-genai-agt-npe, ou-genai-agt-prd | Restrict which foundation models can be invoked |

**Implication:** Teams in standard spoke accounts (444 of 608 accounts) cannot use Bedrock at all. They must either get their account moved to the GenAI OU or be placed in an exception OU.

#### 6. Datadog Integration & Other

| Policy | Attached To | Purpose |
|---|---|---|
| `datadog-integration-no-internet` | Not attached | Datadog integration for private accounts |
| `datadog-integration-allow-internet` | Not attached | Datadog S3 put for public accounts |
| `FullAWSAccessToRestrictedRegions` | Not attached | Allows full access in us-east-1 and ap-southeast-2 |

### Tag Policies

| Policy | Attached To | Purpose |
|---|---|---|
| `cflz-gr-tag-tst-all-standard_tags_test` | test OU | Enforce standard tagging (test only) |

Only 1 tag policy exists and it's only applied to the test OU — tag enforcement is not yet rolled out to production.

### Backup Policies

64 backup policies exist, following a matrix of:
- **Environment:** npe / prd
- **Business Unit:** all, bma, cusa, eg, mei, pn, ptsh, waio
- **Tier:** platinum, gold, silver, bronze (CIA classification)
- **Special:** S3 continuous backup (npe/prd)

**Attachment pattern:**
- `*-all-*` policies (platinum/gold/silver/bronze) → attached to generic OUs (ou-app-npe-private, ou-app-prd-private, etc.)
- `*-{asset}-*` policies → attached to asset-specific child OUs (e.g. `prd-waio-bronze` → ou-waio-prd-private + ou-waio-prd-public)

Accounts in asset-specific OUs get **both** the generic `all` backup policies AND their asset-specific backup policies (inheritance). The tiered approach (platinum/gold/silver/bronze) maps to different RPO/RTO requirements based on data classification.

### AI Services Opt-Out Policy

| Policy | Attached To | Purpose |
|---|---|---|
| `cflz-gr-ai-optout-all` | 22 OUs (all top-level OUs including core) | Opt out of AWS AI service data usage for model improvement |

Applied to virtually the entire organisation — BHP has opted out of AWS using their data for AI service improvement across all accounts.

---

## SCP Layering Model

Accounts receive multiple SCPs through OU attachment. A typical **private NPE account** in `ou-app-npe-private` receives:

1. `cflz-gr-scp-npe-all-approved_services` — Service allowlist
2. `cflz-gr-scp-all-private-baseline` — Encryption + region lock
3. `cflz-gr-scp-npe-all-protect_network` — Network protection
4. `cflz-gr-scp-all-all-protect_config` — Guardrail protection

A **GenAI agent account** in `ou-genai-agt-npe` receives:

1. `cflz-gr-scp-npe-genai_agt-approved_services` — GenAI agent service allowlist
2. `cflz-gr-scp-all-private-baseline` — Encryption + region lock
3. `cflz-gr-scp-npe-all-protect_network` — Network protection
4. `cflz-gr-scp-all-genai-approved_models` — Foundation model restrictions

---

## Key Design Decisions

1. **Region lock** — All accounts are restricted to `us-east-1` and `ap-southeast-2` only (via baseline SCPs).
2. **Service allowlists, not denylists** — The approved_services SCPs are allowlists, meaning only explicitly approved AWS services can be used. This is a restrictive posture.
3. **Network is centrally controlled** — The protect_network SCPs prevent spoke accounts from modifying VPCs, TGW attachments, and routing. All networking is managed by the Cloud Platform team.
4. **GenAI has its own governance** — Separate service allowlists AND model restrictions for GenAI workloads, with distinct agent vs app tiers.
5. **Exception OUs bypass service restrictions** — The exception OUs (`ou-exception-npe-all`, `ou-exception-prd-all`) only have the protect_config SCP, not the approved_services SCP. These accounts have broader service access.
6. **Test OU is a policy sandbox** — The test OU has its own versions of all policy types (including the only tag policy), used to validate policy changes before rollout.
7. **Backup is asset-aware** — Even though most accounts haven't moved to asset OUs, the backup policy framework is already built for the full asset-specific structure.

---

## Gaps and Observations

- **No SCPs on `core` or `audit` OUs** — These are trusted infrastructure accounts with no service restrictions.
- **Tag policy not enforced in production** — Only applied to test OU.
- **Exception OUs have minimal restrictions** — Only config protection, no service or network SCPs.
- **FullAWSAccess SCP** (default) is attached at root — all accounts inherit it, but the restrictive SCPs narrow it down per OU.

---

## Key Structural Observations

**Account Distribution is Heavily Centralised:**
The vast majority of accounts (**444 of ~608, or 73%**) sit in the two generic top-level OUs:
- `ou-app-npe-private` — 271 accounts
- `ou-app-prd-private` — 173 accounts

Most workloads are **not** segregated by business unit at the OU level.

**Asset-Specific OUs Are Largely Empty:**
The business unit OUs (bma, cusa, eg, mei, pn, ptsh, waio) were created to segregate workloads by asset but adoption is minimal. No NPE accounts have been migrated to asset-specific OUs (except 1 in ou-eg). Migration is production-first and incomplete.

**GenAI is Growing Fast:**
The `ou-genai` OU has **46 accounts** — the 3rd largest grouping. NPE alone has 30 app accounts + 7 agent accounts, indicating rapid experimentation.

**Other Patterns:**
- Private dominates public — Public (internet-facing) accounts are rare.
- No accounts at parent OU level — accounts only exist in leaf child OUs.
- Exception OUs are small — Only 6 accounts total, most workloads conform to standard guardrails.

---

## Governance Summary

| Layer | Mechanism | Scope |
|---|---|---|
| Region restriction | Baseline SCPs | All spoke accounts |
| Service allowlisting | Approved services SCPs | All spoke accounts (per environment) |
| Network immutability | Protect network SCPs | All spoke accounts |
| Guardrail protection | Protect config SCPs | All spoke accounts |
| AI model governance | Approved models SCP | GenAI agent accounts only |
| Data backup | Backup policies (tiered) | All spoke accounts + asset-specific |
| AI data opt-out | AI opt-out policy | Entire organisation |
| Tag enforcement | Tag policy | Test OU only (not yet rolled out) |

---

*Generated from AWS Organizations API (read-only) — 2026-05-19*
