output "ecr_repository_arn" {
  value = "${aws_ecr_repository.trendyol_jenkins.arn}"
}

output "ecr_repository_register_id" {
  value = "${aws_ecr_repository.trendyol_jenkins.registry_id}"
}

output "ecr_repository_url" {
  value = "${aws_ecr_repository.trendyol_jenkins.repository_url}"
}

output "ecr_repository_name" {
  value = "${aws_ecr_repository.trendyol_jenkins.name}"
}
