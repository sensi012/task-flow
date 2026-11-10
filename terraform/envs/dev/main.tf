data "aws_caller_identity" "current" {}

data "aws_partition" "current" {}

data "aws_availability_zones" "available" {
  state = "available"
}

locals {
  az_count = min(3, length(data.aws_availability_zones.available.names))
  azs      = slice(data.aws_availability_zones.available.names, 0, local.az_count)

  public_subnets  = [for i in range(local.az_count) : cidrsubnet(var.vpc_cidr, 8, 101 + i)]
  private_subnets = [for i in range(local.az_count) : cidrsubnet(var.vpc_cidr, 5, i)]

  cluster_admin_policy_arn = "arn:${data.aws_partition.current.partition}:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = "${var.project}-${var.environment}-vpc"
  cidr = var.vpc_cidr

  azs             = local.azs
  public_subnets  = local.public_subnets
  private_subnets = local.private_subnets

  enable_nat_gateway = true
  single_nat_gateway = var.single_nat_gateway

  enable_dns_hostnames = true
  enable_dns_support   = true

  public_subnet_tags = {
    "kubernetes.io/role/elb"                      = "1"
    "kubernetes.io/cluster/${var.cluster_name}"  = "shared"
  }

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb"             = "1"
    "kubernetes.io/cluster/${var.cluster_name}"  = "shared"
  }

  tags = {
    Name        = "${var.project}-${var.environment}-vpc"
    Project     = var.project
    Environment = var.environment
  }
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = var.cluster_name
  cluster_version = var.kubernetes_version

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  # For real production, restrict public endpoint access.
  cluster_endpoint_public_access       = true
  cluster_endpoint_private_access      = true
  cluster_endpoint_public_access_cidrs = var.eks_public_access_cidrs

  enable_irsa = true

  authentication_mode = "API_AND_CONFIG_MAP"

  cluster_enabled_log_types = [
    "api",
    "audit",
    "authenticator"
  ]

  cluster_addons = {
    coredns = {
      most_recent = true
    }

    kube-proxy = {
      most_recent = true
    }

    vpc-cni = {
      most_recent    = true
      before_compute = true
    }
  }

  eks_managed_node_groups = {
    general = {
      name           = "general"
      instance_types = var.node_instance_types

      min_size     = var.node_min_size
      max_size     = var.node_max_size
      desired_size = var.node_desired_size

      disk_size = 50

      labels = {
        role = "general"
      }

      tags = {
        Name        = "${var.cluster_name}-general"
        Project     = var.project
        Environment = var.environment
      }
    }
  }

  access_entries = {
    admin = {
      principal_arn = coalesce(
        var.eks_admin_principal_arn,
        data.aws_caller_identity.current.arn
      )

      access_policy_associations = {
        cluster-admin = {
          policy_arn = local.cluster_admin_policy_arn
        }
      }
    }
  }

  tags = {
    Name        = var.cluster_name
    Project     = var.project
    Environment = var.environment
  }
}

module "ebs_csi_irsa" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "~> 5.0"

  role_name                    = "${var.cluster_name}-ebs-csi"
  attach_ebs_csi_driver_policy = true

  oidc_providers = {
    main = {
      provider_arn = module.eks.oidc_provider_arn

      namespace_service_account_name_pairs = {
        kube-system = ["ebs-csi-controller-sa"]
      }
    }
  }

  tags = {
    Project     = var.project
    Environment = var.environment
  }
}

data "aws_eks_addon_version" "ebs_csi" {
  addon_name         = "aws-ebs-csi-driver"
  kubernetes_version = module.eks.cluster_version
  most_recent        = true

  depends_on = [
    module.eks
  ]
}

resource "aws_eks_addon" "ebs_csi" {
  cluster_name             = module.eks.cluster_name
  addon_name               = "aws-ebs-csi-driver"
  addon_version            = data.aws_eks_addon_version.ebs_csi.version
  service_account_role_arn = module.ebs_csi_irsa.iam_role_arn

  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"

  depends_on = [
    module.eks,
    module.ebs_csi_irsa
  ]
}

module "aws_lb_controller_irsa" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "~> 5.0"

  role_name                            = "${var.cluster_name}-aws-lb-controller"
  attach_load_balancer_controller_policy = true

  oidc_providers = {
    main = {
      provider_arn = module.eks.oidc_provider_arn

      namespace_service_account_name_pairs = {
        kube-system = ["aws-load-balancer-controller"]
      }
    }
  }

  tags = {
    Project     = var.project
    Environment = var.environment
  }
}

module "ecr" {
  source = "../../modules/ecr"

  project     = var.project
  environment = var.environment

  # Convenient for dev/demo.
  # Set false for real production unless you really understand the impact.
  force_delete = true

  repositories = {
    "taskflow/api" = {
      description     = "TaskFlow API container image"
      max_image_count = 20
    }

    "taskflow/worker" = {
      description     = "TaskFlow worker container image"
      max_image_count = 20
    }
  }
}