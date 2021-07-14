provider "aws" {
  region = "eu-centrel-1"
}

data "aws_availability_zones" "avalible" {}
data "aws_ami" "current_amazon_linux" {
  owner = ["amazon"]
  most_recent = true
  filter {
    name = "name"
    values = ["amzn2-ami-hvm-2.0.*-x86_64-gp2"]
  }

}
