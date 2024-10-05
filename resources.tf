# GHA Role Provision via OIDC
resource "aws_iam_openid_connect_provider" "gha_oidc" {
  url             = "https://token.actions.githubusercontent.com"
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = ["6938fd4d98bab03faadb97b34396831e3780aea1"] # not requiredj
}

# Prepare OIDC policy
data "aws_iam_openid_connect_provider" "existing_gha_oidc" {
  url = "https://token.actions.githubusercontent.com"
}

resource "aws_iam_role" "github_actions_role" {
  name = "GithubActionsRole"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Federated = data.aws_iam_openid_connect_provider.existing_gha_oidc.arn
        },
        Action = "sts:AssumeRoleWithWebIdentity",
        Condition = {
          StringEquals = {
            "token.actions.githubusercontent.com:aud": "sts.amazonaws.com",
            "token.actions.githubusercontent.com:sub": "repo:yanganaev/rsschool-test:ref:refs/heads/task_1"
          }
        }
      }
    ]
  })
}

# Create Role
resource "aws_iam_role" "terraform_gha_role" {
  name               = "terraform-github-actions-role"
  assume_role_policy = data.aws_iam_policy_document.oidc_policy.json
}
}

# Attach Policies to the role
resource "aws_iam_role_policy_attachment" "attach_policies" {
  for_each   = toset(var.iam_policies)
  role       = aws_iam_role.terraform_gha_role.name
  policy_arn = each.value
}