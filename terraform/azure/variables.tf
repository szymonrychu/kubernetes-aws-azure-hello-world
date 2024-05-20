variable "environment_name" {
  description = "Name of the environment"
  type        = string
  nullable    = false
}
variable "location" {
  description = "Azure region"
  type        = string
  nullable    = false
}
variable "vnetcidr" {
  description = "CIDR for the main VNET"
  type        = string
  nullable    = false
}
variable "websubnetcidr" {
  description = "CIDR for the web subnet (with application gateway)"
  type        = string
  nullable    = false
}

variable "appsubnetcidr" {
  description = "CIDR for the app subnet (with AKS cluster)"
  type        = string
  nullable    = false
}

variable "ssl_certificate_name" {
  description = "Name of the SSL certificate"
  type        = string
  default     = null
  nullable    = true
}

variable "tags" {
  description = "A mapping of tags to assign to resources."
  type        = map(string)
  default = {
    Terraform = "true"
  }
}
