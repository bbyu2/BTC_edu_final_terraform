# VPC
resource "aws_vpc" "vpc" {
  cidr_block           = "10.0.0.0/16"
  instance_tenancy     = "default"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "abc-vpc"
  }
}

# 인터넷 게이트웨이
resource "aws_internet_gateway" "gw" {
  vpc_id = resource.aws_vpc.vpc.id
  tags = {
    Name = "abc-ap2-igw"
  }
}

# NAT 게이트웨이 구성(AZ-c)
resource "aws_eip" "pub10-c" {
  vpc = true
  tags = {
    Name = "abc-ngw-eip-pub10-c"
  }
}
resource "aws_nat_gateway" "gw-c" {
  allocation_id = resource.aws_eip.pub10-c.id
  subnet_id     = resource.aws_subnet.pub10-c.id
  tags = {
    Name = "abc-ngw-c"
  }
  depends_on = [resource.aws_internet_gateway.gw]
}

# public-route-table
resource "aws_route_table" "pub-table" {
  vpc_id = resource.aws_vpc.vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = resource.aws_internet_gateway.gw.id
  }
  tags = {
    Name = "abc-ap2-pub-rt"
  }
}

# private-route-table
resource "aws_route_table" "pri-table" {
  vpc_id = resource.aws_vpc.vpc.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.gw-c.id
  }
  tags = {
    Name = "abc-ap2-pri-rt"
  }
}


# AZ-a
###### public #######
resource "aws_subnet" "pub1-a" {
  vpc_id                  = resource.aws_vpc.vpc.id
  availability_zone       = "ap-northeast-2a"
  cidr_block              = "10.0.0.0/24"
  map_public_ip_on_launch = true
  tags = {
    Name                                = "abc-pub1-a"
    "kubernetes.io/role/elb"            = "1"
    "kubernetes.io/cluster/abc-cluster" = "shared"
  }
}

###### private ######
resource "aws_subnet" "pri1-a" {
  vpc_id            = resource.aws_vpc.vpc.id
  availability_zone = "ap-northeast-2a"
  cidr_block        = "10.0.1.0/24"
  tags = {
    Name = "abc-pri1-a"
  }
}
resource "aws_subnet" "pri2-a" {
  vpc_id            = resource.aws_vpc.vpc.id
  availability_zone = "ap-northeast-2a"
  cidr_block        = "10.0.2.0/24"
  tags = {
    Name = "abc-pri2-a"
  }
}
resource "aws_subnet" "pri3-a" {
  vpc_id            = resource.aws_vpc.vpc.id
  availability_zone = "ap-northeast-2a"
  cidr_block        = "10.0.3.0/24"
  tags = {
    Name = "abc-pri3-a"
  }
}

# AZ-c
###### public ######
resource "aws_subnet" "pub10-c" {
  vpc_id                  = resource.aws_vpc.vpc.id
  availability_zone       = "ap-northeast-2c"
  cidr_block              = "10.0.10.0/24"
  map_public_ip_on_launch = true
  tags = {
    Name                                = "abc-pub10-c"
    "kubernetes.io/role/elb"            = "1"
    "kubernetes.io/cluster/abc-cluster" = "shared"
  }
}

###### private ######
resource "aws_subnet" "pri11-c" {
  vpc_id            = resource.aws_vpc.vpc.id
  availability_zone = "ap-northeast-2c"
  cidr_block        = "10.0.11.0/24"
  tags = {
    Name = "abc-pri11-c"
  }
}
resource "aws_subnet" "pri22-c" {
  vpc_id            = resource.aws_vpc.vpc.id
  availability_zone = "ap-northeast-2c"
  cidr_block        = "10.0.22.0/24"
  tags = {
    Name = "abc-pri22-c"
  }
}
resource "aws_subnet" "pri33-c" {
  vpc_id            = resource.aws_vpc.vpc.id
  availability_zone = "ap-northeast-2c"
  cidr_block        = "10.0.33.0/24"
  tags = {
    Name = "abc-pri33-c"
  }
}

# pub 라우팅 테이블을 pub1 서브넷에 연결
resource "aws_route_table_association" "pub1-a" {
  subnet_id      = aws_subnet.pub1-a.id
  route_table_id = aws_route_table.pub-table.id
}

# pub 라우팅 테이블을 pub10 서브넷에 연결
resource "aws_route_table_association" "pub10-c" {
  subnet_id      = aws_subnet.pub10-c.id
  route_table_id = aws_route_table.pub-table.id
}

# pri 라우팅 테이블을 pri1-a 서브넷에 연결
resource "aws_route_table_association" "pri1-a" {
  subnet_id      = aws_subnet.pri1-a.id
  route_table_id = aws_route_table.pri-table.id
}

# pri 라우팅 테이블을 pri2-a 서브넷에 연결
resource "aws_route_table_association" "pri2-a" {
  subnet_id      = aws_subnet.pri2-a.id
  route_table_id = aws_route_table.pri-table.id
}

# pri 라우팅 테이블을 pri3-a 서브넷에 연결
resource "aws_route_table_association" "pri3-a" {
  subnet_id      = aws_subnet.pri3-a.id
  route_table_id = aws_route_table.pri-table.id
}

# pri 라우팅 테이블을 pri11-c 서브넷에 연결
resource "aws_route_table_association" "pri11-c" {
  subnet_id      = aws_subnet.pri11-c.id
  route_table_id = aws_route_table.pri-table.id
}

# pri 라우팅 테이블을 pri22-c 서브넷에 연결
resource "aws_route_table_association" "pri22-c" {
  subnet_id      = aws_subnet.pri22-c.id
  route_table_id = aws_route_table.pri-table.id
}

# pri 라우팅 테이블을 pri33-c 서브넷에 연결
resource "aws_route_table_association" "pri33-c" {
  subnet_id      = aws_subnet.pri33-c.id
  route_table_id = aws_route_table.pri-table.id
}

resource "aws_vpc_endpoint" "s3" {
  vpc_id       = aws_vpc.vpc.id
  service_name = "com.amazonaws.ap-northeast-2.s3"
}