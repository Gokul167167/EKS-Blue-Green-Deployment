output "secret_arn" {
  description = "ARN of the created Secrets Manager secret"
  value       = aws_secretsmanager_secret.secrets.arn
}

output "secret_name" {
  description = "Name of the created Secrets Manager secret"
  value       = aws_secretsmanager_secret.secrets.name
}

output "random_password" {
  description = "Generated random password for Aurora"
  value       = random_password.aurora_password.result
  sensitive   = true
}