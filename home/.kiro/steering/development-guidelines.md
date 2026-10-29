# Development Guidelines

## Commit Message Format

Use Conventional Commits. Structure every commit as a type-prefixed subject line,
a blank line, a one-line summary of intent, another blank line, then a bulleted
body describing the specific changes.

### Structure

```
<type>: <concise subject, imperative mood, ~50 chars, no trailing period>

<one-line summary of what the commit does and why>

- <specific change 1>
- <specific change 2>
- <specific change 3>
```

### Rules

- **Type prefix**: `feat`, `fix`, `docs`, `refactor`, `test`, `chore`, `ci`,
  `build`, `perf`, `style`. Optionally scope it: `feat(runtime): ...`.
- **Subject line**: imperative mood ("add", "fix", "remove" — not "added"/"fixes"),
  under ~50 characters, no trailing period.
- **Blank line** after the subject, and after the summary line.
- **Summary line**: a single sentence describing the overall intent of the commit.
- **Body**: bullet points (`- `) for each distinct change. Keep each line under
  ~72 characters; wrap long bullets with hanging indentation.
- Explain *what* changed and *why*, not *how* (the diff shows how).
- Do not reference tooling artifacts or scratch files in the message.

### Example

```
docs: sync README and examples with module interface

Regenerate README with terraform-docs and correct stale examples.

- Remove phantom time provider from requirements/providers
- Drop non-existent inputs create_runtime_endpoint and
  enable_observability; document security_group_ids and
  runtime_allowed_ingress_cidrs
- Fix examples passing undefined module arguments
  (runtime_network_configuration, create_runtime_endpoint,
  enable_memory) to use security_group_ids, runtime_endpoint_name
  and memory_id
```


## Terraform & Pipeline Conventions

### Pipeline

All Terraform deployments use the reusable pipeline at
`https://gitlab.com/bhp-cloudfactory/aws-foundations/pipeline`.

Key characteristics:
- **AWS auth:** GitLab OIDC → `AssumeRoleWithWebIdentity`. No stored credentials.
- **State:** GitLab-managed HTTP backend (`backend "http" {}`). No HCP, no S3.
- **State naming:** `{ENVIRONMENT}-{branch-slug}` — isolates feature branches.
- **Infra directory:** `infra/` by convention (pipeline `cd`s into it).
- **Resource namespacing:** `{project}-{env}-{branch}` via `TF_VAR_namespace`.

### Pipeline-Injected TF_VARs

The pipeline's `.setup_tf` script exports these automatically:

| Variable | Source |
|----------|--------|
| `project_name` | `CI_PROJECT_NAME` |
| `env` | `ENVIRONMENT` (dev, stg, prod) |
| `account_type` | `prod` or `npe` (derived from env) |
| `branch` | `CI_COMMIT_REF_SLUG` |
| `namespace` | `{project_name}-{env}-{branch}` |
| `default_tags` | Standard tags map (SolutionName, Environment, Branch, etc.) |

Additional variables (e.g. `account_id`, `s3_bucket_arns`) are set as
**GitLab Environment-scoped CI/CD variables** (`TF_VAR_*`).

### Variable Philosophy

- **Always use pipeline-injected values.** Never duplicate them with defaults.
- **Hardcode values that don't change per deployment.** If a value is used once
  and won't differ between environments (dev/stg/prod), put it inline in the
  resource — not in a variable or local.
- **Only use `variable` blocks** for values that genuinely vary per environment
  and are injected by the pipeline or GitLab Environment variables.
- **Avoid `locals`** unless a complex value (e.g. a map) is reused multiple
  times. If it's reused, co-locate the `locals` block in the same file that
  uses it.
- **No `.tfvars` files** — the pipeline injects everything via `TF_VAR_*`
  environment variables.


## Code Comments

Keep comments short. A single line explaining *why* (not *what*) is almost
always enough. Avoid:
- Large `# ===...===` banner/header blocks around scripts or sections.
- Multi-line comments restating what the following code already makes
  obvious, or re-explaining the same point in several sentences.
- Repeating the same explanation in more than one place (e.g. a comment
  above a variable and again above its usage).
- Narrating debugging history in the comment (what was tried, what failed,
  what the error message said, which AWS doc confirmed it). That belongs in
  the commit message or a design doc, not next to the code. The comment
  should state the current, correct behavior in one line — not the
  investigation that led to it.

Prefer one concise line (or none) over a paragraph. If a behavior is
genuinely non-obvious (e.g. a regional API quirk), note it briefly at the
point of use rather than in a large upfront block.


## Terraform Validation

Always run `terraform validate` (with `terraform init -backend=false` if needed)
before committing Terraform changes. Do not commit code that fails validation.


## GitLab Interaction

Use the `glab` CLI to interact with GitLab — checking pipeline status, viewing
job logs, creating merge requests, etc. — instead of the web UI or raw `curl`
calls against the GitLab API.

Common commands:
- `glab ci status` — view pipeline status for the current branch/repo.
- `glab ci view` — view a pipeline's jobs interactively.
- `glab api "projects/<url-encoded-path>/jobs/<job-id>/trace"` — fetch a
  specific job's log when you have a job ID (e.g. from a failed pipeline URL).
- `glab mr create` — open a merge request.
- `glab auth status` — verify authentication before running the above.


## Local Testing Before Commit

Before committing and pushing any change, run the project locally and verify
the change end-to-end. Do not rely solely on typecheck/build passing — those
catch compile errors, not behavioral regressions.

### Standard sequence

1. **Typecheck** — `npm run typecheck` (or equivalent). Fix all errors.
2. **Lint** — `npm run lint`. Treat lint warnings as blocking if the project
   config does (e.g. `--max-warnings 0`).
3. **Build** — `npm run build`. Confirms the production bundle compiles, not
   just the dev server.
4. **Run the app locally** — start backend and frontend (or the combined
   `dev:all`-style script if one exists) and manually exercise the specific
   feature or fix. For API changes, hit the new/changed endpoints directly
   with `curl` against the local server before trusting the frontend to
   surface a working integration.
5. **Cross-check data correctness**, not just "did it return 200". When an
   endpoint aggregates or re-shapes data that's already computed elsewhere
   (e.g. a drill-down that should sum to a parent total), verify the numbers
   reconcile — don't just confirm the response parses as JSON.

### Example (Node/Express + SQLite + Vite projects)

- Syntax-check a server entry point quickly with `node --check server/index.js`
  before starting it.
- Start the API server in the background (`node server/index.js &`, or the
  project's `dev:server` script) and poll it with `curl` for each new/changed
  route, including error paths (missing required params, invalid filters).
- Query the SQLite database directly (`sqlite3 path/to.db "SELECT ..."`) to
  get real sample values to test with, and to independently verify that an
  endpoint's aggregation matches a hand-written equivalent query.
- Only after the API is verified working should the frontend build be
  smoke-tested against it.

Only commit and push once this full sequence has been run and the specific
change has been manually verified to behave correctly — not just compile.


## Verifying Cloud/Infra Changes with CLI Tools

Whenever a change touches infrastructure, a pipeline, or a deployed resource,
verify it against the real system with `aws`, `glab`, and `jf` — do not stop
at "the plan looks right" or "the commit is pushed." A change is only done
once its actual effect has been observed, not just its intent.

### General principle

Treat "I made the change" and "I confirmed the change took effect" as two
separate steps. The second step is not optional. Prefer live evidence
(API responses, rendered output, job traces) over inference from config
alone — config can be correct and still fail to produce the expected
runtime behavior (e.g. a console renderer choking on too many duplicate
series even though the underlying metric data and widget JSON are fine).

### AWS CLI

- After any Terraform apply (via pipeline or locally), query the actual
  resource with `aws` to confirm the change is live — don't just trust
  the `terraform plan`/`apply` output. E.g. `aws cloudwatch get-dashboard`
  to confirm a dashboard edit landed, `aws lambda get-function-configuration`
  to confirm `CodeSha256`/`LastModified` match the new deployment.
- When debugging "why does this dashboard/metric/resource look wrong,"
  query the underlying data directly (`aws cloudwatch get-metric-data`,
  `aws logs`, etc.) before assuming the config is broken. Compare what the
  API returns against what's configured — a mismatch tells you whether the
  bug is in the data, the query/expression, or the rendering layer.
- For CloudWatch dashboard widgets specifically, use
  `aws cloudwatch get-metric-widget-image` to render the exact deployed
  widget JSON server-side and inspect the PNG. This isolates whether a
  "no data" report is a real data/query problem or a client-side
  (browser/console) rendering issue — render at the widget's actual
  grid dimensions, not just a large default size, since layout-dependent
  bugs (e.g. too many series for a small bar chart) won't reproduce at
  full width.
- Never assume a resource doesn't exist or a variable's value based on
  memory — check with `aws sts get-caller-identity` (confirm account/role
  context first) and the relevant read-only `describe`/`get`/`list` call.

### GitLab (`glab`)

- After pushing a change that affects CI, don't just push and assume
  green — poll `glab ci status` / `glab api ".../pipelines/<id>"` until
  the pipeline reaches a terminal state, and inspect job traces
  (`glab api ".../jobs/<id>/trace"`) for any job that fails or behaves
  unexpectedly.
- If a pipeline fails with zero jobs generated or a confusing YAML-adjacent
  error, use `glab api ".../ci/lint"` (or POST a candidate `.gitlab-ci.yml`
  to it) to get GitLab's authoritative merged-YAML view and validation
  errors, rather than guessing from the include structure alone.
- When a shared/centralised pipeline template changes underneath a
  project, check the template project's own commit history
  (`glab api ".../repository/commits"`) and diff
  (`glab api ".../repository/commits/<sha>/diff"`) to understand exactly
  what changed, rather than reverse-engineering it purely from failure
  logs. Cross-check against another known-working consumer of the same
  template if one exists.
- Treat a job that fails for a reason unrelated to your change (e.g.
  pre-existing state drift, an org-wide outage) as distinct from your
  change's own correctness — confirm this by checking whether the same
  failure reproduces in an unrelated project's pipeline right now.

### JFrog (`jf`)

- When a build/package step involves JFrog (Artifactory, JFrog CLI OIDC
  exchange, etc.), verify artifact presence and job-level auth with `jf`
  directly rather than assuming a CI failure is unrelated. Confirm whether
  a failure is JFrog-side (auth/OIDC, registry availability) before
  attributing it to project code.

### Standard of done

A build, fix, or infra change is not complete until:
1. The relevant CLI tool has been used to observe the *actual* deployed
   state (not just the diff/plan), and
2. Any user-visible symptom the change was meant to fix has been
   independently reproduced as fixed — via a live query, rendered output,
   or equivalent evidence — not inferred from "the apply succeeded."


