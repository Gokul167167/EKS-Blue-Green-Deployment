output "bastion_instance_id" {
  description = "The EC2 Instance ID of the Bastion server"
  value       = aws_instance.bastion.id
}

output "bastion_public_ip" {
  description = "The public IP address of the Bastion server"
  value       = aws_instance.bastion.public_ip
}
