package js.npm.aws_sdk.client_s3;

import js.npm.aws_sdk.client_s3.ListObjectsV2Command;

@:jsRequire("@aws-sdk/client-s3", "paginateListObjectsV2")
extern class PaginateListObjectsV2 {
    @:selfCall static function paginateListObjectsV2(config:S3PaginationConfiguration, input:ListObjectsV2CommandInput):Paginator<ListObjectsV2CommandOutput>;
}

