
output "public_ip" {
  value       = aws_instance.example-app-vm.public_ip
  description = "This is the IPv4 of the created compute instance."
}

output "instance_id" {
  value       = aws_instance.example-app-vm.id
  description = "This is the instance ID of the compute instance."
}