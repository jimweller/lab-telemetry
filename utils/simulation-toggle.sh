#!/bin/bash

PARAM_NAME="/fcc-demo-telemetry/events_enabled"
LAMBDA_FUNCTION="simulation_toggle_lambda"

CURRENT_VALUE=$(aws ssm get-parameter --name "$PARAM_NAME" --query "Parameter.Value" --output text)

if [ "$CURRENT_VALUE" == "true" ]; then
  NEW_VALUE="false"
else
  NEW_VALUE="true"
fi

aws ssm put-parameter --name "$PARAM_NAME" --value "$NEW_VALUE" --overwrite
aws lambda invoke --function-name "$LAMBDA_FUNCTION" response.json >/dev/null

echo "Simulation Status: $NEW_VALUE"
