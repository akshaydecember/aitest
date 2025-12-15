variable "name" {
	type = string
}

variable "private_subnets" {
	type = list(string)
}

variable "security_group_ids" {
	type = list(string)
}

variable "node_type" {
	type    = string
	default = "cache.t3.micro"
}

variable "number_cache_clusters" {
	type    = number
	default = 1
}

variable "engine_version" {
	type    = string
	default = "6.x"
}

variable "parameter_group_name" {
	type    = string
	default = "default.redis6.x"
}

variable "tags" {
	type    = map(string)
	default = {}
}

variable "enabled" {
	type    = bool
	default = false
}
