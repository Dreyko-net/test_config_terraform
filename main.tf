#--------------Network---------------------
resource "aws_default_subnet" "default_subnet_1" {
    availability_zone = data.aws_availability_zones.avalible.names[0]
}
resource "aws_default_subnet" "default_subnet_2" {
    availability_zone = data.aws_availability_zones.avalible.names[1]
}

resource "aws_security_group" "sg_web_server" {
  name = "Security Group for Web Server"
  dynamic "ingress" {
      for_each = ["80","443"]
      content {
        from_port = ingress.value
        to_port = ingress.value
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
      }

  }
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    name = "Security Group for Web Server"
  }
}

resource "aws_elb" "lb_web_server" {
    name = "lb-ha-web-server"
    availability_zones = [data.aws_availability_zones.avalible.names[0],data.aws_availability_zones.avalible.names[1]]
    security_groups = [aws_security_group.sg_web_server.id]
    listener {
      instance_port = 80
      instance_protocol = "http"
      lb_port = 80
      lb_protocol = "http"
    }
health_check {
  healthy_threshold = 2
  unhealthy_threshold =2
  timeout = 3
  target = "HTTP:80/health-check-web-server.html"
  interval = 10
}
tags = {
  Name = "lb_ha_web_server"
}
}


#--------------Instance---------------------
resource "aws_launch_configuration" "lc_web_server" {
    name_prefix = "LC_HA_Web_Server"
    image_id = data.aws_ami.current_amazon_linux.id
    instance_type = "t2.micro"
    security_groups = [aws_security_group.sg_web_server.id]
    user_data = file("user_data.sh")
    lifecycle {
      create_before_destroy = true
    }
}

resource "aws_autoscaling_group" "ag_web_server" {
    name = "ASG-${aws_launch_configuration.lc_web_server.name}"
    launch_configuration = aws_launch_configuration.lc_web_server.name
    min_size = 2
    max_size = 2
    min_elb_capacity = 2
    health_check_type = "ELB"
    vpc_zone_identifier = [aws_default_subnet.default_subnet_1.id,aws_default_subnet.default_subnet_2.id]
    load_balancers = [aws_elb.lb_web_server.name]

    tag  {
      key = "name"
	value = "ASG-Web-Server"
propagate_at_launch = true
    }
lifecycle {
  create_before_destroy = true
}
}
