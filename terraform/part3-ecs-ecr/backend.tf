terraform {

  backend "s3" {

    bucket = "hanisha-terraform-state-123"

    key    = "ecs/terraform.tfstate"

    region = "ap-south-2"
  }
}