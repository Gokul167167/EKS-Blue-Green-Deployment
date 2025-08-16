module "network" {
    source = "./modules/vpc"
    region             = var.region
    vpc_cidr           = var.vpc_cidr
    azs                = var.azs
    web_subnet_cidrs   = var.web_subnet_cidrs
    blue_subnet_cidrs  = var.blue_subnet_cidrs
    green_subnet_cidrs = var.green_subnet_cidrs
    db_subnet_cidrs    = var.db_subnet_cidrs
}

module "ecr" {
    source = "./modules/ecr"
    repo_name = var.repo_name
}

module "eks_cluster_role" {
  source           = "./modules/iam"
  role_name        = var.eks_cluster_role_name
  trusted_services = var.eks_cluster_trusted_services
  policy_arns      = [
  "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy",
  "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
]
}

module "eks_node_group_role" {
  source           = "./modules/iam"
  role_name        = var.eks_node_group_role_name
  trusted_services = var.eks_node_group_trusted_services
  policy_arns      = [
  "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy",
  "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy",
  "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly",
  "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
]
}

module "rds_role" {
  source           = "./modules/iam"
  role_name        = var.aurora_role_name
  trusted_services = var.aurora_trusted_services
  policy_arns      = [
  "arn:aws:iam::aws:policy/service-role/AmazonRDSEnhancedMonitoringRole"
]
}


module "bastion_sg" {
  source = "./modules/sg"
  vpc_id = module.network.vpc_id
  sg_name = var.bastion_sg_name
  sg_description = "Allow SSH"
  ingress_rules = [
  {
    description = "Allow SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ]
}

module "alb_sg" {
  source = "./modules/sg"
  vpc_id = module.network.vpc_id
  sg_name = var.alb_sg_name
  sg_description = "Allow HTTP and HTTPS Request"
  ingress_rules = [
  {
    description = "Allow HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  },
  {
    description = "Allow HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ]
}

module "eks_blue_sg" {
  source = "./modules/sg"
  vpc_id = module.network.vpc_id
  sg_name = var.eks_blue_sg_name
  sg_description = "Allow HTTP and HTTPS Request from ALB"
  ingress_rules = [
  {
    description     = "Allow HTTP from ALB"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    cidr_blocks     = ["10.50.1.0/24","10.50.2.0/24"]
  },
  {
    description     = "Allow HTTPS from ALB"
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    cidr_blocks     = ["10.50.1.0/24","10.50.2.0/24"]
  }
]
}

module "eks_green_sg" {
  source = "./modules/sg"
  vpc_id = module.network.vpc_id
  sg_name = var.eks_green_sg_name
  sg_description = "Allow HTTP and HTTPS Request"
  ingress_rules = [
  {
    description     = "Allow HTTP from ALB"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    cidr_blocks     = ["10.50.1.0/24","10.50.2.0/24"]
  },
  {
    description     = "Allow HTTPS from ALB"
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    cidr_blocks     = ["10.50.1.0/24","10.50.2.0/24"]
  }
]
}

module "db_sg" {
  source = "./modules/sg"
  vpc_id = module.network.vpc_id
  sg_name = var.db_sg_name
  sg_description = "Allow MYSQL from EKS Clusters"
  ingress_rules = [
  {
    description     = "Allow MySQL from EKS clusters"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    cidr_blocks     = ["10.50.3.0/24","10.50.4.0/24","10.50.5.0/24","10.50.6.0/24"]
  }
]
}

module "aurora_db_secret" {
  source      = "./modules/secretsmanager"
  secret_name = var.secret_name
  description = var.description
  recovery_window_in_days = var.recovery_window_in_days
  secret_string = jsonencode({
    username = var.master_username  
    password = module.aurora_db_secret.random_password 
    endpoint = module.aurora.aurora_endpoint
    reader_endpoint = module.aurora.aurora_reader_endpoint
    dbname   = var.db_name          
  })
}

module "bastion" {
  source           = "./modules/ec2"
  vpc_id           = module.network.vpc_id
  subnet_id        = module.network.web_subnet_ids[0]
  security_group_ids = [module.bastion_sg.security_group_id]
  ami_id           = var.ami_id           
  instance_type    = var.instance_type
  key_name         = var.key_name
  instance_name    = var.instance_name
  root_volume_size = var.root_volume_size
  root_volume_type = var.root_volume_type
}


module "eks_blue" {
  source                = "./modules/eks"
  vpc_id                = module.network.vpc_id
  vpc_cidr              = var.vpc_cidr
  subnet_ids            = module.network.blue_subnet_ids
  security_group_ids    = [module.eks_blue_sg.security_group_id]
  cluster_name          = var.cluster_name[0]
  k8s_version           = var.k8s_version
  node_instance_type    = var.node_instance_type
  node_min              = var.node_min
  node_max              = var.node_max
  node_desired          = var.node_desired
  ami_type = var.ami_type
  disk_size = var.disk_size
  cluster_role_arn = module.eks_cluster_role.role_arn
  node_group_role_arn = module.eks_node_group_role.role_arn
}


module "eks_green" {
  source                = "./modules/eks"
  vpc_id                = module.network.vpc_id
  vpc_cidr              = var.vpc_cidr
  subnet_ids            = module.network.green_subnet_ids
  security_group_ids    = [module.eks_green_sg.security_group_id]
  cluster_name          = var.cluster_name[1]
  k8s_version           = var.k8s_version
  node_instance_type    = var.node_instance_type
  node_min              = var.node_min
  node_max              = var.node_max
  node_desired          = var.node_desired
  ami_type              = var.ami_type
  disk_size             = var.disk_size
  cluster_role_arn = module.eks_cluster_role.role_arn
  node_group_role_arn = module.eks_node_group_role.role_arn 
}


module "aurora" {
  source           = "./modules/rds"
  vpc_id           = module.network.vpc_id
  db_name          = var.db_name
  engine_version   = var.engine_version
  engine           = var.engine
  engine_mode      = var.engine_mode
  subnet_ids       = module.network.db_subnet_ids
  backup_retention_period = var.backup_retention_period
  instance_class   = var.instance_class
  instance_count   = var.instance_count
  db_monitor_role_arn = module.rds_role.role_arn
  master_username  = var.master_username
  master_password  = module.aurora_db_secret.random_password                
  security_group_ids    = [module.db_sg.security_group_id]     
}


