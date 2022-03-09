
module "eks" {
  source = "terraform-aws-modules/eks/aws"

  cluster_name                    = "devtron-cluster"
  cluster_version                 = "1.21"
  cluster_endpoint_private_access = true
  cluster_endpoint_public_access  = true

  cluster_addons = {
    coredns = {
      resolve_conflicts = "OVERWRITE"
    }
    kube-proxy = {}
    vpc-cni = {
      resolve_conflicts = "OVERWRITE"
    }

  }



  vpc_id     = "vpc-014e9f9b52be4b84f"
  subnet_ids = ["subnet-067398d1e40c9fe96", "subnet-0b8a35353ce4cc232","subnet-03ba650e264ba62c3","subnet-07cb77b2d7b3aa2ae"]

  self_managed_node_group_defaults = {
    disk_size = 50
    update_launch_template_default_version = true
    iam_role_additional_policies = [
      "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy",
      "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy",
      "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryFullAccess",
      "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy",
      "arn:aws:iam::aws:policy/AmazonEKSServicePolicy",
      "arn:aws:iam::657792652926:policy/eks-role"
    ]
  }

  self_managed_node_groups = {
    one = {
      name = "devtron-nodes"

      min_size     = 2
      max_size     = 5
      desired_size = 2

      use_mixed_instances_policy = true
      mixed_instances_policy = {
        instances_distribution = {
          on_demand_base_capacity                  = 2
          on_demand_percentage_above_base_capacity = 0
          spot_allocation_strategy                 = "capacity-optimized"
        }

        override = [
          {
            instance_type     = "t2.micro"
            weighted_capacity = "1"
          },
          {
            instance_type     = "t2.medium"
            weighted_capacity = "1"
          },
          {
            instance_type     = "t2.small"
            weighted_capacity = "1"
          }
        ]
            
      }
            
    #  key_name = "devops.pem"

      bootstrap_extra_args = "--kubelet-extra-args --kube-reserved memory=200Mi ,cpu=200m ,ephemeral-storage=1Gi --kube-reserved-cgroup --system-reserved memory=200Mi,ephemeral-storage=1Gi --eviction-hard memory.available=200Mi,nodefs.available=10% --featureGates DynamicKubeletConfig=true,RotateKubeletServerCertificate=true,CPUManager=true"
}
    two = {
      name = "ci-nodes"

      min_size     = 1
      max_size     = 5
      desired_size = 1

      use_mixed_instances_policy = true
      mixed_instances_policy = {
        instances_distribution = {
          on_demand_base_capacity                  = 0
          on_demand_percentage_above_base_capacity = 0
          spot_allocation_strategy                 = "capacity-optimized"
        }

        override = [
          {
            instance_type     = "t2.micro"
            weighted_capacity = "1"
          },
          {
            instance_type     = "t2.medium"
            weighted_capacity = "1"
          },
          {
            instance_type     = "t2.small"
            weighted_capacity = "1"
          }
        ]
      }
            # key_name = "devops.pem"

      bootstrap_extra_args = "--kubelet-extra-args --kube-reserved memory=200Mi ,ephemeral-storage=1Gi --system-reserved memory=200Mi,ephemeral-storage=1Gi --eviction-hard memory.available=200Mi,nodefs.available=10% --featureGates DynamicKubeletConfig=true,RotateKubeletServerCertificate=true"

      taints = [
        {
          key   = "dedicated"
          value = "ci:NoSchedule"

        }
      ]


    }
  }

  tags = {
    Component = "cicd"
  }
}
