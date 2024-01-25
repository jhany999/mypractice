provider "aws" {
    region = "us-east-1"
  }
resource "aws_instance" "demo" {
    ami = "ami-0c7217cdde317cfec"
    instance_type =  "t2.micro"
    key_name =  "vedha"
    security_groups = ["demo-sg"]
  }
  resource "aws_security_group" "demo-sg" {
  name        = "demo-sg"
  description = "SSH Access"
  
  tags = {
    Name = "ssh-port"
  }
 ingress {
    description = "Ssh access"
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
 }
 egress {

    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
 }
  }