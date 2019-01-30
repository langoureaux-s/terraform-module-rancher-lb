# terraform-module-rancher-lb

This module permit to deploy Load Balancer stack on Rancher 1.6.x.

```
terragrunt = {
  terraform {
    source = "git::https://github.com/langoureaux-s/terraform-module-rancher-lb.git"
  }
  
  project_name            = "test"
  stack_name              = "lb"
  finish_upgrade          = "true"
  label_global_scheduling = "lb=true"
  lb_ports                = ["443:443/tcp"]
  lb_scale                = "2"
  certificates            = ["app1-tls"]
  default_certificate     = "app2-tls"
  cookie_name             = "test"
  hostnames               = ["app1.domain.com", "app2.domain.com"]
  protocols               = ["https", "https"]
  services                = ["test/app1", "test/app2"]
  sources_port            = ["443", "443"]
  targets_port            = ["8080", 8080]
}
```

> Don't forget to read the file `variables.tf` to get all informations about variables.