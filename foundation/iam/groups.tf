resource "aws_iam_group" "team_groups" {
  for_each = var.iam_groups

  name = each.key
  path = each.value.path

}
resource "aws_iam_group_policy_attachment" "group_policies" {
  for_each = {
    for pair in flatten([
      for group_name, group_config in var.iam_groups : [
        for policy_arn in group_config.policies : {
          key        = "${group_name}-${basename(policy_arn)}"
          group_name = group_name
          policy_arn = policy_arn
        }
      ]
    ]) : pair.key => pair
  }

  group      = aws_iam_group.team_groups[each.value.group_name].name
  policy_arn = each.value.policy_arn
}