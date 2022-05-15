terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.27"
    }
  }

  required_version = ">= 0.14.9"
}

provider "aws" {
  profile = "personal-2"
  region  = "ap-northeast-1"
}

variable "bigdata_sandbox_aurora_cluster_master_password" {
}

resource "aws_rds_cluster" "bigdata-sandbox-aurora-cluster" {
  availability_zones                  = [
    "ap-northeast-1a",
    "ap-northeast-1c",
    "ap-northeast-1d",
  ]
  backtrack_window                    = 0
  backup_retention_period             = 7
  cluster_identifier                  = "bigdata-sandbox-aurora-cluster"
  cluster_members                     = [
    "bigdata-sandbox-aurora-cluster-instance-1",
  ]
  copy_tags_to_snapshot               = true
  database_name                       = "bigdata_sandbox_aurora_db"
  db_cluster_parameter_group_name     = "default.aurora-postgresql13"
  db_subnet_group_name                = "default-vpc-0a2a725f51e785674"
  deletion_protection                 = false
  enable_http_endpoint                = false
  enabled_cloudwatch_logs_exports     = []
  engine                              = "aurora-postgresql"
  engine_mode                         = "provisioned"
  engine_version                      = "13.6"
  iam_database_authentication_enabled = false
  iam_roles                           = []
  kms_key_id                          = "arn:aws:kms:ap-northeast-1:060507316679:key/ee6fb50c-99d2-40f2-a1cd-fd2670f7ef27"
  master_username                     = "postgres"
  master_password = var.bigdata_sandbox_aurora_cluster_master_password
  port                                = 5432
  preferred_backup_window             = "15:40-16:10"
  preferred_maintenance_window        = "sat:16:45-sat:17:15"
  skip_final_snapshot                 = true
  storage_encrypted                   = true
  vpc_security_group_ids              = [
    "sg-081dcc68bf2202452",
  ]

  timeouts {}
}

resource "aws_rds_cluster_instance" "bigdata-sandbox-aurora-cluster-instance-1" {
  auto_minor_version_upgrade            = true
  availability_zone                     = "ap-northeast-1c"
  ca_cert_identifier                    = "rds-ca-2019"
  cluster_identifier                    = "bigdata-sandbox-aurora-cluster"
  copy_tags_to_snapshot                 = false
  db_parameter_group_name               = "default.aurora-postgresql13"
  db_subnet_group_name                  = "default-vpc-0a2a725f51e785674"
  engine                                = "aurora-postgresql"
  engine_version                        = "13.6"
  identifier                            = "bigdata-sandbox-aurora-cluster-instance-1"
  instance_class                        = "db.t3.medium"
  monitoring_interval                   = 60
  monitoring_role_arn                   = "arn:aws:iam::060507316679:role/rds-monitoring-role"
  performance_insights_enabled          = true
  performance_insights_kms_key_id       = "arn:aws:kms:ap-northeast-1:060507316679:key/ee6fb50c-99d2-40f2-a1cd-fd2670f7ef27"
  performance_insights_retention_period = 7
  promotion_tier                        = 1
  publicly_accessible                   = false

  timeouts {}
}
