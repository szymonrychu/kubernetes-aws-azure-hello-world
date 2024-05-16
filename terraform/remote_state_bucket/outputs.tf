output "bucket_name" {
  value = aws_s3_bucket.state.bucket
}

output "dynamo_table" {
  value = aws_dynamodb_table.lock.name
}
