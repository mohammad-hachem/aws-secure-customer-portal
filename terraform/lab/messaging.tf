resource "aws_sqs_queue" "portal_data_dlq" {
  name = "securanova-portal-data-dlq"

  visibility_timeout_seconds = 30
  message_retention_seconds  = 1209600
  delay_seconds              = 0
  max_message_size           = 1048576
  receive_wait_time_seconds  = 0

  sqs_managed_sse_enabled = true
}

resource "aws_sqs_queue" "portal_data_events" {
  name = "securanova-portal-data-events"

  visibility_timeout_seconds = 60
  message_retention_seconds  = 345600
  delay_seconds              = 0
  max_message_size           = 1048576
  receive_wait_time_seconds  = 0

  sqs_managed_sse_enabled = true

  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.portal_data_dlq.arn
    maxReceiveCount     = 3
  })
}

data "aws_iam_policy_document" "s3_to_portal_events" {
  statement {
    sid    = "AllowS3ToSendMessages"
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["s3.amazonaws.com"]
    }

    actions = ["sqs:SendMessage"]

    resources = [
      aws_sqs_queue.portal_data_events.arn
    ]

    condition {
      test     = "ArnEquals"
      variable = "aws:SourceArn"
      values   = [aws_s3_bucket.portal_data.arn]
    }

    condition {
      test     = "StringEquals"
      variable = "aws:SourceAccount"
      values   = ["${data.aws_caller_identity.current.account_id}"]
    }
  }
}

resource "aws_sqs_queue_policy" "portal_data_events" {
  queue_url = aws_sqs_queue.portal_data_events.id
  policy    = data.aws_iam_policy_document.s3_to_portal_events.json
}

resource "aws_s3_bucket_notification" "portal_data" {
  bucket = aws_s3_bucket.portal_data.id

  queue {
    id        = "portal-object-created"
    queue_arn = aws_sqs_queue.portal_data_events.arn
    events    = ["s3:ObjectCreated:*"]

    filter_prefix = "portal/"
  }

  depends_on = [
    aws_sqs_queue_policy.portal_data_events
  ]
}
