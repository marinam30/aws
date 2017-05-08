variable "name" { default = "marina-vpc" }

variable "user" {
  description = "marina_securitygroup"
  default = "marina_mcculloch"
}

variable "environment" {
  description = "The name of the environment that the user wants to create."
  default = "devop"
}


provider "aws" {
	region = "eu-west-2"
}

variable "cidr" {
    description = "CIDR for the Public Subnet"
    default = "10.0.0.0/24"
}

resource "aws_instance" "web" {
	count = 3
	vpc_security_group_ids = [
	    "${aws_security_group.web.id}"
	]
   ami = "ami-79e3f71d"
   instance_type = "t2.micro" 
}

resource "aws_instance" "web2" {
	count = 3
	vpc_security_group_ids = [
	    "${aws_security_group.web.id}"
	]
   ami = "ami-79e3f71d"
   instance_type = "t2.micro" 
}

resource "aws_vpc" "marina-vpc" {
  cidr_block           = "${var.cidr}"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags      { Name = "${var.name}" }
  lifecycle { create_before_destroy = true }
}



output "vpc_id"   { value = "${aws_vpc.marina-vpc.id}" }
output "vpc_cidr" { value = "${aws_vpc.marina-vpc.cidr_block}" }

resource "aws_security_group" "web" {
  name = "${var.user}-${var.environment}-web-firewall"
  description = "Firewall rules for the web server."

  ingress {
      from_port = 8080
      to_port = 8080
      protocol = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
      from_port = 0
      to_port = 0
      protocol = "-1"
      cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_elb" "web-load-balancer" {
  name = "${var.user}-${var.environment}-web-elb"
  availability_zones = ["${data.aws_availability_zones.available.names}"]

  listener {
    instance_port = 8080
    instance_protocol = "http"
    lb_port = 80
    lb_protocol = "http"
  }
}