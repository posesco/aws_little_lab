resource "aws_iam_role" "cost_explorer_reader" {
  name               = "cost-explorer-reader"
  description        = "Read-only access to Cost Explorer"
  assume_role_policy = data.aws_iam_policy_document.cost_explorer_assume_role.json

  tags = merge(
    local.common_tags,
    {
      ResourceName = "cost-explorer-reader"
      AssumedBy    = "ServiceAccounts"
    }
  )
}

resource "aws_iam_role_policy_attachment" "cost_explorer_access" {
  role       = aws_iam_role.cost_explorer_reader.name
  policy_arn = "arn:aws:iam::aws:policy/AWSBillingReadOnlyAccess"
}
