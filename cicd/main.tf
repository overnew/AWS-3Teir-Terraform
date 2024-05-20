# reference with https://github.com/aws-samples/aws-codepipeline-terraform-cicd-samples

locals {
  codepipe_name = format("%s-%s",var.project_name ,"codepipeline")
  pipe_role_name = format("%s-%s",var.project_name ,"role")
  pipe_bucket_name = format("%s-%s",var.project_name ,"bucket-ldj")

  default_tag = {
    project = var.project_name
    owner = "ldj"
    part = "vpc"
    env ="test"
  }
}


resource "aws_codepipeline" "codepipeline" {
  name     = local.codepipe_name
  role_arn = aws_iam_role.cp_service_role.arn

  artifact_store {
    location = aws_s3_bucket.pipeline_artifact.id #module.s3_artifact.s3_bucket_id
    type     = "S3"
  }
  

  stage {
    name = "Source"

    action {
      name             = "Source"
      category         = "Source"
      owner            = "AWS"
      version          = "1"
      provider         = "CodeCommit"
      namespace        = "SourceVariables"
      output_artifacts = ["source_out"]
      run_order        = 1

      configuration = {
        RepositoryName       = var.source_repository_name
        BranchName           = var.source_repository_branch
        PollForSourceChanges = "false"   #변경사항에 자동 반응해 build
      }
    }
  }


  stage {
    name = "Build"
    action {
      name             = "Build"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      input_artifacts  = ["source_out"]
      output_artifacts = ["build_out"] # 다음 스테이지로 넘길 아웃풋을 지정합니다.
      version          = "1"

      configuration = {
        ProjectName = var.build_name   # 생성할 코드빌드를 이용합니다.
      }
    }
  }

 # pipeLine에서 관리자가 직접 승인해주는 단계
  stage {
    name = "Approve"
    action {
      name     = "Approval"
      category = "Approval"
      owner    = "AWS"
      provider = "Manual"
      version  = "1"
    }
  }


    stage {
      name = "Deploy"
      action {
        name            = "Deploy"
        category        = "Deploy"
        owner           = "AWS"
        provider        = "CodeDeployToECS"
        version         = "1"
        run_order       = 3
        input_artifacts = ["build_out"]
        configuration   = {
          ApplicationName                = aws_codedeploy_app.main.name
          DeploymentGroupName            = aws_codedeploy_deployment_group.main.deployment_group_name
          TaskDefinitionTemplateArtifact = "build_out"
          TaskDefinitionTemplatePath     = "task_definition.json"
          AppSpecTemplateArtifact        = "build_out"
          AppSpecTemplatePath            = "appspec.yml"
        }
      }
    }
}


# s3 codePipeLine에서 사용할 버킷
resource "aws_s3_bucket" "pipeline_artifact" {
  bucket        = local.pipe_bucket_name
  force_destroy = true
}

resource "aws_s3_bucket_acl" "pipeline_artifact_bucket_acl" {
  bucket = aws_s3_bucket.pipeline_artifact.id
  acl    = "private"
  depends_on = [aws_s3_bucket_ownership_controls.s3_bucket_acl_ownership]
}

# Resource to avoid error "AccessControlListNotSupported: The bucket does not allow ACLs"
resource "aws_s3_bucket_ownership_controls" "s3_bucket_acl_ownership" {
  depends_on = [aws_s3_bucket.pipeline_artifact]
  bucket = aws_s3_bucket.pipeline_artifact.id
  rule {
    object_ownership = "ObjectWriter"
  }
}

/*
module "s3_artifact" {
  source        = "terraform-aws-modules/s3-bucket/aws"
  bucket        = local.pipe_bucket_name
  acl           = "private"
  force_destroy = true
  versioning    = { enabled = false }
}
*/


resource aws_iam_role cp_service_role {
  name               = "${local.codepipe_name}-role"
  assume_role_policy = data.aws_iam_policy_document.cp_assume_role_policy.json
}

resource aws_iam_role_policy cp_service_role {
  name   = "${local.codepipe_name}-codepipeline-policy"
  role   = aws_iam_role.cp_service_role.id
  policy = data.aws_iam_policy_document.cp_policy.json
}

data aws_iam_policy_document cp_assume_role_policy {
  statement {
    actions = [
      "sts:AssumeRole",
    ]

    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["codepipeline.amazonaws.com"]
    }
  }
}

data aws_iam_policy_document cp_policy {
  statement {
    effect    = "Allow"
    actions   = [
      "iam:PassRole"
    ]
    resources = [
      "*"
    ]
    condition {
      test = "StringEqualsIfExists"
      variable = "iam:PassedToService"
      values = [
        "ecs-tasks.amazonaws.com"
      ]
    }
  }

  statement {
    effect    = "Allow"
    actions   = [
      "s3:GetBucketVersioning",
      "s3:GetObject",
      "s3:GetObjectVersion",
      "s3:PutObject"
    ]
    resources = [
      "*"
    ]
  }
  
  statement {
    effect    = "Allow"
    actions   = [
       "codecommit:*"
    ]
    resources = [
      "*"
    ]
  }

  statement {
    effect    = "Allow"
    actions   = [
      "codebuild:BatchGetBuilds",
      "codebuild:StartBuild"
    ]
    resources = [
      "*"
    ]
  }

  statement {
    effect    = "Allow"
    actions   = [
      "codedeploy:CreateDeployment",
      "codedeploy:GetApplication",
      "codedeploy:GetApplicationRevision",
      "codedeploy:GetDeployment",
      "codedeploy:GetDeploymentConfig",
      "codedeploy:RegisterApplicationRevision"
    ]
    resources = [
      "*"
    ]
  }

  statement {
    effect    = "Allow"
    actions   = [
      "ecr:DescribeImages"
    ]
    resources = [
      "*"
    ]
  }

  statement {
    effect    = "Allow"
    actions   = [
      "elasticloadbalancing:*",
      "cloudwatch:*",
      "sns:*",
      "ecs:*",
    ]
    resources = [
      "*"
    ]
  }
}