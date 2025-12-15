variable "name" {
	type = string
}

variable "container_image" {
	type = string
}

variable "container_port" {
	type    = number
	default = 80
}

variable "cpu" {
	type    = string
	default = "256"
}

variable "memory" {
	type    = string
	default = "512"
}

variable "execution_role_arn" {
	type = string
}

variable "task_role_arn" {
	type = string
}

variable "private_subnets" {
	type = list(string)
}

variable "security_group_ids" {
	type = list(string)
}

variable "environment_variables" {
	type    = map(string)
	default = {}
}

variable "desired_count" {
	type    = number
	default = 2
}

variable "container_name" {
	type    = string
	default = "app"
}

variable "load_balancer_target_group_arn" {
	type    = string
	default = ""
}

variable "autoscaling_min" {
	type    = number
	default = 1
}

variable "autoscaling_max" {
	type    = number
	default = 4
}

variable "autoscaling_target_cpu" {
	type    = number
	default = 60
}
