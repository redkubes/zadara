terraform {
  required_version = ">= 0.12"
}

#------------------------------------------------------------------------------#
# Security groups
#------------------------------------------------------------------------------#

resource "aws_security_group" "allow_all" {
  name        = "all-k8s-traffic"
  description = "All k8s traffic"
  vpc_id      = "${var.vpc}"

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

#------------------------------------------------------------------------------#
# Elastic IP for master node
#------------------------------------------------------------------------------#

resource "aws_eip" "master-1" {
  vpc  = true
}

resource "aws_eip_association" "master-1" {
  allocation_id = aws_eip.master-1.id
  instance_id = aws_instance.master-1.id
}

#------------------------------------------------------------------------------#
# Bootstrap token for kubeadm
#------------------------------------------------------------------------------#

resource "random_string" "token_id" {
  length  = 6
  special = false
  upper   = false
}

resource "random_string" "token_secret" {
  length  = 16
  special = false
  upper   = false
}

locals {
  token = "${random_string.token_id.result}.${random_string.token_secret.result}"
}

#------------------------------------------------------------------------------#
# Instances
#------------------------------------------------------------------------------#

resource "aws_instance" "master-1" {
  ami           = "${var.ami}"
  instance_type = "${var.master_instance}"
  subnet_id = "${var.subnet}"
  key_name = "${var.keyname}"
  vpc_security_group_ids = [aws_security_group.allow_all.id]
  tags =  { "Name" = "master-1" }
  user_data = templatefile(
    "${path.module}/master-1.tftpl",
    {
      node = "master-1",
      token = local.token,
      otomi = var.otomi,
      vpsa_host = var.vpsa_host_name,
      vpc = var.vpc,
      subnet = var.subnet,
      accesskey = var.accesskey,
      secretkey = var.secretkey,
      awsApiEndpoint = var.zcloud_ip,
      vpsa_token = var.vpsa_token,
      master-1_public_ip = aws_eip.master-1.public_ip,
      worker_index = var.num_workers,
      ipaddresspool = var.ipaddresspool,
      otomi_domainSuffix = var.otomi_domainSuffix,
      otomi_entrypoint = var.otomi_entrypoint,
      domainFilter = var.domainFilter,
      otomi_dns_secretKey = var.otomi_dns_secretKey,
      otomi_dns_accessKey = var.otomi_dns_accessKey,
      otomi_email = var.otomi_email
    }
  )
  root_block_device {
    volume_size           = "50"
  }
}

resource "aws_instance" "workers" {
  count = var.num_workers
  ami = "${var.ami}"
  instance_type = "${var.worker_instance}"
  subnet_id = "${var.subnet}"
  key_name = "${var.keyname}"
  vpc_security_group_ids = [aws_security_group.allow_all.id]
  tags = { "Name" = "worker-${count.index}" }
  user_data = templatefile(
    "${path.module}/workers.tftpl",
    {
      node = "worker",
      token = local.token,
      master-1_public_ip  = null,
      master-1_private_ip = aws_instance.master-1.private_ip,
      worker_index = count.index
    }
  )
  root_block_device {
    volume_size           = "50"
  }
}

#------------------------------------------------------------------------------#
# Wait for bootstrap to finish on all nodes
#------------------------------------------------------------------------------#

resource "null_resource" "wait_for_bootstrap_to_finish" {
  provisioner "local-exec" {
    command = <<-EOF
    alias ssh='ssh -q -i ${var.private_key_file} -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null'
    while true; do
      sleep 2
      ! ssh ubuntu@${aws_eip.master-1.public_ip} [[ -f /home/ubuntu/done ]] >/dev/null && continue
      break
    done
    EOF
  }
  triggers = {
    instance_id = aws_instance.master-1.id
  }
}
