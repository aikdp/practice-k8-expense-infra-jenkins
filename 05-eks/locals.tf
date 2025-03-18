locals {
  resource_name = "${var.project}-${var.environment}-${var.app_name}"
  eks_control_plane_sg_id = data.aws_ssm_parameter.eks_control_plane_sg_id.value
  worker_node_sg_id = data.aws_ssm_parameter.worker_node_sg_id.value
  private_subnet_id = split(",", data.aws_ssm_parameter.private_subnet_ids.value)
  ami_id = data.aws_ami.rhel.id
  my_vpc_id = data.aws_ssm_parameter.vpc_id.value
}