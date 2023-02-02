provider "aws" {
  region = "us-east-1"
}


resource "aws_sqs_queue" "terraform_queue" {
  name                      = "inv-devint-ue1-sqs-move-money-contributions"
  delay_seconds             = 0
  max_message_size          = 1024
  message_retention_seconds = 604800
  receive_wait_time_seconds = 0
  visibility_timeout_seconds = 300

}

resource "aws_sqs_queue_policy" "queue" {
  queue_url = aws_sqs_queue.terraform_queue.id
  policy    = data.aws_iam_policy_document.queue.json
}

data "aws_iam_policy_document" "queue" {
  statement {
    effect    = "Allow"
    resources = [aws_sqs_queue.terraform_queue.arn]
    actions = [
      "sqs:ChangeMessageVisibility",
      "sqs:DeleteMessage",
      "sqs:GetQueueAttributes",
      "sqs:GetQueueUrl",
      "sqs:ListQueueTags",
      "sqs:ReceiveMessage",
      "sqs:SendMessage",
    ]
  
  }
}

resource "aws_sqs_queue" "terraform_queue_deadletter" {
  name = "terraform-example-deadletter-queue"
  redrive_allow_policy = jsonencode({
    redrivePermission = "byQueue",
    sourceQueueArns   = [aws_sqs_queue.terraform_queue.arn]
  })
}


resource "aws_sqs_queue_policy" "deadletter_queue" {
  queue_url = aws_sqs_queue.terraform_queue_deadletter.id
  policy    = data.aws_iam_policy_document.deadletter_queue.json
}

data "aws_iam_policy_document" "deadletter_queue" {
  statement {
    effect    = "Allow"
    resources = [aws_sqs_queue.terraform_queue_deadletter.arn]
    actions = [
      "sqs:ChangeMessageVisibility",
      "sqs:DeleteMessage",
      "sqs:GetQueueAttributes",
      "sqs:GetQueueUrl",
      "sqs:ListQueueTags",
      "sqs:ReceiveMessage",
      "sqs:SendMessage",
    ]
 
  }
}

resource "aws_sns_topic" "user_updates" {
  name            = "inv-devint-sqs-move-money-contribution"
  delivery_policy = <<EOF
{
  "http": {
    "defaultHealthyRetryPolicy": {
      "minDelayTarget": 20,
      "maxDelayTarget": 20,
      "numRetries": 3,
      "numMaxDelayRetries": 0,
      "numNoDelayRetries": 0,
      "numMinDelayRetries": 0,
      "backoffFunction": "linear"
    },
    "disableSubscriptionOverrides": false,
    "defaultThrottlePolicy": {
      "maxReceivesPerSecond": 1
    }
  }
}
EOF
}