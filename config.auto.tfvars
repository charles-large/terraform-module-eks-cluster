# // AWS Settings

# region = "us-west-2"


# // EKS Cluster Settings
# eks_cluster_name = "primary_eks_cluster"

# private_cluster = false
# fargate_cluster = true

# endpoint_private_access = true
# endpoint_public_access = true

# // Node Type - Mutually exclusive with fargate_cluster
# managed_node_group = false

# // Managed Node Group settings

# node_group_name = "primary_managed_node_group"
# disk_size = 20
# capacity_type = "ON_DEMAND"
# instance_type = ["t3.small"]
# force_update_version = false
# timeouts = {
#     create = "30m"
#     update = "30m"
#     delete = "30m"
# }
# scaling_config = {
#     desired_size = 2
#     max_size     = 3
#     min_size     = 2
# }
# update_config = 1

# // Drivers

# efs-csi = false
# ebs-csi = true
# metric-server = true
# aws-alb-controller = true
# aws-fluent-bit = false