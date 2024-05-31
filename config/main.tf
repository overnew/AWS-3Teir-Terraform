
# key rotated 여부
resource "aws_config_conformance_pack" "example" {
  name = "example"

  input_parameter {
    parameter_name  = "AccessKeysRotatedParameterMaxAccessKeyAge"
    parameter_value = "90"
  }

  template_body = <<EOT
Parameters:
  AccessKeysRotatedParameterMaxAccessKeyAge:
    Type: String
Resources:
  IAMPasswordPolicy:
    Properties:
      ConfigRuleName: IAMPasswordPolicy
      Source:
        Owner: AWS
        SourceIdentifier: IAM_PASSWORD_POLICY
    Type: AWS::Config::ConfigRule
EOT

  depends_on = [aws_config_configuration_recorder.my_config]

}



resource "aws_config_config_rule" "r" {
  name = "ldj-config"

  source {   #제공하는 Rule의 주체
    owner             = "AWS"
    source_identifier = "S3_BUCKET_VERSIONING_ENABLED"
  }

  depends_on = [aws_config_configuration_recorder.my_config]


  tags = var.default_tag
}


resource "aws_config_configuration_recorder" "my_config" {
  name     = "ldj-config"
  role_arn = aws_iam_role.config_role.arn
}

resource "aws_config_delivery_channel" "to_s3" {
  name           = "ldj-config-delivery"
  s3_bucket_name = var.log_central_bucket
  s3_key_prefix = "config"
  depends_on     = [aws_config_configuration_recorder.my_config] #race condition 방지
}

#aws_config_delivery_channel가 먼저 있어야 config 레코드를 활성화함
resource "aws_config_configuration_recorder_status" "recode_enable" {
  name       = aws_config_configuration_recorder.my_config.name
  is_enabled = true
  depends_on = [aws_config_delivery_channel.to_s3]
}


data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["config.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "config_role" {
  name               = "ldj-awsconfig-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
  
  tags = var.default_tag
}

data "aws_iam_policy_document" "config_policy_doc" {
  statement {
    effect    = "Allow"
    actions   = ["config:Put*", "s3:*", "kms:*"]
    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "config_policy" {
  name   = "ldj-awsconfig-policy"
  role   = aws_iam_role.config_role.id
  policy = data.aws_iam_policy_document.config_policy_doc.json
  
}
