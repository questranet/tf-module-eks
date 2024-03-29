resource "aws_eks_cluster" "main" {
  name     = "${var.env}-${var.project_name}"
  role_arn = aws_iam_role.main.arn

  vpc_config {
    subnet_ids = var.subnet_ids
  }
}

resource "null_resource" "aws-auth" {
  depends_on = [aws_eks_cluster.main]
  provisioner "local-exec" {
    command = <<EOF
aws eks update-kubeconfig --name ${var.env}-${var.project_name}
aws-auth upsert --mapusers --userarn arn:aws:iam::008089408493:user/wale --username wale --groups system:masters
EOF
  }
}

resource "aws_eks_node_group" "main" {
  cluster_name    = aws_eks_cluster.main.name
  node_group_name = "${var.env}-${var.project_name}-ng"
  node_role_arn   = aws_iam_role.node.arn
  subnet_ids      = var.subnet_ids
  instance_types  = var.instance_types
  //capacity_type   = "SPOT"

  scaling_config {
    desired_size = var.node_count
    max_size     = var.node_count
    min_size     = var.node_count
  }
}