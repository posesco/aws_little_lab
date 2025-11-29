resource "aws_iam_user" "developer" {
  name = "jesus.posada.develop"

  tags = merge(
    local.common_tags,
    {
      Type = "human"
      Group = "developer"
    }
  )
}
resource "aws_iam_access_key" "developer_access_key" {
  user = aws_iam_user.developer.name
}

output "access_key_id" {
  value = aws_iam_access_key.developer_access_key.id
  sensitive = true
}

output "secret_access_key" {
  value = aws_iam_access_key.developer_access_key.secret
  sensitive = true
}

locals {
  developer_keys_csv = "access_key,secret_key\n${aws_iam_access_key.developer_access_key.id},${aws_iam_access_key.developer_access_key.secret}"
}

resource "local_file" "developer_keys" {
  content  = local.developer_keys_csv
  filename = "developer-keys.csv"
}