resource "aws_s3_bucket" "s3bucket" {
  bucket = "${var.env}-s3"
  acl    = "private"

  tags {
    Name        = "${var.env}-s3"
    stack_name  = "${var.env}"
  }
}

resource "aws_s3_bucket_policy" "s3bucket" {
  bucket = "${aws_s3_bucket.s3bucket.id}"
  policy =<<POLICY
{
  "Version": "2008-10-17",
  "Statement": [
    {
      "Sid": "AllowPublicRead",
      "Effect": "Allow",
      "Principal": {
        "AWS": "*"
      },
      "Action": "s3:GetObject",
      "Resource": "arn:aws:s3:::${var.env}-s3/*"
    }
  ]
}
POLICY
}

resource "aws_s3_bucket" "s3private" {
  bucket = "${var.env}-s3-private"
  acl    = "private"

  tags {
    Name        = "${var.env}-s3-private"
    stack_name  = "${var.env}"
  }
}

resource "aws_s3_bucket" "hbase_backups" {
  bucket = "${var.env}-hbase-backups"
  acl    = "private"

  tags {
    Name        = "${var.env}-hbase-backups"
    stack_name  = "${var.env}"
  }
}
