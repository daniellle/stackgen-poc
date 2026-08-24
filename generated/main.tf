module "postgres_ledger" {
  source                            = "./modules/aws_rds"
  cluster_identifier                = null
  rds_auto_pause                    = true
  rds_availability_zones            = ["us-east-1a", "us-east-1b"]
  rds_backup_retention_period       = 9
  rds_database_name                 = "default"
  rds_db_subnet_group_name          = "default"
  rds_engine                        = "postgres"
  rds_engine_mode                   = "provisioned"
  rds_engine_version                = "16.4"
  rds_master_password               = "password"
  rds_master_username               = "admin"
  rds_max_capacity                  = 2
  rds_min_capacity                  = 1
  rds_preferred_backup_window       = "07:00-09:00"
  rds_preferred_maintenance_window  = "sun:05:00-sun:06:00"
  rds_storage_encrypted             = true
  region                            = var.region
  security_groups                   = null
  tags                              = null
  use_custom_kms_key_for_encryption = false
}

module "stackgen_475c18c8-7baf-434e-8a74-132cf0a84057" {
  source                       = "./modules/aws_s3"
  block_public_access          = true
  bucket_name                  = "danielle-poc-pci-archive"
  bucket_policy                = ""
  enable_versioning            = true
  enable_website_configuration = false
  sse_algorithm                = "aws:kms"
  tags                         = {}
  website_error_document       = "404.html"
  website_index_document       = "index.html"
}

