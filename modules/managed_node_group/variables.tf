//EKS cluster settings

variable "eks_cluster_subnets" {
  type = list
}

variable "eks_cluster_sg" {
  type = string
}

variable "eks_cluster_name" {
  type = string
}

variable "private_cluster" {
  type = string
  
}

// Managed Node group Settings

variable "node_group_name" {
  type = string
}

variable "managed_node_group" {
  type = bool
  
}

variable "disk_size" {
  type = number
}

variable "capacity_type" {
  type = string
}

variable "instance_type" {
  type = list(string)
}

variable "force_update_version" {
  type = bool
}

variable "timeouts" {
  type = map(string)
}

variable "scaling_config" {
  type = map(number)
}

variable "update_config" {
  type = number
}