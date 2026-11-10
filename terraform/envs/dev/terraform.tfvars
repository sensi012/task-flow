aws_region = "us-east-1"

project     = "taskflow"
environment = "dev"

cluster_name       = "taskflow-dev"
kubernetes_version = "1.31"

vpc_cidr = "10.0.0.0/16"

node_instance_types = ["t3.medium"]
node_min_size       = 2
node_max_size       = 4
node_desired_size   = 2

single_nat_gateway = true

# Dev convenience only.
# In real production, restrict this to your office/home IP or VPN CIDR.
eks_public_access_cidrs = ["0.0.0.0/0"]

# If you use SSO or assume roles, set this explicitly:
# eks_admin_principal_arn = "arn:aws:iam::123456789012:role/your-admin-role"