resource "aws_iam_role" "LambdaAllowStopStartEC2Role" {
  name = "LambdaAllowStopStartEC2Role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_policy" "LambdaAllowStopStartEC2Policy" {
  name        = "LambdaAllowStopStartEC2Policy"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [{
    "Action": [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ],
    "Resource": "arn:aws:logs:*:*:*",
    "Effect": "Allow"
  },
  {
    "Action": [
      "ec2:DescribeInstances",
      "ec2:DescribeRegions",
      "ec2:StartInstances",
      "ec2:StopInstances"
    ],
    "Resource": "*",
    "Effect": "Allow"
  }]
}
EOF
}



resource "aws_iam_role_policy_attachment" "LambdaTagBasedEC2RestrictionsAttachment" {
  role   = "${aws_iam_role.LambdaAllowStopStartEC2Role.id}"
  policy_arn = "${aws_iam_policy.LambdaAllowStopStartEC2Policy.arn}"
}

data "null_data_source" "lambda_file" {
  inputs = {
    filename = "/lambda/LambadaStopStartEC2Instances.js"
  }
}

data "null_data_source" "lambda_archive" {
  inputs = {
    filename = "${path.module}/lambda/LambadaStopStartEC2Instances.zip"
  }
} 

data "archive_file" "lambda" {
  type        = "zip"
  # source_file = "${data.null_data_source.lambda_file.outputs.filename}"
  source_dir  = "${path.module}/lambda"
  output_path = "${data.null_data_source.lambda_archive.outputs.filename}"
}

resource "aws_cloudwatch_log_group" "lambda_function_logging_group" {
  name = "/aws/lambda/LambadaStopStartEC2Instances"
}

resource "aws_lambda_function" "LambadaStopStartEC2Instances" {
  filename         = "${data.archive_file.lambda.output_path}"
  function_name    = "LambadaStopStartEC2Instances"
  role             = "${aws_iam_role.LambdaAllowStopStartEC2Role.arn}"
  handler          = "LambadaStopStartEC2Instances.handler"
  source_code_hash = "${data.archive_file.lambda.output_base64sha256}"
  runtime          = "nodejs10.x"
  timeout          = 60

  environment {
    variables = {
      TIME_ZONE  = "${var.timeZone}"
    }
  }

}

resource "aws_lambda_permission" "allowStopEC2InstancesRule" {
    statement_id = "AllowExecutionFromCloudWatchStopRule"
    action = "lambda:InvokeFunction"
    function_name = "${aws_lambda_function.LambadaStopStartEC2Instances.function_name}"
    principal = "events.amazonaws.com"
    source_arn = "${aws_cloudwatch_event_rule.StopEC2Instances.arn}"
}

resource "aws_lambda_permission" "allowStartEC2InstancesRule" {
    statement_id = "AllowExecutionFromCloudWatchStartRule"
    action = "lambda:InvokeFunction"
    function_name = "${aws_lambda_function.LambadaStopStartEC2Instances.function_name}"
    principal = "events.amazonaws.com"
    source_arn = "${aws_cloudwatch_event_rule.StartEC2Instances.arn}"
}




