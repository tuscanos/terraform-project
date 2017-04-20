provider "aws" {
  region = "us-east-1"
}

resource "aws_instance" "s_instance" {
  ami = "ami-e3106686"
  instance_type = "t2.micro"
  tags {
    Name = "hello-instance"
  }
  key_name = "ll_aws_secure"
  subnet_id = "subnet-5d49e676"
}
