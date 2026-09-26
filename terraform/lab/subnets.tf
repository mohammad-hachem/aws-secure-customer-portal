resource "aws_subnet" "this" {
  for_each = local.subnets

  vpc_id = aws_vpc.main.id

  cidr_block        = each.value.cidr
  availability_zone = each.value.az

  map_public_ip_on_launch = false

  tags = {
    Name = each.key
    Tier = each.value.tier

    Project     = "aws-secure-portal"
    Environment = "lab"
    ManagedBy   = "Terraform"
  }
}
