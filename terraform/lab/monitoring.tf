resource "aws_sns_topic" "portal_alerts" {
  name = "securanova-portal-alerts"

  tags = {
    Name        = "securanova-portal-alerts"
    Project     = "aws-secure-portal"
    Environment = "lab"
    ManagedBy   = "Terraform"
  }
}

resource "aws_sns_topic_subscription" "portal_alerts_email" {
  topic_arn = aws_sns_topic.portal_alerts.arn
  protocol  = "email"
  endpoint  = var.alert_email
}

resource "aws_cloudwatch_metric_alarm" "portal_dlq_messages" {
  alarm_name = "securanova-portal-dlq-messages"

  actions_enabled = true

  namespace   = "AWS/SQS"
  metric_name = "ApproximateNumberOfMessagesVisible"

  statistic = "Maximum"
  period    = 60

  comparison_operator = "GreaterThanOrEqualToThreshold"
  threshold           = 1

  evaluation_periods  = 1
  datapoints_to_alarm = 1

  treat_missing_data = "notBreaching"

  dimensions = {
    QueueName = aws_sqs_queue.portal_data_dlq.name
  }

  alarm_actions = [
    aws_sns_topic.portal_alerts.arn
  ]

  ok_actions                = []
  insufficient_data_actions = []

  tags = {
    Name        = "securanova-portal-dlq-messages"
    Project     = "aws-secure-portal"
    Environment = "lab"
    ManagedBy   = "Terraform"
  }
}
