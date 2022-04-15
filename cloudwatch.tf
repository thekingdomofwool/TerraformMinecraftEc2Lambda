resource "aws_cloudwatch_event_rule" "ec2_stop_rule" {
  name        = "StopEC2Instances"
  description = "Stop EC2 nodes at 19:00 from Monday to friday"
  schedule_expression = "cron(0 19 ? * 2-6 *)"
}
resource "aws_cloudwatch_event_target" "ec2_stop_rule_target" {
  rule      = "${aws_cloudwatch_event_rule.ec2_stop_rule.name}"
  arn       = "${aws_lambda_function.stop_ec2_lambda.arn}"
}

resource "aws_lambda_permission" "allow_cloudwatch_stop" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.stop_ec2_lambda.function_name}"
  principal     = "events.amazonaws.com"
}
