output "vpc_flow_logs_instance_public_ip" {
    value = aws_instance.vpc_flow_logs_instance.public_ip
}
output "vpc_flow_logs_instance_public_dns" {
    value = aws_instance.vpc_flow_logs_instance.public_dns
}

