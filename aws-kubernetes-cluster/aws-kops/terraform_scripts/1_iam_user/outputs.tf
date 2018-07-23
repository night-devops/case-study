output "access_key" {
  value = "${aws_iam_access_key.user_key.id}"
}

output "access_secret_key" {
  value = "${aws_iam_access_key.user_key.secret}"
}
