output "stack_id" {
  value = "${rancher_stack.this.id}"
}

output "stack_name" {
  value = "${rancher_stack.this.name}/lb"
}