# Common function

# AWS provider
provider "aws" {
  region = "${var.region}"
}

# Build VPC
resource "aws_vpc" "enc_ami" {
  cidr_block = "${var.vpc_cidr}"
  enable_dns_support = "true"

  tags = {
    Name = "TEMP VPC AMI Enc"
  }
}

# Setup subnet
resource "aws_subnet" "pvt_net" {
  vpc_id                  = "${aws_vpc.enc_ami.id}"
  cidr_block              = "${var.subnet_cidr}"
  availability_zone       = "${var.az}"
  map_public_ip_on_launch = false
  
  tags = {
  	Name =  "Temp Pvt Subnet"
  }
}
# End of common function

#  Build EC2 Instance
data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["${var.ami}"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
   owners = ["099720109477"] # Canonical
}

resource "aws_instance" "elastic_instance" {
  ami                         = "${data.aws_ami.ubuntu.id}"
  instance_type               = "${var.instance_type}"
  subnet_id                   = "${aws_subnet.pvt_net.id}"
  source_dest_check           =  "false"
  
  
  root_block_device {
    volume_type           = "${var.vol_type}"
    delete_on_termination = true
  }

  tags {
    Name = "Temp ec2 for ami creation"
  }
}

#  Use local KMS to encrypt root volume
resource "aws_kms_key" "enc_key" {
	description = "KMS key to encrypt root disk"
	  tags {
		Name = "Ubuntu Root Disk Encryption Key"
	  }
}

resource "aws_kms_alias" "enc_key" {
  name          = "alias/autogrid/root_device"
  target_key_id = "${aws_kms_key.enc_key.key_id}"
}

# Create AMI from instance
resource "aws_ami_from_instance" "ami" {
  name               = "Ubuntu"
  source_instance_id = "${aws_instance.elastic_instance.id}"
}

# Can be copied to different region(s)
resource "aws_ami_copy" "ami" {
  name              = "Ubuntu-rootdev-encrypted"
  description       = "A copy of ${var.ami} with root_device encrypted"
  source_ami_id     = "${aws_ami_from_instance.ami.id}"
  source_ami_region = "${var.region}"
  encrypted 		    = true
  kms_key_id		    = "${aws_kms_key.enc_key.arn}"

  tags {
    Name = "Ubuntu root_device encrypted"
  }
}