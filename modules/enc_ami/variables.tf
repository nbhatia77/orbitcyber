variable "ami" {
	#default = "ami-fc7ef19c"
  default = "ubuntu/images/hvm-ssd/ubuntu-trusty-14.04-amd64-server-*"
}

variable "instance_type" {
    default = "m4.large"
}

variable "az" {
	default = "us-west-2a"
}

variable "vol_type" {
    default = "gp2"
}

variable "vpc_cidr" {
  default = "10.10.0.0/16"
}

variable "subnet_cidr" {
  default = "10.10.1.0/24"
}

variable "region" {
  default = "us-west-2"
}

