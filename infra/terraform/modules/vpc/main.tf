resource "aws_vpc" "this" {
  cidr_block = var.cidr_block
  enable_dns_hostnames = true
  enable_dns_support = true
  tags = var.tags
}

resource "aws_subnet" "public" {
  count = length(var.public_subnets_cidrs)
  vpc_id = aws_vpc.this.id
  cidr_block = var.public_subnets_cidrs[count.index]
  map_public_ip_on_launch = true
  availability_zone = element(var.azs, count.index)
  tags = merge(var.tags, { Name = "${var.name}-public-${count.index}" })
}

resource "aws_subnet" "private" {
  count = length(var.private_subnets_cidrs)
  vpc_id = aws_vpc.this.id
  cidr_block = var.private_subnets_cidrs[count.index]
  availability_zone = element(var.azs, count.index)
  tags = merge(var.tags, { Name = "${var.name}-private-${count.index}" })
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.this.id
  tags = merge(var.tags, { Name = "${var.name}-igw" })
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = merge(var.tags, { Name = "${var.name}-public-rt" })
}

resource "aws_route_table_association" "public" {
  count = length(aws_subnet.public)
  subnet_id = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

output "vpc_id" {
  value = aws_vpc.this.id
}

output "public_subnets" {
  value = [for s in aws_subnet.public : s.id]
}

output "private_subnets" {
  value = [for s in aws_subnet.private : s.id]
}
