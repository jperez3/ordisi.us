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

#### Dev Container
1. In VSCode, press `command+shift+p`
2. Select "Dev Containers: Reopen in Container"

#### Local
1. Install tools: `brew install hugo opentofu pre-commit detect-secrets trivy`


### Build

1. In terminal, navigate to `app/blog`
2. Build Hugo site: `hugo`


### Run Hugo
1. Run Hugo server: `hugo server -D`
2. Validate: http://localhost:1313/


## Tools

### Pre-Commit
1. Testing pre-commit changes: `pre-commit run -a`
