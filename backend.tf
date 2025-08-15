terraform {
  backend "s3" {
    bucket         = "s3-tf-state-bucket-1234567890"      
    key            = "prod/terraform.tfstate"          
    region         = "us-east-1"                    
    encrypt        = true
    dynamodb_table = "tf-state-lock"
  }
}