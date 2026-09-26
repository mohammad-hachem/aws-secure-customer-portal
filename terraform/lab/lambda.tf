data "aws_iam_policy_document" "lambda_assume_role" {
  statement {
    effect = "Allow"

    actions = [
      "sts:AssumeRole"
    ]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "portal_data_processor" {
  name = "securanova-portal-data-processor-role-tlfry71k"
  path = "/service-role/"

  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role.json
}

data "aws_iam_policy_document" "lambda_basic_execution" {
  statement {
    effect = "Allow"

    actions = [
      "logs:CreateLogGroup"
    ]

    resources = [
      "arn:aws:logs:eu-central-1:${data.aws_caller_identity.current.account_id}:*"
    ]
  }

  statement {
    effect = "Allow"

    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]

    resources = [
      "arn:aws:logs:eu-central-1:${data.aws_caller_identity.current.account_id}:log-group:/aws/lambda/securanova-portal-data-processor:*"
    ]
  }
}

resource "aws_iam_policy" "lambda_basic_execution" {
  name = "AWSLambdaBasicExecutionRole-94b7f860-e84c-4941-8081-aaa21faa6c8c"
  path = "/service-role/"

  policy = data.aws_iam_policy_document.lambda_basic_execution.json
}

resource "aws_iam_role_policy_attachment" "lambda_basic_execution" {
  role       = aws_iam_role.portal_data_processor.name
  policy_arn = aws_iam_policy.lambda_basic_execution.arn
}

data "aws_iam_policy_document" "lambda_sqs_consume" {
  statement {
    sid    = "ConsumePortalDataEvents"
    effect = "Allow"

    actions = [
      "sqs:ReceiveMessage",
      "sqs:DeleteMessage",
      "sqs:GetQueueAttributes"
    ]

    resources = [
      aws_sqs_queue.portal_data_events.arn
    ]
  }
}

resource "aws_iam_role_policy" "lambda_sqs_consume" {
  name = "securanova-portal-sqs-consume"
  role = aws_iam_role.portal_data_processor.name

  policy = data.aws_iam_policy_document.lambda_sqs_consume.json
}

data "archive_file" "portal_data_processor" {
  type = "zip"

  source_file = "${path.module}/lambda/portal_data_processor/lambda_function.py"
  output_path = "${path.module}/lambda/portal_data_processor.zip"
}

resource "aws_lambda_function" "portal_data_processor" {
  function_name = "securanova-portal-data-processor"

  role    = aws_iam_role.portal_data_processor.arn
  runtime = "python3.14"
  handler = "lambda_function.lambda_handler"

  filename         = data.archive_file.portal_data_processor.output_path
  source_code_hash = data.archive_file.portal_data_processor.output_base64sha256

  architectures = ["x86_64"]

  memory_size = 128
  timeout     = 10

  package_type = "Zip"

  ephemeral_storage {
    size = 512
  }

  tracing_config {
    mode = "PassThrough"
  }

  logging_config {
    log_format = "Text"
    log_group  = "/aws/lambda/securanova-portal-data-processor"
  }

  depends_on = [
    aws_iam_role_policy_attachment.lambda_basic_execution,
    aws_iam_role_policy.lambda_sqs_consume
  ]
}

resource "aws_lambda_event_source_mapping" "portal_data_events" {
  event_source_arn = aws_sqs_queue.portal_data_events.arn
  function_name    = aws_lambda_function.portal_data_processor.arn

  enabled = true

  batch_size                         = 10
  maximum_batching_window_in_seconds = 0

  function_response_types = [
    "ReportBatchItemFailures"
  ]

  depends_on = [
    aws_iam_role_policy.lambda_sqs_consume
  ]
}
