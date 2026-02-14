package js.npm.aws_sdk.client_s3;

import js.lib.Promise;

@:jsRequire("@aws-sdk/client-s3", "S3Client")
extern class S3Client {
    public function new(?options:Dynamic):Void;
    public function send<T>(?command:Command<T>):Promise<T>;
}
