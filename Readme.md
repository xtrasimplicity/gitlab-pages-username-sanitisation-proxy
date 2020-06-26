# GitLab Pages - Username sanitisation proxy
_Simple reverse proxy to sit in front of GitLab pages, to fix SSL support for GitLab usernames with dots in them._

## How it works
Currently, if a GitLab username is in the format `firstname.lastname` (or some other format that includes dots), GitLab will automatically set the subdomain for the user's GitLab pages to be `firstname.lastname.gitlab-pages-fqdn`.

As a result, we end up with an additional level of subdomain nesting that works fine for HTTP, but not at all for HTTPS. When using HTTPS, you would need to have a wildcard certificate to cover `*.*.gitlab-pages-fqdn` (which isn't possible), or use `Let's Encrypt` and _somehow_ dynamically fetch certs **and** avoid their rate limiting.

Instead, this simple reverse proxy sits in front of your GitLab Pages server and rewrites URLs into something a little more browser-friendly.

### Example
Say I have a GitLab Pages server running on `pages.mycorp.local`, my username is `fred.smith` and my pages-enabled repository is called `myrepo`.

When I follow the GitLab-generated URL of `http://fred.smith.pages.mycorp.local/myrepo`, this proxy will automatically redirect the user to `https://fred-smith.pages.mycorp.local/myrepo`.

The request to `https://fred-smith.pages.mycorp.local/myrepo` is then _transparently_ proxied to the **IP address** of my GitLab Pages server (**not** the proxy server!), and the `Host` header is set to `http://fred.smith.pages.mycorp.local/myrepo`.

From GitLab's perspective, the request comes via HTTP (not HTTPS), but all traffic between the client and proxy server is encrypted.

## Caveats
- This only works if the initial request to `http://firstname.lastname.gitlab-pages-fqdn` is via HTTP.

## Usage
This reverse proxy requires the following environment variables to be set:
  - BASE_DOMAIN <= The Fully-qualified domain name (FQDN) of your GitLab Pages installation.
  - GITLAB_PAGES_SERVER_ADDRESS <= The internal IP address/hostname of your GitLab Pages server. This is where the requests will be proxied.
  - HTTP_ONLY <= Set to 'true' if you don't want the proxy server to use SSL. This is useful if you are deploying the proxy server behind another proxy server which handles SSL termination.

If you have a wildcard SSL certificate that you'd like to use, simply mount it to `/certs` within the container. The proxy server will automatically use any PEM files in this folder named `cert.pem` and `key.pem`. If these files are not mounted, a self-signed wildcard certificate will be automatically generated.

### Example Docker command:
```
docker run -d \
           --name gitlab-pages-url-sanitiser \
           -p 443:443 \
           -p 80:80 \
           -v $PWD/certs:/certs \
           --env BASE_DOMAIN=pages.mycorp.local \
           --env GITLAB_PAGES_SERVER_ADDRESS=http://10.1.1.1:80 \
           xtrasimplicity/gitlab-pages-username-sanitisation-proxy 
```
### Example `docker-compose.yml` file:
```
---
version: '3.5'
services:
  proxy:
    image: xtrasimplicity/gitlab-pages-username-sanitisation-proxy
    ports:
      - 80:80
      - 443:443
    environment:
      BASE_DOMAIN: pages.mycorp.local
      GITLAB_PAGES_SERVER_ADDRESS: http://10.1.1.1:80
```