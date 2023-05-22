resource "aws_vpc" "custom_vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "Custom_vpc"
  }
}

resource "aws_internet_gateway" "IGW" {
  vpc_id = aws_vpc.custom_vpc.id
  tags = {
    Name = "my-internet-gateway"
  }
  depends_on = [
    aws_vpc.custom_vpc
  ]
}

resource "aws_subnet" "public_subnets" {
 count      = length(var.public_subnet_cidrs)
 vpc_id     = aws_vpc.custom_vpc.id
 cidr_block = element(var.public_subnet_cidrs, count.index)
 availability_zone = element(var.azs, count.index)
 tags = {
   Name = "Public Subnet ${count.index + 1}"
 }
}
 
resource "aws_subnet" "private_subnets" {
 count      = length(var.private_subnet_cidrs)
 vpc_id     = aws_vpc.custom_vpc.id
 cidr_block = element(var.private_subnet_cidrs, count.index)
 availability_zone = element(var.azs, count.index)
 tags = {
   Name = "Private Subnet ${count.index + 1}"
 }
}
resource "aws_route_table" "PublicRT" {
  vpc_id = aws_vpc.custom_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.IGW.id
  }
   tags = {
   Name = "PrivateRT"
 }
  depends_on = [
    aws_internet_gateway.IGW
  ]
}


resource "aws_eip" "nateIP" {
  count = 2
  vpc = true
}

 resource "aws_nat_gateway" "NATgw" {
  count = length(var.private_subnet_cidrs)
  allocation_id = aws_eip.nateIP[count.index].id
  subnet_id     = aws_subnet.public_subnets[count.index].id
}


resource "aws_route_table" "PrivateRT" {
  vpc_id = aws_vpc.custom_vpc.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.NATgw[0].id
  }
   route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.NATgw[1].id
  }
   tags = {
   Name = "PrivateRT"
 }
}

resource "aws_route_table_association" "public_subnet_asso" {
 count = length(var.public_subnet_cidrs)
 subnet_id      = element(aws_subnet.public_subnets[*].id, count.index)
 route_table_id = aws_route_table.PublicRT.id
}



resource "aws_route_table_association" "private_subnet_asso" {
 count = length(var.public_subnet_cidrs)
 subnet_id      = element(aws_subnet.private_subnets[*].id, count.index)
 route_table_id = aws_route_table.PrivateRT.id
}
