
# -------------------------
# RDS
# -------------------------
resource "aws_db_subnet_group" "rds" {
  name       = "${var.project_name}-rds-subnets"
  subnet_ids = aws_subnet.private[*].id

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-rds-subnets"
  })
}
resource "aws_db_instance" "mysql" {
  identifier              = "${var.project_name}-mysql"
  engine                  = "mysql"
  engine_version          = var.db_engine_version
  instance_class          = var.db_instance_class
  allocated_storage       = 20
  max_allocated_storage   = 100
  storage_type            = "gp3"
  db_name                 = var.db_name
  username                = var.db_username
  password                = var.db_password
  port                    = 3306
  db_subnet_group_name    = aws_db_subnet_group.rds.name
  vpc_security_group_ids  = [aws_security_group.rds.id]
  publicly_accessible     = true
  multi_az                = true
  storage_encrypted       = true
  backup_retention_period = 7
  deletion_protection     = false #can set to true for production, but will require manual deletion of RDS instance
  skip_final_snapshot     = true

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-mysql"
  })
}
