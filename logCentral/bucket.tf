#s3 선언
resource "aws_s3_bucket" "log_central_bucket" {
  bucket        = "log-central-ldj-${random_string.bucket_random_id.id}"
  force_destroy = true
}

resource "aws_s3_bucket_ownership_controls" "log_central_bucket_ownership_control" {
  bucket = aws_s3_bucket.log_central_bucket.id
  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

resource "aws_s3_bucket_public_access_block" "log_central_bucket_public_access_block" {
  bucket = aws_s3_bucket.log_central_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "random_string" "bucket_random_id" {
  length  = 8
  upper   = false
  lower   = true
  numeric  = true
  special = false
}