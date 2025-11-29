resource "aws_iam_group" "developers" {
  name = "developers"
  path = "/developers/"
}

resource "aws_iam_group" "accountants" {
  name = "accountants"
  path = "/accountants/"
}


resource "aws_iam_group_policy_attachment" "accountants_billing_ro_access" {
  policy_arn = data.aws_iam_policy.billing_ro_access.arn
  group      = aws_iam_group.accountants.name
}


resource "aws_iam_group_policy_attachment" "developers_rds_full_access" {
  policy_arn = data.aws_iam_policy.rds_full_access.arn
  group      = aws_iam_group.developers.name
}

resource "aws_iam_group_policy_attachment" "developers_ec2_full_access" {
  policy_arn = data.aws_iam_policy.ec2_full_access.arn
  group      = aws_iam_group.developers.name
}

resource "aws_iam_group_policy_attachment" "developers_s3_full_access" {
  policy_arn = data.aws_iam_policy.s3_full_access.arn
  group      = aws_iam_group.developers.name
}

resource "aws_iam_group_policy_attachment" "developers_lambda_full_access" {
  policy_arn = data.aws_iam_policy.lambda_full_access.arn
  group      = aws_iam_group.developers.name
}
