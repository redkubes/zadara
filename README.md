# Introduction

This module allows to create Zadara compute infrastructure, bootstrap a Kubernetes cluster and install Otomi on it with a single command.

The number and types of nodes, the Pod network CIDR block, and many other parameters are configurable.

Notes:

- For now, the created clusters are limited to a single master node

# Prerequisites

In order to use this module, make sure to meet the following prerequisites.

## Terraform

Install Terraform as described in the [Terraform documentation](https://learn.hashicorp.com/tutorials/terraform/install-cli).

If you use macOS, you can simply do:

```bash
brew install terraform
```

## Zadara

### VPC

Create a VPC with a subnet configured for VPSA

### Network load balancer

To expose the Otomi platform services you will need to manually create an NLB with a public EIP.

### VPSA

A VPSA account set up.

## OpenSSH

The module requires the `ssh` and `scp` commands, which are most probably already installed on your system. In case they aren't, you can install them with:

```bash
# Linux
sudo apt-get install openssh-client
# macOS
brew install openssh
```

The module, by default, uses the default SSH key par `~/.ssh/id_rsa` and `~/.ssh/id_rsa.pub` to set up SSH acess to your cluster nodes. In case you don't have this key pair, you can create it with:

```bash
ssh-keygen
```

> Note that you can configure a different SSH key pair through the module's [input variables](variables.tf).

## Quick start

1. Run the following command:

```bash
terraform init
```

The [`terraform init`](https://www.terraform.io/docs/cli/commands/init.html) command downloads the module as well as the latest versions of any required [providers](https://registry.terraform.io/browse/providers).

2. Run:

```bash
terraform apply
```

The [`terraform apply`](https://www.terraform.io/docs/cli/commands/apply.html) command first displays all the Zadara compute resources that it's planning create, and will ask if you want to proceed.

Type `yes` to proceed.

> If you want to skip the interactive dialog and automatically proceed, you can use `terraform apply --auto-approve`.

3. SSH into the master-1 node

4. Get the kubecfg:

```
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
```

5. Run the following cmd:

```
watch kubectl get svc -n ingress
```

and wait for the `ingress-nginx-platform-controller` service to pop up. When the `ingress-nginx-platform-controller` service is created, then copy the node port for `443`. When the port is `80:31764/TCP,443:32640/TCP`, the port needed is `32640`

6. Create a Target Group using the Zadara Cloud Services console::

Details:
- Name: 443
- Protocol: TCP
- Default Port: the port copied in step 5
- Click next
Health Check:
- Protocol: TCP
- Click next
Targets:
- Target Type: Instance
- Add all the worker nodes as target with the port copied in step 5
- Click Finish

7. Add a Listener to the NLB with the public EIP:

- Click Create
- Port: `443`
- Forward to: select `443`
- Click Finish

## Cleaning up

To delete the Kubernetes cluster, run the following command:

```bash
terraform destroy
```

The [`terraform destroy`](https://www.terraform.io/docs/cli/commands/destroy.html) command first displays all the Zadara resources it's planning to delete, and asks you for confirmation to proceed.

Type `yes` to proceed.

> If you want to skip the interactive dialog and automatically proceed, you can use `--auto-approve` flag.

After a few minutes, all the Zadara cloud resources that you previously created should be deleted, and the account should be in exactly the same state as before you created the Kubernetes cluster.
