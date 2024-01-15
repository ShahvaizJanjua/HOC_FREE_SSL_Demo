resource "oci_bastion_bastion" "bastion" {
    bastion_type = "STANDARD"
    compartment_id = oci_identity_compartment.demo.id
    target_subnet_id = oci_core_subnet.vm_sub.id
    client_cidr_block_allow_list = ["0.0.0.0/0"]
    name = "Bastion1"
}

resource "time_sleep" "wait_5_minutes_for_bastion_plugin" {
  depends_on = [oci_core_instance.CertBotVM]
  create_duration = "5m"
}

resource "oci_bastion_session" "session" {
    bastion_id = oci_bastion_bastion.bastion.id
    key_details {
        public_key_content = file(var.public_key_path)
    }
    target_resource_details {
        session_type = "MANAGED_SSH"
        target_resource_id = oci_core_instance.CertBotVM.id
        target_resource_operating_system_user_name = "opc"
        target_resource_port = "22"
    }
    display_name = "CertbotSession"
    session_ttl_in_seconds = "10800"
    depends_on = [time_sleep.wait_5_minutes_for_bastion_plugin]
}