package js.npm.aws_sdk.client_s3;

typedef HeadObjectCommandInput = {
    Bucket: String,
    Key: String,
    ?ChecksumMode: String,
    ?ExpectedBucketOwner: String,
    ?IfMatch: String,
    ?IfModifiedSince: Date,
    ?IfNoneMatch: String,
    ?IfUnmodifiedSince: Date,
    ?PartNumber: Int,
    ?Range: String,
    ?RequestPayer: String,
    ?ResponseCacheControl: String,
    ?ResponseContentDisposition: String,
    ?ResponseContentEncoding: String,
    ?ResponseContentLanguage: String,
    ?ResponseContentType: String,
    ?ResponseExpires: Date,
    ?SSECustomerAlgorithm: String,
    ?SSECustomerKey: String,
    ?SSECustomerKeyMD5: String,
    ?VersionId: String,
}

typedef HeadObjectCommandOutput = {
    ?AcceptRanges: String,
    ?ArchiveStatus: String,
    ?BucketKeyEnabled: Bool,
    ?CacheControl: String,
    ?ChecksumCRC32: String,
    ?ChecksumCRC32C: String,
    ?ChecksumCRC64NVME: String,
    ?ChecksumSHA1: String,
    ?ChecksumSHA256: String,
    ?ChecksumType: String,
    ?ContentDisposition: String,
    ?ContentEncoding: String,
    ?ContentLanguage: String,
    ?ContentLength: Float,
    ?ContentRange: String,
    ?ContentType: String,
    ?DeleteMarker: Bool,
    ?ETag: String,
    ?Expiration: String,
    ?Expires: Date,
    ?ExpiresString: String,
    ?LastModified: Date,
    ?Metadata: Array<Dynamic>,
    ?MissingMeta: Int,
    ?ObjectLockLegalHoldStatus: String,
    ?ObjectLockMode: String,
    ?ObjectLockRetainUntilDate: Date,
    ?PartsCount: Int,
    ?ReplicationStatus: String,
    ?RequestCharged: String,
    ?Restore: String,
    ?SSECustomerAlgorithm: String,
    ?SSECustomerKeyMD5: String,
    ?SSEKMSKeyId: String,
    ?ServerSideEncryption: String,
    ?StorageClass: String,
    ?TagCount: Int,
    ?VersionId: String,
    ?WebsiteRedirectLocation: String,
}

/**
 * https://docs.aws.amazon.com/AWSJavaScriptSDK/v3/latest/client/s3/command/HeadObjectCommand/
 */
@:jsRequire("@aws-sdk/client-s3", "HeadObjectCommand")
extern class HeadObjectCommand implements Command<HeadObjectCommandOutput> {
    public function new(params:HeadObjectCommandInput):Void;
}