# ordisi.us

## General

* Description: _[ordisi.us](https://www.ordisi.us) blog/portfolio project_
* Created By: Joe Perez


### Repo Structure

```bash
.
├── app                     # application code
│   └── blog                # hugo site
│       ├── archetypes
│       ├── assets
│       ├── content
│       │   └── posts       # markdown based blog posts go here
│       ├── data
│       ├── i18n
│       ├── layouts
│       ├── public          # built hugo site
│       ├── resources
│       ├── static
│       └── themes
│           └── typo
└── infra                   # infrastructure code
    └── workspaces
        ├── app
        │   └── blog        # resources to support hugo site
        └── global          # dns and other global level resources
```

## Local Dev

### Pre-Flight

#### Dev Container (Golden Path)
1. Install dev containers extension
2. Install Docker
3. In VSCode, press `command+shift+p`
4. Select "Dev Containers: Reopen in Container"

#### Local
1. Install tools: `brew install hugo opentofu pre-commit detect-secrets trivy`


### Build

1. In terminal, navigate to `app/blog`
2. Build Hugo site: `hugo`


### Run Hugo
1. Run Hugo server: `hugo server -D`
2. Browse to: http://localhost:1313/


### Develop
1. Make changes to markdown files in `app/blog/content` and save
    - Hugo will detect the change and reload automatically
2. Validate changes by browsing to: http://localhost:1313/

### Infrastructure
1. In terminal, browse to: `infra/workspaces/app/blog`
2. Create `prod.tfvars` file and update values:

```bash
env                   = "prod"
cloudflare_api_token  = "CLOUDFLAREAPITOKENGOESHERE"
cloudflare_account_id = "CLOUDFLAREACCOUNTIDGOESHERE"
r2_access_key         = "R2ACCESSKEYGOESHERE"
r2_secret_key         = "R2SECRETKEYGOESHERE"           #pragma: allowlist secret
```
_Note: Cloudflare does not offer OIDC/SSO similar to AWS_
3. Make changes to terraform files in `infra/workspaces/app/blog` and save
4. Initialize infrastructure: `tofu init -var-file=prod.tfvars`
5. See pending changes: `tofu plan -var-file=prod.tfvars`


### Creating PR

1. Check in code
2. Fill out PR details
3. Request review from team


## CI

### Cloudflare

* Workflow name: `N/A`
* Description: Cloudflare pages have been hooked into this repository. When a PR is created, a workflow will run to build the Hugo site and deploy it to Cloudlare pages. Once it's been deployed, the workflow will post a comment in the PR with details on how to preview the changes.

### Infrastructure

* Workflow name: `infra.yaml`
* Description: The Cloudflare pages infrastructure is managed by OpenTofu (Terraform.) When a PR is created, an approval to start the workflow is required (an extra precaution for a public repo), then the workflow will checkout the code, navigate to the workspace, initialize the infrastructure, run a plan, and post the pending changes as a comment on the PR. After the PR has been reviewed and merged to `main`, the workflow will run again and apply the changes.


### Spellcheck

* Workflow name: `markdown_spellcheck.yaml`
* Description: When a PR is created, this workflow will run a spellcheck on changes to markdown files. If there are spelling mistakes, the job will fail. If a word causes a failure, but is not actually a typo, it can be added to `.spellcheck-wordlist.txt`


## Tools

### Pre-Commit
1. Testing pre-commit changes: `pre-commit run -a`



### Resources

* [GHA - Spellcheck](https://github.com/rojopolis/spellcheck-github-actions)
* [GHA - Changed Files](https://github.com/tj-actions/changed-files)
