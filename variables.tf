variable "account_id" {
  description = "AWS Account ID"
  type        = string
}

variable "repo_name" {
  description = "GitHub repository name in the format owner/repo"
  type        = string
}

variable "branch" {
  description = "Branch for GitHub Actions"
  type        = string
}
