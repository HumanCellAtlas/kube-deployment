variable "aws_profile" {}

variable "aws_region" {
  default = "us-east-1"
}

provider "aws" {
  region = "${var.aws_region}"
  profile = "${var.aws_profile}"
}

////
// general setup
//

// the bucket must be configured with the -backend-config flag on `terraform init`

terraform {
  backend "s3" {
    key = "ingest/ingest-auth.tfstate"
  }
}

variable "account_id" {}

resource "aws_iam_role" "ingest_auth" {
  name               = "ingest-auth"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "ingest_auth" {
  name   = "ingest-auth"
  role   = "ingest-auth"
  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "logs:CreateLogStream",
                "logs:PutLogEvents"
            ],
            "Resource": "arn:aws:logs:*:*:*"
        },
        {
            "Effect": "Allow",
            "Action": "logs:CreateLogGroup",
            "Resource": "arn:aws:logs:*:*:*"
        },
        {
            "Effect": "Allow",
            "Action": "secretsmanager:*",
            "Resource": "arn:aws:secretsmanager:${var.aws_region}:${var.account_id}:secret:dcp/ingest/*/*"
        }
    ]
}
EOF
  depends_on = [
    "aws_iam_role.ingest_auth"
  ]
}

resource "aws_lambda_function" "ingest_auth" {
  function_name = "ingest-auth"

  s3_bucket = "ingest-auth-${var.account_id}"
  s3_key    = "ingest-auth.zip"

  # "main" is the filename within the zip file (main.js) and "handler"
  # is the name of the property under which the handler function was
  # exported in that file.
  handler = "app.handler"
  runtime = "python3.6"

  role = "${aws_iam_role.ingest_auth.arn}"
}

resource "aws_cloudwatch_log_group" "ingest_auth" {
  name = "/aws/lambda/ingest_auth"
}

resource "aws_api_gateway_rest_api" "ingest_auth" {
  name        = "ingest-auth"
  description = "Ingest Auth Serverless App"
}

resource "aws_api_gateway_resource" "proxy" {
  rest_api_id = "${aws_api_gateway_rest_api.ingest_auth.id}"
  parent_id   = "${aws_api_gateway_rest_api.ingest_auth.root_resource_id}"
  path_part   = "{proxy+}"
}

resource "aws_api_gateway_method" "proxy" {
  rest_api_id   = "${aws_api_gateway_rest_api.ingest_auth.id}"
  resource_id   = "${aws_api_gateway_resource.proxy.id}"
  http_method   = "ANY"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda" {
  rest_api_id = "${aws_api_gateway_rest_api.ingest_auth.id}"
  resource_id = "${aws_api_gateway_method.proxy.resource_id}"
  http_method = "${aws_api_gateway_method.proxy.http_method}"

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = "${aws_lambda_function.ingest_auth.invoke_arn}"
}

resource "aws_api_gateway_method" "proxy_root" {
  rest_api_id   = "${aws_api_gateway_rest_api.ingest_auth.id}"
  resource_id   = "${aws_api_gateway_rest_api.ingest_auth.root_resource_id}"
  http_method   = "ANY"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda_root" {
  rest_api_id = "${aws_api_gateway_rest_api.ingest_auth.id}"
  resource_id = "${aws_api_gateway_method.proxy_root.resource_id}"
  http_method = "${aws_api_gateway_method.proxy_root.http_method}"

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = "${aws_lambda_function.ingest_auth.invoke_arn}"
}

resource "aws_api_gateway_deployment" "ingest_auth_test" {
  depends_on = [
    "aws_api_gateway_integration.lambda",
    "aws_api_gateway_integration.lambda_root",
  ]

  rest_api_id = "${aws_api_gateway_rest_api.ingest_auth.id}"
  stage_name  = "test"
}

resource "aws_lambda_permission" "apigw_test" {
  statement_id  = "AllowAPIGatewayInvoke-test"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.ingest_auth.arn}"
  principal     = "apigateway.amazonaws.com"

  # The /*/* portion grants access from any method on any resource
  # within the API Gateway "REST API".
  source_arn = "${aws_api_gateway_deployment.ingest_auth_test.execution_arn}/*/*"
}

resource "aws_api_gateway_deployment" "ingest_auth_dev" {
  depends_on = [
    "aws_api_gateway_integration.lambda",
    "aws_api_gateway_integration.lambda_root",
  ]

  rest_api_id = "${aws_api_gateway_rest_api.ingest_auth.id}"
  stage_name  = "dev"
}

resource "aws_lambda_permission" "apigw_dev" {
  statement_id  = "AllowAPIGatewayInvoke-dev"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.ingest_auth.arn}"
  principal     = "apigateway.amazonaws.com"

  # The /*/* portion grants access from any method on any resource
  # within the API Gateway "REST API".
  source_arn = "${aws_api_gateway_deployment.ingest_auth_dev.execution_arn}/*/*"
}

resource "aws_api_gateway_deployment" "ingest_auth_integration" {
  depends_on = [
    "aws_api_gateway_integration.lambda",
    "aws_api_gateway_integration.lambda_root",
  ]

  rest_api_id = "${aws_api_gateway_rest_api.ingest_auth.id}"
  stage_name  = "integration"
}

resource "aws_lambda_permission" "apigw_integration" {
  statement_id  = "AllowAPIGatewayInvoke-integration"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.ingest_auth.arn}"
  principal     = "apigateway.amazonaws.com"

  # The /*/* portion grants access from any method on any resource
  # within the API Gateway "REST API".
  source_arn = "${aws_api_gateway_deployment.ingest_auth_integration.execution_arn}/*/*"
}

resource "aws_api_gateway_deployment" "ingest_auth_staging" {
  depends_on = [
    "aws_api_gateway_integration.lambda",
    "aws_api_gateway_integration.lambda_root",
  ]

  rest_api_id = "${aws_api_gateway_rest_api.ingest_auth.id}"
  stage_name  = "staging"
}

resource "aws_lambda_permission" "apigw_staging" {
  statement_id  = "AllowAPIGatewayInvoke-staging"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.ingest_auth.arn}"
  principal     = "apigateway.amazonaws.com"

  # The /*/* portion grants access from any method on any resource
  # within the API Gateway "REST API".
  source_arn = "${aws_api_gateway_deployment.ingest_auth_staging.execution_arn}/*/*"
}

output "base_url" {
  value = "${aws_api_gateway_deployment.ingest_auth_staging.invoke_url}"
}
