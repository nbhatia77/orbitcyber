
resource "aws_api_gateway_method" "ApiGatewayBadBotMethod" {
    depends_on = ["aws_lambda_function.LambdaWAFBadBotParserFunction", "aws_lambda_permission.LambdaInvokePermissionBadBot", "aws_api_gateway_rest_api.ApiGatewayBadBot"]
    rest_api_id = "${aws_api_gateway_rest_api.ApiGatewayBadBot.id}"
    resource_id = "${aws_api_gateway_resource.ApiGatewayBadBotResource.id}"
    http_method = "GET"
    authorization = "NONE"
    request_parameters = { "method.request.header.X-Forwarded-For" = false } 
}

resource "aws_api_gateway_method_response" "200" {
    rest_api_id = "${aws_api_gateway_rest_api.ApiGatewayBadBot.id}"
    resource_id = "${aws_api_gateway_resource.ApiGatewayBadBotResource.id}"
    http_method = "${aws_api_gateway_method.ApiGatewayBadBotMethod.http_method}"
    status_code = "200"
}

resource "aws_api_gateway_integration" "ApiGatewayBadBotIntegration" {
    depends_on = ["aws_api_gateway_method.ApiGatewayBadBotMethod"]
    rest_api_id = "${aws_api_gateway_rest_api.ApiGatewayBadBot.id}"
    resource_id = "${aws_api_gateway_resource.ApiGatewayBadBotResource.id}"
    http_method = "${aws_api_gateway_method.ApiGatewayBadBotMethod.http_method}"
    integration_http_method = "POST"
    uri = "arn:aws:apigateway:${var.aws_region}:lambda:path/2015-03-31/functions/${aws_lambda_function.LambdaWAFBadBotParserFunction.arn}/invocations"
    type = "AWS"
    request_templates = {
        "application/json" = "{\n    \"source_ip\" : \"$input.params('X-Forwarded-For')\",\n    \"user_agent\" : \"$input.params('User-Agent')\",\n    \"bad_bot_ip_set\" : \"${aws_waf_ipset.WAFBadBotSet.id}\"\n}"
    }
}

resource "aws_api_gateway_integration_response" "ApiGatewayBadBotIntegrationResponse" {
    rest_api_id = "${aws_api_gateway_rest_api.ApiGatewayBadBot.id}"
    resource_id = "${aws_api_gateway_resource.ApiGatewayBadBotResource.id}"
    http_method = "${aws_api_gateway_integration.ApiGatewayBadBotIntegration.http_method}"
    status_code = "${aws_api_gateway_method_response.200.status_code}"
    response_templates = { "application/json" = "" } 
}

resource "aws_api_gateway_deployment" "ApiGatewayBadBotDeployment" {
    depends_on = [
      "aws_api_gateway_method.ApiGatewayBadBotMethod",
      "aws_api_gateway_integration.ApiGatewayBadBotIntegration",
    ]
    rest_api_id = "${aws_api_gateway_rest_api.ApiGatewayBadBot.id}"
    stage_name = "CFDeploymentStage" 
    description = "CloudFormation Deployment Stage"
}

resource "aws_api_gateway_deployment" "ApiGatewayBadBotStage" {
    depends_on = [
      "aws_api_gateway_method.ApiGatewayBadBotMethod",
      "aws_api_gateway_integration.ApiGatewayBadBotIntegration",
    ]
    #depends_on = ["aws_api_gateway_deployment.ApiGatewayBadBotDeployment"]
    rest_api_id = "${aws_api_gateway_rest_api.ApiGatewayBadBot.id}"
    stage_name = "ProdStage" 
    description = "Production Stage"
}
