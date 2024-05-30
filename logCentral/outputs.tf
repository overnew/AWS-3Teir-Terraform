output "log_central_bucket_arn" {
  value = aws_s3_bucket.log_central_bucket.arn
}

output "log_central_bucket_id" {
  value = aws_s3_bucket.log_central_bucket.id
}


output "log_central_bucket" {
  value = aws_s3_bucket.log_central_bucket.bucket
}
