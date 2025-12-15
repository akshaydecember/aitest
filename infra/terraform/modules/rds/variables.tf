variable "name" {
	type = string
}

variable "private_subnets" {
	type = list(string)
}

variable "security_group_ids" {
	type = list(string)
}

variable "allocated_storage" {
	type    = number
	default = 20
}

variable "engine" {
	type    = string
	default = "mysql"
}

variable "instance_class" {
	type    = string
	default = "db.t3.medium"
}

variable "replica_instance_class" {
	type    = string
	default = "db.t3.medium"
}

variable "db_name" {
	type = string
}

variable "username" {
	type = string
}

variable "password" {
	type      = string
	sensitive = true
}

variable "create_cross_region_replica" {
	type    = bool
	default = false
}

variable "replica_db_subnet_group" {
	type    = string
	default = ""
}

variable "tags" {
	type = map(string)
}
