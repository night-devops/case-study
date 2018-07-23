provider "aws" {
  profile = "${var.profile}"
  region  = "us-east-1"
}

data "aws_iam_policy" "full_ecr_access_policy" {
  arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryFullAccess"
}

resource "aws_iam_user" "user" {
  name = "${var.iam_username}"
}

resource "aws_iam_access_key" "user_key" {
  user = "${aws_iam_user.user.name}"
}

resource "aws_iam_user_policy_attachment" "full-ecr-attach" {
  user       = "${aws_iam_user.user.name}"
  policy_arn = "${data.aws_iam_policy.full_ecr_access_policy.arn}"

  # Setting trendyol-ecr-user aws_access_key_id and trendyol-ecr-user aws_secret_access_key as environment variables 
  provisioner "local-exec" {
    command = "sudo chown -R vagrant /home/vagrant/.aws/"
  }

  provisioner "local-exec" {
    command = "aws configure set aws_access_key_id ${aws_iam_access_key.user_key.id} --profile trendyol-ecr"
  }

  provisioner "local-exec" {
    command = "aws configure set aws_secret_access_key ${aws_iam_access_key.user_key.secret} --profile trendyol-ecr"
  }

  provisioner "local-exec" {
    command = "aws configure set profile.trendyol-ecr.region us-east-1"
  }

  provisioner "local-exec" {
    command = "aws configure set profile.trendyol-ecr.output json"
  }
}
