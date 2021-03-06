resource "aws_cloudwatch_event_rule" "StopEC2Instances" {
  name        = "StopEC2Instances"
  description = "stop instances midnight"
  schedule_expression = "cron(0 ${var.stopHour} ? * MON-FRI *)"
 
}

resource "aws_cloudwatch_event_target" "StopEC2InstancesEventTarget" {
  rule      = "${aws_cloudwatch_event_rule.StopEC2Instances.name}"
  target_id = "StopEC2Instances"
  arn       = "${aws_lambda_function.LambadaStopStartEC2Instances.arn}"

  depends_on = [
      aws_lambda_function.LambadaStopStartEC2Instances,
  ]

}


resource "aws_cloudwatch_event_rule" "StartEC2Instances" {
  name        = "StartEC2Instances"
  description = "Start instances at begining of day"
  schedule_expression = "cron(0 ${var.startHour} ? * MON-FRI *)"
 
}

resource "aws_cloudwatch_event_target" "StartEC2InstancesEventTarget" {
  rule      = "${aws_cloudwatch_event_rule.StartEC2Instances.name}"
  target_id = "StartEC2Instances"
  arn       = "${aws_lambda_function.LambadaStopStartEC2Instances.arn}"

  depends_on = [
      aws_lambda_function.LambadaStopStartEC2Instances,
  ]

}

