# Specify the provider and access details
provider "aws" {
    #access_key = "${var.aws_access_key}"
    #secret_key = "${var.aws_secret_key}"
    #region = "${var.aws_region}"
    region                  = "us-west-2"
}

# Create a VPC to launch our instances into
resource "aws_vpc" "default" {
  cidr_block = "${var.vpc_cidr}"
  tags {
    Name = "terraform-aws-vpc"
  }
}

# Create an internet gateway to give our subnet access to the outside world
resource "aws_internet_gateway" "default" {
  vpc_id = "${aws_vpc.default.id}"
}


# Public Subnet
resource "aws_subnet" "public" {
  vpc_id                  = "${aws_vpc.default.id}"
  cidr_block              = "${var.public_subnet_cidr}"
  availability_zone       = "${var.public_subnet_avail_zone}"
  map_public_ip_on_launch = true
  tags {
    Name = "terraform-public-subnet"
  }
}

resource "aws_route_table" "public_route_table" {
  vpc_id         = "${aws_vpc.default.id}"
  route {
        cidr_block = "0.0.0.0/0"
        gateway_id = "${aws_internet_gateway.default.id}"
    }
  tags {
        Name = "Public-Subnet-route-table"
    }
}

resource "aws_route_table_association" "public_rt_association" {
    subnet_id = "${aws_subnet.public.id}"
    route_table_id = "${aws_route_table.public_route_table.id}"
}

# Private Subnet
resource "aws_subnet" "private" {
    vpc_id = "${aws_vpc.default.id}"
    cidr_block = "${var.private_subnet_cidr}"
    availability_zone = "${var.private_subnet_avail_zone}"
    tags {
        Name = "terraform-private-subnet"
    }
}

resource "aws_route_table" "private_route_table" {
    vpc_id = "${aws_vpc.default.id}"
    route {
        cidr_block = "0.0.0.0/0"
        instance_id = "${aws_instance.nat-instance.id}"
    }
    tags {
        Name = "Private-Subnet-route-table"
    }
}

resource "aws_route_table_association" "private_rt_association" {
    subnet_id = "${aws_subnet.private.id}"
    route_table_id = "${aws_route_table.private_route_table.id}"
}


/*
  NAT Instance
*/
resource "aws_security_group" "nat_sg" {
    name = "vpc_nat"
    description = "Allow traffic to pass from the private subnet to the internet"
    ingress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["${var.private_subnet_cidr}"]
    }
    ingress {
        from_port = 443
        to_port = 443
        protocol = "tcp"
        cidr_blocks = ["${var.private_subnet_cidr}"]
    }
    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
        from_port = -1
        to_port = -1
        protocol = "icmp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    egress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    egress {
        from_port = 443
        to_port = 443
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    egress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["${var.vpc_cidr}"]
    }
    egress {
        from_port = -1
        to_port = -1
        protocol = "icmp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    vpc_id = "${aws_vpc.default.id}"

    tags {
        Name = "terraform-NATSG"
    }
}

resource "aws_instance" "nat-instance" {
    ami = "${var.aws_amis}" # this is a special ami preconfigured to do NAT
    availability_zone = "${var.public_subnet_avail_zone}"
    instance_type = "${var.nat_instance_type}"
    key_name = "${var.aws_key_name}"
    vpc_security_group_ids = ["${aws_security_group.nat_sg.id}"]
    subnet_id = "${aws_subnet.public.id}"
    associate_public_ip_address = true
    source_dest_check = false
    tags {
        Name = "terraform-VPC-NAT"
    }
    user_data = "${file("nat-userdata.sh")}"
}

#resource "aws_eip" "nat" {
#    instance = "${aws_instance.nat.id}"
#    vpc = true
#}
