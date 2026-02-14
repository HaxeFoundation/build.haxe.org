package js.npm.aws_sdk.client_s3;

/**
 * https://docs.aws.amazon.com/AWSJavaScriptSDK/v3/latest/Package/-aws-sdk-client-s3/Interface/S3PaginationConfiguration/
 */
typedef S3PaginationConfiguration = {
    client: S3Client,
    ?pageSize: Int,
    ?startingToken: String,
    ?stopOnSameToken: Bool,
}