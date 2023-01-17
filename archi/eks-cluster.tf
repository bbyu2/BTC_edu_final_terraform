#
# EKS Cluster Resources
#  * IAM Role to allow EKS service to manage other AWS services
#  * EC2 Security Group to allow networking traffic with EKS cluster
#  * EKS Cluster
#

resource "aws_iam_role" "eks-cluster" {
  name = "role-of-eks-cluster"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "cluster-AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks-cluster.name
}

resource "aws_iam_role_policy_attachment" "cluster-AmazonEKSVPCResourceController" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
  role       = aws_iam_role.eks-cluster.name
}

resource "aws_eks_cluster" "cluster" {
  name     = "abc-cluster"
  role_arn = aws_iam_role.eks-cluster.arn

  vpc_config {
    security_group_ids = [aws_security_group.node-cluster-sg.id]
    subnet_ids         = [aws_subnet.pri2-a.id, aws_subnet.pri22-c.id]
  }

  depends_on = [
    aws_iam_role_policy_attachment.cluster-AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.cluster-AmazonEKSVPCResourceController,
  ]
}

resource "aws_eks_addon" "eks-cni" {
  cluster_name      = aws_eks_cluster.cluster.name
  addon_name        = "vpc-cni"
  addon_version     = "v1.11.4-eksbuild.1"
  resolve_conflicts = "OVERWRITE" # NONE, OVERWRITE, PRESERVE
}

resource "aws_eks_addon" "eks-coredns" {
  cluster_name      = aws_eks_cluster.cluster.name
  addon_name        = "coredns"
  addon_version     = "v1.8.7-eksbuild.3"
  resolve_conflicts = "OVERWRITE"
}

resource "aws_eks_addon" "eks-kube-proxy" {
  cluster_name      = aws_eks_cluster.cluster.name
  addon_name        = "kube-proxy"
  addon_version     = "v1.23.8-eksbuild.2"
  resolve_conflicts = "OVERWRITE"
}

resource "aws_iam_role" "eks-cni-role" {
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json
  name               = "eks-cni-role"
}

resource "aws_iam_role_policy_attachment" "eks-cni-role-policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.eks-cni-role.name
}

data "tls_certificate" "tls-cert" {
  url = aws_eks_cluster.cluster.identity[0].oidc[0].issuer
}

resource "aws_iam_openid_connect_provider" "eks_" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.tls-cert.certificates[0].sha1_fingerprint]
  url             = aws_eks_cluster.cluster.identity[0].oidc[0].issuer
}

data "aws_iam_policy_document" "assume_role_policy" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    condition {
      test     = "StringEquals"
      variable = "${replace(aws_iam_openid_connect_provider.eks_.url, "https://", "")}:sub"
      values   = ["system:serviceaccount:kube-system:aws-node"]
    }

    principals {
      identifiers = [aws_iam_openid_connect_provider.eks_.arn]
      type        = "Federated"
    }
  }
}