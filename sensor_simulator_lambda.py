import json
import os
import logging
import requests
import random
from random import choices

# Set up logging
logger = logging.getLogger()
logger.setLevel(logging.INFO)

# Retrieve the API Gateway URL from the environment variables
API_URL = os.getenv("API_URL")

def lambda_handler(event, context):
    try:
        # Extract city and company information from the event
        city = event.get("city")
        company = event.get("company")
        coordinates = event.get("coordinates", {})
        latitude = coordinates.get("latitude")
        longitude = coordinates.get("longitude")

        # Generate a random health status with specified weights
        health_status = random.choices([0, 1], weights=[0.85, 0.15])[0]

        # Construct the telemetry data as query parameters
        params = {
            "city": city,
            "company": company,
            "latitude": latitude,
            "longitude": longitude,
            "health": health_status
        }

        # Send the data to the API Gateway endpoint using GET
        response = requests.get(API_URL, params=params)
        response.raise_for_status()

        logger.info(f"Telemetry data sent: {json.dumps(params)}")
        
        return {
            "statusCode": 200,
            "body": json.dumps({
                "message": "Data sent successfully",
                "payload": params
            })
        }
    
    except requests.exceptions.RequestException as e:
        logger.error(f"Error sending telemetry data: {e}")
        return {
            "statusCode": 500,
            "body": json.dumps({"message": "Failed to send telemetry data"})
        }
    except Exception as e:
        logger.error(f"Unexpected error: {e}")
        return {
            "statusCode": 500,
            "body": json.dumps({"message": "An unexpected error occurred"})
        }
