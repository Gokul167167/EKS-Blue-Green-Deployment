output "vpc_id" {
  value = aws_vpc.main.id
}

output "web_subnet_ids" {
  value = [for subnet in aws_subnet.web : subnet.id]
}

output "blue_subnet_ids" {
  value = [for subnet in aws_subnet.blue : subnet.id]
}

output "green_subnet_ids" {
  value = [for subnet in aws_subnet.green : subnet.id]
}

output "db_subnet_ids" {
  value = [for subnet in aws_subnet.db : subnet.id]
}

output "internet_gateway_id" {
  value = aws_internet_gateway.igw.id
}

output "nat_gateway_ids" {
  value = [for id, ngw in aws_nat_gateway.ngw : ngw.id]
}

output "public_route_table_id" {
  value = aws_route_table.public.id
}

output "private_route_table1_id" {
  value = aws_route_table.private_rt_1.id
}

output "private_route_table2_id" {
  value = aws_route_table.private_rt_2.id
}

# output "db_route_table_id" {
#   value = aws_route_table.db.id
# }