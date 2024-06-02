#https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/backup_selection.html
locals {
  dynamodb_backup_tag = "dynamodb-backup"
}

data "aws_kms_key" "by_alias" {
  key_id = "alias/backup-key"
}

resource "aws_backup_plan" "s3_plan" {
  name = "tf_example_backup_plan"

  rule {
    rule_name         = "tf_example_backup_rule"
    target_vault_name = aws_backup_vault.s3_vault.name
    schedule          = "cron(0 4 ? * MON *)"

    lifecycle {
      delete_after = 60
    }
  }
  /*
  advanced_backup_setting {
    backup_options = {
      WindowsVSS = "enabled"
    }
    resource_type = "EC2"
  }*/
}

resource "aws_backup_vault" "s3_vault" {
  name        = "s3_backup_vault"
  kms_key_arn = data.aws_kms_key.by_alias.arn
}

resource "aws_backup_selection" "s3" {
  iam_role_arn = aws_iam_role.back_role.arn
  name         = "tf_s3_backup_selection"
  plan_id      = aws_backup_plan.s3_plan.id

  selection_tag {
    type  = "STRINGEQUALS"
    key   = var.s3_backup_tag
    value = "true"
  }

  #arn으로 설정도 가능
  #resources = [
  #  aws_db_instance.example.arn,
  #  aws_ebs_volume.example.arn,
  #  aws_efs_file_system.example.arn,
  #]
}


#dynamodb_plan
resource "aws_backup_plan" "dynamodb_plan" {
  name = "dynamodb_backup_plan"

  rule {
    rule_name         = "dynamodb_backup_rule"
    target_vault_name = aws_backup_vault.dynamodb_vault.name
    schedule          = "cron(0 3 * * ? *)"

    lifecycle {
      delete_after = 60
    }
  }
}

resource "aws_backup_vault" "dynamodb_vault" {
  name        = "dynamodb_backup_vault"
  kms_key_arn = data.aws_kms_key.by_alias.arn
}

resource "aws_backup_selection" "dynamodb" {
  iam_role_arn = aws_iam_role.back_role.arn
  name         = "dynamodb_backup_selection"
  plan_id      = aws_backup_plan.dynamodb_plan.id

  selection_tag {
    type  = "STRINGEQUALS"
    key   = local.dynamodb_backup_tag
    value = "true"
  }

}

data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["backup.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}
resource "aws_iam_role" "back_role" {
  name               = "back-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

resource "aws_iam_role_policy_attachment" "backup_policy" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSBackupServiceRolePolicyForBackup"
  role       = aws_iam_role.back_role.name
}