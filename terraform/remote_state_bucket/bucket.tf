resource "aws_s3_bucket" "state" {
  bucket        = var.s3_bucket_name
  force_destroy = var.s3_bucket_force_destroy

  tags = var.tags
}

resource "aws_s3_bucket_policy" "state_force_ssl" {
  bucket = aws_s3_bucket.state.id
  policy = data.aws_iam_policy_document.state_force_ssl.json

  depends_on = [aws_s3_bucket_public_access_block.state]
}

resource "aws_s3_bucket_ownership_controls" "state" {
  bucket = aws_s3_bucket.state.id

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "state" {
  depends_on = [aws_s3_bucket_ownership_controls.state]
  bucket     = aws_s3_bucket.state.id
  acl        = "private"
}

resource "aws_s3_bucket_versioning" "state" {
  bucket = aws_s3_bucket.state.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "state" {
  bucket = aws_s3_bucket.state.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = aws_kms_key.this.arn
    }
  }
}

resource "aws_s3_bucket_public_access_block" "state" {
  bucket                  = aws_s3_bucket.state.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
