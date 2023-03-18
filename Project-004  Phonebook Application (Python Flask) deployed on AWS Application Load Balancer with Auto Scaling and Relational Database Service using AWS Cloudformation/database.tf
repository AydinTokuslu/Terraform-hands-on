resource "aws_db_instance" "example" {

  identifier = "phonebook-app-db"
  engine         = "mysql"
  engine_version = "8.0.28"
  instance_class = "db.t2.micro"

  allocated_storage     = 20
  max_allocated_storage = 40

  db_name             = "clarusway_phonebook"
  username            = "admin"
  port                = 3306
  password            = "awsdevops13"
  publicly_accessible = false
  skip_final_snapshot = true


  db_subnet_group_name = module.vpc.database_subnet_group_name
  vpc_security_group_ids = ["${aws_security_group.rds-sec.id}"]
  backup_retention_period = 0
}