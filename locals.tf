
data "aws_availability_zones" "available" {}

data "aws_caller_identity" "current" {}

data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners     = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm*"]
  }
}


locals {
  env                 = "dev"
  az1                 = data.aws_availability_zones.available.names[0]
  az2                 = data.aws_availability_zones.available.names[1]
  ami                 = data.aws_ami.amazon_linux_2.id
  region              = var.region
  account_id          = data.aws_caller_identity.current.account_id
}