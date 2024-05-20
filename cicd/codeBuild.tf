locals {
  build_name = "${var.project_name}-${var.build_name}"
}

# codebuild
resource "aws_codebuild_project" "this" {
  depends_on = [ aws_codecommit_repository.source_repository ]
  name          = local.build_name  #"${var.project_name}-build"
  build_timeout = 6
  service_role  =  aws_iam_role.build_task_role.arn #module.iam.iam_role_arn
  
  artifacts {
    type = "CODEPIPELINE"
  }
  
  source {
    type      = "CODEPIPELINE" #or S3, GITHUB, CODEPIPELINE , CODECOMMIT
    git_clone_depth = 1
    #소스파일 위치
    location  = "https://git-codecommit.${var.region}.amazonaws.com/v1/repos/${var.source_repository_name}"
    
    # 빌드 스펙의 위치 기본적으로 CodeBuild는 소스 코드 루트 디렉터리에서 buildspec.yml 파일을 찾습니다.
    # ${빌드 스펙 위치}
    #buildspec = 
  }
  source_version = "refs/heads/main"
  #온디맨드 형식의 타입을 사용
  environment {
    compute_type    = "BUILD_GENERAL1_SMALL"
    image           = "aws/codebuild/amazonlinux2-x86_64-standard:4.0"
    type            = "LINUX_CONTAINER"
    privileged_mode = true  #특권모드를 true로 설정


    #environment_variable {  #환경 변수 설정
    #  name  = "ECS_FAMILY"
    #  value = aws_ecs_task_definition.main.family
    #}
    environment_variable {
      name  = "ONE_CONTAINER_NAME"
      value = "app"
    }

  }

  # vpc 설정
  #vpc_config {
  #  vpc_id             = "vpc-01c885f9e4c0434f7" #aws_vpc.default.id #local.vpc_id 
  #  subnets            = ["subnet-02c59928b96231787"]
  #  security_group_ids = ["sg-0a1d1942a88d9d60e"]
  #}

  # codePipeLine을 사용하기에 따로 codeBuild용 아티팩트 버킷을 사용하지않습니다.


  tags = local.default_tag
}

#data "aws_vpc" "default" {
#  default = true
#} 


resource "aws_iam_role" "build_task_role" {
  name = "${var.project_name}-build-task-role"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = ["codebuild.amazonaws.com"]
        }
      },
    ]
  })
  

  inline_policy {
    name = "${var.project_name}-buidler-task-role"
    
    policy = jsonencode({
    Version: "2012-10-17",
    Statement: [
        {
            "Effect": "Allow",
            "Resource": [
                "arn:aws:logs:ap-northeast-1:${var.user_id}:log-group:/aws/codebuild/docker-test",
                "arn:aws:logs:ap-northeast-1:${var.user_id}:log-group:/aws/codebuild/docker-test:*"
            ],
            "Action": [
                "logs:CreateLogGroup",
                "logs:CreateLogStream",
                "logs:PutLogEvents"
            ]
        },
        {
            "Effect": "Allow",
            "Resource": [
                "arn:aws:s3:::codepipeline-ap-northeast-1-*"
            ],
            "Action": [
                "s3:PutObject",
                "s3:GetObject",
                "s3:GetObjectVersion",
                "s3:GetBucketAcl",
                "s3:GetBucketLocation"
            ]
        },
        {
            "Effect": "Allow",
            "Resource": [
                "*"
            ],
            "Action": [     #ecs의 task 정보를 읽고 쓰기위한 권한
                "ecs:ListTaskDefinitions",
                "ecs:DescribeTaskDefinition"
            ]
        },
        {
            "Effect": "Allow",
            "Resource": [
                "arn:aws:codecommit:ap-northeast-1:${var.user_id}:ldj-web-repo"
            ],
            "Action": [
                "codecommit:GitPull"
            ]
        },
        {
            "Effect": "Allow",
            "Action": [
                "codebuild:CreateReportGroup",
                "codebuild:CreateReport",
                "codebuild:UpdateReport",
                "codebuild:BatchPutTestCases",
                "codebuild:BatchPutCodeCoverages"
            ],
            "Resource": [
                "arn:aws:codebuild:ap-northeast-1:${var.user_id}:report-group/docker-test-*"
            ]
        },
        {
            "Sid": "CloudWatchLogsPolicy",
            "Effect": "Allow",
            "Action": [
                "logs:CreateLogGroup",
                "logs:CreateLogStream",
                "logs:PutLogEvents"
            ],
            "Resource": [
                "*"
            ]
        },
        {
            "Sid": "S3GetObjectPolicy",
            "Effect": "Allow",
            "Action": [
                "s3:GetObject",
                "s3:GetObjectVersion"
            ],
            "Resource": [
                "*"
            ]
        },
        {
            "Sid": "S3PutObjectPolicy",
            "Effect": "Allow",
            "Action": [
                "s3:PutObject"
            ],
            "Resource": [
                "*"
            ]
        },
        {
            "Sid": "ECRPullPolicy",
            "Effect": "Allow",
            "Action": [
                "ecr:BatchCheckLayerAvailability",
                "ecr:GetDownloadUrlForLayer",
                "ecr:BatchGetImage",
                "ecr:InitiateLayerUpload",
                "ecr:UploadLayerPart",
                "ecr:CompleteLayerUpload",
                "ecr:PutImage"
            ],
            "Resource": [
                "*"
            ]
        },
        {
            "Sid": "ECRAuthPolicy",
            "Effect": "Allow",
            "Action": [
                "ecr:GetAuthorizationToken"
            ],
            "Resource": [
                "*"
            ]
        },
        {
            "Sid": "S3BucketIdentity",
            "Effect": "Allow",
            "Action": [
                "s3:GetBucketAcl",
                "s3:GetBucketLocation"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "ec2:CreateNetworkInterface",
                "ec2:DescribeDhcpOptions",
                "ec2:DescribeNetworkInterfaces",
                "ec2:DeleteNetworkInterface",
                "ec2:DescribeSubnets",
                "ec2:DescribeSecurityGroups",
                "ec2:DescribeVpcs"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "ec2:CreateNetworkInterfacePermission"
            ],
            "Resource": "arn:aws:ec2:ap-northeast-1:${var.user_id}:network-interface/*",
            "Condition": {
                "StringEquals": {
                    "ec2:Subnet": [
                        "arn:aws:ec2:ap-northeast-1:${var.user_id}:subnet/subnet-02c59928b96231787"
                    ],
                    "ec2:AuthorizedService": "codebuild.amazonaws.com"
                }
            }
        }
    ]
    })
  }

  tags = local.default_tag
}