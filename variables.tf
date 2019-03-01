variable "project_name" {
    description = "The project name (environment name)"
}
variable "stack_name" {
    description = "The name for the Elasticsearch stack"
}
variable "finish_upgrade" {
  description = "Automatically finish upgrade on Rancher when apply new plan"
}
variable "label_scheduling" {
  description = "The label to use when schedule this stack"
  default = ""
}
variable "global_scheduling" {
  description = "Set to true if you should to deploy on all node that match label_scheduling"
  default     = "true"
}

variable "lb_version" {
  description = "The image version of LB to use"
  default = "v0.9.6"
}
variable "lb_ports" {
  description = "The list of port to expose on Load Balancer like 443:443/tcp"
  type = "list"
}
variable "lb_scale" {
  description = "The number instance of Load Balancer"
  default = ""
}
variable "certificates" {
  description = "The list of Rancher certificates"
  type = "list"
  default = []
}
variable "default_certificate" {
  description = "Default certificate"
  default = ""
}
variable "cookie_name" {
  description = "The cookie name"
  default = ""
}
variable "hostnames" {
  description = "The list of alias DNS"
  type = "list"
}
variable "protocols" {
  description = "The list of protocols to use for each hostname"
  type = "list"
}
variable "services" {
  description = "The list of target service to use for each hostname"
  type = "list"
}
variable "sources_port" {
  description = "The list of source port to use for each hostname"
  type = "list"
}
variable "targets_port" {
  description = "The list of target port to use for each hostname"
  type = "list"
}




variable "redirector_ports" {
  description = "The list of port to expose on redirector like 80:80/tcp"
  type = "list"
  default = []
}
variable "redirector_scale" {
  description = "The number instance of redirector"
  default = ""
}

variable "deploy_redirector" {
  description = "Permit to deploy redirector http to force https"
  default = "true"
}

variable "public_ports" {
  description = "Expose ports on hosts"
  default = "true"
}
