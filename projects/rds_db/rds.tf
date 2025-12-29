resource "aws_db_subnet_group" "main" {
  name        = "${var.project}-${local.env}-subnet-group"
  description = "Database subnet group for ${var.project} in ${local.env}"
  subnet_ids  = data.terraform_remote_state.networking.outputs.private_subnet_ids

  tags = merge(
    local.common_tags,
    {
      ResourceName = "${var.project}-${local.env}-subnet-group"
      Component    = "database"
    }
  )
}

resource "aws_db_instance" "main" {
  identifier = "${var.project}-${local.env}-postgres"

  engine               = "postgres"
  engine_version       = var.db_engine_version
  instance_class       = var.db_instance_class[local.env]
  parameter_group_name = aws_db_parameter_group.main.name

  allocated_storage     = var.db_allocated_storage[local.env]
  max_allocated_storage = var.db_max_allocated_storage[local.env]
  storage_type          = "gp3"
  storage_encrypted     = true

  db_name = var.db_name

  manage_master_user_password = true
  username                    = var.db_username

  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [aws_security_group.rds.id]
  publicly_accessible    = false
  port                   = 5432

  multi_az = var.db_multi_az[local.env]

  backup_retention_period   = var.db_backup_retention_period[local.env]
  backup_window             = "03:00-04:00"
  maintenance_window        = "sun:04:00-sun:05:00"
  copy_tags_to_snapshot     = true
  delete_automated_backups  = local.env == "prod" ? false : true
  final_snapshot_identifier = var.db_skip_final_snapshot[local.env] ? null : "${var.project}-${local.env}-final-snapshot"
  skip_final_snapshot       = var.db_skip_final_snapshot[local.env]

  deletion_protection = var.db_deletion_protection[local.env]

  performance_insights_enabled          = var.db_performance_insights_enabled[local.env]
  performance_insights_retention_period = var.db_performance_insights_enabled[local.env] ? 7 : null
  enabled_cloudwatch_logs_exports       = var.db_cloudwatch_logs_exports[local.env]

  auto_minor_version_upgrade  = true
  allow_major_version_upgrade = false
  apply_immediately           = local.env == "prod" ? false : true

  tags = merge(
    local.common_tags,
    {
      ResourceName = "${var.project}-${local.env}-postgres"
      Component    = "database"
    }
  )

  lifecycle {
    prevent_destroy = false
  }
}

resource "aws_db_parameter_group" "main" {
  name        = "${var.project}-${local.env}-params"
  family      = "postgres18"
  description = "Custom parameter group for ${var.project} PostgreSQL 18 in ${local.env}"

  parameter {
    name  = "log_statement"
    value = "ddl"
  }

  parameter {
    name  = "log_min_duration_statement"
    value = "1000"
  }

  parameter {
    name         = "shared_preload_libraries"
    value        = "pg_stat_statements"
    apply_method = "pending-reboot"
  }

  tags = merge(
    local.common_tags,
    {
      ResourceName = "${var.project}-${local.env}-params"
      Component    = "database"
    }
  )
}
