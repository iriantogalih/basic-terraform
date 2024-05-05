output "my_ip_public" {
  value = aws_instance.ec2_example.public_ip  
}

output "my_ip_private" {
  value = aws_instance.ec2_example.private_ip 
}
