import json
import os
import boto3
import logging
import random
from typing import Dict, Any
from datetime import datetime,timezone


# Set up logging
logger = logging.getLogger()
logger.setLevel(logging.INFO)

# Initialize Kinesis Firehose client
firehose_client = boto3.client('firehose')

# Define the Firehose delivery stream name
FIREHOSE_STREAM_NAME = os.getenv("FIREHOSE_STREAM_NAME")

def lambda_handler(event: Dict[str, Any], context) -> Dict[str, Any]:
    try:
        
        logger.info(f"Received event: {json.dumps(event)}")

        # Extract data from the event
        params = event["queryStringParameters"]
        city = params.get("city")
        company = params.get("company")
        latitude = float(params.get("latitude"))
        longitude = float(params.get("longitude"))
        health = int(params.get("health"))
        timestamp = datetime.now(timezone.utc).isoformat()

        # Log the extracted information
        logger.info(f"Processing data for sensor: {timestamp} {city} : {company} : [{latitude},{longitude}] : {health}") 
        
        # Construct the data to send to Firehose
        payload = {
            "city": city,
            "company": company,
            "coordinates": {
                "latitude": latitude,
                "longitude": longitude
            },
            "health": health,
            "timestamp": timestamp
        }
        
        # Send data to Kinesis Firehose
        firehose_client.put_record(
            DeliveryStreamName=FIREHOSE_STREAM_NAME,
            Record={
                "Data": json.dumps(payload) + "\n"
            }
        )

        logger.info(f"Data sent to Firehose: {json.dumps(payload)}")


        return {
            "statusCode": 200,
            "body": json.dumps({
                "message": f"Data processed for {company} in {city}"
            }),
        }
    except Exception as e:
        logger.error(f"Error processing data: {e}")
        return {
            "statusCode": 500,
            "body": json.dumps({
                "message": "An error occurred while processing data."
            }),
        }
