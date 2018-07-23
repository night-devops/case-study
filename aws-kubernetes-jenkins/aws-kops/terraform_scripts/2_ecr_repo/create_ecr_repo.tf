provider "aws" {
  profile = "${var.profile}"
  region  = "us-east-1"
}

resource "aws_ecr_repository" "trendyol_jenkins" {
  name = "${var.ecr_repo_name}"
}

resource "aws_ecr_lifecycle_policy" "jenkins_baris_ecr_lifecycle_policy" {
  repository = "${aws_ecr_repository.trendyol_jenkins.name}"

  policy = <<EOF
{
    "rules": [
        {
            "rulePriority": 1,
            "description": "Expire images older than 14 days",
            "selection": {
                "tagStatus": "untagged",
                "countType": "sinceImagePushed",
                "countUnit": "days",
                "countNumber": 14
            },
            "action": {
                "type": "expire"
            }
        }
    ]
}
EOF

  provisioner "local-exec" {
    command = "echo sudo $$(aws ecr get-login --no-include-email --region us-east-1 --profile trendyol-ecr) >> docker_login_key.txt"
  }

  provisioner "local-exec" {
    command = "$$(cat docker_login_key.txt)"
  }
}
