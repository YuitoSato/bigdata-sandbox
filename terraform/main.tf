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
  db_cluster_parameter_group_name     = "bigdata-sandbox-aurora-cluster-parameter-group"
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
  cluster_identifier                    = aws_rds_cluster.bigdata-sandbox-aurora-cluster.id
  copy_tags_to_snapshot                 = false
  db_parameter_group_name               = "bigdata-sandbox-aurora-db-instance-parameter-group"
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

resource "aws_route53_zone" "bigdata-sandbox-internal-route53" {
  name = "bigdata-sandbox-internal.com"

  vpc {
    vpc_id = "vpc-0a2a725f51e785674"
  }
}

resource "aws_route53_record" "bigdata-sandbox-internal-aurora-route53-record" {
  zone_id = aws_route53_zone.bigdata-sandbox-internal-route53.zone_id
  name = "aurora-write.bigdata-sandbox-internal.com"
  type = "CNAME"
  ttl = 300

  records = [
    aws_rds_cluster.bigdata-sandbox-aurora-cluster.endpoint,
  ]
}

resource "aws_dms_replication_instance" "bigdata-sandbox-aurora2instance-rpl-instance" {
  allocated_storage                = 50
  auto_minor_version_upgrade       = true
  availability_zone                = "ap-northeast-1a"
  engine_version                   = "3.4.6"
  kms_key_arn                      = "arn:aws:kms:ap-northeast-1:060507316679:key/21d148da-046c-45ee-a60b-0a3f3b8888ad"
  multi_az                         = false
  preferred_maintenance_window     = "sun:11:33-sun:12:03"
  publicly_accessible              = false
  replication_instance_class       = "dms.t3.small"
  replication_instance_id          = "bigdata-sandbox-aurora2instance-rpl-instance"
  replication_subnet_group_id      = "default-vpc-0a2a725f51e785674"
  tags                             = {
    "description" = "bigdata-sandbox-aurora2instance-rpl-instance"
  }
  tags_all                         = {
    "description" = "bigdata-sandbox-aurora2instance-rpl-instance"
  }
  vpc_security_group_ids           = [
    "sg-081dcc68bf2202452",
  ]
}

resource "aws_dms_endpoint" "bigdata-sandbox-aurora-cluster-source-endpoint" {
  database_name = "bigdata_sandbox_aurora_db"
  endpoint_id   = "bigdata-sandbox-aurora-cluster-source-endpoint"
  endpoint_type = "source"
  engine_name   = "aurora-postgresql"
  kms_key_arn   = "arn:aws:kms:ap-northeast-1:060507316679:key/21d148da-046c-45ee-a60b-0a3f3b8888ad"
  port          = 5432
  server_name   = aws_rds_cluster.bigdata-sandbox-aurora-cluster.endpoint
  ssl_mode      = "none"
  tags          = {}
  tags_all      = {}
  username      = "postgres"
  password      = var.bigdata_sandbox_aurora_cluster_master_password
}

resource "aws_dms_endpoint" "bigdata-sandbox-aurora2snowflake-s3-target-endpoint" {
  endpoint_id                 = "bigdata-sandbox-aurora2snowflake-s3-target-endpoint"
  endpoint_type               = "target"
  engine_name                 = "s3"
  extra_connection_attributes = "bucketFolder=aurora2snowflake;bucketName=bigdata-sandbox-aurora2snowflake-s3;compressionType=NONE;csvDelimiter=,;csvRowDelimiter=\\n;datePartitionEnabled=false;"
  ssl_mode                    = "none"
  tags                        = {}
  tags_all                    = {}

  s3_settings {
    bucket_folder                    = "aurora2snowflake"
    bucket_name                      = "bigdata-sandbox-aurora2snowflake-s3"
    compression_type                 = "NONE"
    csv_delimiter                    = ","
    csv_row_delimiter                = "\\n"
    date_partition_enabled           = false
    parquet_timestamp_in_millisecond = false
    service_access_role_arn          = "arn:aws:iam::060507316679:role/bigdata-sandbox-aurora2snowflake-dms-role"
  }
}


#
#resource "aws_dms_replication_task" "bigdata-sandbox-aurora2snowflake-dms-task" {
#}
