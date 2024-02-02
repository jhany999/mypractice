provider "aws" {
  region = "us-east-1"  # Replace with your desired region
}

resource "aws_vpc" "my_vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "my-vpc"
  }
}

resource "aws_subnet" "public_subnet_1" {
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-east-1a"
  vpc_id = aws_vpc.my_vpc.id
  map_public_ip_on_launch = "true"
  tags = {
    Name = "public-subnet-1"
  }
}

resource "aws_subnet" "public_subnet_2" {
  cidr_block = "10.0.2.0/24"
  availability_zone = "us-east-1b"
  vpc_id = aws_vpc.my_vpc.id
   map_public_ip_on_launch = "true"
  
  tags = {
    Name = "public-subnet-2"
  }
}

resource "aws_internet_gateway" "my_igw" {
  vpc_id = aws_vpc.my_vpc.id
}

resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.my_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my_igw.id
  }
}

resource "aws_route_table_association" "public_subnet_1_association" {
  subnet_id      = aws_subnet.public_subnet_1.id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_route_table_association" "public_subnet_2_association" {
  subnet_id      = aws_subnet.public_subnet_2.id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_security_group" "allow_ssh" {
  name        = "allow_ssh"
  description = "Allow SSH traffic"
  vpc_id      = aws_vpc.my_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
   ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "my_instance" {
  ami           = "ami-0c7217cdde317cfec"  # Replace with your desired AMI
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.public_subnet_1.id  # Choose desired subnet
  vpc_security_group_ids = [aws_security_group.allow_ssh.id]
  key_name = "vedha"  # Replace with your SSH key name
  for_each = toset(["jenkins-master","build-slave","ansible"])
  tags = {
    Name = "${each.key}"
  }
}
