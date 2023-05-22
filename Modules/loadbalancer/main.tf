resource "aws_lb" "applb" {
  count = 2
  name               = "basic-load-balancer"
  load_balancer_type = "application"
  subnets            = var.public_subnet_id_var[count.index]
    tags = {
    Name = "Load Balancer"
  }
}


resource "aws_lb_listener" "front_end" {
  load_balancer_arn = aws_lb.applb.arn
  port              = "80"
  protocol          = "HTTP"
}

