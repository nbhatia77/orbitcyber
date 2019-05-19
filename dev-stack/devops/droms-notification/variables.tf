################# Resque notification ###############

variable "env" {}

variable "region" {}

variable "min" {
    default = "0"
}

variable "max" {
    default = "11"
}

variable "instance_type" {
     default = "m4.4xlarge" 
}
variable "vpc_stack_name" {
  default = "env"
}

variable "subnet_name" {
  default = "Engineering Dev Network"
}

variable "instance_role" {
  default = "droms-resque-pool,droms-all"
}

variable "metrics_name" {
  default = "notification_jobs_count"
}

variable "ami_name" {
  default = "env-resque-image"
}

variable "lc_name" {
  default = "env-resque-lc"
}

variable "asg_name" {
  default = "env-resque-asg"
}

variable "alarm_name_scaleup" {
  default = "env-max-queue-scaleup"
}

variable "alarm_name_scaledown" {
  default = "env-max-queue-scaledown"
}

variable "asp_scaleup_name" {
  default = "resque-notification-scaleup"
}

variable "asp_scaledown_name" {
  default = "resque-notification-scaledown"
}

variable "dimensions_name" {
  type = "map"

  default = {
    Environment = "env"
  }
}

variable "sg_name1" {

  default = "name of security group1"
}

variable "sg_name2" {

  default = "name of security group2"
}

variable "sg_stack_name" {

  default = "env"
}