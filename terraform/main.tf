terraform {
  required_version = "~> 1.14.3"
  required_providers {
    linode = {
      source  = "linode/linode"
      version = "~> 3.9.0"
    }
    ovh = {
      source  = "ovh/ovh"
      version = "~> 2.11.0"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.7.0"
    }
  }
}

provider "linode" {
  token = var.linode_token
}

provider "ovh" {
  endpoint           = var.ovh_endpoint
  application_key    = var.ovh_application_key
  application_secret = var.ovh_application_secret
  consumer_key       = var.ovh_consumer_key
}

resource "linode_instance" "vps-01" {
  region = var.linode_region
  label  = "master"
  image  = "linode/ubuntu24.04"
  # https://www.linode.com/products/shared/
  type = "g6-standard-2" # 2 CPU, 4GB RAM, 80GB SSD, 4TB xfer


  authorized_keys = [trimspace(file(var.path_ssh_pub_key))]
  root_pass       = var.vm_root_password

  booted = true
}

resource "linode_instance_disk" "installer" {
  label      = "installer"
  linode_id  = linode_instance.vps-01.id
  size       = 1280
  filesystem = "ext4"
}

resource "linode_instance_disk" "boot" {
  label      = "boot"
  linode_id  = linode_instance.vps-01.id
  size       = 1024
  filesystem = "swap"
}


resource "ovh_domain_zone_record" "majabojarska_dev" {
  zone      = "majabojarska.dev"
  subdomain = ""
  fieldtype = "A"
  ttl       = 0
  target    = linode_instance.vps-01.ip_address

  depends_on = [linode_instance.vps-01]
}

resource "ovh_domain_zone_record" "vps-01_cloud_majabojarska_dev" {
  zone      = "vps-01.cloud.majabojarska.dev"
  subdomain = ""
  fieldtype = "A"
  ttl       = 0
  target    = linode_instance.vps-01.ip_address

  depends_on = [linode_instance.vps-01]
}

# Passes info about master to Ansible
resource "local_file" "linode_instance_master_ip_addr" {
  filename        = "${path.module}/linode_instance_master_ip_addr"
  file_permission = "0644"
  content         = linode_instance.master.ip_address

  depends_on = [linode_instance.master]
}
