locals {
  stack_id    = "${compact(concat(coalescelist(rancher_stack.this_redirector.*.id, rancher_stack.this.*.id), list("")))}"
  stack_name  = "${compact(concat(coalescelist(rancher_stack.this_redirector.*.name, rancher_stack.this.*.name), list("")))}"
}


output "stack_id" {
  value = "${join("", local.stack_id)}"
}

output "stack_name" {
  value = "${join("", local.stack_name)}/elasticsearch"
}