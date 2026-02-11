import Indexer.Record;
import js.lib.Promise;
import js.Node.*;
import js.node.*;
import js.npm.express.*;
import js.npm.aws_sdk.client_s3.S3Client;
import js.npm.aws_sdk.client_s3.HeadObjectCommand;
import js.npm.aws_sdk.client_s3.PaginateListObjectsV2.paginateListObjectsV2;
import haxe.io.*;
using StringTools;
using Lambda;

@:jsRequire("base64-stream", "Base64Encode")
extern class Base64Encode {
    public function new():Void;
}

class Index {
    static function main():Void {
        final app = new Application();
        final config:S3ClientConfig = {
            credentials: {
                accessKeyId: Sys.getEnv("HXBUILDS_ACCESS_KEY_ID"),
                secretAccessKey: Sys.getEnv("HXBUILDS_SECRET_ACCESS_KEY"),
            },
            region: switch (Sys.getEnv("HXBUILDS_REGION")) {
                case null: "us-east-1";
                case region: region;
            }
        }
        switch (Sys.getEnv("HXBUILDS_ENDPOINT")) {
            case null: // pass
            case endpoint: config.endpoint = endpoint;
        }
        switch (Sys.getEnv("HXBUILDS_FORCE_PATH_STYLE")) {
            case null | "false": // pass
            case "true": config.forcePathStyle = true;
        }
        final s3 = new js.npm.aws_sdk.client_s3.S3Client(config);
        final bucket = switch (Sys.getEnv("HXBUILDS_BUCKET")) {
            case null: "hxbuilds";
            case v: v;
        };

        function listDirectory(path:String):Promise<{dirs:Array<String>, files:Array<Record>}> {
            // trace('listing directory ${path}');
            return new Promise(function(resolve, reject) {
                // normalize the s3 prefix to NOT contain leading slash, but with a trailing slash
                final prefix = switch (Path.addTrailingSlash(path.split("/").filter(p -> p != "").join("/"))) {
                    case "/":
                        "";
                    case p:
                        p;
                }
                trace('listing ${prefix}');

                var dirs = [];
                var records = [];

                final paginator = paginateListObjectsV2({
                    client: s3,
                }, {
                    Bucket: bucket,
                    Prefix: prefix,
                    Delimiter: '/',
                });
                function listAll():Void {
                    paginator.next()
                        .then(function(result) {
                            if (result.done) {
                                resolve({ dirs: dirs, files: records });
                                return;
                            }
                            final data = result.value;
                            if (data.CommonPrefixes != null) {
                                dirs = dirs.concat(data.CommonPrefixes.map(function(p) return p.Prefix.substr(data.Prefix.length)));
                            }
                            if (data.Contents != null) {
                                records = records.concat([
                                    for (item in data.Contents)
                                    if (item.Key != prefix)
                                    {
                                        date: item.LastModified.toString(),
                                        size: item.Size,
                                        path: item.Key,
                                        fname: haxe.io.Path.withoutDirectory(item.Key),
                                        etag: item.ETag,
                                    }
                                ]);
                            }
                            listAll();
                        })
                        .catchError(function(err) {
                            trace(err);
                            reject(err);
                        });
                }
                listAll();
            });
        }

        // get *_latest.* file
        app.use(function (req:Request, res:Response, next:haxe.Constraints.Function) {
            // remove leading slash
            final s3key = req.path.startsWith("/") ? req.path.substr(1) : req.path;
            final fileName = Path.withoutDirectory(s3key);

            final latestRegex = ~/_latest\.(zip|tar\.gz|nupkg)$/;
            if (!latestRegex.match(fileName)) {
                next();
                return;
            }
            listDirectory(Path.directory(s3key))
                .then(function(result){
                    final latest = result.files.find(r -> r.fname == fileName);
                    if (latest == null) {
                        res.status(404);
                        res.header('Content-Type', 'text/plain');
                        res.send("No such file.");
                        return;
                    }
                    final actual = result.files.find(r -> r.fname != fileName && r.etag == latest.etag);
                    if (actual != null) {
                        final maxAge = 60 * 5; // 5 minutes
                        final staleWhileRevalidate = 60 * 1; // 1 minutes
                        res.setHeader("Cache-Control", 'public, max-age=${maxAge}, stale-while-revalidate=$staleWhileRevalidate');
                        res.redirect(actual.fname);
                        return;
                    }
                    // fallback to directly serving the _latest file
                    next();
                })
                .catchError(function(err) {
                    res.status(500);
                    res.header('Content-Type', 'text/plain');
                    res.send(haxe.Json.stringify(err, null, "  "));
                });
        });

        // get file
        app.use(function (req:Request, res:Response, next:haxe.Constraints.Function) {
            // remove leading slash
            final s3key = req.path.startsWith("/") ? req.path.substr(1) : req.path;
            final fileName = Path.withoutDirectory(s3key);

            switch (Path.extension(fileName)) {
                case null, "":
                    // it's not a file
                    next();
                    return;
                case _:
                    //pass
            }

            trace('getting ${s3key}');
            final headReq = new HeadObjectCommand({
                Bucket: bucket, 
                Key: s3key,
            });
            final publicHost = "https://hxbuilds-hjtpx7fj.haxe.org";
            s3.send(headReq)
                .then(function(r){
                    switch (r.WebsiteRedirectLocation) {
                        case null:
                            res.redirect(Path.join([publicHost, s3key]));
                        case loc:
                            res.redirect(Path.join([publicHost, loc]));
                    }
                })
                .catchError(function(err) {
                    switch (err.code) {
                        case "NoSuchKey" | "NotFound":
                            res.status(404);
                            res.header('Content-Type', 'text/plain');
                            res.send("No such file.");
                            return;
                        case _:
                            res.status(500);
                            res.header('Content-Type', 'text/plain');
                            res.send(haxe.Json.stringify(err, null, "  "));
                    }
                });
        });

        // list directory
        app.use(function (req:Request, res:Response, next:haxe.Constraints.Function) {
            // make sure there is a trailing slash
            // or else the <a> links wouldn't work properly
            if (!req.path.endsWith("/")) {
                res.redirect(Path.addTrailingSlash(req.path));
                return;
            }

            listDirectory(req.path)
                .then(function(result) {
                    final indexPage = Indexer.buildIndexPage(result.dirs, result.files);
                    res.header('Content-Type', 'text/html');
                    res.send(indexPage);
                })
                .catchError(function(err) {
                    res.status(500);
                    res.header('Content-Type', 'text/plain');
                    res.send(haxe.Json.stringify(err, null, "  "));
                });
        });

        js.Node.process.on('SIGINT', function() {
            js.Node.process.exit();
        });

        app.listen(3000, function(){
            trace("http://localhost:3000");
        });
    }
}