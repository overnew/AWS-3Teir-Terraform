resource "aws_ecr_repository" "app" {
  name                 = "milliapp"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_ecr_repository" "web" {
  name                 = "milliweb"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

#inspector 활성화
data "aws_caller_identity" "current" {}

resource "aws_inspector2_enabler" "image_scan" {
  account_ids    = [data.aws_caller_identity.current.account_id]
  resource_types = ["ECR"]
}