#s3 선언
resource "aws_s3_bucket" "log_central_bucket" {
  bucket        = "log-central-ldj-${random_string.bucket_random_id.id}"
  force_destroy = true
}

resource "aws_s3_bucket_ownership_controls" "log_central_bucket_ownership_control" {
  bucket = aws_s3_bucket.log_central_bucket.id
  rule {
    object_ownership = "ObjectWriter"#"BucketOwnerEnforced"
  }
}

resource "aws_s3_bucket_public_access_block" "log_central_bucket_public_access_block" {
  bucket = aws_s3_bucket.log_central_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}


resource "aws_s3_bucket_policy" "s3_example_bucket_policy" {
  bucket = aws_s3_bucket.log_central_bucket.id
   policy = jsonencode({
    "Version": "2012-10-17",
        "Statement": [
           {
            "Effect": "Allow",
            "Principal": {
                "Service": ["osis-pipelines.amazonaws.com","delivery.logs.amazonaws.com", "logs.amazonaws.com","cloudtrail.amazonaws.com"]
            },
            "Action": [
                "s3:GetBucketAcl",
                "s3:PutObject",
                "s3:GetObject",
                "s3:ListBucket"
            ],
            "Resource": [
                "${aws_s3_bucket.log_central_bucket.arn}/*",
                "${aws_s3_bucket.log_central_bucket.arn}",
                "${aws_s3_bucket.log_central_bucket.arn}/cloudtrail",
                "${aws_s3_bucket.log_central_bucket.arn}/config",
				        "${aws_s3_bucket.log_central_bucket.arn}/config/*",
                "${aws_s3_bucket.log_central_bucket.arn}/networkfirewall",
                "${aws_s3_bucket.log_central_bucket.arn}/networkfirewall/AWSLogs/*",                
                "${aws_s3_bucket.log_central_bucket.arn}/networkfirewall/AWSLogs/${data.aws_caller_identity.current.account_id}/*"
                
            ]
        }

         ]
  })

}



resource "random_string" "bucket_random_id" {
  length  = 8
  upper   = false
  lower   = true
  numeric  = true
  special = false
}