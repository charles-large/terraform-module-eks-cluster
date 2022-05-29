// EKS Cluster Networking

variable "eks_cluster_subnets" {
  type = list
}

# variable "eks_cluster_sg" {
#   type = string
# }

// EKS General Settings

variable "eks_cluster_name" {
  type = string
}

variable "endpoint_private_access" {
  type = string
  description = "Enable private access endpoint for EKS cluster"
}

variable "endpoint_public_access" {
  type = string
  description = "Enable public access endpoint for EKS cluster"
}

variable "eks_version" {
  type = string
  description = "EKS cluster version"
}

variable "private_cluster" {
  type = bool
  description = "To enable settings for completely private EKS cluster."
  
}

variable "vpc_id" {
  type = string
  default = null
}

