
resource "aws_lambda_permission" "LambdaInvokePermissionLogParser" {
    #depends_on = ["aws_lambda_function.LambdaWAFLogParserFunction"]
    statement_id = "AllowExecutionFromS3Bucket"
    action = "lambda:*"
    function_name = "${aws_lambda_function.LambdaWAFLogParserFunction.arn}"
    principal = "s3.amazonaws.com"
    source_account = "${data.aws_caller_identity.current.account_id}"
}
