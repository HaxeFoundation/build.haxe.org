import Indexer.Record;
import js.lib.Promise;
import js.Node.*;
import js.node.*;
import js.npm.express.*;
import haxe.io.*;
using StringTools;

typedef ListObjectsV2Result = {
    IsTruncated: Bool,
    Contents: Array<{
        Key: String,
        LastModified: Date,
        ETag: String,
        Size: Int,
        StorageClass: String,
    }>,
    Name: String,
    Prefix: String,
    MaxKeys: Int,
    CommonPrefixes: Array<{
        Prefix: String,
    }>,
    KeyCount: Int,
    NextContinuationToken: Null<String>,
};

@:jsRequire("base64-stream", "Base64Encode")
extern class Base64Encode {
    public function new():Void;
}

class Index {
    static function main():Void {
        final app = new Application();
        final awsAuth = {
            accessKeyId: Sys.getEnv("HXBUILDS_AWS_ACCESS_KEY_ID"),
            secretAccessKey: Sys.getEnv("HXBUILDS_AWS_SECRET_ACCESS_KEY"),
        }
        final s3 = new js.npm.aws_sdk.S3(awsAuth);
        final bucket = "hxbuilds";
        final region = "us-east-1";

        function listDirectory(path:String):Promise<{dirs:Array<String>, files:Array<Record>}> {
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

                function listAll(params):Void {
                    s3.listObjectsV2(params, function(err, result:ListObjectsV2Result) {
                        if (err != null) {
                            reject(err);
                            return;
                        }

                        dirs = dirs.concat(result.CommonPrefixes.map(function(p) return p.Prefix.substr(result.Prefix.length)));
                        records = records.concat([
                            for (item in result.Contents)
                            if (item.Key != prefix)
                            {
                                date: item.LastModified.toString(),
                                size: item.Size,
                                path: item.Key,
                                fname: haxe.io.Path.withoutDirectory(item.Key),
                            }
                        ]);

                        if (result.IsTruncated) {
                            params.ContinuationToken = result.NextContinuationToken;
                            listAll(params);
                        } else {
                            resolve({ dirs: dirs, files: records });
                        }
                    });
                }
                listAll({
                    Bucket: bucket,
                    Prefix: prefix,
                    Delimiter: '/',
                });
            });
        }

        // get file
        app.use(function (req:Request, res:Response, next:haxe.Constraints.Function) {
            // remove leading slash
            final s3key = req.path.startsWith("/") ? req.path.substr(1) : req.path;
            final fileName = Path.withoutDirectory(s3key);
            final ext = Path.extension(fileName);
            switch (ext) {
                case null, "":
                    // it's not a file
                    next();
                    return;
                case _:
                    //pass
            }

            trace('getting ${s3key}');
            final s3req = s3.headObject({
                Bucket: bucket, 
                Key: s3key,
            });
            final publicHost = "https://hxbuilds-hjtpx7fj.haxe.org";
            s3req.promise().then(function(r:Dynamic){
                switch (r.WebsiteRedirectLocation) {
                    case null:
                        res.redirect(Path.join([publicHost, s3key]));
                    case loc:
                        res.redirect(Path.join([publicHost, loc]));
                }
            }).catchError(function(err) {
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