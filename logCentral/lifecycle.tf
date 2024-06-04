
resource "aws_s3_bucket_lifecycle_configuration" "bucket-config" {
  bucket = aws_s3_bucket.log_central_bucket.id

  rule {
    id = "log"

    expiration {
      days = 120
    }

    #filter {
    #  and {
    #    prefix = "log-central-ldj"
    #
    #    #tags = {
    #    #  rule      = "log"
    #    #  autoclean = "true"
    #    #}
    #  }
    #}

    status = "Enabled"

    transition {
      days          = 30
      storage_class = "STANDARD_IA"
    }

    transition {
      days          = 60
      storage_class = "GLACIER"
    }
  }
  
  /*
  rule {
    id = "tmp"

    filter {
      prefix = "tmp/"
    }

    expiration {
      date = "2023-01-13T00:00:00Z"
    }

    status = "Enabled"
  }*/
}