# Region
variable "region" {
  default = "us-east-1"
}

variable "env_tag" {
  description = "Environment tag"
  default = "dev"
}

variable "ami_id" {
  description = "Ubuntu 18.04 in us-east-1"
  default = "ami-0747bdcabd34c712a"
}