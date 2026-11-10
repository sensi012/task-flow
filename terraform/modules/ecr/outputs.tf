output "repository_names" {
  description = "ECR repository names"
  value       = { for name, repo in aws_ecr_repository.this : name => repo.name }
}

output "repository_arns" {
  description = "ECR repository ARNs"
  value       = { for name, repo in aws_ecr_repository.this : name => repo.arn }
}

output "repository_urls" {
  description = "ECR repository URLs"
  value       = { for name, repo in aws_ecr_repository.this : name => repo.repository_url }
}

output "registry_id" {
  description = "ECR registry ID"
  value       = length(aws_ecr_repository.this) > 0 ? values(aws_ecr_repository.this)[0].registry_id : ""
}