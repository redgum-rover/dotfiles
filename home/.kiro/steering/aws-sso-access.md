# AWS Access via SSO Profiles

> ## ⚠️ WARNING: you can access AWS on your own
> These profiles let you reach live BHP accounts, including **production
> management (174264307355)**, without the user typing anything.
>
> - **Use ViewOnly / ReadOnly profiles by default** for every query.
> - **If an account has no ViewOnly / ReadOnly profile**, you may use its Admin profile
>   without asking, **for read-only calls only** (`get-*`, `list-*`, `describe-*`,
>   `sts get-caller-identity`, and similar). Say which profile you used. Check the
>   account's profiles first (see below); if a ViewOnly/ReadOnly one exists, use it.
> - **Before any call that changes anything** (create, update, delete, put, attach,
>   invoke, apply, deploy), through any profile, **stop and get the user's explicit
>   approval for that specific action.** Say which profile, account and command
>   you'll use. Approval covers only that action. It doesn't carry over to later calls.

## How the profiles work

`~/.aws/config` holds native AWS CLI SSO profiles created by `aws-sso-util`
(`~/.local/bin/aws-sso-util`), named `<account_id>.<role_name>`. There's one for
every account and role the user can access in both Identity Center instances
(about 1,240 profiles).

| Org | Start URL | SSO region |
|---|---|---|
| Main | `https://bhp.awsapps.com/start` | us-east-1 |
| Test | `https://bhp-test.awsapps.com/start` | us-east-1 |

Use a profile by name:
- `use_aws` tool: `profile_name: "174264307355.S-ViewOnlyAccess"`
- Shell: `aws ... --profile 174264307355.S-ViewOnlyAccess` or `AWS_PROFILE=...`

Find the profiles for an account:
```bash
grep -oE '^\[profile 545788340810\.[^]]+' ~/.aws/config
```

Always run `aws sts get-caller-identity --profile <name>` first to confirm the
account and role.

## Common accounts

| Account | Purpose | Default profile | Write/Admin (approval required) |
|---|---|---|---|
| 174264307355 | Prod org mgmt | `174264307355.S-ViewOnlyAccess` | `174264307355.S-AdministratorAccess` |
| 545788340810 | Prod member test account | `545788340810.S-ViewOnlyAccess` | `545788340810.S-AdministratorAccess` |
| 083334183455 | Test org mgmt | `083334183455.S-AdministratorAccess` (no ViewOnly role; read-only calls only) | same profile |

## Expired session

If a call fails with an expired or missing SSO token, stop and ask the user to run
the command below. You can't complete the browser login.
```bash
aws-sso-util login -u https://bhp.awsapps.com/start       # main org
aws-sso-util login -u https://bhp-test.awsapps.com/start  # test org
```
Edge opens through `BROWSER=~/.local/bin/edge-open` (set in `~/.zshrc`).

`aws-sso-util configure populate` is only needed when the user gains access to new
accounts. It's slow (about 3 min for the main org), so run it in the background.
