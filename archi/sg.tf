# 퍼블릭 서브넷 보안그룹(Bastion)
resource "aws_security_group" "pub-sg" {
  name        = "pub-sg"
  description = "Allow SSH inbound traffic"
  vpc_id      = resource.aws_vpc.vpc.id

  ingress {
    description = "ssh"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "ssh"
    from_port   = 22222
    to_port     = 22222
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "jenkins"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "abc-pub-sg"
  }
}

# 프라이빗1 서브넷 보안그룹 (EKS 관리서버)
resource "aws_security_group" "mng-sg" {
  name        = "mng-sg"
  description = "Allow SSH inbound traffic"
  vpc_id      = resource.aws_vpc.vpc.id

  ingress {
    description = "ssh"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description     = "ssh"
    from_port       = 22222
    to_port         = 22222
    protocol        = "tcp"
    security_groups = [resource.aws_security_group.pub-sg.id]
  }

  ingress {
    description = "jenkins"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "abc-pri1-sg"
  }
}

# 프라이빗2 서브넷 보안그룹 (워커노드그룹)
resource "aws_security_group" "node-sg" {
  name        = "node-sg"
  description = "Allow SSH,HTTP(S) inbound traffic"
  vpc_id      = resource.aws_vpc.vpc.id

  ingress {
    description = "ssh"
    from_port   = 22222
    to_port     = 22222
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }

  ingress {
    description     = "HTTP from alb"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [resource.aws_security_group.alb-sg.id]
  }

  ingress {
    description     = "HTTPs from alb"
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = [resource.aws_security_group.alb-sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "abc-pri2-sg"
  }

  depends_on = [resource.aws_db_subnet_group.db]

}

# RDS 보안그룹
resource "aws_security_group" "rds-sg" {
  name        = "rds-sg"
  description = "Allow mysql from Node Group"
  vpc_id      = resource.aws_vpc.vpc.id

  ingress {
    description     = "Mysql from Node Group"
    from_port       = 33333
    to_port         = 33333
    protocol        = "tcp"
    security_groups = [resource.aws_security_group.node-sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "abc-rds-sg"
  }
}

# ALB 보안그룹
resource "aws_security_group" "alb-sg" {
  name        = "alb-sg"
  description = "Allow HTTP(S) inbound traffic"
  vpc_id      = resource.aws_vpc.vpc.id

  ingress {
    description = "HTTP from all"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPs from all"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "abc-alb-sg"
  }
}

# eks-노드그룹 보안그룹
resource "aws_security_group" "node-cluster-sg" {
  name        = "node-cluster-sg"
  description = "Cluster communication with worker nodes"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    description = "Allow workstation to communicate with the cluster API Server"
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "node-cluster-sg"
  }
}

# efs 보안그룹
resource "aws_security_group" "efs" {
  name        = "efs-sg"
  description = "Allos inbound efs traffic from ec2"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    from_port   = 2049
    to_port     = 2049
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}