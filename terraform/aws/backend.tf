terraform {
  backend "s3" {
    bucket         = "tf-remote-state-szymonrichert"
    dynamodb_table = "tf-remote-state-szymonrichert"

    key    = "kubernetes-aws-azure-hello-world/terraform/aws/tfstate"
    region = "eu-central-1"
  }
}
