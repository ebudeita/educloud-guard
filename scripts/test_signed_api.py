import boto3
import requests
from botocore.auth import SigV4Auth
from botocore.awsrequest import AWSRequest


REGION = "us-east-1"

session = boto3.Session()
credentials = session.get_credentials().get_frozen_credentials()

url = input("Findings API URL: ").strip()

request = AWSRequest(
    method="GET",
    url=url,
)

SigV4Auth(
    credentials,
    "execute-api",
    REGION,
).add_auth(request)

prepared = request.prepare()

response = requests.get(
    url,
    headers=dict(prepared.headers),
    timeout=30,
)

print(
    f"HTTP Status: {response.status_code}"
)

try:
    print(
        response.json()
    )
except ValueError:
    print(
        response.text
    )
