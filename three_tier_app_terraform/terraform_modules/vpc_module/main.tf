resource "aws_vpc" "myvpc" {
  cidr_block = var.vpc_cidr_block_value
}

resource "aws_subnet" "public-subnet-1" {
  vpc_id                  = aws_vpc.myvpc.id
  cidr_block              = var.pubsub1_cidr_block_value
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true
}

resource "aws_subnet" "private-subnet-1" {
  vpc_id            = aws_vpc.myvpc.id
  cidr_block        = var.pvtsub1_cidr_block_value
  availability_zone = "us-east-1a"
}

resource "aws_subnet" "public-subnet-2" {
  vpc_id                  = aws_vpc.myvpc.id
  cidr_block              = var.pubsub2_cidr_block_value
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true
}

resource "aws_subnet" "private-subnet-2" {
  vpc_id            = aws_vpc.myvpc.id
  cidr_block        = var.pvtsub2_cidr_block_value
  availability_zone = "us-east-1b"
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.myvpc.id
}

resource "aws_route_table" "RT1" {
  vpc_id = aws_vpc.myvpc.id


  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

}

resource "aws_route_table_association" "rta1" {
  route_table_id = aws_route_table.RT1.id
  subnet_id      = aws_subnet.public-subnet-1.id
}

resource "aws_route_table_association" "rta2" {
  route_table_id = aws_route_table.RT1.id
  subnet_id      = aws_subnet.public-subnet-2.id
}

resource "aws_eip" "nat" {
  domain = "vpc"
}

resource "aws_nat_gateway" "nat_gateway" {
  subnet_id     = aws_subnet.public-subnet-1.id
  allocation_id = aws_eip.nat.id
  depends_on    = [aws_internet_gateway.igw]
}

resource "aws_route_table" "RT2" {
  vpc_id = aws_vpc.myvpc.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gateway.id
  }
}

resource "aws_route_table_association" "rta3" {
  route_table_id = aws_route_table.RT2.id
  subnet_id      = aws_subnet.private-subnet-1.id
}

resource "aws_route_table_association" "rta4" {
  route_table_id = aws_route_table.RT2.id
  subnet_id      = aws_subnet.private-subnet-2.id
}