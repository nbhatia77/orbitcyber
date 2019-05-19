output "unique_id" {
    value = "${random_id.unique_string.hex}"
}