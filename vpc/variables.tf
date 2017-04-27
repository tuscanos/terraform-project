#variable "aws_access_key" {}
#variable "aws_secret_key" {}

variable "aws_key_name" {
  default = "tf-aws-secure"
}

variable "aws_region" {
    description = "EC2 Region for the VPC"
    default = "us-west-2"
}


variable "vpc_cidr" {
  description = "CIDR for the whole VPC"
  default = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
  description = "CIDR for the Public Subnet"
  default = "10.0.0.0/24"
}

variable "public_subnet_avail_zone" {
  default = "us-west-2a"
}

variable "private_subnet_cidr" {
  description = "CIDR for the Private Subnet"
  default = "10.0.1.0/24"
}

variable "private_subnet_avail_zone" {
  default = "us-west-2b"
}

variable "nat_instance_type" {
  default = "t2.micro"
}

#variable "public_key_path" {
#  description = <<DESCRIPTION
#Path to the SSH public key to be used for authentication.
#Ensure this keypair is added to your local SSH agent so provisioners can
#connect.
#Example: ~/.ssh/terraform.pub
#DESCRIPTION
#}

#variable "key_name" {
#  description = "Desired name of AWS key pair"
#}


# Ubuntu Precise 12.04 LTS (x64)
variable "aws_amis" {
  default = "ami-4836a428"
#    us-wast-1 = "ami-7a85a01a"
#    us-west-2 = "ami-4836a428"

}
