
variable "my_project" {
  default = "expense"
}

variable "my_env" {
  default = "dev"
}

variable "bastion_sg"{
    default = "bastion"
}

variable "mysql_sg"{
    default = "mysql"
}


variable "web_alb_sg"{
  default = "web-alb"
}


variable "worker_node_sg" {
  default = "node"
}

variable "eks_control_plane_sg"{
  default = "control-plane"
}


variable "common_tags" {
  type = map(any)
  default = {
    Project     = "expense"
    Module      = "sg"
    Terraform   = "true"
    environment = "dev"
  }
}

