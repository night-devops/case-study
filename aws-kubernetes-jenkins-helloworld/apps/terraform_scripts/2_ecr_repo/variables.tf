variable "profile" {
  default = "trendyol-ecr"
}

variable "ecr_repo_name" {
  default = "trendyol-jenkins"
}

/*NOTE: You should set user_name when terraform apply - like  terraform apply -var 'user_name=barisgece'*/
variable "user_name" {
  default = "unknown_user"
}
