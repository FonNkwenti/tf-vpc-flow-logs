resource "aws_vpc" "this" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = {
    Name = "flow-logs-vpc"
    Env = var.tag_environment
    Project = var.tag_project
  }

}


resource "aws_subnet" "flow_logs_pub_sn_az1" {
  vpc_id                  = aws_vpc.this.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = true
  tags = {
    Name = "flow-logs-pub-sn-az1"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name = "flow_logs_igw"
  }
}

resource "aws_route_table" "flow_logs_pub_rt_az1" {
  vpc_id = aws_vpc.this.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this.id
  }


  tags = {
    Name = "flow-logs-pub-rt-az1"
  }
}


resource "aws_route_table_association" "pub_rta1_az1" {
  subnet_id      = aws_subnet.flow_logs_pub_sn_az1.id
  route_table_id = aws_route_table.flow_logs_pub_rt_az1.id
}

# VPC Flow Log config
resource "aws_flow_log" "vpc_flow_logs" {
  iam_role_arn              = aws_iam_role.vpc_flow_logs.arn
  log_destination           = aws_cloudwatch_log_group.flow_logs.arn
  traffic_type              = "ALL"
  vpc_id                    = aws_vpc.this.id
  max_aggregation_interval  = 60
  log_format                = "$${version} $${account-id} $${interface-id} $${srcaddr} $${dstaddr} $${srcport} $${dstport} $${protocol} $${packets} $${bytes} $${start} $${end} $${action} $${log-status}"
  tags = {
    Name = "vpc-flow-logs"
  }

}

resource "aws_cloudwatch_log_group" "flow_logs" {
  name              = "/aws/vpc/vpc-flow-logs"
  retention_in_days = 7  
}

resource "aws_iam_role" "vpc_flow_logs" {
  name = "vpc-flow-logs-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "vpc-flow-logs.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}



resource "aws_iam_role_policy" "vpc_flow_logs" {
  name = "vpc-flow-logs-cloudwatch-policy"
  role = aws_iam_role.vpc_flow_logs.id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents",
        "logs:DescribeLogGroups",
        "logs:DescribeLogStreams"
      ],
      "Effect": "Allow",
      "Resource": [
        "arn:aws:logs:*:*:log-group:/aws/vpc/flow-logs*",
        "arn:aws:logs:*:*:log-stream:/aws/vpc/flow-logs*"
      ]
    }
  ]
}
EOF
}

