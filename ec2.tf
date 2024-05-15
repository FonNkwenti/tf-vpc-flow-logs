# EC2 exec role
resource "aws_iam_role" "vpca_ec2_exec_role" {
  name = "vpca-ec2-exec-role"

  assume_role_policy = jsonencode(
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
})

  tags = {
    tag-key = "vpca-ec2-exec-role"
  }
}




resource "aws_iam_policy_attachment" "ssm_manager_attachment" {
  name       = "ec2-exec-attachement"
  roles      = [aws_iam_role.vpca_ec2_exec_role.name]
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}


resource "aws_iam_instance_profile" "instance_a_profile" {
  name = "instance-a-profile"
  role = aws_iam_role.vpca_ec2_exec_role.name
}


resource "aws_instance" "vpc_flow_logs_instance" {
  ami                    = local.ami
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.flow_logs_pub_sn_az1.id
  associate_public_ip_address = true
  key_name = "default-euc1"
  vpc_security_group_ids = [aws_security_group.www_sg.id]
  iam_instance_profile   = aws_iam_instance_profile.instance_a_profile.name
   user_data_replace_on_change = true
  user_data_base64 = "IyEvYmluL2Jhc2gNCnN1ZG8geXVtIHVwZGF0ZSAteQ0Kc3VkbyB5dW0gaW5zdGFsbCAteSBodHRwZA0Kc3VkbyBzeXN0ZW1jdGwgc3RhcnQgaHR0cGQNCnN1ZG8gc3lzdGVtY3RsIGVuYWJsZSBodHRwZA0Kc3VkbyB1c2VybW9kIC1hIC1HIGFwYWNoZSBlYzItdXNlcg0Kc3VkbyBjaG93biAtUiBlYzItdXNlcjphcGFjaGUgL3Zhci93d3cNCnN1ZG8gY2htb2QgMjc3NSAvdmFyL3d3dw0Kc3VkbyBmaW5kIC92YXIvd3d3IC10eXBlIGQgLWV4ZWMgY2htb2QgMjc3NSB7fSBcOw0Kc3VkbyBmaW5kIC92YXIvd3d3IC10eXBlIGYgLWV4ZWMgY2htb2QgMDY2NCB7fSBcOw0Kc3VkbyBlY2hvICI8P3BocCBwaHBpbmZvKCk7ID8+IiA+IC92YXIvd3d3L2h0bWwvcGhwaW5mby5waHA="

  tags = {
    Name = "vpc-flow-log-instance"
  }
}
