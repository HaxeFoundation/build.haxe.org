# build.haxe.org

This is the minimal web UI ([https://build.haxe.org](https://build.haxe.org)) for Haxe Foundation's snapshot build storage. The storage itself is using AWS S3. This UI is served by AWS Lambda with a CloudFront reverse proxy.

The file name and URL format is quite stable, though we're not fully commit to that and you should make sure to follow redirections when using the files programmatically, such that when we move the files, we can maintain backward compatibility with redirection.
The html markup is subject to change and you should never depend on that.
