# Output the instance's public IP and ID
output "instance_public_ip" {
  value = aws_lightsail_instance.create_instance.public_ip_address
}

output "instance_id" {
  value = aws_lightsail_instance.create_instance.id
}