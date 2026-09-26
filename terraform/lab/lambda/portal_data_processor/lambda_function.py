import json
import urllib.parse


def lambda_handler(event, context):
    print(f"Received {len(event.get('Records', []))} SQS message(s)")

    failures = []

    for record in event.get("Records", []):
        message_id = record["messageId"]

        try:
            body = json.loads(record["body"])

            if body.get("Event") == "s3:TestEvent":
                print(
                    json.dumps(
                        {
                            "type": "S3TestEvent",
                            "bucket": body.get("Bucket"),
                            "message_id": message_id,
                        }
                    )
                )
                continue

            for s3_record in body.get("Records", []):
                bucket = s3_record["s3"]["bucket"]["name"]

                key = urllib.parse.unquote_plus(
                    s3_record["s3"]["object"]["key"]
                )

                event_name = s3_record["eventName"]
                version_id = s3_record["s3"]["object"].get("versionId")
                size = s3_record["s3"]["object"].get("size")

                print(
                    json.dumps(
                        {
                            "type": "S3ObjectEvent",
                            "bucket": bucket,
                            "key": key,
                            "event": event_name,
                            "version_id": version_id,
                            "size": size,
                            "sqs_message_id": message_id,
                        }
                    )
                )

        except Exception as exc:
            print(
                json.dumps(
                    {
                        "type": "ProcessingError",
                        "message_id": message_id,
                        "error": str(exc),
                    }
                )
            )

            failures.append(
                {
                    "itemIdentifier": message_id
                }
            )

    return {
        "batchItemFailures": failures
    }
