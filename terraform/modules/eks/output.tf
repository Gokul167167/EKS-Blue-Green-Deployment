output "cluster_id" {
  description = "EKS Cluster ID"
  value       = aws_eks_cluster.cluster.id
}

output "cluster_endpoint" {
  description = "EKS Cluster API server endpoint"
  value       = aws_eks_cluster.cluster.endpoint
}

output "node_group_id" {
  description = "EKS managed node group ID"
  value       = aws_eks_node_group.workers.id
}