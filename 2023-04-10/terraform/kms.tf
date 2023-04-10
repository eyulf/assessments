resource "aws_kms_key" "main" {
  description             = "KMS Key for ${local.environment}"
  deletion_window_in_days = 7
  enable_key_rotation     = true
  policy                  = data.aws_iam_policy_document.kms_main.json
}

data "aws_iam_policy_document" "kms_main" {
  statement {
    sid       = "AllowAdminAccessToKey"
    effect    = "Allow"
    actions   = ["kms:*"]
    resources = ["*"]

    principals {
      type = "AWS"
      identifiers = ["arn:aws:iam::${local.account_id}:root"]
    }
  }

  #checkov:skip=CKV_AWS_109:Skipping Constraints for now
  #checkov:skip=CKV_AWS_111:Skipping Constraints for now
}

resource "aws_kms_alias" "cicd" {
  name          = "alias/${local.environment}-cicd"
  target_key_id = aws_kms_key.main.key_id
}
