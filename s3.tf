resource "aws_s3_bucket_policy" "allow-upload-and-download" {
  bucket = aws_s3_bucket.backups.id

  policy = jsonencode({
    Version = "2012-10-17"
    Id      = "UploadPolicy"
    Statement = [
      {
        Sid       = "IPAllow"
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:PutObject"
        Resource = [
          aws_s3_bucket.backups.arn,
          "${aws_s3_bucket.backups.arn}/*",
        ]
        Condition = {
          IpAddress = {
            "aws:SourceIp" = [
              openstack_compute_instance_v2.valhalla.access_ip_v4,
              "51.91.210.24"
            ]
          }
        }
      },
      {
        Sid       = "IPAllow"
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource = [
          "${aws_s3_bucket.backups.arn}/valheim.tar.gz",
        ]
      },
    ]
  })
}

resource "aws_s3_bucket_policy" "allow-upload-and-downloadnext" {
  bucket = aws_s3_bucket.next.id

  policy = jsonencode({
    Version = "2012-10-17"
    Id      = "UploadPolicy"
    Statement = [
      {
        Sid       = "IPAllow"
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:PutObject"
        Resource = [
          aws_s3_bucket.next.arn,
          "${aws_s3_bucket.next.arn}/*",
        ]
        Condition = {
          IpAddress = {
            "aws:SourceIp" = [
              openstack_compute_instance_v2.valhalla.access_ip_v4,
              "51.91.210.24"
            ]
          }
        }
      },
      {
        Sid       = "IPAllow"
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource = [
          "${aws_s3_bucket.next.arn}/valheim.tar.gz",
        ]
      },
    ]
  })
}

resource "aws_s3_bucket" "backups" {
  bucket = "${var.route53_subdomain}-backups"

  versioning {
    enabled = true
  }

  lifecycle_rule {
    abort_incomplete_multipart_upload_days = 0
    enabled                                = true
    id                                     = "kill-after-60-days"
    tags                                   = {}
    noncurrent_version_expiration {
      days = 60
    }
  }
}

resource "aws_s3_bucket" "next" {
  bucket = "${var.route53_subdomain}-backups-next"

  versioning {
    enabled = true
  }

  lifecycle_rule {
    abort_incomplete_multipart_upload_days = 0
    enabled                                = true
    id                                     = "kill-after-10-days"
    tags                                   = {}
    noncurrent_version_expiration {
      days = 10
    }
  }
}
