data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

data "archive_file" "sensor_simulator_lambda_file" {
  type        = "zip"
  source_file = "sensor_simulator_lambda.py"
  output_path = "sensor_simulator_lambda.zip"
}

data "archive_file" "telemetry_lambda_file" {
  type        = "zip"
  source_file = "telemetry_lambda.py"
  output_path = "telemetry_lambda.zip"
}

data "archive_file" "simulation_toggle_lambda" {
  type        = "zip"
  source_file = "simulation_toggle_lambda.py"
  output_path = "simulation_toggle_lambda.zip"
}

data "klayers_package_latest_version" "requests" {
  name           = "requests"
  region         = "us-east-1"
  python_version = "3.12-arm64"
}