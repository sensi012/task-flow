output "state_bucket" {
  description = "Terraform state bucket"
  value       = aws_s3_bucket.state.id
}

output "bootstrap_summary" {
  description = "Use these values in the dev backend configuration"
  value       = <<-EOT
    S3 bucket:
      ${aws_s3_bucket.state.id}
      
    Backend:
      bucket         = "${aws_s3_bucket.state.id}"
  EOT
}