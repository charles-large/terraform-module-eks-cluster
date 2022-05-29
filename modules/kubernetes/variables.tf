variable "ebs-csi" {
    type = bool
    default = false
  
}

variable "efs-csi" {
  type = bool
  default = false
}

variable "metric-server" {
  type = bool
  default = false
}

variable "aws-alb-controller" {
    type = bool
    default = false
}

variable "aws-fluent-bit" {
    type = bool
    default = false
  
}

variable "coredns"{
    type = bool
    default = true
}

variable "region" {
  type = string
}

variable "cluster_id" {
  type = string
}

variable "endpoint" {
  type = string
}

variable "ca" {
  type = string
}

variable "cluster_name" {
  type = string
}

variable "oidc-arn" {
  type = string
}

variable "oidc-url" {
  type = string
}

variable "vpc-id" {
  type = string
  
}

variable "efs-id" {
  type = string
  default = ""
}

variable "efs-access-point-id" {
  type = string
  default = ""
}
