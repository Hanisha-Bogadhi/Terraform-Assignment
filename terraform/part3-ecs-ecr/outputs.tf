output "load_balancer_url" {
  value = aws_lb.alb.dns_name
}