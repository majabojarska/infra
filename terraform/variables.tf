variable "linode_token" {
  description = "Linode API token."
  type        = string
  sensitive   = true
}

variable "ovh_endpoint" {
  description = "OVH API endpoint."
  type        = string
  sensitive   = false
}

variable "ovh_application_key" {
  description = "OVH API application key."
  type        = string
  sensitive   = true
}

variable "ovh_application_secret" {
  description = "OVH API application secret."
  type        = string
  sensitive   = true
}

variable "ovh_consumer_key" {
  description = "OVH API consumer key."
  type        = string
  sensitive   = true
}

variable "path_ssh_pub_key" {
  description = "Path to SSH public key for VMs."
  type        = string
  sensitive   = false
}

variable "vm_root_password" {
  description = "Password for the VM's root user."
  type        = string
  sensitive   = true
}

variable "linode_region" {
  description = "Linode region to provision resources in."
  type        = string
  sensitive   = false
}
