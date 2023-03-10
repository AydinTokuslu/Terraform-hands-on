terraform {
  required_providers {
    github = {
      source = "integrations/github"
      version = "5.18.0"
    }
  }
}

provider "github" {
  token = var.token
  
}

variable "token" {
  type    = string
  default = "XXXXXXXX"
}

resource "github_repository" "github-test-repo" {
  name        = "github-test-repo"
  description = "terraform-git-hub-deneme"

}

