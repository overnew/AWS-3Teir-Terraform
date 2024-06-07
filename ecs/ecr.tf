resource "aws_ecr_repository" "app" {
  #count = 0
  name                 = "milliapp"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_ecr_repository" "web" {
  #count = 0
  name                 = "milliweb"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}


data "aws_ecr_repository" "test_repo" {
  name = "name"
}

#ECR lifecycle
resource "aws_ecr_lifecycle_policy" "test" {
  repository = data.aws_ecr_repository.test_repo.name

  policy = <<EOF
{
    "rules": [
        {
            "rulePriority": 1,
            "description": "Expire images older than 35 days",
            "selection": {
                "tagStatus": "any",
                "countType": "sinceImagePushed",
                "countUnit": "days",
                "countNumber": 35
            },
            "action": {
                "type": "expire"
            }
        }
    ]
}
EOF
}

#ECR lifecycle
resource "aws_ecr_lifecycle_policy" "app" {
  repository = aws_ecr_repository.app.name

  policy = <<EOF
{
    "rules": [
        {
            "rulePriority": 1,
            "description": "Expire images older than 35 days",
            "selection": {
                "tagStatus": "any",
                "countType": "sinceImagePushed",
                "countUnit": "days",
                "countNumber": 35
            },
            "action": {
                "type": "expire"
            }
        }
    ]
}
EOF
}

#ECR lifecycle
resource "aws_ecr_lifecycle_policy" "web" {
  repository = aws_ecr_repository.web.name

  policy = <<EOF
{
    "rules": [
        {
            "rulePriority": 1,
            "description": "Expire images older than 35 days",
            "selection": {
                "tagStatus": "any",
                "countType": "sinceImagePushed",
                "countUnit": "days",
                "countNumber": 35
            },
            "action": {
                "type": "expire"
            }
        }
    ]
}
EOF
}


#inspector 활성화
data "aws_caller_identity" "current" {}

resource "aws_inspector2_enabler" "image_scan" {
  account_ids    = [data.aws_caller_identity.current.account_id]
  resource_types = ["ECR"]
}