# TaskFlow Terraform

Terraform infrastructure for the TaskFlow reliability project.

## Layout

- `bootstrap/`: creates S3 state bucket and DynamoDB lock table
- `modules/`: reusable Terraform modules
- `envs/dev/`: dev AWS environment

## Important

This creates real AWS resources.

Expected cost includes:

- EKS control plane
- EC2 worker nodes
- NAT gateway
- EBS volumes
- CloudWatch logs
- ECR
- load balancers if later deployed

Destroy resources when finished:

```bash
terraform destroy

---

# 13. Bootstrap the Terraform State Backend

From the repository root:

```bash
cd infra/terraform/bootstrap