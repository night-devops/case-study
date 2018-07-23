variable "profile" {
  default = "trendyol-kops"
}

variable "iam_username" {
  default = "trendyol-ecr"
}

/*NOTE: You should set user_name when terraform apply - like  terraform apply -var 'user_name=barisgece'*/
variable "user_name" {
  default = "unknown_user"
}
