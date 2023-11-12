variable "wireguard_server_domain_endpoint" {
  description = "domain endpoint for wireguard server"
  type        = string
}

variable "domain_zone_id" {
  description = "zone id of domain"
  type        = string
}

terraform {
  required_version = ">= 1.5.7"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  cloud {
    organization = "user"

    workspaces {
      name = "wireguard-server"
    }
  }
}

provider "aws" {
  region = local.region
}

locals {
  name               = "personal-wireguard-server"
  region             = "us-east-1"
  instance_type      = "t3.micro"
  instance_profile   = "AmazonSSMRoleForInstancesQuickSetup"
  ami_id             = "ami-053b0d53c279acc90" # ubuntu 22.04 LTS
  existing_vpc_id    = "vpc-0806a23b71bed215a"
  existing_subnet_id = "subnet-032188003e1d4a81b"
  tags = {
    Name = local.name
  }
}

# tfsec:ignore:aws-ec2-no-public-egress-sgr
resource "aws_security_group" "wireguard_sg" {
  name        = "${local.name}-sg"
  description = "WireGuard Security Group"
  vpc_id      = local.existing_vpc_id

  ingress {
    description = "TESTING ALLOW ALL PERSONAL"
    from_port   = 51820
    to_port     = 51820
    protocol    = "udp"
    cidr_blocks = ["136.32.84.4/32"]
  }
  egress {
    description = "needs outbound anywhere as it is a vpn"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = local.tags
}

# tfsec:ignore:aws-ec2-enforce-http-token-imds
# tfsec:ignore:aws-ec2-enable-at-rest-encryption
module "ec2" {

  source                      = "git::https://github.com/terraform-aws-modules/terraform-aws-ec2-instance.git?ref=6c13542c52e4ed87ca959b2027c85146e8548ac6"
  name                        = local.name
  instance_type               = local.instance_type
  key_name                    = "${local.name}-ssh-key"
  ami                         = local.ami_id
  monitoring                  = false
  subnet_id                   = local.existing_subnet_id
  create_iam_instance_profile = false
  iam_instance_profile        = local.instance_profile
  vpc_security_group_ids      = [aws_security_group.wireguard_sg.id]

  root_block_device = [
    {
      encrypted = true
    }
  ]

  metadata_options = {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 8
    instance_metadata_tags      = "enabled"
  }
  user_data = <<-EOF
              #!/bin/bash
              sudo apt-get update && sudo apt upgrade -y
              sudo snap refresh
              EOF
  tags      = local.tags
}

# Route 53 Record
resource "aws_route53_record" "wireguard_record" {
  zone_id = var.domain_zone_id
  name    = var.wireguard_server_domain_endpoint
  type    = "A"
  ttl     = "300"
  records = [module.ec2.public_ip]
}
