resource "aws_secretsmanager_secret" "secrets" {
  name        = var.secret_name
  description = var.description
 
  recovery_window_in_days = var.recovery_window_in_days
 
  tags = {
    Environment = "production"
    App         = "e-commerce"
  }
}
 
data "aws_secretsmanager_random_password" "password" {
  password_length = 8
  require_each_included_type = true
}
 
resource "aws_secretsmanager_secret_version" "type" {
  secret_id     = aws_secretsmanager_secret.secrets.id
  secret_string = var.secret_string
}