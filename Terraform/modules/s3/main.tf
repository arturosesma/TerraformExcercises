resource "aws_s3_bucket" "arturo" {
  bucket = var.bucket_name

  tags = {
    Name = var.bucket_name
  }
}

resource "aws_s3_bucket_versioning" "arturo" {
  bucket = aws_s3_bucket.arturo.id

  versioning_configuration {
    status = var.versioning_enabled ? "Enabled" : "Suspended"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "arturo" {
  bucket = aws_s3_bucket.arturo.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
    bucket_key_enabled = true
  }
}

# Block all public access — objects are only reachable via IAM or pre-signed URLs
resource "aws_s3_bucket_public_access_block" "arturo" {
  bucket = aws_s3_bucket.arturo.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_lifecycle_configuration" "arturo" {
  bucket = aws_s3_bucket.arturo.id

  depends_on = [aws_s3_bucket_versioning.arturo]

  rule {
    id     = "expire-noncurrent-versions"
    status = "Enabled"

    noncurrent_version_expiration {
      noncurrent_days = var.noncurrent_version_expiration_days
    }

    abort_incomplete_multipart_upload {
      days_after_initiation = 7
    }
  }
}
