#------------------------------------------------------------------------------#
# Mandatory variables
#------------------------------------------------------------------------------#

variable "accesskey" {
  default = ""
}

variable "secretkey" {
  default = ""
}

variable "zcloud_ip" {
  default = ""
}

variable "keyname" {
  default = "your-key"
}

variable "master_instance" {
  default = "z4.4xlarge"
}

variable "worker_instance" {
  default = "z4.2xlarge"
}

variable "ami" {
    default = "ami-"
}

variable "vpc" {
  default = "vpc-"
}
variable "subnet" {
  default = "subnet-"
}

variable "vpsa_host_name" {
  default = ""
}

variable "vpsa_token" {
  default = ""
}

variable "private_key_file" {
  type        = string
  description = "Filename of the private key of a key pair on your local machine. This key pair will allow to connect to the nodes of the cluster with SSH."
  default     = "~/.ssh/id_rsa"
}
variable "public_key_file" {
  type        = string
  description = "Filename of the public key of a key pair on your local machine. This key pair will allow to connect to the nodes of the cluster with SSH."
  default     = "~/.ssh/id_rsa.pub"
}

variable "num_workers" {
  type        = number
  description = "Number of worker nodes."
  default     = 3
}

variable "otomi" {
  type        = bool
  default     = true
}

variable "ipaddresspool" {
  description = "The IP pool used by Metallb. Otomi will need at least 1 IP in the private subnet"
  default = "172.28.227.150-172.28.227.152"
}

variable "otomi_domainSuffix" {
  description = "The DNS domain suffix used by Otomi"
  default = "zadara.d2-otomi.net"
}

variable "otomi_entrypoint" {
  description = "The public IP of the NLB"
  default = ""
}

variable "domainFilter" {
  description = "The domain filter for external-dns"
  default = "d2-otomi.net"
}

variable "otomi_dns_secretKey" {
  description = "The secretKey of a AWS account used for access to the used Route53 hosted zone"
  default = ""
}

variable "otomi_dns_accessKey" {
  description = "The accessKey of a AWS account used for access to the used Route53 hosted zone"
  default = ""
}

variable "otomi_email" {
  description = "A valid email address"
  default = "support@redkubes.com"
}