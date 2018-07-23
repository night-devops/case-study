provider "aws" {
  profile = "${var.profile}"
  region  = "us-east-1"
}

resource "aws_s3_bucket" "state_store" {
  bucket        = "${var.bucket_name}-${var.env}-state-store"
  acl           = "private"
  force_destroy = true

  versioning {
    enabled = true
  }

  tags {
    Name        = "${var.bucket_name}-${var.env}-state-store"
    Environment = "${var.env}"
    Terraformed = "true"
  }
}
