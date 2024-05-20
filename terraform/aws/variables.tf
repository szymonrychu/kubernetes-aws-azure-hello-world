variable "environment_name" {
  description = "Name of the environment"
  type        = string
  nullable    = false
}

variable "eks_capacity_type" {
  description = "Type of capacity type used for EKS managed node groups"
  type        = string
  default     = "ON_DEMAND"
}

variable "tags" {
  description = "A mapping of tags to assign to resources."
  type        = map(string)
  default = {
    Terraform = "true"
  }
}
