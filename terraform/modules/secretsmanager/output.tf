output "secret_arn" {
  description = "ARN of the created Secrets Manager secret"
  value       = aws_secretsmanager_secret.secrets.arn
}

output "secret_name" {
  description = "Name of the created Secrets Manager secret"
  value       = aws_secretsmanager_secret.secrets.name
}

output "random_password" {
  value = data.aws_secretsmanager_random_password.password.random_password
}