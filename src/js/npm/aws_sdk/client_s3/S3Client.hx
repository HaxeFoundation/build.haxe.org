package js.npm.aws_sdk.client_s3;

import haxe.ds.Either;
import js.lib.Promise;
import haxe.extern.EitherType;

typedef Provider<T> = EitherType<T, ()->Promise<T>>;

// https://github.com/aws/aws-sdk-js-v3/blob/main/supplemental-docs/CLIENTS.md#common-client-constructor-parameters
// https://docs.aws.amazon.com/AWSJavaScriptSDK/v3/latest/Package/-aws-sdk-client-s3/Interface/S3ClientConfig/
typedef S3ClientConfig = {
    ?region: Provider<String>,
    ?credentials: Provider<{
        ?accessKeyId: String,
        ?secretAccessKey: String,
        ?sessionToken: String,
        ?expiration: Date,
    }>,
    ?endpoint: Provider<String>,
    ?forcePathStyle: Provider<Bool>,
}

@:jsRequire("@aws-sdk/client-s3", "S3Client")
extern class S3Client {
    public function new(?config:S3ClientConfig):Void;
    public function send<T>(?command:Command<T>):Promise<T>;
}
