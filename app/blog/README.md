# Blog - ordisius.us

## General

* Site: [ordisi.us](https://www.ordisi.us)


## Local Dev

### Pre-Flight

#### Dev Container (Golden Path)
1. In VSCode, press `command+shift+p`
2. Select "Dev Containers: Reopen in Container"

#### Local (Alternative)
1. Install tools: `brew install hugo opentofu pre-commit detect-secrets`

### Create new post
1. Create new blog post: `hugo new content/posts/EXAMPLE.md`

### Build

1. In terminal, navigate to `app/blog`
2. Build Hugo site: `hugo`


### Run Hugo
1. Run Hugo server: `hugo server -D`
2. Validate: http://localhost:1313/



### Resources

* [Dev Container Setup for Hugo](https://theindiecoder.cloud/posts/dev-container-setup-for-hugo/)
* [Github Actions for Hugo](https://github.com/marketplace/actions/hugo-setup)
