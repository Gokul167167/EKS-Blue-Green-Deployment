resource "aws_secretsmanager_secret" "secrets" {
  name        = var.secret_name
  description = var.description
 
  recovery_window_in_days = var.recovery_window_in_days
 
  tags = {
    Environment = "production"
    App         = "e-commerce"
  }
}
 
resource "random_password" "aurora_password" {
  length           = 16
  special          = true
  override_special = "_%#-"   # allow safe special chars
}

 
resource "aws_secretsmanager_secret_version" "type" {
  secret_id     = aws_secretsmanager_secret.secrets.id
  secret_string = var.secret_string
}