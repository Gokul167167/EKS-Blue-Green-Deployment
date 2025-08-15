resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = { Name = "k8s_vpc" }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
  tags = { Name = "k8s_vpc-igw" }
}

resource "aws_subnet" "web" {
  for_each = { for idx, cidr in var.web_subnet_cidrs : idx => cidr }
  vpc_id                  = aws_vpc.main.id
  cidr_block              = each.value
  availability_zone       = var.azs[each.key]
  map_public_ip_on_launch = true
  tags = { Name = "web_subnet-${split("-",var.azs[each.key])[2]}"}
}

resource "aws_subnet" "blue" {
  for_each = { for idx, cidr in var.blue_subnet_cidrs : idx => cidr }
  vpc_id            = aws_vpc.main.id
  cidr_block        = each.value
  availability_zone = var.azs[each.key]
  tags = { Name = "blue_subnet-${split("-",var.azs[each.key])[2]}"}
}

resource "aws_subnet" "green" {
  for_each = { for idx, cidr in var.green_subnet_cidrs : idx => cidr }
  vpc_id            = aws_vpc.main.id
  cidr_block        = each.value
  availability_zone = var.azs[each.key]
  tags = { Name = "green_subnet-${split("-",var.azs[each.key])[2]}"}
}

resource "aws_subnet" "db" {
  for_each = { for idx, cidr in var.db_subnet_cidrs : idx => cidr }
  vpc_id            = aws_vpc.main.id
  cidr_block        = each.value
  availability_zone = var.azs[each.key]
  tags = { Name = "db_subnet-${split("-",var.azs[each.key])[2]}"}
}

resource "aws_eip" "nat" {
  for_each = aws_subnet.web
}

resource "aws_nat_gateway" "ngw" {
  for_each      = aws_subnet.web
  allocation_id = aws_eip.nat[each.key].id
  subnet_id     = aws_subnet.web[each.key].id
  depends_on    = [aws_internet_gateway.igw]
  tags = { Name = "NAT-Gateway-${split("-",var.azs[each.key])[2]}"}
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  tags = { Name = "WEB-RT" }
}

resource "aws_route_table" "private_rt_1" {
  vpc_id = aws_vpc.main.id
  tags = { Name = "PR-RT-1a" }
}

resource "aws_route_table" "private_rt_2" {
  vpc_id = aws_vpc.main.id
  tags = { Name = "PR-RT-2b" }
}

# resource "aws_route_table" "db" {
#   vpc_id = aws_vpc.main.id
#   tags = { Name = "DB-RT" }
# }

resource "aws_route" "public_internet" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

resource "aws_route" "private_nat_1" {
  route_table_id         = aws_route_table.private_rt_1.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.ngw["0"].id
}

resource "aws_route" "private_nat_2" {
  route_table_id         = aws_route_table.private_rt_2.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.ngw["1"].id
}

resource "aws_route_table_association" "public" {
  for_each      = aws_subnet.web
  subnet_id     = aws_subnet.web[each.key].id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private_az1" {
  for_each = {
    blue  = aws_subnet.blue["0"].id
    green = aws_subnet.green["0"].id
  }
 
  subnet_id      = each.value
  route_table_id = aws_route_table.private_rt_1.id
}


resource "aws_route_table_association" "private1_az2" {
  for_each = {
    blue  = aws_subnet.blue["1"].id
    green = aws_subnet.green["1"].id
  }
 
  subnet_id      = each.value
  route_table_id = aws_route_table.private_rt_2.id
}


# resource "aws_route_table_association" "db" {
#   for_each      = aws_subnet.db
#   subnet_id     = aws_subnet.db[each.key].id
#   route_table_id = aws_route_table.db.id
# }
