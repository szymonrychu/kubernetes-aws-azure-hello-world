module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.10"

  cluster_name    = var.environment_name
  cluster_version = "1.24"

  cluster_endpoint_private_access = true
  cluster_endpoint_public_access  = true

  cluster_addons = {
    coredns = {
      resolve_conflicts_on_update = "OVERWRITE"
    }
    kube-proxy = {}
    vpc-cni = {
      resolve_conflicts_on_update = "OVERWRITE"
    }
  }

  create_kms_key = true
  cluster_encryption_config = {
    resources = ["secrets"]
  }
  kms_key_deletion_window_in_days = 7
  enable_kms_key_rotation         = true

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  # EKS Managed Node Group(s)
  eks_managed_node_group_defaults = {
    disk_size      = 50
    instance_types = ["m6i.large", "m5.large", "m5n.large", "m5zn.large"]
  }

  eks_managed_node_groups = {
    main = {
      min_size     = 1
      max_size     = 10
      desired_size = 1

      instance_types = ["t3.large"]
      capacity_type  = var.eks_capacity_type
    }
  }

  cluster_identity_providers = {
    sts = {
      client_id = "sts.amazonaws.com"
    }
  }

  access_entries = {
    # One access entry with a policy associated
    admins = {
      principal_arn = module.eks_management_role.iam_role_arn

      policy_associations = {
        example = {
          policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
          access_scope = {
            type = "cluster"
          }
        }
      }
    }
  }

  tags = var.tags
}
