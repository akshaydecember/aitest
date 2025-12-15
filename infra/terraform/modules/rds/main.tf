resource "aws_db_subnet_group" "this" {
  name = "${var.name}-db-subnet-group"
  subnet_ids = var.private_subnets
  tags = var.tags
}

resource "aws_db_instance" "primary" {
  allocated_storage    = var.allocated_storage
  engine               = var.engine
  instance_class       = var.instance_class
  name                 = var.db_name
  username             = var.username
  password             = var.password
  publicly_accessible  = false
  multi_az             = true
  db_subnet_group_name = aws_db_subnet_group.this.name
  vpc_security_group_ids = var.security_group_ids
  skip_final_snapshot  = true
  tags = var.tags
}

resource "aws_db_instance" "replica_secondary" {
  provider = aws.secondary
  count = var.create_cross_region_replica ? 1 : 0
  replicate_source_db = aws_db_instance.primary.arn
  instance_class = var.replica_instance_class
  db_subnet_group_name = var.replica_db_subnet_group
  vpc_security_group_ids = var.security_group_ids
  tags = var.tags
}

output "primary_endpoint" {
  value = aws_db_instance.primary.endpoint
}
