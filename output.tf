output "username" {
  value = var.admin_username
}

output "password" {
  value = var.admin_password
}

output "psql_username" {
  value = var.admin_db_username
}

output "psql_password" {
  value = var.admin_db_password
}

output "nic_id_list" {
  value = module.vm_app.*.nic_ids.id
}
