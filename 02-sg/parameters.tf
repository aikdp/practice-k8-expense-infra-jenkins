#bastion_sg_id
resource "aws_ssm_parameter" "bastion_sg_id" {
  name        = "/${var.my_project}/${var.my_env}/bastion_sg_id"
  description = "The parameter description"
  type        = "String"
  value       = module.bastion_sg_id.sg_id
}

#mysql_sg_id
resource "aws_ssm_parameter" "mysql_sg_id" {
  name        = "/${var.my_project}/${var.my_env}/mysql_sg_id"
  description = "The parameter description"
  type        = "String"
  value       = module.mysql_sg_id.sg_id
}

#web_alb_sg_id
resource "aws_ssm_parameter" "web_alb_sg_id" {
  name        = "/${var.my_project}/${var.my_env}/web_alb_sg_id"
  description = "The parameter description"
  type        = "String"
  value       = module.web_alb_sg_id.sg_id
}

#eks_control_plane_sg_id
resource "aws_ssm_parameter" "eks_control_plane_sg_id" {
  name        = "/${var.my_project}/${var.my_env}/eks_control_plane_sg_id"
  description = "The parameter description"
  type        = "String"
  value       = module.eks_control_plane_sg_id.sg_id
}

#worker_node_sg_id
resource "aws_ssm_parameter" "worker_node_sg_id" {
  name        = "/${var.my_project}/${var.my_env}/worker_node_sg_id"
  description = "The parameter description"
  type        = "String"
  value       = module.worker_node_sg_id.sg_id
}



