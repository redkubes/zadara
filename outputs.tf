output "cluster_nodes" {
  value = [
    for i in concat([aws_instance.master-1], aws_instance.workers, ) : {
      subnet_id  = i.subnet_id
      private_ip = i.private_ip
      public_ip  = i.public_ip
    }
  ]
  description = "Name, public and private IP address, and subnet ID of all nodes of the created cluster."
}

output "vpc_id" {
  value       = aws_security_group.allow_all.vpc_id
  description = "ID of the VPC in which the cluster has been created."
}
