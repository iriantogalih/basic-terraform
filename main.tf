provider "aws" {
  region     = "ap-southeast-1"  
} 

locals {
  ingress_rule = [{
    port = 80
    description = "Ingress rule for port 80"
  },
  {
    port = 22
    description = "Ingress rule for port 22"
  },
  {
    port = 433
    description = "Ingress rule for port 433"
  }]
}


resource "aws_vpc" "staging-vpc" { 
  
  cidr_block       = "10.5.0.0/16"
  instance_tenancy = "default"

  tags = {    
    Name = "${var.environment_name}-vpc-tag"
  } 
}

resource "aws_subnet" "staging-subnet-1" {
  vpc_id     = aws_vpc.staging-vpc.id
  cidr_block = "10.5.1.0/24"

  tags = {
    Name = "${var.environment_name}-subnet-tag"
  }
}


resource "aws_instance" "ec2_example" {
    
    ami = "ami-003c463c8207b4dfa"  
    instance_type = var.instance_type
    key_name = "aws-demo-key"
    vpc_security_group_ids = [aws_security_group.main.id]
    subnet_id = aws_subnet.staging-subnet-1.id 
    //count = var.instance_count
    associate_public_ip_address = var.enable_public

    user_data = file("userdata.tpl")

    tags = {
      Name = "${var.environment_name} - terraform EC2"
    } 
}

resource "aws_security_group" "main" {
   name        = "allow_tls"
   description = "Allow TLS inbound traffic and all outbound traffic"
   vpc_id      = aws_vpc.staging-vpc.id

   dynamic "ingress" {
      for_each = local.ingress_rule

      content {
        description = ingress.value.description
        from_port   = ingress.value.port
        to_port     = ingress.value.port
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
      }
   }

   tags = {
     Name = "${var.environment_name} - Security Group"
   }
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4" {
  security_group_id = aws_security_group.main.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}


resource "aws_key_pair" "deployer" {
  key_name   = "aws-demo-key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCmSKz+QIYx1eHJYBbb6/KIr015ebJPyhxV5FDVxMSBt0T6rEWTg6b7hBygUwyeDHDkPN7CA6bJXBJnPW0uwqLSn2Bb7RVHHG+F5muI0HUCgrDWDe10OeHiwCW0icbgBrnlWm6xY/yJElLmNC0fJGYi2I2I7ag56rnREtvHKKY7GpV2IuaF33BVXhQO1O8fE6ty9J9gtrvOs8iYvw2j9Ks0cwQ3wMUf//b1HgPtmy5tn1seXaxagiA62/J5K85PfgZjR32BtSuLg/0gxBAdENhPbPhanBuX5Jt9mJTLM4vbqsMK34GeXGUwsrEqXE3GsAXThVK+Hqiw+hlRxv8xB1Xv galih@galihisaputro"
}


/*
resource "aws_vpc_security_group_ingress_rule" "allow_ssh_ipv4" {
  security_group_id = aws_security_group.main.id
  cidr_ipv4         = aws_vpc.staging-vpc.cidr_block
  from_port         = 22
  ip_protocol       = "TCP"
  to_port           = 22
}

resource "aws_vpc_security_group_ingress_rule" "allow_http_ipv4" {
  security_group_id = aws_security_group.main.id
  cidr_ipv4         = aws_vpc.staging-vpc.cidr_block
  from_port         = 80
  ip_protocol       = "TCP"
  to_port           = 80
}

*/


//resource  "aws_iam_user" "example"{
//  count = length(var.user_name)
//  name = var.user_name[count.index]
//}


  

