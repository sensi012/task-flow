variable "project" {
  description = "Project name"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "force_delete" {
  description = "Allow ECR repositories to be deleted even if images exist. Convenient for dev, dangerous for prod."
  type        = bool
  default     = false
}

variable "repositories" {
  description = "ECR repositories to create"
  type = map(object({
    description          = optional(string, "")
    image_tag_mutability = optional(string, "IMMUTABLE")
    scan_on_push         = optional(bool, true)
    max_image_count      = optional(number, 20)
  }))
  default = {}
}