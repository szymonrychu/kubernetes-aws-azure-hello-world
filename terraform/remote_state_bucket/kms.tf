resource "aws_kms_key" "this" {
  description             = "" // TODO: add descriptions
  deletion_window_in_days = var.kms_key_deletion_window_in_days
  enable_key_rotation     = true
  tags                    = var.tags
}

resource "aws_kms_alias" "this" {
  name          = "alias/${var.kms_key_alias}"
  target_key_id = aws_kms_key.this.key_id
}
