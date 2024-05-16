output "kubernetes_admin_role_arn" {
  value = module.eks_management_role.iam_role_arn
}
