
resource "aws_lambda_permission" "LambdaInvokePermissionReputationListsParser" {
    #depends_on = ["aws_lambda_function.LambdaWAFReputationListsParserFunction", "aws_cloudwatch_event_rule.LambdaWAFReputationListsParserEventsRule"]
    function_name = "${aws_lambda_function.LambdaWAFReputationListsParserFunction.arn}"
    action = "lambda:InvokeFunction"
    principal = "events.amazonaws.com"
    statement_id = "AllowExecutionFromCloudWatch"
    source_arn = "${aws_cloudwatch_event_rule.LambdaWAFReputationListsParserEventsRule.arn}"
    #source_arn = "arn:aws:execute-api:${var.aws_region}:${data.aws_caller_identity.current.account_id}:${aws_api_gateway_rest_api.ApiGatewayBadBot.id}/*/${aws_api_gateway_method.ApiGatewayBadBotMethod.http_method}/"
}
