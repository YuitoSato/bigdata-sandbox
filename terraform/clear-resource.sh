terraform destroy -target=aws_rds_cluster_instance.bigdata-sandbox-aurora-cluster-instance-1 -auto-approve
terraform destroy -target=aws_rds_cluster.bigdata-sandbox-aurora-cluster -auto-approve
