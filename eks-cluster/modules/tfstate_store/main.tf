locals {
  backend_bucket_name    = var.backend_bucket_name
  backend_ddb_table_name = var.backend_ddb_table_name
}


resource "aws_s3_bucket" "tf_state" { # State를 저장하는 S3 Bucket 생성
  bucket = local.backend_bucket_name
}


resource "aws_s3_bucket_versioning" "tf_state" { # 버전 관리 활성화
  bucket = aws_s3_bucket.tf_state.id

  versioning_configuration {
    status = "Enabled"
  }
}

# State 파일 암호화
resource "aws_s3_bucket_server_side_encryption_configuration" "tf_state" {
  bucket = aws_s3_bucket.tf_state.id

  rule {
    bucket_key_enabled = false

    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# 동시 접근 제어를 위한 lock 데이터를 저장할 DDB 테이블 생성
resource "aws_dynamodb_table" "tf_lock" {
  name         = local.backend_ddb_table_name
  depends_on   = [aws_s3_bucket.tf_state]
  hash_key     = "LockID"
  billing_mode = "PAY_PER_REQUEST"

  attribute {
    name = "LockID"
    type = "S"
  }
}
