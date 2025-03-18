#SG_id
data "aws_ssm_parameter" "ek"{
    name = "/${var.project}/${var.environment}/bastion_sg_id"
}



data "aws_ssm_parameter" "private_subnet_ids"{
    name = "/${var.project}/${var.environment}/private_subnet_ids"
}

data "aws_ssm_parameter" "vpc_id"{
    name = "/${var.project}/${var.environment}/vpc_id"
}
data "aws_ssm_parameter" "eks_control_plane_sg_id"{
    name = "/${var.project}/${var.environment}/eks_control_plane_sg_id"
}

data "aws_ssm_parameter" "worker_node_sg_id"{
    name = "/${var.project}/${var.environment}/worker_node_sg_id"
}



#devops-practice
data "aws_ami" "rhel" {

  most_recent      = true

  owners           = ["973714476881"]

  filter {
    name   = "name"
    values = ["RHEL-9-DevOps-Practice"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}