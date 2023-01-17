# key pair
resource "aws_key_pair" "abc-key" {
  key_name   = "####"
  public_key = file("####")
}

# bastion instance
resource "aws_instance" "bastion" {
  ami                         = data.aws_ami.amazon_linux2.id #Amazon Linux 2 (ap-northeast-2)
  instance_type               = "t2.micro"
  vpc_security_group_ids      = [aws_security_group.pub-sg.id]
  user_data_replace_on_change = true #userdata 변경시 인스턴스 종료 후 재시작 
  key_name                    = aws_key_pair.abc-key.key_name
  subnet_id                   = aws_subnet.pub10-c.id

  user_data = file("userdata-bastion.tftpl")

  tags = {
    Name = "abc-bastion-2c"
  }

  depends_on = [aws_nat_gateway.gw-c]

}

# eks-mng instance
resource "aws_instance" "eks-mng" {
  ami                         = data.aws_ami.amazon_linux2.id #Amazon Linux 2 (ap-northeast-2)
  instance_type               = "t2.micro"
  vpc_security_group_ids      = [aws_security_group.mng-sg.id]
  user_data_replace_on_change = true
  key_name                    = aws_key_pair.abc-key.key_name
  subnet_id                   = aws_subnet.pri11-c.id

  user_data = file("userdata-eks-mng.tftpl")

  tags = {
    Name = "abc-eks-mng-2c"
  }

}

# Jenkins instance
resource "aws_instance" "jenkins" {
  ami                         = data.aws_ami.amazon_linux2.id #Amazon Linux 2 (ap-northeast-2)
  instance_type               = "t3.medium"
  vpc_security_group_ids      = [aws_security_group.pub-sg.id]
  user_data_replace_on_change = true
  key_name                    = aws_key_pair.abc-key.key_name
  subnet_id                   = aws_subnet.pub10-c.id

  user_data = file("userdata-jenkins.tftpl")

  tags = {
    Name = "abc-jenkins-2c"
  }
  depends_on = [aws_nat_gateway.gw-c]
}


#################### Data ####################

data "aws_ami" "amazon_linux2" {
  most_recent = true
  name_regex  = "^amzn2-"
  owners      = ["137112412989"]

  filter {
    name   = "name"
    values = ["amzn2-ami-kernel-5.10-hvm-2.0.*"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}
