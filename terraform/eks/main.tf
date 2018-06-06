variable "aws_profile" {}

variable "deployment_stage" {}

variable "aws_region" {}

variable "account_id" {}

variable "vpc_cidr_block" {}

variable "subnet_cidr_block_one" {}

variable "subnet_cidr_block_two" {}

variable "availability_zones" {
  default = [
    "us-east-1a",
    "us-east-1c",
    "us-east-1d"
  ]
  type = "list"
}

provider "aws" {
  region = "${var.aws_region}"
  profile = "${var.aws_profile}"
}

////
// general setup
//

terraform {
  backend "s3" {}
}

////
// Network setup
//

resource "aws_vpc" "ingest_eks" {
  cidr_block = "${var.vpc_cidr_block}"

  tags = "${
    map(
     "Name", "ingest-eks-${var.deployment_stage}",
     "kubernetes.io/cluster/ingest-eks-${var.deployment_stage}", "shared",
    )
  }"
}

resource "aws_subnet" "ingest_eks" {
  count = 2

  availability_zone = "${var.availability_zones[count.index]}"
  cidr_block        = "10.10.${count.index}.0/24"
  vpc_id            = "${aws_vpc.ingest_eks.id}"

  tags = "${
    map(
     "Name", "ingest-eks-${var.deployment_stage}",
     "kubernetes.io/cluster/ingest-eks-${var.deployment_stage}", "shared",
    )
  }"
}

resource "aws_internet_gateway" "ingest_eks" {
  vpc_id = "${aws_vpc.ingest_eks.id}"

  tags {
    Name = "ingest-eks-${var.deployment_stage}"
  }
}

resource "aws_route_table" "ingest_eks" {
  vpc_id = "${aws_vpc.ingest_eks.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.ingest_eks.id}"
  }
}

resource "aws_route_table_association" "ingest_eks" {
  count = 2

  subnet_id      = "${aws_subnet.ingest_eks.*.id[count.index]}"
  route_table_id = "${aws_route_table.ingest_eks.id}"
}

resource "aws_security_group" "ingest_eks_cluster" {
  name        = "ingest-eks-cluster-${var.deployment_stage}"
  description = "Cluster communication with worker nodes"
  vpc_id      = "${aws_vpc.ingest_eks.id}"

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name = "ingest-eks-${var.deployment_stage}"
  }
}

resource "aws_security_group_rule" "ingest_eks_cluster_ingress_workstation_https" {
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "Allow workstation to communicate with the cluster API Server"
  from_port         = 443
  protocol          = "tcp"
  security_group_id = "${aws_security_group.ingest_eks_cluster.id}"
  to_port           = 443
  type              = "ingress"
}

////
// IAM Setup
//

resource "aws_iam_role" "ingest_eks_cluster" {
  name = "ingest-eks-cluster-${var.deployment_stage}"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "ingest_eks_cluster_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = "${aws_iam_role.ingest_eks_cluster.name}"
}

resource "aws_iam_role_policy_attachment" "ingest_eks_service_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
  role       = "${aws_iam_role.ingest_eks_cluster.name}"
}

////
// Cluster and Node setup
//

resource "aws_eks_cluster" "ingest_eks" {
  name            = "ingest-eks-${var.deployment_stage}"
  role_arn        = "${aws_iam_role.ingest_eks_cluster.arn}"

  vpc_config {
    security_group_ids = ["${aws_security_group.ingest_eks_cluster.id}"]
    subnet_ids         = ["${aws_subnet.ingest_eks.*.id}"]
  }

  depends_on = [
    "aws_iam_role_policy_attachment.ingest_eks_cluster_policy",
    "aws_iam_role_policy_attachment.ingest_eks_service_policy",
  ]
}

////
// Worker node IAM setup
//

resource "aws_iam_role" "ingest_eks_node" {
  name = "ingest-eks-node-${var.deployment_stage}"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "ingest_eks_node_AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = "${aws_iam_role.ingest_eks_node.name}"
}

resource "aws_iam_role_policy_attachment" "ingest_eks_node_AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = "${aws_iam_role.ingest_eks_node.name}"
}

resource "aws_iam_role_policy_attachment" "ingest_eks_node_AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = "${aws_iam_role.ingest_eks_node.name}"
}

resource "aws_iam_instance_profile" "ingest_eks_node" {
  name = "terraform-eks-demo"
  role = "${aws_iam_role.ingest_eks_node.name}"
}

////
// Worker node security group setup
//

resource "aws_security_group" "ingest_eks_node" {
  name        = "ingest-eks-node-${var.deployment_stage}"
  description = "Security group for all nodes in the cluster"
  vpc_id      = "${aws_vpc.ingest_eks.id}"

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = "${
    map(
     "Name", "ingest-eks-node-${var.deployment_stage}",
     "ingest-eks-${var.deployment_stage}", "owned",
    )
  }"
}

resource "aws_security_group_rule" "ingest_node_ingress_self" {
  description              = "Allow node to communicate with each other"
  from_port                = 0
  protocol                 = "-1"
  security_group_id        = "${aws_security_group.ingest_eks_node.id}"
  source_security_group_id = "${aws_security_group.ingest_eks_node.id}"
  to_port                  = 65535
  type                     = "ingress"
}

resource "aws_security_group_rule" "ingest_node_ingress_cluster" {
  description              = "Allow worker Kubelets and pods to receive communication from the cluster control plane"
  from_port                = 1025
  protocol                 = "tcp"
  security_group_id        = "${aws_security_group.ingest_eks_node.id}"
  source_security_group_id = "${aws_security_group.ingest_eks_cluster.id}"
  to_port                  = 65535
  type                     = "ingress"
}

resource "aws_security_group_rule" "ingest_cluster_ingress_node_https" {
  description              = "Allow pods to communicate with the cluster API Server"
  from_port                = 443
  protocol                 = "tcp"
  security_group_id        = "${aws_security_group.ingest_eks_cluster.id}"
  source_security_group_id = "${aws_security_group.ingest_eks_node.id}"
  to_port                  = 443
  type                     = "ingress"
}


////
// Worker Node Instance Setup
//

data "aws_region" "current" {}

data "aws_ami" "eks_worker" {
  filter {
    name   = "name"
    values = ["eks-worker-*"]
  }

  most_recent = true
}

locals {
  ingest-node-userdata = <<USERDATA
#!/bin/bash -xe

CA_CERTIFICATE_DIRECTORY=/etc/kubernetes/pki
CA_CERTIFICATE_FILE_PATH=$CA_CERTIFICATE_DIRECTORY/ca.crt
mkdir -p $CA_CERTIFICATE_DIRECTORY
echo "${aws_eks_cluster.ingest_eks.certificate_authority.0.data}" | base64 -d >  $CA_CERTIFICATE_FILE_PATH
INTERNAL_IP=$(curl -s http://169.254.169.254/latest/meta-data/local-ipv4)
sed -i s,MASTER_ENDPOINT,${aws_eks_cluster.ingest_eks.endpoint},g /var/lib/kubelet/kubeconfig
sed -i s,CLUSTER_NAME,ingest-eks-${var.deployment_stage},g /var/lib/kubelet/kubeconfig
sed -i s,REGION,${data.aws_region.current.name},g /etc/systemd/system/kubelet.service
sed -i s,MAX_PODS,20,g /etc/systemd/system/kubelet.service
sed -i s,MASTER_ENDPOINT,${aws_eks_cluster.ingest_eks.endpoint},g /etc/systemd/system/kubelet.service
sed -i s,INTERNAL_IP,$INTERNAL_IP,g /etc/systemd/system/kubelet.service
DNS_CLUSTER_IP=10.100.0.10
if [[ $INTERNAL_IP == 10.* ]] ; then DNS_CLUSTER_IP=172.20.0.10; fi
sed -i s,DNS_CLUSTER_IP,$DNS_CLUSTER_IP,g /etc/systemd/system/kubelet.service
sed -i s,CERTIFICATE_AUTHORITY_FILE,$CA_CERTIFICATE_FILE_PATH,g /var/lib/kubelet/kubeconfig
sed -i s,CLIENT_CA_FILE,$CA_CERTIFICATE_FILE_PATH,g  /etc/systemd/system/kubelet.service
systemctl daemon-reload
systemctl restart kubelet kube-proxy
USERDATA
}

resource "aws_launch_configuration" "ingest_eks" {
  associate_public_ip_address = true
  iam_instance_profile        = "${aws_iam_instance_profile.ingest_eks_node.name}"
  image_id                    = "${data.aws_ami.eks_worker.id}"
  instance_type               = "m4.large"
  name_prefix                 = "ingest-eks-${var.deployment_stage}"
  security_groups             = ["${aws_security_group.ingest_eks_node.id}"]
  user_data_base64            = "${base64encode(local.ingest-node-userdata)}"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "ingest_eks" {
  desired_capacity     = 2
  launch_configuration = "${aws_launch_configuration.ingest_eks.id}"
  max_size             = 2
  min_size             = 1
  name                 = "ingest-eks-${var.deployment_stage}"
  vpc_zone_identifier  = ["${aws_subnet.ingest_eks.*.id}"]

  tag {
    key                 = "Name"
    value               = "ingest-eks-${var.deployment_stage}"
    propagate_at_launch = true
  }

  tag {
    key                 = "kubernetes.io/cluster/ingest-eks-${var.deployment_stage}"
    value               = "owned"
    propagate_at_launch = true
  }
}



////
// Config Outputs
//

locals {
  kubeconfig = <<KUBECONFIG
apiVersion: v1
clusters:
- cluster:
    server: ${aws_eks_cluster.ingest_eks.endpoint}
    certificate-authority-data: ${aws_eks_cluster.ingest_eks.certificate_authority.0.data}
  name: ingest-eks-${var.deployment_stage}
contexts:
- context:
    cluster: ingest-eks-${var.deployment_stage}
    user: aws
  name: ingest-eks-${var.deployment_stage}
current-context: ingest-eks-${var.deployment_stage}
kind: Config
preferences: {}
users:
- name: aws
  user:
    exec:
      apiVersion: client.authentication.k8s.io/v1alpha1
      command: heptio-authenticator-aws
      args:
        - "token"
        - "-i"
        - "ingest-eks-${var.deployment_stage}"
KUBECONFIG
}

output "kubeconfig" {
  value = "${local.kubeconfig}"
}

locals {
  config_map = <<CONFIGMAPAWSAUTH
apiVersion: v1
kind: ConfigMap
metadata:
  name: aws-auth
  namespace: kube-system
data:
  mapRoles: |
    - rolearn: ${aws_iam_role.ingest_eks_node.arn}
      username: system:node:{{EC2PrivateDNSName}}
      groups:
        - system:bootstrappers
        - system:nodes
CONFIGMAPAWSAUTH
}

output "config_map" {
  value = "${local.config_map}"
}

locals {
  namespace = <<NAMESPACE
apiVersion: v1
kind: Namespace
metadata:
  name: ${var.deployment_stage}-environment
  labels:
    name: ${var.deployment_stage}-environment
NAMESPACE
}

output "namespace" {
  value = "${local.namespace}"
}
