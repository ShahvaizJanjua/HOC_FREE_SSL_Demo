output "connection_details" {
  value = oci_bastion_session.session.ssh_metadata.command
}