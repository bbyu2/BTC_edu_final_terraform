output "bastion_public_ip" {
  value       = aws_instance.bastion.public_ip
  description = "The public IP address of the bastion server"
}

output "eks_mng_private_ip" {
  value       = aws_instance.eks-mng.private_ip
  description = "The private IP address of the eks_mng server"
}

output "rds_endpoint" {
  value       = resource.aws_rds_cluster.cluster.endpoint
  description = "The endpoint of the RDS"
}

output "eks_cluster_endpoint" {
  value = aws_eks_cluster.cluster.endpoint
}

output "jenkins_public_ip" {
  value       = aws_instance.jenkins.public_ip
  description = "The public IP address of the jenkins server"
}