terraform {
  required_version = ">= 1.7.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    bucket         = "task-state-flow"
    key            = "taskflow/dev/terraform.tfstate"
    region         = "us-east-1"
    use_lockfile = false
    encrypt        = true
  }
}