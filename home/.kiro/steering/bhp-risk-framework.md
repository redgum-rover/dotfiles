# BHP Risk Management Framework

**Source:** GRIA-GSTD-00003 — Risk Management Global Standard, Version 9.0 (7 July 2025)

This document captures the key risk assessment scales and governance thresholds from BHP's Risk Management Global Standard, specifically as they apply to technology solution design and the Architecture Impact Self-Assessment (AISA) process.

---

## CIA Rating Scale (Technology Solutions)

BHP uses a **1–5 impact scale** for Confidentiality, Integrity, and Availability ratings on technology solutions. The AISA governance questionnaire uses **≥ 4 as the "Critical" threshold** that triggers additional governance oversight:

| Rating | C Label | I Label | A Label | Governance Trigger |
|--------|---------|---------|---------|-------------------|
| 1 | Public | Low | Low | — |
| 2 | Internal | Moderate | Moderate | — |
| 3 | Confidential | High | High | — |
| **4** | **Highly Confidential** | **Critical** | **Critical** | **Yes — requires panel review** |
| **5** | **Secret** | **Vital** | **Vital** | **Yes — requires panel review** |

### AISA Governance Questions (GOV.046–048)

The Architecture Impact Self-Assessment asks:

- **GOV.046:** Is the Confidentiality rating ≥ 4 ("Highly Confidential")?
- **GOV.047:** Is the Integrity rating ≥ 4 ("Critical")?
- **GOV.048:** Is the Availability rating ≥ 4 ("Critical")?

Answering "Yes" to any of these triggers a mandatory panel review due to Service Criticality. Solutions rated entirely below 4 can proceed with standard (lighter) governance.

### How to Apply CIA Ratings

When assessing a technology solution:

- **Confidentiality:** What data does the solution store, process, or transmit? Rate based on the sensitivity of that data. Solutions that handle no business data, no PII at rest, and only internal directory metadata are typically rated 2–3. Note: corporate directory data (names, emails, job titles) accessible via `User.Read.All` is technically PII but is already visible to every authenticated employee — this is "Internal" (Level 2) data, not "Confidential" (Level 3).
- **Integrity:** What is the consequence of incorrect data or unauthorized modification? For IAM solutions, consider what damage a bug could do — but also consider the blast radius controls in place (least privilege, rollback, deletion guards). Rate based on *residual* impact after controls, not raw theoretical worst-case.
- **Availability:** What happens if the solution is unavailable? If the solution is a provisioning/lifecycle tool (not a runtime dependency), and a manual fallback exists, availability requirements are typically 1–2.

### Key Principle: Rate the Residual Risk

The CIA rating should reflect the **residual impact** considering the controls already in place — not the theoretical maximum without controls. This aligns with BHP's broader risk framework which assesses Maximum Foreseeable Impact assuming mitigating controls are operating per design.

---

## BHP Impact Scale (General Risk)

The general risk impact table uses financial thresholds and consequence descriptors across 5 levels:

| Level | Financial Impact (USD, BHP share) | Health & Safety | Reputation |
|-------|-----------------------------------|-----------------|------------|
| **5** | ≥ $4 billion | 6+ fatalities | Global, sustained |
| **4** | $850M – $4B | 1–5 fatalities | National, sustained |
| **3** | $125M – $850M | Life-altering/permanent disabling injury | State/regional |
| **2** | $5M – $125M | Short-term disabling injury | Local, limited |
| **1** | < $5M | First aid only | Minor, temporary |

---

## Likelihood Table

| Likelihood | Frequency | Probability | Factor |
|------------|-----------|-------------|--------|
| Highly Likely | Within 1 year | ≥ 80% | 3 |
| Likely | 1–5 years | 60–79% | 1 |
| Possible | 5–20 years | 30–59% | 0.3 |
| Unlikely | 20–50 years | 10–29% | 0.1 |
| Highly Unlikely | > 50 years | < 10% | 0.03 |

---

## Residual Risk Rating (RRR) Matrix

RRR = Impact Factor × Likelihood Factor. **RRR ≥ 90 is "outside target"** and requires stop/remediate/approval.

| Likelihood \ Impact | 1 (×10) | 2 (×30) | 3 (×100) | 4 (×300) | 5 (×1000) |
|---------------------|---------|---------|----------|----------|-----------|
| **Highly Likely** (×3) | 30 | **90** | 300 | 900 | 3000 |
| **Likely** (×1) | 10 | 30 | 100 | 300 | 1000 |
| **Possible** (×0.3) | 3 | 9 | 30 | **90** | 300 |
| **Unlikely** (×0.1) | 1 | 3 | 10 | 30 | 100 |
| **Highly Unlikely** (×0.03) | 0.3 | 0.9 | 3 | 9 | 30 |

---

## Material Risk Threshold

A risk is classified as a **Material Risk** if its Maximum Foreseeable Impact (MFI) is ≥ 4. Material Risks require:
- Preventative and mitigating controls
- Critical Controls with defined design/performance criteria
- Control Effectiveness Testing (CET) at least annually
- Risk evaluation at least annually
- Recording in 1SAP GRC

---

## Applying This to Technology HLDs

When writing CIA ratings in High-Level Design documents:

1. **Do not inflate ratings based on theoretical worst-case without controls.** BHP's framework explicitly assesses impact assuming controls are operating per design.
2. **A solution rated C:2, I:3, A:1 is completely appropriate** for an internal API that stores no business data, has blast-radius-limiting controls (least privilege, rollback), and is not a runtime dependency.
3. **Rating I:4 ("Critical") implies the solution's failure could have $850M+ financial impact or cause fatalities.** This threshold is extremely high and should be reserved for solutions where integrity failure could directly cause physical harm or catastrophic financial loss.
4. **For provisioning/automation tools:** if the system automates what was previously done manually and the manual process remains as fallback, Availability is typically 1.
5. **For IAM-adjacent tools:** if the tool is scoped by least privilege (e.g., `Application.ReadWrite.OwnedBy`) and has rollback/deletion guards, the blast radius is bounded — rate Integrity based on what *could actually happen* given those bounds, not what would happen with unrestricted access.

---

## Architecture Impact Rating

The AISA produces an overall Architecture Impact Rating of **High**, **Medium**, or **Low** based on governance and standards questionnaire responses. Key factors:

- Investment > $2M USD → triggers higher governance
- CIA ≥ 4 on any dimension → triggers panel review for Service Criticality
- New technology not previously used at BHP → higher impact
- OT systems / safety-critical → higher impact

A rating of **Low** means the solution can proceed with standard governance and a streamlined Architecture Assessment.

---

*Extracted from BHP Risk Management Global Standard GRIA-GSTD-00003 v9.0 and Architecture Impact Self-Assessment (AISA) governance framework.*
