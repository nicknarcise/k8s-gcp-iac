terraform {
  required_version = ">= 1.4.0"

  backend "remote" {
    hostname     = "app.terraform.io"
    organization = "n2solutions-io"

    workspaces {
      name = "k8s-gcp-iac"
    }
  }
}
provider "google" {
    project = "k8s-tfc"
    region = "us-east1"
    zone = "us-east1-b"
}