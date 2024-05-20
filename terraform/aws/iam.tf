module "eks_management_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role"
  version = "~> 5.39"

  trusted_role_arns = [
    "arn:aws:iam::${local.accound_id}:root",
  ]

  create_role = true

  role_name         = var.environment_name
  role_requires_mfa = true

  custom_role_policy_arns = [
    "arn:aws:iam::aws:policy/AmazonCognitoReadOnly",
    "arn:aws:iam::aws:policy/AlexaForBusinessFullAccess",
  ]
  number_of_custom_role_policy_arns = 2
}

resource "aws_iam_policy" "aws_loadbalancer_controller" {
  name        = "${var.environment_name}-aws-loadbalancer-controller"
  description = "" # TODO: FIX missing description
  policy      = data.aws_iam_policy_document.aws_loadbalancer_controller.json
}

module "aws_loadbalancer_controller" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-eks-role"
  version = "~> 5.39"

  role_name = "${var.environment_name}-aws-loadbalancer-controller"

  allow_self_assume_role = true
  cluster_service_accounts = {
    (var.environment_name) = ["${local.k8s_sa_lb_namespace}:${local.k8s_sa_lb_name}"]
  }

  tags = var.tags

  role_policy_arns = {
    AmazonEKS_CNI_Policy        = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
    aws_loadbalancer_controller = aws_iam_policy.aws_loadbalancer_controller.arn
  }
}
