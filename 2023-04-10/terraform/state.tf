resource "aws_s3_bucket" "terraform_state" {
  bucket_prefix = "terraform-${local.environment}-"

  #checkov:skip=CKV_AWS_18:Access Logging not required
  #checkov:skip=CKV_AWS_19:Data is encrypted with Default key
  #checkov:skip=CKV_AWS_21:Versioning is enabled below
  #checkov:skip=CKV_AWS_144:Cross-region replication not required
  #checkov:skip=CKV_AWS_145:Choosing not to use KMS to encrypt
}

resource "aws_s3_bucket_server_side_encryption_configuration" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_versioning" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  rule {
    id     = "terraform"
    status = "Enabled"

    noncurrent_version_expiration {
      noncurrent_days = 7
    }

    abort_incomplete_multipart_upload {
      days_after_initiation = 7
    }
  }
}

resource "aws_s3_bucket_public_access_block" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_dynamodb_table" "terraform_statelock" {
  name           = "terraform-lock"
  read_capacity  = 1
  write_capacity = 1
  hash_key       = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  #checkov:skip=CKV_AWS_28:Backup not required for TF State Lock
  #checkov:skip=CKV_AWS_119:KMS Encryption not required for TF State Lock
  #checkov:skip=CKV2_AWS_16:Auto Scaling not required for TF State Lock
}

/*
terraform {
  # You can't use interpolations for this
  backend "s3" {
    bucket         = "terraform-assessment-20230410015704366300000002"
    key            = "terraform/main"
    region         = "ap-southeast-2"
    encrypt        = "true"
    dynamodb_table = "terraform-lock"
  }
}
*/
