# build.haxe.org

This is the minimal web UI ([https://build.haxe.org](https://build.haxe.org)) for Haxe Foundation's snapshot build storage. The storage itself is on Cloudflare R2. This UI is hosted on our Kubernetes cluster with Cloudflare Cache.

The file name and URL format is quite stable, though we're not fully commit to that and you should make sure to follow redirections when using the files programmatically, such that when we move the files, we can maintain backward compatibility with redirection.
The html markup is subject to change and you should never depend on that.

## development

```sh
# Install node and other tools defined in mise.toml.
# Note that Haxe is not included though.
mise install

# Build
haxe build.hxml

# Run
npm start
```

### environment variables

You may create a `mise.local.toml` file with an `[env]` section as follows:
```toml
[env]
HXBUILDS_ACCESS_KEY_ID = "xxxxxx"
HXBUILDS_SECRET_ACCESS_KEY = "xxxxxxxxxxxx"
HXBUILDS_ENDPOINT = "https://xxxxxx.r2.cloudflarestorage.com"
HXBUILDS_FORCE_PATH_STYLE = "true"
HXBUILDS_BUCKET = "xxxxxxxxxxx"
```
