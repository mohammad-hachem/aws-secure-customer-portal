resource "aws_s3_bucket" "portal_data" {
  bucket = "securanova-portal-data-${data.aws_caller_identity.current.account_id}"

  tags = {
    Name        = "securanova-portal-data"
    Project     = "aws-secure-portal"
    Environment = "lab"
    ManagedBy   = "Terraform"
  }
}

resource "aws_s3_bucket_ownership_controls" "portal_data" {
  bucket = aws_s3_bucket.portal_data.id

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

resource "aws_s3_bucket_public_access_block" "portal_data" {
  bucket = aws_s3_bucket.portal_data.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "portal_data" {
  bucket = aws_s3_bucket.portal_data.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "portal_data" {
  bucket = aws_s3_bucket.portal_data.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }

    bucket_key_enabled       = false
    blocked_encryption_types = ["SSE-C"]
  }
}

data "aws_iam_policy_document" "portal_data_bucket" {
  statement {
    sid    = "DenyInsecureTransport"
    effect = "Deny"

    actions = ["s3:*"]

    resources = [
      aws_s3_bucket.portal_data.arn,
      "${aws_s3_bucket.portal_data.arn}/*"
    ]

    principals {
      type        = "*"
      identifiers = ["*"]
    }

    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values   = ["false"]
    }
  }
}

resource "aws_s3_bucket_policy" "portal_data" {
  bucket = aws_s3_bucket.portal_data.id
  policy = data.aws_iam_policy_document.portal_data_bucket.json
}

data "aws_iam_policy_document" "app_s3_data_access" {
  statement {
    sid    = "ListPortalData"
    effect = "Allow"

    actions = ["s3:ListBucket"]

    resources = [
      aws_s3_bucket.portal_data.arn
    ]

    condition {
      test     = "StringLike"
      variable = "s3:prefix"

      values = [
        "portal",
        "portal/*"
      ]
    }
  }

  statement {
    sid    = "ReadWritePortalData"
    effect = "Allow"

    actions = [
      "s3:GetObject",
      "s3:PutObject"
    ]

    resources = [
      "${aws_s3_bucket.portal_data.arn}/portal/*"
    ]
  }
}

resource "aws_iam_role_policy" "app_s3_data_access" {
  name   = "aws-secure-portal-s3-data-access"
  role   = aws_iam_role.app.name
  policy = data.aws_iam_policy_document.app_s3_data_access.json
}
