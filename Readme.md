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
_Coming soon!_