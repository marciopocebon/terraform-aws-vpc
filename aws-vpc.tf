provider "aws" {
	access_key = "${var.aws_access_key}"
	secret_key = "${var.aws_secret_key}"
	region = "${var.aws_region}"
}

resource "aws_vpc" "default" {
	cidr_block = "${var.network}.0.0/16"
	enable_dns_hostnames = "true"
	tags {
		Name = "${var.aws_vpc_name}"
	}
}

output "aws_vpc_id" {
	value = "${aws_vpc.default.id}"
}

resource "aws_internet_gateway" "default" {
	vpc_id = "${aws_vpc.default.id}"
}

output "aws_internet_gateway_id" {
	value = "${aws_internet_gateway.default.id}"
}

resource "aws_subnet" "bastion" {
	vpc_id = "${aws_vpc.default.id}"
	cidr_block = "${var.network}.0.0/24"
	tags {
		Name = "${var.aws_vpc_name}-bastion"
	}
}

output "bastion_subnet" {
	value = "${aws_subnet.bastion.id}"
}

resource "aws_subnet" "microbosh" {
	vpc_id = "${aws_vpc.default.id}"
	cidr_block = "${var.network}.1.0/24"
	tags {
		Name = "${var.aws_vpc_name}-microbosh"
	}
}

output "aws_subnet_microbosh_id" {
  value = "${aws_subnet.microbosh.id}"
}

resource "aws_route_table" "public" {
	vpc_id = "${aws_vpc.default.id}"

	route {
		cidr_block = "0.0.0.0/0"
		gateway_id = "${aws_internet_gateway.default.id}"
	}
}

output "aws_route_table_public_id" {
	value = "${aws_route_table.public.id}"
}

resource "aws_route_table_association" "bastion-public" {
	subnet_id = "${aws_subnet.bastion.id}"
	route_table_id = "${aws_route_table.public.id}"
}

resource "aws_route_table_association" "bastion-microbosh" {
	subnet_id = "${aws_subnet.microbosh.id}"
	route_table_id = "${aws_route_table.public.id}"
}

resource "aws_security_group" "bastion" {
	name = "bastion"
	description = "Allow SSH traffic from the internet"
	vpc_id = "${aws_vpc.default.id}"

	ingress {
		from_port = 22
		to_port = 22
		protocol = "tcp"
		cidr_blocks = ["0.0.0.0/0"]
	}

	ingress {
		from_port = 0
		to_port = 65535
		protocol = "tcp"
		self = "true"
	}

	ingress {
		from_port = 0
		to_port = 65535
		protocol = "udp"
		self = "true"
	}

	ingress {
		cidr_blocks = ["0.0.0.0/0"]
		from_port = -1
		to_port = -1
		protocol = "icmp"
	}

	egress {
		from_port = 0
		to_port = 0
		protocol = "-1"
		cidr_blocks = ["0.0.0.0/0"]
	}

	tags {
		Name = "${var.aws_vpc_name}-bastion"
	}

}

output "aws_security_group_bastion_id" {
  value = "${aws_security_group.bastion.id}"
}

