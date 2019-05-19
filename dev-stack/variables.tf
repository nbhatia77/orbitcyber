# General
variable "env" {}

variable "key_name" {}
variable "region" {}

# Application 
variable "external_cert_arn" {
  default = "arn:aws:iam::948569044292:server-certificate/autogridsystems.net-02242021"
}

variable "ceep_instance_type" {
  default = "m4.large"
}

variable "n_ceep_instances" {
  default = 2
}

variable "ceep_root_volume_size" {
  default = 80
}

variable "ceep_ag_volume_size" {
  default = 160
}

variable "pheme_instance_type" {
  default = "m4.large"
}

variable "n_pheme_instances" {
  default = 2
}

variable "pheme_root_volume_size" {
  default = 80
}

variable "pheme_ag_volume_size" {
  default = 160
}

variable "droms_instance_type" {
  default = "m4.xlarge"
}

variable "n_droms_instances" {
  default = 1
}

variable "droms_root_volume_size" {
  default = 80
}

variable "droms_ag_volume_size" {
  default = 160
}

variable "droms_ebs_optimization" {
  default = true
}

variable "droms_subnet_placement" {
  default = "public"
}

variable "dianoga_instance_type" {
  default = "m4.large"
}

variable "n_dianoga_instances" {
  default = 1
}

variable "dianoga_root_volume_size" {
  default = 80
}

variable "dianoga_ag_volume_size" {
  default = 160
}

variable "dianoga_sftp_volume_size" {
  default = 500
}

variable "dianoga_ebs_optimization" {
  default = true
}

variable "dianoga_subnet_placement" {
  default = "public"
}

variable "redis_instance_type" {
  default = "m4.xlarge"
}

variable "n_redis_instances" {
  default = 1
}

variable "redis_root_volume_size" {
  default = 80
}

variable "redis_ag_volume_size" {
  default = 160
}

variable "redis_subnet_placement" {
  default = "private"
}

variable "n_edp-ps_instances" {
  default = 0
}

variable "edp-ps_ag_volume_size" {
  default = 160
}

variable "edp-ps_instance_type" {
  default = "m4.large"
}

variable "edp-ps_root_volume_size" {
  default = 80
}

variable "edp-ps_subnet_placement" {
  default = "private"
}

variable "rtcc_instance_type" {
  default = "m4.xlarge"
}

variable "n_rtcc_instances" {
  default = 1
}

variable "rtcc_root_volume_size" {
  default = 80
}

variable "rtcc_ag_volume_size" {
  default = 160
}

variable "rtcc_subnet_placement" {
  default = "private"
}

variable "rabbitmq_instance_type" {
  default = "m4.large"
}

variable "n_rabbitmq_instances" {
  default = 1
}

variable "rabbitmq_root_volume_size" {
  default = 80
}

variable "rabbitmq_ag_volume_size" {
  default = 160
}

variable "rabbitmq_subnet_placement" {
  default = "private"
}

variable "hbase-master_instance_type" {
  default = "m4.xlarge"
}

variable "n_hbase-master_instances" {
  default = 1
}

variable "hbase-master_root_volume_size" {
  default = 80
}

variable "hbase-master_ag_volume_size" {
  default = 160
}

variable "hbase-master_hbase_volume_size" {
  default = 1000
}

variable "hbase-master_ebs_optimization" {
  default = true
}

variable "hbase-master_subnet_placement" {
  default = "private"
}

variable "hbase-worker_instance_type" {
  default = "m4.xlarge"
}

variable "n_hbase-worker_instances" {
  default = 3
}

variable "hbase-worker_root_volume_size" {
  default = 80
}

variable "hbase-worker_kafka_volume_size" {
  default = 160
}

variable "hbase-worker_ag_volume_size" {
  default = 160
}

variable "hbase-worker_hbase_volume_size" {
  default = 1000
}

variable "hbase-worker_ebs_optimization" {
  default = true
}

variable "hbase-worker_subnet_placement" {
  default = "private"
}

variable "fam-listener_instance_type" {
  default = "m4.xlarge"
}

variable "n_fam-listener_instances" {
  default = 1
}

variable "fam-listener_root_volume_size" {
  default = 80
}

variable "fam-listener_ag_volume_size" {
  default = 160
}

variable "fam-listener_subnet_placement" {
  default = "private"
}

variable "faas-listener_instance_type" {
  default = "m4.xlarge"
}

variable "n_faas-listener_instances" {
  default = 1
}

variable "faas-listener_root_volume_size" {
  default = 80
}

variable "faas-listener_ag_volume_size" {
  default = 160
}

variable "faas-listener_subnet_placement" {
  default = "private"
}

variable "tusker_instance_type" {
  default = "m4.xlarge"
}

variable "n_tusker_instances" {
  default = 1
}

variable "tusker_root_volume_size" {
  default = 80
}

variable "tusker_ag_volume_size" {
  default = 160
}

variable "tusker_subnet_placement" {
  default = "private"
}

variable "cascade_instance_type" {
  default = "m4.xlarge"
}

variable "n_cascade_instances" {
  default = 1
}

variable "cascade_root_volume_size" {
  default = 80
}

variable "cascade_ag_volume_size" {
  default = 160
}

variable "cascade_subnet_placement" {
  default = "public"
}

variable "analytics-server_instance_type" {
  default = "m4.large"
}

variable "n_analytics-server_instances" {
  default = 1
}

variable "analytics-server_root_volume_size" {
  default = 80
}

variable "analytics-server_ag_volume_size" {
  default = 160
}

variable "analytics-server_subnet_placement" {
  default = "private"
}

variable "openadr2b_instance_type" {
  default = "m4.large"
}

variable "n_openadr2b_instances" {
  default = 1
}

variable "openadr2b_root_volume_size" {
  default = 80
}

variable "openadr2b_ag_volume_size" {
  default = 160
}

variable "openadr2b_subnet_placement" {
  default = "public"
}

variable "proxy_instance_type" {
  default = "m4.large"
}

variable "n_proxy_instances" {
  default = 1
}

variable "proxy_root_volume_size" {
  default = 80
}

variable "proxy_ag_volume_size" {
  default = 160
}

variable "proxy_subnet_placement" {
  default = "public"
}

variable "grafana_instance_type" {
  default = "m4.large"
}

variable "n_grafana_instances" {
  default = 1
}

variable "grafana_root_volume_size" {
  default = 80
}

variable "grafana_ag_volume_size" {
  default = 500
}

variable "k8s_proxy_instance_type" {
  default = "t2.small"
}

variable "n_k8s_proxy_instances" {
  default = 0
}

variable "k8s_proxy_root_volume_size" {
  default = 30
}

variable "k8s_proxy_subnet_placement" {
  default = "private"
}

# Network
variable "devops_ipsec_public_ip" {
  default = "54.200.153.165"
}

variable "devops_ipsec_cidr" {
  default = "10.11.0.0/18"
}

variable "ipsec_instance_type" {
  default = "t2.micro"
}

variable "vpc_cidr_first_two" {
  description = "The first two sections of the IP CIDR. ex. '10.15'"
}

# Database
variable "db_storage_size_gb" {
  default = 100
}

variable "db_storage_type" {
  default = "gp2"
}

variable "db_instance_class" {
  default = "db.m4.xlarge"
}

variable "db_username" {
  default = "awsroot"
}

variable "db_password" {
  default = "awsrootpass"
}

variable "db_engine" {
  default = "5.7.19"
}

variable "db_parameter_group" {
  default = "default.mysql5.7"
}

variable "db_apply_immediately" {
  default = "false"
}

variable "db_allow_major_version_upgrade" {
  default = "false"
}

variable "db_replica_instance_class" {
  default = "db.m4.xlarge"
}

variable "ceep_db_storage_size_gb" {
  default = 100
}

variable "ceep_db_storage_type" {
  default = "gp2"
}

variable "ceep_db_instance_class" {
  default = "db.m4.xlarge"
}

variable "ceep_db_username" {
  default = "awsroot"
}

variable "ceep_db_password" {
  default = "awsrootpass"
}

variable "ceep_db_engine" {
  default = "5.6.29"
}

variable "ceep_db_parameter_group" {
  default = "default.mysql5.6"
}

variable "flip_workers" {
  default = "false" # derms01 set to true because 1 worker in backhaul-b, 2 in backhaul-a
}
