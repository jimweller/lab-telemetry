import boto3
import time
import logging


ssm = boto3.client('ssm')
events = boto3.client('events')

logger = logging.getLogger()
logger.setLevel(logging.INFO)


def lambda_handler(event, context):
    response = ssm.get_parameter(Name='/fcc-demo-telemetry/events_enabled')
    events_enabled = response['Parameter']['Value'] == 'true'

    rules = events.list_rules(NamePrefix='fcc-demo-sensor')['Rules']
    rule_names = [rule['Name'] for rule in rules]

    for rule_name in rule_names:
        if events_enabled:
            logger.info(f"Enabling: {rule_name}") 
            events.enable_rule(Name=rule_name)
        else:
            logger.info(f"Disabling: {rule_name}") 
            events.disable_rule(Name=rule_name)

    return {"status": "Event rules updated", "enabled": events_enabled}
