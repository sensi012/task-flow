variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "project" {
  description = "Project name"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "cluster_name" {
  description = "EKS cluster name"
  type        = string
}

variable "kubernetes_version" {
  description = "EKS Kubernetes version"
  type        = string
  default     = "1.31"
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "node_instance_types" {
  description = "Instance types for EKS managed node group"
  type        = list(string)
  default     = ["t3.medium"]
}

variable "node_min_size" {
  description = "Minimum node group size"
  type        = number
  default     = 2
}

variable "node_max_size" {
  description = "Maximum node group size"
  type        = number
  default     = 4
}

variable "node_desired_size" {
  description = "Desired node group size"
  type        = number
  default     = 2
}

variable "single_nat_gateway" {
  description = "Use a single NAT gateway to reduce dev cost. For production, use one per AZ."
  type        = bool
  default     = true
}

variable "eks_public_access_cidrs" {
  description = "CIDRs allowed to access EKS public API endpoint. Restrict this in real production."
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "eks_admin_principal_arn" {
  description = "IAM principal ARN to grant cluster admin. If empty, current AWS identity is used. If using SSO or assumed roles, set this explicitly to the IAM role ARN."
  type        = string
  default     = ""
}