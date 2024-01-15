
data "oci_identity_availability_domains" "ads" {
  compartment_id = oci_identity_compartment.demo.id
}

data "oci_core_images" "os" {
  compartment_id           = oci_identity_compartment.demo.id
  operating_system = "Oracle Linux"
  operating_system_version = "8"

  shape                    = "VM.Standard.E4.Flex"
  sort_by                  = "TIMECREATED"
  sort_order               = "DESC"
}

data "oci_core_private_ips" "lb_priv_ips" {
    subnet_id = oci_core_subnet.lb_sub.id
}

data "oci_core_services" "all_oci_services" {
  filter {
    name   = "name"
    values = ["All .* Services In Oracle Services Network"]
    regex  = true
  }
}