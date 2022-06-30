terraform {
  backend "s3" {
    encrypt = true    
    bucket = "ankit-webserver-state"
    dynamodb_table = "ankit-webserver-lock"
    key    = "terraform.tfstate"
    region = "us-west-2"
  }
}