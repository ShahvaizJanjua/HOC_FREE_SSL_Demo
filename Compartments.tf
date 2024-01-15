provider "oci" {
  tenancy_ocid = var.tenancy_ocid
  user_ocid = var.user_ocid
  fingerprint = var.fingerprint
  private_key_path = var.private_api_key_path
  region = var.region
}

resource "oci_identity_compartment" "demo" {
    compartment_id = var.rootCompartment
    description = "demo"
    name = "demo"
}