variable "profile" {
  default = "trendyol-kops"
}

variable "env" {
  default = "poc"
}

variable "bucket_name" {
  default = "trendyol-aws-k8s"
}

/*NOTE: You should set user_name when terraform apply - like  terraform apply -var 'user_name=barisgece'*/
variable "user_name" {
  default = "unknown_user"
}
