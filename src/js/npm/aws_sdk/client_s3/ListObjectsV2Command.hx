package js.npm.aws_sdk.client_s3;

typedef ListObjectsV2CommandInput = {
    Bucket: String,
    ?ContinuationToken: String,
    ?Delimiter: String,
    ?EncodingType: String,
    ?ExpectedBucketOwner: String,
    ?FetchOwner: Bool,
    ?MaxKeys: Int,
    ?Prefix: String,
    ?RequestPayer: String,
    ?StartAfter: String,
}

typedef ListObjectsV2CommandOutput = {
    ?IsTruncated: Bool,
    ?Contents: Array<{
        ?Key: String,
        ?LastModified: Date,
        ?ETag: String,
        ?ChecksumAlgorithm: Array<String>,
        ?ChecksumType: String,
        ?Size: Float,
        ?StorageClass: String,
        ?Owner: {
            DisplayName: String,
            ID: String,
        },
        ?RestoreStatus: {
            IsRestoreInProgress: Bool,
            RestoreExpiration: Date,
        },
    }>,
    ?Name: String,
    ?Prefix: String,
    ?Delimiter: String,
    ?MaxKeys: Int,
    ?CommonPrefixes: Array<{ Prefix: String }>,
    ?EncodingType: String,
    ?KeyCount: Int,
    ?ContinuationToken: String,
    ?NextContinuationToken: String,
    ?StartAfter: String,
    ?RequestCharged: String,
}

/**
 * https://docs.aws.amazon.com/AWSJavaScriptSDK/v3/latest/client/s3/command/ListObjectsV2Command/
 */
@:jsRequire("@aws-sdk/client-s3", "ListObjectsV2Command")
extern class ListObjectsV2Command implements Command<ListObjectsV2CommandOutput> {
    public function new(params:ListObjectsV2CommandInput):Void;
}
