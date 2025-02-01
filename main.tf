
# Configure the AWS Provider
provider "aws" {
 # Replace with your actual AWS credentials
 access_key = ""
 secret_key = ""
 region = "us-east-1" # Replace with your desired region
}
# Retrieve the list of AZs in the current AWS region
data "aws_availability_zones" "available" {}
# Define the VPC
resource "aws_vpc" "vpc" {
 cidr_block = var.vpc_cidr
 tags = {
 Name = var.vpc_name
 }
}
# Deploy the private subnets
resource "aws_subnet" "private_subnets" {
 for_each = var.private_subnets
 vpc_id = aws_vpc.vpc.id
 cidr_block = cidrsubnet(var.vpc_cidr, 8, each.value)
 availability_zone = tolist(data.aws_availability_zones.available.names)[each.value]
 tags = {
 Name = each.key
 }
}
# Deploy the public subnets
resource "aws_subnet" "public_subnets" {
 for_each = var.public_subnets
 vpc_id = aws_vpc.vpc.id
 cidr_block = cidrsubnet(var.vpc_cidr, 8, each.value + 100)
 availability_zone = tolist(data.aws_availability_zones.available.names)[each.value]
 map_public_ip_on_launch = true
 tags = {
 Name = each.key
 }
}
# Create route tables for public and private subnets
resource "aws_route_table" "public_route_table" {
 vpc_id = aws_vpc.vpc.id
 route {
 cidr_block = "0.0.0.0/0"
 gateway_id = aws_internet_gateway.internet_gateway.id
 }
 tags = {
 Name = "demo_public_rtb"
 }
}
resource "aws_route_table" "private_route_table" {
 vpc_id = aws_vpc.vpc.id
 route {
 cidr_block = "0.0.0.0/0"
 nat_gateway_id = aws_nat_gateway.nat_gateway.id
 }
 tags = {
 Name = "demo_private_rtb"
 }
}
# Create route table associations
resource "aws_route_table_association" "public" {
 for_each = aws_subnet.public_subnets
 route_table_id = aws_route_table.public_route_table.id
 subnet_id = each.value.id
}
resource "aws_route_table_association" "private" {
 for_each = aws_subnet.private_subnets
 route_table_id = aws_route_table.private_route_table.id
 subnet_id = each.value.id
}
# Create Internet Gateway
resource "aws_internet_gateway" "internet_gateway" {
 vpc_id = aws_vpc.vpc.id
 tags = {
 Name = "demo_igw"
 }
}
# Create EIP for NAT Gateway
resource "aws_eip" "nat_gateway_eip" {
 domain = "vpc"
 tags = {
 Name = "demo_igw_eip"
 }
}
# Create NAT Gateway
resource "aws_nat_gateway" "nat_gateway" {
 allocation_id = aws_eip.nat_gateway_eip.id
 subnet_id = aws_subnet.public_subnets["public_subnet_1"].id
 tags = {
 Name = "demo_nat_gateway"
 }
}
