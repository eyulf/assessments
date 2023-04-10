resource "aws_s3_bucket" "codepipeline" {
  bucket_prefix = "codepipeline-${local.environment}-2048-"
}

resource "aws_s3_bucket_server_side_encryption_configuration" "codepipeline" {
  bucket = aws_s3_bucket.codepipeline.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = aws_kms_alias.cicd.target_key_arn
    }
  }
}

resource "aws_s3_bucket_versioning" "codepipeline" {
  bucket = aws_s3_bucket.codepipeline.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "codepipeline" {
  bucket = aws_s3_bucket.codepipeline.id

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

resource "aws_s3_bucket_public_access_block" "codepipeline" {
  bucket = aws_s3_bucket.codepipeline.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_policy" "codepipeline" {
  bucket = aws_s3_bucket.codepipeline.id
  policy = data.aws_iam_policy_document.s3_codepipeline.json
}

data "aws_iam_policy_document" "s3_codepipeline" {
  statement {
    sid    = "AllowCodePipeline"
    effect = "Allow"
    actions = [
      "s3:Get*",
      "s3:Put*",
      "s3:ListBucket"
    ]
    resources = [
      aws_s3_bucket.codepipeline.arn,
      "${aws_s3_bucket.codepipeline.arn}/*"
    ]

    principals {
      type = "AWS"
      identifiers = [aws_iam_role.codepipeline.arn]
    }
  }
}
