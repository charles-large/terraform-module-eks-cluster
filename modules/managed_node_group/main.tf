resource "aws_eks_node_group" "primary" {
  cluster_name    = var.eks_cluster_name
  node_group_name = var.node_group_name
  node_role_arn   = aws_iam_role.managed.arn
  subnet_ids      = var.private_cluster ? [for x in var.eks_cluster_subnets: x.id if x.tags["public"] == "false"] : [for x in var.eks_cluster_subnets: x.id if x.tags["public"] == "true"]
  
  capacity_type = var.capacity_type
  disk_size = var.disk_size
  force_update_version = var.force_update_version
  instance_types = var.instance_type
  
  timeouts {
    create = var.timeouts["create"]
    update = var.timeouts["update"]
    delete = var.timeouts["delete"]
  }
  
  scaling_config {
    desired_size = var.scaling_config["desired_size"]
    max_size = var.scaling_config["max_size"]
    min_size = var.scaling_config["min_size"]
  }

  update_config {
    max_unavailable = var.update_config
  }

  # Optional: Allow external changes without Terraform plan difference
  lifecycle {
    ignore_changes = [scaling_config[0].desired_size]
  }

  # Ensure that IAM Role permissions are created before and deleted after EKS Node Group handling.
  # Otherwise, EKS will not be able to properly delete EC2 Instances and Elastic Network Interfaces.
  depends_on = [
    aws_iam_role_policy_attachment.managed-AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.managed-AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.managed-AmazonEC2ContainerRegistryReadOnly,
  ]

}

resource "aws_autoscaling_group_tag" "this" {
  autoscaling_group_name = aws_eks_node_group.primary.resources[0].autoscaling_groups[0].name

  tag {
    key                 = "auto-delete"
    value               = "no"
    propagate_at_launch = true
  }
}

###############################################################################################################

##IAM ROLE########

resource "aws_iam_role" "managed" {
  name = "eks-node-group-managed"

  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
    Version = "2012-10-17"
  })
}

resource "aws_iam_role_policy_attachment" "managed-AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.managed.name
}

resource "aws_iam_role_policy_attachment" "managed-AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.managed.name
}

resource "aws_iam_role_policy_attachment" "managed-AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.managed.name
}

resource "aws_iam_role_policy_attachment" "efs-service-policy" {
  policy_arn = "arn:aws:iam::711853232877:policy/efs-service-policy"
  role = aws_iam_role.managed.name
  
}

###############################################################################################################

