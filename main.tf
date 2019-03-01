terraform {
  # The configuration for this backend will be filled in by Terragrunt
  backend "consul" {}
}

# Template provider
provider "template" {
  version = "~> 1.0"
}

# Get the project data
data "rancher_environment" "project" {
  name = "${var.project_name}"
}

locals {
  lb_ports          = "${join("\n", formatlist("- %s", var.lb_ports))}"
  lb_ports_computed = "${indent(6, "${var.public_ports == "true" ? "ports:\n${local.lb_ports}" : "expose:\n${local.lb_ports}"}")}"
  redirector_ports  = "${length(var.certificates) > 0 ? "${indent(6, join("\n", formatlist("- %s", var.redirector_ports)))}" : ""}"
  redirector_scale  = "${var.redirector_scale != "" ? "scale: ${var.redirector_scale}" : ""}"
  lb_scale          = "${var.lb_scale != "" ? "scale: ${var.lb_scale}" : ""}"
  certificates      = "${length(var.certificates) > 0 ? "certs:\n${indent(8, join("\n", formatlist("- %s", var.certificates)))}" : ""}"
  port_rules        = "${length(var.hostnames) > 0 ? "" : indent(8, join("\n", formatlist("- protocol: %s\n  service: %s\n  source_port: %s\n  target_port: %s", var.protocols, var.services, var.sources_port, var.targets_port)))}"
  stickiness_policy = "${var.cookie_name != "" ? indent(6, "stickiness_policy:\n  cookie: ${var.cookie_name}\n  domain:\n  indirect: false\n  mode: insert\n  nocache: false\n  postonly: false") : ""}"
  default_certificate = "${var.default_certificate != "" ? "default_cert: ${var.default_certificate}": ""}"
}


# Stack with redirector
data "template_file" "docker_compose_lb_redirector" {
  template = "${file("${path.module}/rancher/lb-redirector/docker-compose.yml")}"
  count    = "${var.deploy_redirector == "true" ? 1 : 0 }"

  vars {
    lb_version              = "${var.lb_version}"
    label_scheduling        = "${var.label_scheduling}"
    global_scheduling       = "${var.global_scheduling}"
    lb_ports                = "${local.lb_ports_computed}"
    redirector_ports        = "${local.redirector_ports}"
  }
}
data "template_file" "rancher_compose_lb_redirector" {
  template = "${file("${path.module}/rancher/lb-redirector/rancher-compose.yml")}"
  count    = "${var.deploy_redirector == "true" ? 1 : 0 }"

  vars {
    redirector_scale    = "${local.redirector_scale}"
    lb_scale            = "${local.lb_scale}"
    certificates        = "${local.certificates}"
    default_certificate = "${local.default_certificate}"
    cookie_name         = "${var.cookie_name}"
    port_rules          = "${local.port_rules}"
    stickiness_policy   = "${local.stickiness_policy}"
  }
}
resource "rancher_stack" "this_redirector" {
  count           = "${var.deploy_redirector == "true" ? 1 : 0 }"
  name            = "${var.stack_name}"
  description     = "Load Balancer"
  environment_id  = "${data.rancher_environment.project.id}"
  scope           = "user"
  start_on_create = true
  finish_upgrade  = "${var.finish_upgrade}"
  docker_compose  = "${data.template_file.docker_compose_lb_redirector.rendered}"
  rancher_compose = "${data.template_file.rancher_compose_lb_redirector.rendered}"
}

#Stack without redirector
data "template_file" "docker_compose_lb" {
  template = "${file("${path.module}/rancher/lb/docker-compose.yml")}"
  count    = "${var.deploy_redirector != "true" ? 1 : 0 }"

  vars {
    lb_version              = "${var.lb_version}"
    label_scheduling        = "${var.label_scheduling}"
    global_scheduling       = "${var.global_scheduling}"
    lb_ports                = "${local.lb_ports_computed}"
  }
}
data "template_file" "rancher_compose_lb" {
  template = "${file("${path.module}/rancher/lb/rancher-compose.yml")}"
  count    = "${var.deploy_redirector != "true" ? 1 : 0 }"

  vars {
    lb_scale            = "${local.lb_scale}"
    certificates        = "${local.certificates}"
    default_certificate = "${local.default_certificate}"
    cookie_name         = "${var.cookie_name}"
    port_rules          = "${local.port_rules}"
    stickiness_policy   = "${local.stickiness_policy}"
  }
}
resource "rancher_stack" "this" {
  count           = "${var.deploy_redirector != "true" ? 1 : 0 }"
  name            = "${var.stack_name}"
  description     = "Load Balancer"
  environment_id  = "${data.rancher_environment.project.id}"
  scope           = "user"
  start_on_create = true
  finish_upgrade  = "${var.finish_upgrade}"
  docker_compose  = "${data.template_file.docker_compose_lb.rendered}"
  rancher_compose = "${data.template_file.rancher_compose_lb.rendered}"
}