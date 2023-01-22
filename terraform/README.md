# Terraform module for scalable self hosted GitHub action runners on openstack cloud

This terraform module creates the required infrastructure needed to host scalable self hosted GitHub action runners on openstack cloud

Tested on:
- Openstack OVH Public Cloud
- Github runners: Linux X64 based on Ubuntu 20.04 image

## Purpose

- Deploy a pool of self-hosted github runners in an openstack project
- Terraform module creates the minimal following infrastructure:
  - 1 network, subnet and router
  - N instances running cloud-config and install scripts at boot time to configure self-hosted github runners
  - cloud-config and self-hosted github runners install scripts are defined in `terraform/modules/runner/config-scripts` directory
  - github runners register at the first boot with temp token and stay connected until destroyed
  - No inbound ssh is needed to work. Github Runners are configured to access github api with outbound https. No inbound trafic required
  - Optionnal, if Debug is needed , you can activate SSH on a FIP associated on the first runner. (FIP, Lbaas, ssh security group rule are created on demand)

## Setup terraform module

See `sample` directory to see how to use this module

```bash
module "github-runner" {
  source             = "github.com/tchapgouv/self-hosted-github-runner//terraform?ref=main"
  keypair_name               = var.keypair_name
  dns_nameservers            = var.dns_nameservers
  default_cidr               = var.default_cidr
  router_config              = var.router_config
  subnet_routes_config       = var.subnet_routes_config
  runner_url_deployer_script = var.runner_url_deployer_script
  runner_name                = var.runner_name
  runner_count               = var.runner_count
  runner_flavor              = var.runner_flavor
  runner_image               = var.runner_image
  runner_volume_type         = var.runner_volume_type
  runner_data_volume_size    = var.runner_data_volume_size
  runner_volume_size         = var.runner_volume_size
  gh_runner_version          = var.gh_runner_version
  gh_runner_hash             = var.gh_runner_hash
  gh_runner_group            = var.gh_runner_group
  gh_url                     = var.gh_url
  gh_token                   = var.gh_token
  gh_label                   = var.gh_label
  http_proxy                 = var.http_proxy
  no_proxy                   = var.no_proxy
}

```

## Prepare deployment

- Override parameters in `terraform.tfvars`
```
keypair_name  = "runner-key"  # define keyname
runner_count  = 2             # define number of runner in the pool
runner_flavor = "b2-7"        # define the flavor of runner (CPU/RAM/DISK)
runner_volume_type = "classic" # define runner volume type
runner_volume_size = 10       # define runner root volume size
runner_name = "ovh"           # define runner_name
#
## optional: override default
#
gh_runner_version = "2.300.2" # github runner package version
gh_runner_hash    = "ed5bf2799c1ef7b2dd607df66e6b676dff8c44fb359c6fedc9ebf7db53339f0c" # github runner package checksum
gh_runner_group   = "Default" # Default runner group
#
# network configuration
#
router_config = [
  { name = "rt_runner", ip = "192.168.1.1", extnet = "Ext-Net", allow_fip = false }
]
## only to Debug and access runner ssh (default no SSH to runner) allow_fip = true on one external net only
#
#router_config = [
#  { name = "rt_runner", ip = "192.168.1.1", extnet = "Ext-Net", allow_fip = true }
#]
subnet_routes_config = [
  { destination = "0.0.0.0/0", nexthop = "192.168.1.1" }
]

```

- Get temporary token and org name from your ORG settings in /settings/actions/runners/new
- override your secrets with `TF_VAR_`

```bash
export TF_VAR_gh_url=https://github.com/ORG
export TF_VAR_gh_token=<GH_TOKEN>
```

## To deploy runners:
- set your openstack variables `OS_`

```bash
export OS_IDENTITY_API_VERSION
export OS_PASSWORD
export OS_PROJECT_NAME
export OS_USER_DOMAIN_NAME
export OS_PROJECT_ID
export OS_USERNAME
export OS_AUTH_URL
export OS_INTERFACE
export OS_PROJECT_DOMAIN_ID
export OS_REGION_NAME
```

- set your AWS S3 credentials for terraform S3 backend

```bash
export AWS_DEFAULT_REGION
export AWS_S3_ENDPOINT
export AWS_SECRET_KEY
export AWS_ACCESS_KEY
```

- set your secrets and deploy

```bash
# override your secrets
export TF_VAR_gh_url=https://github.com/ORG
export TF_VAR_gh_token=<GH_TOKEN>

terraform init
terraform plan
terraform apply -auto-approve
```

## Results

- Check if runners are registered ,  in your organisation, see `/settings/actions/runners`
- To use self-hosted runners in your workflow: 
```
# Use this YAML in your workflow file for each job
runs-on: self-hosted
```
