############## RDS ############## 

# db 서브넷 그룹
resource "aws_db_subnet_group" "db" {
  name       = "abc-ap2-db-subnet-group"
  subnet_ids = [resource.aws_subnet.pri3-a.id, resource.aws_subnet.pri33-c.id]
}

# rds 클러스터
resource "aws_rds_cluster" "cluster" {
  engine                 = "aurora-mysql"
  engine_version         = "5.7.mysql_aurora.2.10.2"
  cluster_identifier     = "abc-mysql"
  vpc_security_group_ids = [resource.aws_security_group.rds-sg.id]
  port                   = ####
  master_username        = "####"
  master_password        = "####"
  database_name          = "abcbit"

  db_subnet_group_name = resource.aws_db_subnet_group.db.name

  backup_retention_period = 1
  skip_final_snapshot     = true
  copy_tags_to_snapshot   = true
}

# db 인스턴스
resource "aws_rds_cluster_instance" "cluster_instances" {
  identifier         = "abc-mysql-${count.index}"
  count              = 1
  cluster_identifier = aws_rds_cluster.cluster.id
  instance_class     = "db.t3.small"
  engine             = aws_rds_cluster.cluster.engine
  engine_version     = aws_rds_cluster.cluster.engine_version

  publicly_accessible = true

  depends_on = [resource.aws_db_subnet_group.db]
}
