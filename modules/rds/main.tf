resource "aws_db_subnet_group" "aurora_subnet_group" {
  name       = "${var.db_name}-aurora-subnet-group"
  subnet_ids = var.subnet_ids

  tags = {
    Name = "${var.db_name}-aurora-subnet-group"
  }
}

resource "aws_rds_cluster" "aurora" {
  cluster_identifier      = "${var.db_name}-cluster"
  engine                  = var.engine
  engine_mode             = var.engine_mode
  engine_version          = var.engine_version
  database_name           = var.db_name
  master_username         = var.master_username
  master_password         = var.master_password
  db_subnet_group_name    = aws_db_subnet_group.aurora_subnet_group.name
  vpc_security_group_ids  = var.security_group_ids
  monitoring_interval      = 60
  monitoring_role_arn      = var.db_monitor_role_arn
  storage_encrypted       = true
  backup_retention_period = var.backup_retention_period
  preferred_backup_window = "02:00-03:00"
  preferred_maintenance_window = "sun:04:00-sun:05:00"
  skip_final_snapshot     = true
  final_snapshot_identifier = "${var.db_name}-final-snapshot"
  deletion_protection     = false
  enable_http_endpoint    = false
  apply_immediately       = true

  tags = {
    Name = "${var.db_name}-cluster"
  }
}


resource "aws_rds_cluster_instance" "aurora_instances" {
  count               = var.instance_count
  identifier          = "${var.db_name}-instance-${count.index + 1}"
  cluster_identifier  = aws_rds_cluster.aurora.id
  instance_class      = var.instance_class
  engine              = aws_rds_cluster.aurora.engine
  engine_version      = aws_rds_cluster.aurora.engine_version
  publicly_accessible = false

  tags = {
    Name = "${var.db_name}-instance-${count.index + 1}"
  }
}