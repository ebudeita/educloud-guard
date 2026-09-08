import os

import boto3
import requests
from flask import Flask, jsonify, request, send_from_directory
from botocore.auth import SigV4Auth
from botocore.awsrequest import AWSRequest


REGION = "us-east-1"

BASE_DIR = os.path.dirname(
    os.path.abspath(__file__)
)

app = Flask(
    __name__,
    static_folder=BASE_DIR,
    static_url_path="",
)


def signed_get(url):
    session = boto3.Session()

    credentials = (
        session
        .get_credentials()
        .get_frozen_credentials()
    )

    aws_request = AWSRequest(
        method="GET",
        url=url,
    )

    SigV4Auth(
        credentials,
        "execute-api",
        REGION,
    ).add_auth(aws_request)

    prepared = aws_request.prepare()

    response = requests.get(
        url,
        headers=dict(prepared.headers),
        timeout=30,
    )

    response.raise_for_status()

    return response.json()


@app.route("/")
def dashboard():
    return send_from_directory(
        BASE_DIR,
        "index.html",
    )


@app.route("/api/findings")
def findings_proxy():
    api_url = os.environ.get(
        "FINDINGS_API_URL"
    )

    if not api_url:
        return jsonify(
            {
                "error":
                    "FINDINGS_API_URL is not configured."
            }
        ), 500

    query_string = request.query_string.decode()

    if query_string:
        target_url = (
            f"{api_url}?{query_string}"
        )
    else:
        target_url = api_url

    try:
        data = signed_get(target_url)

        return jsonify(data)

    except requests.RequestException as error:
        print(
            f"Findings API request failed: {error}"
        )

        return jsonify(
            {
                "error":
                    "Unable to retrieve findings."
            }
        ), 502


if __name__ == "__main__":
    app.run(
        host="127.0.0.1",
        port=8080,
        debug=True,
    )
