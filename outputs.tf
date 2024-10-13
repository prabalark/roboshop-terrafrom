output "subnets" {
  value = "module.subnets"
}

output "subnet_ids" {
  value = aws_subnet.main.*.id
}

output "subnet_cidrs" {
  value = aws_subnet.main.*.cidr_block
}