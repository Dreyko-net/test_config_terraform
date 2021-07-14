output "lb_web_server_url" {
  value = aws_elb.lb_web_server.dns_name
}
