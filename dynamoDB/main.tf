resource "aws_dynamodb_table" "user_table" {
  name           = "user_table2"
  billing_mode   = "PROVISIONED"
  read_capacity  = 10
  write_capacity = 10
  hash_key       = "email"
  #range_key      = "GameTitle"

  point_in_time_recovery{
    enabled = true
  }

  attribute {
    name = "email"
    type = "S"
  }

  attribute {
    name = "id"
    type = "S"
  }

  attribute {
    name = "name"
    type = "S"
  }

  attribute {
    name = "password"
    type = "S"
  }

  #ttl {
  #  attribute_name = "TimeToExist"
  #  enabled        = false
  #}

  tags = {
    Name        = "dynamodb-table-1"
    Environment = "production"
  }
}