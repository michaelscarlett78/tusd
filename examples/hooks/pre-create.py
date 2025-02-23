#!/bin/python3

import sys
import requests
import json

    # Read data from STDIN (assuming it's JSON)

def make_post_request(url, data):
    try:
        response = requests.post(url, json=data)
        response.raise_for_status()  # Check for errors
        return response.json()  # Return the JSON response
    except requests.exceptions.RequestException as e:
        print("Error making POST request:", e)
        sys.exit(1)

if __name__ == "__main__":
    # Get the URL from command-line arguments or set it directly
    url = "https://testportal.mainstream.co.nz/TEST/subroutine/WEBTERMS"

    # Read data from STDIN (assuming it's JSON)
    try:
        data = sys.stdin.read()
        data = data.strip()  # Remove any leading/trailing whitespaces
        data = json.loads(data)  # Parse the JSON data
    except Exception as e:
        print("Error reading data from STDIN:", e)
        sys.exit(1)
    # Check we have a filename and exit if not 
    if data['Upload']['MetaData']['filename'] is null

    # Make the POST request and handle the response
    response_data = make_post_request(url, data)
    print("Response:", response_data)
