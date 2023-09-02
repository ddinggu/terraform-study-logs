locals {
  frontend_bucket_name = var.frontend_bucket_name
}

resource "aws_s3_bucket" "static_web_hosting_bucket" {
  bucket = local.frontend_bucket_name
}

resource "aws_s3_bucket_public_access_block" "static_web_hosting_bucket" {
  bucket = aws_s3_bucket.static_web_hosting_bucket.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_website_configuration" "static_web_hosting_bucket" {
  bucket = aws_s3_bucket.static_web_hosting_bucket.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "index.html"
  }
}

resource "aws_s3_bucket_ownership_controls" "static_web_hosting_bucket" {
  bucket = aws_s3_bucket.static_web_hosting_bucket.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

// terraform에서 실제 S3의 ACL 설정값이 제거되지 않음으로 유의(tfstate에선 제거됨)
// https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_acl
resource "aws_s3_bucket_acl" "static_web_hosting_bucket" {
  depends_on = [
    aws_s3_bucket_ownership_controls.static_web_hosting_bucket,
    aws_s3_bucket_public_access_block.static_web_hosting_bucket,
  ]

  bucket = aws_s3_bucket.static_web_hosting_bucket.id
  acl    = "public-read"
}

resource "aws_s3_bucket_policy" "allow_public_s3_read" {
  depends_on = [aws_s3_bucket.static_web_hosting_bucket]

  bucket = aws_s3_bucket.static_web_hosting_bucket.id
  policy = data.aws_iam_policy_document.allow_public_s3_read.json
}

data "aws_iam_policy_document" "allow_public_s3_read" {
  statement {
    sid    = "PublicReadGetObject"
    effect = "Allow"

    actions = [
      "s3:GetObject",
    ]

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    resources = [
      "${aws_s3_bucket.static_web_hosting_bucket.arn}/*"
    ]
  }
}
