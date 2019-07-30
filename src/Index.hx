import js.Node.*;
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
};

class Index {
    static function main():Void {
        // for local dev: read env vars from .env, which contains AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY
        require('dotenv').config();

        var app = new Application();
        var s3 = new js.npm.aws_sdk.S3({
            accessKeyId: Sys.getEnv("HXBUILDS_AWS_ACCESS_KEY_ID"),
            secretAccessKey: Sys.getEnv("HXBUILDS_AWS_SECRET_ACCESS_KEY"),
        });
        var bucket = "hxbuilds";

        // get file
        app.use(function (req:Request, res:Response, next:haxe.Constraints.Function) {
            // remove leading slash
            var s3key = req.path.startsWith("/") ? req.path.substr(1) : req.path;
            var ext = Path.extension(Path.withoutDirectory(s3key));
            switch (ext) {
                case null, "":
                    // it's not a file
                    next();
                    return;
                case _:
                    //pass
            }

            trace('getting ${s3key}');
            var s3req = s3.getObject({
                Bucket: bucket, 
                Key: s3key,
            });
            var stream = s3req.createReadStream();
            stream.on("error", function(err) {
                if (err.code == "NoSuchKey") {
                    res.status(404);
                    res.header('Content-Type', 'text/plain');
                    res.send("No such file.");
                    return;
                }

                res.status(500);
                res.header('Content-Type', 'text/plain');
                res.send(haxe.Json.stringify(err, null, "  "));
                return;
            });
            (untyped stream.pipe)(res);
        });

        // list directory
        app.use(function (req:Request, res:Response, next:haxe.Constraints.Function) {
            // make sure there is a trailing slash
            // or else the <a> links wouldn't work properly
            if (!req.path.endsWith("/")) {
                res.redirect(Path.addTrailingSlash(req.path));
                return;
            }

            // normalize the s3 prefix to NOT contain leading slash, but with a trailing slash
            var prefix = Path.addTrailingSlash(req.path.split("/").filter(function(p) return p != "").join("/"));
            trace('listing ${prefix}');

            s3.listObjectsV2({
                Bucket: bucket,
                Prefix: prefix,
                Delimiter: '/',
                MaxKeys: 10000,
            }, function(err, result:ListObjectsV2Result) {
                if (err != null) {
                    next(err);
                    return;
                }

                var dirs = result.CommonPrefixes.map(function(p) return p.Prefix.substr(result.Prefix.length));
                var records = [
                    for (item in result.Contents)
                    if (item.Key != prefix)
                    {
                        date: item.LastModified.toString(),
                        size: item.Size,
                        path: item.Key,
                        fname: haxe.io.Path.withoutDirectory(item.Key),
                    }
                ];

                var indexPage = Indexer.buildIndexPage(dirs, records);
                res.header('Content-Type', 'text/html');
                res.send(indexPage);
            });
        });

        var isMain = (untyped __js__("require")).main == module;
        if (isMain) {
            app.listen(3000, function(){
                trace("http://localhost:3000");
            });
        } else {
            var serverless = require('serverless-http');
            js.Node.exports.handler = serverless(app);
        }
    }
}