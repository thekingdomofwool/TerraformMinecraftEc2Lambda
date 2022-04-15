
resource "aws_iam_policy" "stop_start_ec2_policy" {
  name = "StopStartEC2Policy"
  path = "/"
  description = "IAM policy for stop and start EC2 from a lambda"
policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": "arn:aws:logs:*:*:*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "ec2:Start*",
        "ec2:Stop*",
        "ec2:DescribeInstances*"
      ],
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_role" "stop_start_ec2_role" {
  name = "StopStartEC2Role"
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
resource "aws_iam_role_policy_attachment" "lambda_role_policy" {
  role = "${aws_iam_role.stop_start_ec2_role.name}"
  policy_arn = "${aws_iam_policy.stop_start_ec2_policy.arn}"
}

resource "aws_lambda_function" "stop_ec2_lambda" {
  filename      = "/home/andrew/s3resume/minecraftemail/ec2_lambda_handler.zip"
  function_name = "stopEC2Lambda"
  role          = "${aws_iam_role.stop_start_ec2_role.arn}"
  handler       = "ec2_lambda_handler.stop"
  source_code_hash = "${filebase64sha256("ec2_lambda_handler.zip")}"
  runtime = "python3.7"
  memory_size = "250"
  timeout = "60"
}