# ordisi.us

### General

* Description: _ordisi.us blog/portfolio project_
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

### Pre-Flight

1. Install tools: `brew install hugo opentofu pre-commit detect-secrets`


### Pre-Commit

1. Create detect-secrets baseline: `detect-secrets scan > .secrets.baseline`
