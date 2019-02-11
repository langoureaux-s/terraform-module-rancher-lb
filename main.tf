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


data "template_file" "docker_compose_lb" {
  template = "${file("${path.module}/rancher/lb/docker-compose.yml")}"

  vars {
    lb_version              = "${var.lb_version}"
    label_scheduling        = "${var.label_scheduling}"
    global_scheduling       = "${var.global_scheduling}"
    lb_ports                = "${indent(8, join("\n", formatlist("- %s", var.lb_ports)))}"
    redirector_ports        = "${indent(8, join("\n", formatlist("- %s", var.redirector_ports)))}"
  }
}
data "template_file" "rancher_compose_lb" {
  template = "${file("${path.module}/rancher/lb/rancher-compose.yml")}"

  vars {
    redirector_scale    = "${var.redirector_scale != "" ? "scale: ${var.redirector_scale}" : ""}"
    lb_scale            = "${var.lb_scale != "" ? "scale: ${var.lb_scale}" : ""}"
    certificates        = "${indent(8, join("\n", formatlist("- %s", var.certificates)))}"
    default_certificate = "${var.default_certificate}"
    cookie_name         = "${var.cookie_name}"
    port_rules          = "${indent(8, join("\n", formatlist("- hostname: %s\n  protocol: %s\n  service: %s\n  source_port: %s\n  target_port: %s", var.hostnames, var.protocols, var.services, var.sources_port, var.targets_port)))}"
  }
}
resource "rancher_stack" "this" {
  name            = "${var.stack_name}"
  description     = "Load Balancer"
  environment_id  = "${data.rancher_environment.project.id}"
  scope           = "user"
  start_on_create = true
  finish_upgrade  = "${var.finish_upgrade}"
  docker_compose  = "${data.template_file.docker_compose_lb.rendered}"
  rancher_compose = "${data.template_file.rancher_compose_lb.rendered}"
}