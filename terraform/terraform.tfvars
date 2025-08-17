region = "us-east-1"
vpc_cidr = "10.50.0.0/16"
azs = ["us-east-1a","us-east-1b"]
web_subnet_cidrs = ["10.50.1.0/24","10.50.2.0/24"]
blue_subnet_cidrs = ["10.50.3.0/24","10.50.4.0/24"]
green_subnet_cidrs = ["10.50.5.0/24","10.50.6.0/24"]
db_subnet_cidrs = ["10.50.7.0/24","10.50.8.0/24"]


eks_cluster_role_name        = "eks-cluster-role"
eks_cluster_trusted_services = ["eks.amazonaws.com"]

eks_node_group_role_name        = "eks-node-group-role"
eks_node_group_trusted_services = ["ec2.amazonaws.com"]

aurora_role_name        = "aurora-monitoring-role"
aurora_trusted_services = ["monitoring.rds.amazonaws.com"]

bastion_sg_name   = "bastion-sg"
alb_sg_name       = "alb-sg"
eks_blue_sg_name  = "eks-blue-sg"
eks_green_sg_name = "eks-green-sg"
db_sg_name = "db-sg"


ami_id           = "ami-020cba7c55df1f615"            
instance_type    = "t3.medium"
key_name         = "key_pair1"
instance_name    = "bastion_server"
root_volume_size = "20"
root_volume_type = "gp3"


cluster_name = ["blue_env_cluster","green_env_cluster"]
k8s_version = "1.32"
node_instance_type = "t3.medium"
node_min  =  "2"
node_max = "3"
node_desired = "2"
ami_type = "AL2_x86_64"
disk_size = 50

db_name = "appdb"
engine_version = "8.0.mysql_aurora.3.04.0"
instance_class = "db.t3.medium"
instance_count = 2
engine         = "aurora-mysql"
engine_mode    = "provisioned"
backup_retention_period = 30
master_username ="dbadmin"

repo_name = "e-commerce"

secret_name = "appdb/credentials"
description = "Credentials for Aurora MySQL app_db"
recovery_window_in_days= 30

