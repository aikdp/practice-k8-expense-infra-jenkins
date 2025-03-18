
variable "project" {
  default = "expense"
}

variable "environment" {
  default = "dev"
}

variable "app_name"{
    default = "eks"
}

variable "common_tags" {
  type = map
  default = {
    Project     = "expense"
    Module      = "eks"
    Terraform   = "true"
    environment = "dev"
  }
}
