locals {
  session_table_name = "sessions"
}

resource "aws_dynamodb_table" "session_table" {
  name           = local.session_table_name
  billing_mode   = "PROVISIONED"
  read_capacity  = 10
  write_capacity = 10
  hash_key       = "id"

  attribute {
    name = "id"
    type = "S"
  }

  tags = {
    owner = "ldj"
    Name        = "session-table"
    Environment = "production"
  }
}

resource "aws_appautoscaling_target" "dynamodb_table_read_target_session" {
  depends_on = [ aws_dynamodb_table.session_table ]
  max_capacity       = 10
  min_capacity       = 1
  resource_id        = "table/${local.session_table_name}"
  scalable_dimension = "dynamodb:table:ReadCapacityUnits"
  service_namespace  = "dynamodb"
}

resource "aws_appautoscaling_policy" "dynamodb_table_read_policy_session" {
  name               = "DynamoDBReadCapacityUtilization:${aws_appautoscaling_target.dynamodb_table_read_target_session.resource_id}"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.dynamodb_table_read_target_session.resource_id
  scalable_dimension = aws_appautoscaling_target.dynamodb_table_read_target_session.scalable_dimension
  service_namespace  = aws_appautoscaling_target.dynamodb_table_read_target_session.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "DynamoDBReadCapacityUtilization"
    }

    target_value = 70
  }
}


resource "aws_appautoscaling_target" "dynamodb_table_write_target_session" {
  depends_on = [ aws_dynamodb_table.session_table ]
  max_capacity       = 10
  min_capacity       = 1
  resource_id        = "table/${local.session_table_name}"
  scalable_dimension = "dynamodb:table:WriteCapacityUnits"
  service_namespace  = "dynamodb"
}

resource "aws_appautoscaling_policy" "dynamodb_table_write_policy_session" {
  name               = "DynamoDBWriteCapacityUtilization:${aws_appautoscaling_target.dynamodb_table_write_target_session.resource_id}"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.dynamodb_table_write_target_session.resource_id
  scalable_dimension = aws_appautoscaling_target.dynamodb_table_write_target_session.scalable_dimension
  service_namespace  = aws_appautoscaling_target.dynamodb_table_write_target_session.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "DynamoDBWriteCapacityUtilization"
    }

    target_value = 70
  }
}