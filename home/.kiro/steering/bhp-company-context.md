# BHP Technology Platforms — Global Steering Document

## 1. Company Overview

BHP is the world's largest mining company. They build and run numerous technology platforms and maintain hundreds of in-house built applications across a multi-cloud environment.

### Cloud Strategy

- **AWS** — Primary cloud for bespoke applications, data workloads, and AI.
- **Azure** — Primary cloud for COTS (Commercial Off-The-Shelf) workloads.

### Supported Languages

- **TypeScript**
- **Python**
- **C#**

### Infrastructure Tooling

- **Terraform** with **HCP Backend** for state management is the current standard for infrastructure-as-code.
- Terraform has been the standard since BHP's cloud adoption. A **Cloud Platform** provisions AWS accounts, then development teams create Terraform infrastructure within those accounts.
- BHP previously attempted to create **centralised Terraform modules** to standardise infrastructure patterns. These modules were not properly maintained — no team owned them, no SLAs existed, and they became stale. Development teams stopped using them. This failed initiative is a key reason for the current trust deficit around centrally provided infrastructure tooling.

---

## 2. Operating Model

BHP is not a DevOps company. The operating model follows a capital-funded project lifecycle:

1. **Funding & Build** — Initiatives receive capital funding. A project team is spun up to build a new application or product.
2. **Handover** — When funding runs dry, the application is handed over to a service owner and centralised operations teams.
3. **Ongoing Operations** — Operations teams inherit full responsibility for the application and its underlying infrastructure.

### Core Problem with This Model

The operations teams come from a traditional hosting background (VMs and databases). They are not equipped to manage cloud-native solutions. The consequences are:

- **Vulnerabilities and patching** are routed back to the original development team, which no longer exists.
- **Terraform stacks** are handed over without context, become stale, pipelines fail, and infrastructure state becomes locked.
- **Operations teams** are managing and attempting to operate hundreds of AWS accounts and Azure subscriptions with insufficient cloud-native expertise.

**This operating model is a fixed constraint and is not changing.**

### Vortex Initiative

In response to the operational challenges above, BHP has created an initiative called **Vortex**. The purpose of Vortex is to move operations teams away from managing infrastructure via Terraform and instead operate directly on infrastructure using **Runbooks in AWS Systems Manager (SSM)**. These runbooks perform common operational activities such as resizing instances, patching, and other Day 2 tasks. This reflects a strategic direction where operations teams interact with infrastructure through operational tooling (SSM Runbooks) rather than IaC tooling (Terraform).

When a Vortex Runbook cannot resolve an issue, it escalates to the operations team for manual investigation. If the operations team cannot resolve it, it escalates back to the development team — which may have been disbanded post-TTO. This escalation gap is a known structural problem.

### Lifecycle Gates

Applications follow a gated lifecycle to production:

1. **Design** — Application and infrastructure design.
2. **HLD / TSA Signoff** — High-Level Design and Technical Security Assessment must be approved before production deployment. Development teams are encouraged to initiate this process as soon as design is complete (not after build) to avoid delays. The more standardised platform components a team uses, the lighter this process becomes.
3. **Build** — Development and infrastructure provisioning.
4. **TTO Checklist** — Before production, a Transition to Operations checklist must be completed. This identifies a service owner and documents all components so operations teams can manage the application long-term.
5. **Production Deployment** — Application goes live.
6. **Ongoing Operations** — Operations teams manage the application via Vortex Runbooks and escalation paths.

### Operations Model

- Operations is a **single centralised team** (not aligned to business units).
- They currently handle **L1 support only**. Anything beyond L1 escalates to the development team.
- This creates a structural problem: development teams end up performing too much operational work, and post-TTO, the development team may no longer exist.

### CI/CD

- **GitLab** is the standard CI/CD platform. Developers build their own pipelines.
- **ArgoCD** is used specifically for CaaS workloads — it pulls Kubernetes manifests into the shared EKS cluster via GitOps.

### Platform Teams

The following platform teams exist at BHP:

| Platform Team | Scope |
|---|---|
| **CaaS** | Shared EKS compute, Crossplane compositions, workload deployment patterns |
| **Shared Database** | Shared RDS cluster, per-application database provisioning |
| **Networking / Connectivity** | Network infrastructure, connectivity between environments |
| **IAM / Identity** | Entra ID, App Registrations, access management |
| **CI/CD** | GitLab platform (but developers build their own pipelines) |

---

## 3. Strategic Direction — Shared Platforms

BHP's solution to the operational challenges above is **shared platforms**. The intent is to stop each team provisioning their own AWS account or Azure subscription and subsequently handballing it to operations.

### Rationale

- Drastically reduce **Total Cost of Ownership (TCO)**.
- Centralise operational responsibility onto purpose-built platform teams.
- Remove the need for operations teams to manage individual cloud accounts.

### Trade-offs

- **Reduced flexibility** for development teams, at least initially.
- Development teams now depend on centrally built internal platforms instead of directly interacting with AWS/Azure.
- **Trust deficit** — Development teams have historically lost trust in central platforms because previous iterations were built poorly.

**The shared platform vision is a fixed constraint and is not changing.**

---

## 4. Current Shared Platforms

### 4.1 CaaS — Container-as-a-Service (Compute)

A centralised **Amazon EKS** cluster providing shared compute. The cluster itself is managed by the CaaS platform team using **Terraform**. This is the consultant's team — the backlog is directly influenceable.

**Tenancy Provisioning:**
- A "Create Tenancy" form is published via **Port.io** (the developer platform).
- Under the hood, the form triggers an API that interacts with Kubernetes to provision:
  - Namespaces
  - RoleBindings
  - Resource Quotas
  - Network Policies
- Provisioning is **fully automated** via consumer-facing APIs.

**Workload Deployment:**
- Developers push container images to **JFrog Artifactory**.
- The cluster deploys images from Artifactory.
- Developers can deploy using their own **Kubernetes manifests / Helm charts**, or use a **cookie-cutter template** provided by the platform team.

**Maturity: Medium** — Tenancy provisioning is automated, but significant gaps remain before the platform delivers a true Day 1 developer experience.

**Known Gaps (Horizon 1 — FY27 Roadmap):**

The current developer journey to non-production takes ~1.5 weeks across 4 manual requests to 4 separate teams. Three of those four steps are not automated:

| Blocker | Current Wait | Status |
|---------|-------------|--------|
| Cloud Landscape Provisioning | ~2 days | Not automated |
| Entra ID App Registration | ~1 week | Not automated |
| Terraform Project / Workspace | ~1 day | Automated ✓ |
| SSL Certificate Provisioning | ~2 days | Not automated |

Three initiatives are in flight to close these gaps:

1. **One-Click Workload Provisioning** — Single Port self-service action that provisions a standardised Helm chart (Deployment, Service, Ingress, cert-manager Certificate), automates AD group membership via Microsoft Graph API, and creates ArgoCD Repository + Application declaratively. Eliminates per-team manifest drift and manual ArgoCD configuration.
2. **Entra ID App Registration API** — A single API call provisions a fully secured App Registration (Auth Code + PKCE only, single-tenant, v2 tokens, no secrets, appRoleAssignmentRequired: true, atomic provisioning with rollback). Eliminates the ~1 week IAM queue.
3. **SSL Certificate Automation** — Self-service REST API for certificate lifecycle (order, store, retrieve, renew, revoke) backed by DigiCert CertCentral, AWS Secrets Manager, and Step Functions. Includes automated renewal and Certificate Transparency monitoring. Eliminates the ~2 day manual certificate request.

**Vision:** Enable Day 1 Delivery — code to non-production in minutes, production in under a day. The platform's standardised patterns are the foundation for a proposed Architecture Board fast-track that would reduce HLD/TSA governance overhead by ~80–90% for teams deploying on platform templates.

**Key Dependencies:** All three initiatives depend on the IAM team accepting ownership post-build. The approach is to arrive with complete designs, working PoCs, and a clear ownership model — not open-ended requests for effort.

### 4.2 Shared Database Platform (Data)

A single **Amazon RDS cluster** with individual databases provisioned per application/workload.

**Provisioning:**
- Databases are **hand-provisioned** — no end-to-end automation.
- Likely provisioned via CLI commands against existing clusters.
- No real infrastructure-as-code in place.

**Maturity: Low** — Manual processes, no self-service, no automation.

---

## 5. The Gap — Problem Statement

While the two shared platforms reduce TCO, they limit developer capability. Developers building modern applications naturally require resources beyond compute and relational databases:

- Object storage (e.g. S3 buckets)
- Serverless functions (e.g. Lambda)
- NoSQL databases (e.g. DynamoDB)
- Queues and notifications (e.g. SQS, SNS)
- Event-driven architectures (e.g. EventBridge)

**None of these are currently supported by the shared platforms.**

### Current Developer Experience

To build a complete application, a developer must:

1. Provision **compute** via CaaS (shared EKS).
2. Provision a **relational database** via the shared database platform.
3. Provision **all other cloud resources** in their own AWS account — managed via a completely separate method (Terraform, manual, etc.).

This fragments the developer experience across three different provisioning methods and reintroduces the original operational handover problem for the resources outside the shared platforms.

---

## 6. Consultant Context

### Advisor Profile

- **Background:** 7-year tenure at AWS as a Senior Cloud Architect. Software engineer by trade with 12+ years of experience. Deep expertise across software engineering, cloud architecture, DevOps, and AI.
- **Role at BHP:** Consultant brought in to advise on how platforms and product teams can align. Specifically tasked with accelerating adoption of internal platforms.
- **Value Proposition:** Bridges the gap between platform builders and platform consumers — with deep experience on both sides. Has built products on platforms and built the platforms themselves.

### Mandate

Accelerate developer adoption of BHP's internal shared platforms by ensuring they genuinely serve development teams — providing freedom, guardrails, governance, and a path to self-service for the full spectrum of cloud resources developers need.

---

## 7. Glossary

| Term | Definition |
|---|---|
| **TTO** | Transition to Operations — the handover point where a project team transfers ownership of an application and its infrastructure to centralised operations teams. |

---

*Document Version: 1.2 — 30 April 2026*
