resource "aws_apigatewayv2_api" "telemetry_api" {
  name          = "TelemetryAPI"
  protocol_type = "HTTP"
  description   = "API Gateway to simulate city sensors sending telemetry data"
}

resource "aws_apigatewayv2_stage" "prod" {
  api_id      = aws_apigatewayv2_api.telemetry_api.id
  name        = "$default"
  auto_deploy = true

  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.api_gateway_logs.arn
    format = jsonencode({
      "requestId" : "$context.requestId",
      "ip" : "$context.identity.sourceIp",
      "requestTime" : "$context.requestTime",
      "httpMethod" : "$context.httpMethod",
      "routeKey" : "$context.routeKey",
      "status" : "$context.status",
      "protocol" : "$context.protocol",
      "responseLength" : "$context.responseLength"
    })
  }
}

resource "aws_apigatewayv2_integration" "telemetry_lambda_integration" {
  api_id             = aws_apigatewayv2_api.telemetry_api.id
  integration_type   = "AWS_PROXY"
  integration_uri    = aws_lambda_function.telemetry_lambda.invoke_arn
  integration_method = "POST"
}

resource "aws_apigatewayv2_route" "telemetry_route" {
  api_id             = aws_apigatewayv2_api.telemetry_api.id
  route_key          = "GET /telemetry"
  target             = "integrations/${aws_apigatewayv2_integration.telemetry_lambda_integration.id}"
  authorization_type = "NONE"
}


resource "aws_lambda_function" "sensor_simulator_lambda" {
  filename         = "sensor_simulator_lambda.zip"
  function_name    = "sensor_simulator_lambda"
  role             = aws_iam_role.lambda_role.arn
  handler          = "sensor_simulator_lambda.lambda_handler"
  runtime          = "python3.12"
  source_code_hash = filebase64sha256("sensor_simulator_lambda.zip")
  architectures    = ["arm64"]
  timeout          = 15

  layers = [
    data.klayers_package_latest_version.requests.arn
  ]

  environment {
    variables = {
      API_URL = "${aws_apigatewayv2_stage.prod.invoke_url}telemetry"
    }
  }
}

resource "aws_cloudwatch_event_rule" "sensor_schedule" {
  for_each            = { for idx, city in var.city_data : idx => city }
  name                = "fcc-demo-sensor-schedule-${each.key}"
  schedule_expression = "rate(1 minute)"
  description         = "FCC Demo schedule for ${each.value.city} sensor reporting from ${each.value.company}"
}

resource "aws_cloudwatch_event_target" "invoke_api_target" {
  for_each = { for idx, city in var.city_data : idx => city }
  rule     = aws_cloudwatch_event_rule.sensor_schedule[each.key].name
  arn      = aws_lambda_function.sensor_simulator_lambda.arn

  input = jsonencode({
    city    = each.value.city,
    company = each.value.company,
    coordinates = {
      latitude  = each.value.latitude,
      longitude = each.value.longitude
    }
  })
}

resource "aws_lambda_permission" "allow_cloudwatch_invoke_api" {
  statement_id  = "AllowExecutionFromCloudWatchInvokeAPI"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.sensor_simulator_lambda.function_name
  principal     = "events.amazonaws.com"
  source_arn    = "arn:aws:events:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:rule/fcc-demo-sensor-schedule-*"
}

resource "aws_lambda_function" "telemetry_lambda" {
  filename         = "telemetry_lambda.zip"
  function_name    = "telemetry_lambda"
  role             = aws_iam_role.lambda_role.arn
  handler          = "telemetry_lambda.lambda_handler"
  runtime          = "python3.12"
  source_code_hash = filebase64sha256("telemetry_lambda.zip")
  architectures    = ["arm64"]
  timeout          = 15

  environment {
    variables = {
      FIREHOSE_STREAM_NAME = aws_kinesis_firehose_delivery_stream.sensor_data_stream.name
    }
  }
}

resource "aws_lambda_permission" "allow_api_gateway_invoke_telemetry" {
  statement_id  = "AllowExecutionFromAPIGatewayTelemetry"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.telemetry_lambda.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.telemetry_api.execution_arn}/*/GET/telemetry"
}

resource "aws_cloudwatch_log_group" "api_gateway_logs" {
  name              = "/aws/apigateway/telemetry_api_logs"
  retention_in_days = 1
}




resource "aws_api_gateway_account" "account_settings" {
  cloudwatch_role_arn = aws_iam_role.api_gateway_cloudwatch_role.arn
}





resource "aws_kinesis_firehose_delivery_stream" "sensor_data_stream" {
  name        = "sensor-data-stream"
  destination = "opensearch"

  opensearch_configuration {
    role_arn           = aws_iam_role.firehose_role.arn
    domain_arn         = aws_opensearch_domain.opensearch_domain_telemetry.arn
    index_name         = "sensor-data-index"
    buffering_size     = 1
    buffering_interval = 5
    retry_duration     = 0

    s3_backup_mode = "FailedDocumentsOnly"
    s3_configuration {
      role_arn           = aws_iam_role.firehose_role.arn
      bucket_arn         = aws_s3_bucket.firehose_bucket.arn
      buffering_size     = 1
      buffering_interval = 60
      compression_format = "UNCOMPRESSED"
    }

    cloudwatch_logging_options {
      enabled         = true
      log_group_name  = aws_cloudwatch_log_group.firehose_error_logs.name
      log_stream_name = "sensor-data-stream-errors"
    }
  }
}


resource "aws_cloudwatch_log_group" "firehose_error_logs" {
  name              = "/aws/kinesisfirehose/sensor-data-stream-errors"
  retention_in_days = 1
}


resource "aws_s3_bucket" "firehose_bucket" {
  bucket = "sensor-data-firehose"
  force_destroy = true
}

resource "aws_opensearch_domain" "opensearch_domain_telemetry" {
  domain_name = "sdt"

  cluster_config {
    instance_type  = "m5.large.search"
    instance_count = 1
  }

  ebs_options {
    ebs_enabled = true
    volume_size = 10
    volume_type = "gp2"
  }

  node_to_node_encryption {
    enabled = true
  }

  encrypt_at_rest {
    enabled = true
  }

  domain_endpoint_options {
    enforce_https = true
  }

  access_policies = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : "*",
        "Action" : "es:ESHttp*",
        "Resource" : "arn:aws:es:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:domain/sdt/*",
        "Condition" : {
          "IpAddress" : {
            "aws:SourceIp" : ["97.113.133.254/32"]
          }
        }
      }
    ]
  })
}





resource "aws_lambda_function" "simulation_toggle_lambda" {
  filename         = "simulation_toggle_lambda.zip"
  function_name    = "simulation_toggle_lambda"
  role             = aws_iam_role.lambda_role.arn
  handler          = "simulation_toggle_lambda.lambda_handler"
  runtime          = "python3.12"
  source_code_hash = filebase64sha256("simulation_toggle_lambda.zip")
  architectures    = ["arm64"]
  timeout          = 15

  environment {
    variables = {
      PARAM_NAME_PREFIX = "/fcc-demo-telemetry/events_enabled"
    }
  }
}

resource "aws_lambda_permission" "allow_cloudwatch_control_lambda" {
  statement_id  = "AllowExecutionFromLambdaToggle"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.simulation_toggle_lambda.function_name
  principal     = "events.amazonaws.com"
}



resource "aws_ssm_parameter" "events_enabled" {
  name  = "/fcc-demo-telemetry/events_enabled"
  type  = "String"
  value = "true"
}


resource "aws_grafana_workspace" "telemetry_grafana_workspace" {
  account_access_type      = "CURRENT_ACCOUNT"
  name                     = "TelemetryGrafanaWorkspace"
  authentication_providers = ["SAML"]
  permission_type          = "SERVICE_MANAGED"
  data_sources             = ["AMAZON_OPENSEARCH_SERVICE"]
  role_arn                 = aws_iam_role.grafana_role.arn

  configuration = jsonencode(
    {
      "plugins" = {
        "pluginAdminEnabled" = true
      },
      "unifiedAlerting" = {
        "enabled" = false
      }
    }
  )

}




resource "aws_grafana_workspace_saml_configuration" "grafana_saml_configuration" {
  workspace_id       = aws_grafana_workspace.telemetry_grafana_workspace.id
  role_assertion     = "mail"
  admin_role_values  = ["jim.weller@gmail.com"]
  editor_role_values = ["Editor"]
  email_assertion    = "mail"
  login_assertion    = "mail"
  name_assertion     = "displayName"
  idp_metadata_url   = "https://trial-6804569.okta.com/app/exkl24c2nwgAeNlBM697/sso/saml/metadata"
}







resource "aws_iam_role" "lambda_role" {
  name = "lambda_role"
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "lambda.amazonaws.com"
        },
        "Action" : "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_policy" "telemetry_lambda_firehose_policy" {
  name = "telemetry_lambda_firehose_policy"
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "firehose:PutRecord",
          "firehose:PutRecordBatch"
        ],
        "Resource" : "${aws_kinesis_firehose_delivery_stream.sensor_data_stream.arn}"
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        "Resource" : "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:/aws/lambda/telemetry_lambda:*"
      }
    ]
  })
}

resource "aws_iam_policy" "simulation_toggle_lambda_policy" {
  name = "simulation_toggle_lambda_policy"
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "ssm:SetParameter",
          "ssm:GetParameter"
        ],
        "Resource" : "arn:aws:ssm:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:parameter/fcc-demo-telemetry/events_enabled"
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "events:ListRules"
        ],
        "Resource" : "*"
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "events:EnableRule",
          "events:DisableRule"
        ],
        "Resource" : "arn:aws:events:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:rule/fcc-demo-sensor-schedule-*"
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        "Resource" : "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:/aws/lambda/simulation_toggle_lambda:*"
      }
    ]
  })
}

resource "aws_iam_policy" "sensor_simulator_lambda_policy" {
  name        = "sensor_simulator_lambda_policy"
  description = "IAM policy for sensor_simulator_lambda with least privilege"
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        "Resource" : "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:/aws/lambda/sensor_simulator_lambda:*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "sensor_simulator_lambda_policy_attachment" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.sensor_simulator_lambda_policy.arn
}

resource "aws_iam_role_policy_attachment" "simulation_toggle_lambda_policy_attachment" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.simulation_toggle_lambda_policy.arn
}

resource "aws_iam_role_policy_attachment" "telemetry_lambda_policy_attachment" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.telemetry_lambda_firehose_policy.arn
}





resource "aws_iam_role" "api_gateway_cloudwatch_role" {
  name = "api_gateway_cloudwatch_role"
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "apigateway.amazonaws.com"
        },
        "Action" : "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_policy" "api_gateway_cloudwatch_policy" {
  name = "APIGatewayCloudWatchLogsPolicy"
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        "Resource" : "${aws_cloudwatch_log_group.api_gateway_logs.arn}:*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "api_gateway_cloudwatch_attachment" {
  role       = aws_iam_role.api_gateway_cloudwatch_role.name
  policy_arn = aws_iam_policy.api_gateway_cloudwatch_policy.arn
}







resource "aws_iam_role" "firehose_role" {
  name = "firehose_delivery_role"
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "firehose.amazonaws.com"
        },
        "Action" : "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_policy" "firehose_policy" {
  name = "firehose_policy"
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        "Resource" : [
          "${aws_cloudwatch_log_group.firehose_error_logs.arn}:*"
        ]
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "s3:PutObject",
          "s3:GetObject",
          "s3:ListBucket"
        ],
        "Resource" : [
          "${aws_s3_bucket.firehose_bucket.arn}",
          "${aws_s3_bucket.firehose_bucket.arn}/*"
        ]
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "es:DescribeDomain",
          "es:DescribeDomains",
          "es:DescribeDomainConfig", 
          "es:ESHttpPost",
          "es:ESHttpPut",
          "es:ESHttpGet"
        ],
        "Resource" : [
          "${aws_opensearch_domain.opensearch_domain_telemetry.arn}/*"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "firehose_policy_attachment" {
  role       = aws_iam_role.firehose_role.name
  policy_arn = aws_iam_policy.firehose_policy.arn
}






resource "aws_iam_role" "grafana_role" {
  name = "telemetry-grafana-role"
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "grafana.amazonaws.com"
        },
        "Action" : "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_policy" "grafana_opensearch_policy" {
    name = "GrafanaOpenSearchPolicy"
    policy = jsonencode({
        "Version" : "2012-10-17",
        "Statement" : [
            {
                "Effect" : "Allow",
                "Action" : [
                    "es:ESHttpGet",
                    "es:ESHttpPost",
                ],
                "Resource" : [
                    "${aws_opensearch_domain.opensearch_domain_telemetry.arn}/*"
                ]
            }
        ]
    })
}

resource "aws_iam_role_policy_attachment" "grafana_role_policy_attachment" {
  role       = aws_iam_role.grafana_role.name
  policy_arn = aws_iam_policy.grafana_opensearch_policy.arn
}







output "grafana_workspace_id" {
  value = aws_grafana_workspace.telemetry_grafana_workspace.id
}

output "grafana_workspace_endpoint" {
  value = aws_grafana_workspace.telemetry_grafana_workspace.endpoint
}

output "grafana_role_arn" {
  value = aws_iam_role.grafana_role.arn
}
