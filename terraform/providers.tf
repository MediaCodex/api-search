terraform {
  backend "s3" {
    bucket         = "terraform-state-mediacodex"
    key            = "search.tfstate"
    region         = "eu-central-1"
    encrypt        = true
    dynamodb_table = "terraform-state-lock"
    role_arn       = "arn:aws:iam::939514526661:role/remotestate/search"
    session_name   = "terraform"
  }
}

variable "deploy_aws_roles" {
  type = map(string)
  default = {
    dev  = "arn:aws:iam::949257948165:role/deploy-search"
    prod = "arn:aws:iam::000000000000:role/deploy-search"
  }
}

variable "deploy_aws_accounts" {
  type = map(list(string))
  default = {
    dev  = ["949257948165"]
    prod = ["000000000000"]
  }
}

provider "aws" {
  version             = "~> 3.0"
  region              = "eu-central-1"
  allowed_account_ids = var.deploy_aws_accounts[local.environment]
  assume_role {
    role_arn = var.deploy_aws_roles[local.environment]
  }
}
data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

data "terraform_remote_state" "core" {
  backend   = "s3"
  workspace = terraform.workspace
  config = {
    bucket       = "terraform-state-mediacodex"
    key          = "core.tfstate"
    region       = "eu-central-1"
    role_arn     = "arn:aws:iam::939514526661:role/remotestate/website"
    session_name = "terraform"
  }
}

