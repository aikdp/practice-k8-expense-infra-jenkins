module "bastion_sg_id"{
    # source = "../../01-sg-module-tf"
    source = "git::https://github.com/aikdp/01-sg-module-tf.git?ref=main"
    project = var.my_project
    environment = var.my_env
    sg_name = var.bastion_sg
    vpc_id = local.my_vpc_id
}

module "mysql_sg_id"{
    # source = "../../01-sg-module-tf"
    source = "git::https://github.com/aikdp/01-sg-module-tf.git?ref=main"
    project = var.my_project
    environment = var.my_env
    sg_name = var.mysql_sg
    vpc_id = local.my_vpc_id
}

module "worker_node_sg_id"{
    # source = "../../01-sg-module-tf"
    source = "git::https://github.com/aikdp/01-sg-module-tf.git?ref=main"
    project = var.my_project
    environment = var.my_env
    sg_name = var.worker_node_sg
    vpc_id = local.my_vpc_id
}

module "eks_control_plane_sg_id"{
    # source = "../../01-sg-module-tf"
    source = "git::https://github.com/aikdp/01-sg-module-tf.git?ref=main"
    project = var.my_project
    environment = var.my_env
    sg_name = var.eks_control_plane_sg
    vpc_id = local.my_vpc_id
}

module "web_alb_sg_id"{
    # source = "../../01-sg-module-tf"
    source = "git::https://github.com/aikdp/01-sg-module-tf.git?ref=main"
    project = var.my_project
    environment = var.my_env
    sg_name = var.web_alb_sg
    vpc_id = local.my_vpc_id
}


#SG Rules:
#1.web_alb_public
#2. bastion_public (Here, employee  Ip)
#3. mysql_worker_node
#4. mysql_bastion
#5. worker_node_eks_control_plane
#6. eks_control_plane_worker_node
#7. worker_node_web_alb
#8. worker_node_bastion
#9. eks_control_plane_bastion
#10 nworker_node_vpc_cidr



#1.web_alb_public
resource "aws_security_group_rule" "web_alb_public" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = module.web_alb_sg_id.sg_id
}
#2 bastion_public
resource "aws_security_group_rule" "bastion_public" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = module.bastion_sg_id.sg_id
}

#3. mysql_worker_node
resource "aws_security_group_rule" "mysql_worker_node" {
  type              = "ingress"
  from_port         = 3306
  to_port           = 3306
  protocol          = "tcp"
  source_security_group_id       = module.worker_node_sg_id.sg_id
  security_group_id = module.mysql_sg_id.sg_id
}

#4. mysql_bastion

resource "aws_security_group_rule" "mysql_bastion" {
  type              = "ingress"
  from_port         = 3306
  to_port           = 3306
  protocol          = "tcp"
  source_security_group_id       = module.bastion_sg_id.sg_id
  security_group_id = module.mysql_sg_id.sg_id
}

##5. worker_node_eks_control_plane
resource "aws_security_group_rule" "worker_node_eks_control_plane" {
  type              = "ingress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  source_security_group_id       = module.eks_control_plane_sg_id.sg_id
  security_group_id = module.worker_node_sg_id.sg_id
}

#6. eks_control_plane_worker_node
resource "aws_security_group_rule" "eks_control_plane_worker_node" {
  type              = "ingress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  source_security_group_id       = module.worker_node_sg_id.sg_id
  security_group_id = module.eks_control_plane_sg_id.sg_id
}

#7. worker_node_web_alb
resource "aws_security_group_rule" "worker_node_web_alb" {
  type              = "ingress"
  from_port         = 30000
  to_port           = 32767
  protocol          = "tcp"
  source_security_group_id       = module.web_alb_sg_id.sg_id
  security_group_id = module.worker_node_sg_id.sg_id
}

#8. worker_node_bastion
resource "aws_security_group_rule" "worker_node_bastion" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  source_security_group_id       = module.bastion_sg_id.sg_id
  security_group_id = module.worker_node_sg_id.sg_id
}

#9. eks_control_plane_bastion
resource "aws_security_group_rule" "eks_control_plane_bastion" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  source_security_group_id       = module.bastion_sg_id.sg_id
  security_group_id = module.eks_control_plane_sg_id.sg_id
}

#10. Node to Node Comm (Pod to pod communication, Eg: pod-1 in Node-1 and Pod-2 is in Node-2, b/w the communication, we are allowing all vpc_cidrs)
resource "aws_security_group_rule" "worker_node_vpc_cidr" {
  type              = "ingress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["10.0.0.0/16"]
  security_group_id = module.worker_node_sg_id.sg_id
}