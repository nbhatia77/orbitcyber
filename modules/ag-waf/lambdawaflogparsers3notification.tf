
resource "aws_s3_bucket_notification" "LambdaWAFLogParserS3Notification" {
    bucket = "${var.CloudFrontAccessLogBucket}"
    lambda_function = [
        {
                id = "${var.customer}-LambdaWAFLogParserFunction"
                lambda_function_arn = "${aws_lambda_function.LambdaWAFLogParserFunction.arn}"
                events = ["s3:ObjectCreated:*"]
                filter_suffix = "gz"
        }
    ]
}
