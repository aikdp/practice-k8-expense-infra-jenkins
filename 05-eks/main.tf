#create Key 
resource "aws_key_pair" "eks" {
  key_name   = "eks"
  # public_key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICl6tjaPMzCYYR51/5XcWU+0Kx9q6CGV4Vo/ahoQKxLw kdpra@KDP"
  # public_key = file("~/.ssh/openvpn.pub")
  public_key = file("openvpn.pub")
}


#aws eks cluster
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
#   version = "~> 20.0"

  cluster_name    = "${var.project}-${var.environment}"
  cluster_version = "1.32"

    # Optional
  cluster_endpoint_public_access = true #if it is false then we need to access Cluster from VPN

#   bootstrap_self_managed_addons = false
  cluster_addons = {
    coredns                = {}
    eks-pod-identity-agent = {}
    kube-proxy             = {}
    vpc-cni                = {}
  }



  vpc_id                   = local.my_vpc_id
  subnet_ids               = local.private_subnet_id
  control_plane_subnet_ids = local.private_subnet_id

  create_cluster_security_group = false
  cluster_security_group_id = local.eks_control_plane_sg_id

  create_node_security_group = false
  node_security_group_id = local.worker_node_sg_id

  # EKS Managed Node Group(s)
  eks_managed_node_group_defaults = {
    instance_types = ["m6i.large", "m5.large", "m5n.large", "m5zn.large"]
  }

  eks_managed_node_groups = {
    # blue = {
    #   min_size     = 2
    #   max_size     = 10
    #   desired_size = 2

    # #   instance_types = ["t3.large"]
    #   capacity_type  = "SPOT"
    #   iam_role_additional_policies = {  #map(string)  --I have given these ploices to access and create resoureces like, ebs, efs and LB. You can gice in varibles as well, or data sources or resources
    #       AmazonEBSCSIDriverPolicy = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy", 
    #       AmazonEFSCSIDriverPolicy = "arn:aws:iam::aws:policy/service-role/AmazonEFSCSIDriverPolicy",
    #       ElasticLoadBalancingFullAccess = "arn:aws:iam::aws:policy/ElasticLoadBalancingFullAccess"
    #   }
    #   key_name = aws_key_pair.eks.key_name  # you can describe nodes with this key pair
     
    # }
   green = {
      min_size     = 2
      max_size     = 10
      desired_size = 2

    #   instance_types = ["t3.large"]
      capacity_type  = "SPOT"
      
      iam_role_additional_policies = {  #map(string)  --I have given these ploices to access and create resoureces like, ebs, efs and LB. You can gice in varibles as well, or data sources or resources
        AmazonEBSCSIDriverPolicy = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy", 
        AmazonEFSCSIDriverPolicy = "arn:aws:iam::aws:policy/service-role/AmazonEFSCSIDriverPolicy",
        ElasticLoadBalancingFullAccess = "arn:aws:iam::aws:policy/ElasticLoadBalancingFullAccess"
    }
    key_name = aws_key_pair.eks.key_name  #you can exec nodes with this key pair
    }
  }

  # Optional: Adds the current caller identity as an administrator via cluster access entry
    enable_cluster_creator_admin_permissions = true

  tags = merge(
    var.common_tags,
    {
        Name = local.resource_name
    }
  )
}