
resource "aws_api_gateway_rest_api" "ApiGatewayBadBot" {
    name = "${var.customer} - Security Automations - WAF Bad Bot API"
    description = "API created by AWS WAF Security Automations CloudFormation template. This endpoint will be used to capture bad bots."
}

resource "aws_api_gateway_resource" "ApiGatewayBadBotResource" {
    rest_api_id = "${aws_api_gateway_rest_api.ApiGatewayBadBot.id}"
    parent_id = "${aws_api_gateway_rest_api.ApiGatewayBadBot.root_resource_id}"
    path_part = "waf"
}
