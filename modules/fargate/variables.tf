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