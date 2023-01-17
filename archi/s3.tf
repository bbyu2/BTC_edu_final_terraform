# 로그관리용
resource "aws_s3_bucket" "log-bucket" {
  bucket_prefix = "abcbit-log-"

  tags = {
    Name = "abc-log-bucket"
  }
}

resource "aws_s3_bucket_acl" "s3-log-acl" {
  bucket = aws_s3_bucket.log-bucket.id
  acl    = "private"
}

resource "aws_s3_bucket_lifecycle_configuration" "logs-mng" {
  bucket = aws_s3_bucket.log-bucket.id

  rule {
    id = "logs-mng"

    status = "Enabled"

    #S3 객체가 지정된 스토리지 클래스로 전환되는 시기 설정
    transition {
      days          = 30
      storage_class = "GLACIER"
    }

  }
}