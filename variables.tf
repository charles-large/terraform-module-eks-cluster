// AWS Settings

variable "region" {
  type = string
  description = "AWS Region"
  default = "us-east-2"
  
}

// EKS Cluster Settings
variable "eks_cluster_name" {
  type = string
  description = "EKS cluster name"
  default = "primary_eks_cluster"
}

variable "endpoint_private_access" {
  type = bool
  default = false
  description = "Enable private access endpoint for EKS cluster"
}

variable "endpoint_public_access" {
  type = bool
  default = true
  description = "Enable public access endpoint for EKS cluster"
}

variable "eks_version" {
  type = string
  description = "EKS cluster version"
  default = null

  validation {
    condition = var.eks_version == null ? true : contains(["1.19", "1.20", "1.21", "1.22"], var.eks_version)
    error_message = "Invalid EKS Version. Current allowed versions 1.19-1.22."
  
}
}

variable "vpc_id" {
  type = string
  default = null
}

variable "vpc_subnets" {
  type = list
  default = null
  
}

// Drivers

variable "ebs-csi" {
    type = bool
    default = true
  
}

variable "efs-csi" {
    type = bool
    default = true
  
}

variable "metric-server" {
    type = bool
    default = true
  
}

variable "aws-alb-controller"{
    type = bool
    default = true
}

variable "aws-fluent-bit"{
    type = bool
    default = true
}

variable "coredns"{
    type = bool
    default = true
}



# variable "deployment" {
#   type = object({
#     private_cluster = bool,
#     fargate_cluster = bool
#   })
#   default = {
#     fargate_cluster = true
#     private_cluster = true
#   }
#   validation {
#     condition = var.deployment.fargate_cluster && !var.deployment.private_cluster ?  false : true
#     error_message = "Fargate is only support with private subnets. Enable private_cluster." 
#   }
# }


// Private Cluster - If enabled, EKS will deploy ENIs and managed nodes in private subnets

variable "private_cluster" {
  type = bool
  default = false
  description = "Enable settings for private EKS cluster."
  
}

variable "endpoint_services" {
  type = list
  description = "VPC Endpoint services used for private EKS cluster."
  default = ["ec2", "ecr.api", "ecr.dkr", "s3", "logs", "elasticloadbalancing", "sts"]
  
}

// Fargate Cluster

variable "fargate_cluster" {
  type = bool
  default = false
  description = "Launch EKS cluster using only Fargate"
}

// Manged Node Group Settings

variable "managed_node_group" {
  type = bool
  default = true
  description = "Toggle for creation of managed node group. Can not be used with Fargate Cluster"
  
}

variable "node_group_name" {
  type = string
  description = "Managed Node Group Name"
  default = "primary_managed_node_group"
}

variable "disk_size" {
  type = number
  description = "Ephermeral storage amount for nodes"
  default = 20
  
}

variable "capacity_type" {
  type        = string
  description = "Capacity type for nodes. Valid values ON_DEMAND or SPOT"
  default = "ON_DEMAND"

  validation {
    condition = anytrue([
      var.capacity_type == "ON_DEMAND",
      var.capacity_type == "SPOT",
      
    ])
    error_message = "Invalid capacity type. Valid values are ON_DEMAND or SPOT."
  
}
}

variable "instance_type" {

  type        = list
  description = "instance_type for nodes"
  default = ["t3.medium"]

  validation {
    condition = alltrue([for o in var.instance_type : anytrue([
      o == "t3.small",
      o == "t3.medium",
      o == "t3.large"
      
    ])])
    error_message = "Invalid instance_type. Current allowed values are t3.small, t3.medium, t3.large."
  
} 
}

variable "force_update_version" {

  type        = bool
  description = "Force version update if existing pods are unable to be drained due to a pod disruption budget issue"
  default = "false"
}

variable "timeouts" {
  type = map
  description = <<-EOT
  create - How long to wait for the EKS Node Group to be created
  update - How long to wait for the EKS Node Group to be updated. Note that the update timeout is used separately for both configuration and version update operations
  delete - How long to wait for the EKS Node Group to be deleted.
  EOT
  
  default = {
    create = "30m"
    update = "30m"
    delete = "30m"
  }

  validation {
    condition = alltrue([for o in var.timeouts : substr(o, -1, 1) == "m" || substr(o, -1, 1) == "h"])
    error_message = "Invalid value given for timeouts. Example are 30m and 1h."
  }

  
}

variable "scaling_config" {
  type = map
  description = <<-EOT
  desired size - Desired number of worker nodes.
  max_size - Maximum number of worker nodes.
  min_size - Minimum number of worker nodes.
  EOT
  
  default = {
    desired_size = 2
    max_size     = 3
    min_size     = 2
  }

  # validation {
  #   condition = alltrue([for o in var.scaling_config : o == number])
  #   error_message = "Invalid value given for scaling_config. Values should be numbers."
  # }

  
}


variable "update_config" {
  type = number
  default = 1
  description = "Desired max number of unavailable worker nodes during node group update."
}


 