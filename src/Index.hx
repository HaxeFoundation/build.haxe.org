import js.Node.*;
import js.npm.express.*;

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
        var s3 = new js.npm.aws_sdk.S3();

        app.use(function (req:Request, res:Response, next:haxe.Constraints.Function) {
            // normalize the s3 prefix to NOT contain leading slash, but with a trailing slash
            var prefix = haxe.io.Path.addTrailingSlash(req.path.split("/").filter(function(p) return p != "").join("/"));

            s3.listObjectsV2({
                Bucket: "hxbuilds",
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