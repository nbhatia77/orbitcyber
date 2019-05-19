
resource "aws_lambda_permission" "LambdaInvokePermissionBadBot" {
    #depends_on = ["aws_lambda_function.LambdaWAFBadBotParserFunction"]
    statement_id = "AllowExecutionFromCloudWatch"
    action = "lambda:*"
    function_name = "${aws_lambda_function.LambdaWAFBadBotParserFunction.arn}"
    principal = "apigateway.amazonaws.com"
}
