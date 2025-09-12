output "myvpc_id" {
  value = aws_vpc.myvpc.id
}

output "pub_sub1_id" {
  value = aws_subnet.public-subnet-1.id
}

output "pub_sub2_id" {
  value = aws_subnet.public-subnet-2.id
}

output "pvt_sub1_id" {
  value = aws_subnet.private-subnet-1.id
}

output "pvt_sub2_id" {
  value = aws_subnet.private-subnet-2.id
}

output "igw_id" {
  value = aws_internet_gateway.igw.id
}

output "nat_gateway_id" {
  value = aws_nat_gateway.nat_gateway.id
}