resource "aws_instance" "ec2_public_instance" {
  ami           = "ami-01acac09adf473073"
  count = 2
  instance_type = "t2.micro"
  tags = {
    Name = "Public-ec2 ${count.index + 1}"
  }
  subnet_id = var.public_subnet_id_var[count.index]

}

resource "aws_instance" "ec2_private_instance" {
  ami           = "ami-01acac09adf473073"
  count = 2
  instance_type = "t2.micro"
  associate_public_ip_address ="false"
  tags = {
    Name = "Private_ec2 ${count.index + 1}"
  }
  subnet_id = var.private_subnet_id_var[count.index]
}