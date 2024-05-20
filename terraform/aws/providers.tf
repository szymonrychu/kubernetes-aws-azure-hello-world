terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">=4.9.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">=2.24.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = ">=2.13.2"
    }
  }
}

provider "aws" {
  region = "eu-central-1"
}

provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
  token                  = data.aws_eks_cluster_auth.current.token
}

provider "helm" {
  kubernetes {
    host                   = module.eks.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
    token                  = data.aws_eks_cluster_auth.current.token
  }
}
