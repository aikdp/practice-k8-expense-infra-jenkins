#Instance
module "bastion" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  ami = local.ami_id
  name = local.resource_name

  instance_type          = "t3.micro"
 
  vpc_security_group_ids = [local.bastion_sg_id]
  subnet_id              = local.public_subnet_id

  user_data = file("docker.sh")
  
    #  root_block_device {
    #     volume_type = "gp3"
    #     volume_size = 50
    #     delete_on_termination  = true
    # }
  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}