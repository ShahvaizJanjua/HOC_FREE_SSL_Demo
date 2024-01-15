resource "oci_core_vcn" "lb_demo_vcn" {
    cidr_block = "10.0.0.0/16"
    compartment_id = oci_identity_compartment.demo.id
    dns_label = "lbdemo"
    display_name = "LB-Demo-VCN"
}

resource "oci_core_internet_gateway" "lb_demo_igw" {
    compartment_id = oci_identity_compartment.demo.id
    vcn_id = oci_core_vcn.lb_demo_vcn.id

    display_name = "LB-DEMO-IGW"
}

resource "oci_core_route_table" "lb_rt" {
    compartment_id = oci_identity_compartment.demo.id
    vcn_id = oci_core_vcn.lb_demo_vcn.id
    display_name = "LB_RT"

    route_rules {
        network_entity_id = oci_core_internet_gateway.lb_demo_igw.id
        destination = "0.0.0.0/0"
        destination_type = "CIDR_BLOCK"
        }
}

resource "oci_core_route_table" "app_rt" {
    compartment_id = oci_identity_compartment.demo.id
    vcn_id = oci_core_vcn.lb_demo_vcn.id
    display_name = "APP_RT"

       route_rules {
        network_entity_id = oci_core_service_gateway.service_gateway.id
        //destination = "all-fra-services-in-oracle-services-network"//data.oci_core_services.all_oci_services.services.0.name
        destination = lookup(data.oci_core_services.all_oci_services.services[0], "cidr_block")
        destination_type = "SERVICE_CIDR_BLOCK"
    }

        route_rules {
        network_entity_id = oci_core_nat_gateway.nat_gateway.id
        destination = "0.0.0.0/0"
        destination_type = "CIDR_BLOCK"
        }
}

resource "oci_core_default_security_list" "lb_demo_default_sl" {
    manage_default_resource_id = oci_core_vcn.lb_demo_vcn.default_security_list_id
    compartment_id = oci_identity_compartment.demo.id

   ingress_security_rules {
    protocol = "all"
    source = "0.0.0.0/0"
   }

    egress_security_rules {
    protocol = "all"
    destination = "0.0.0.0/0"
   }
}

resource "oci_core_subnet" "lb_sub" {
    cidr_block = "10.0.0.0/24"
    compartment_id = oci_identity_compartment.demo.id
    vcn_id = oci_core_vcn.lb_demo_vcn.id
    route_table_id = oci_core_route_table.lb_rt.id

    dns_label = "lbsub"
    display_name = "LB-Sub"
}

resource "oci_core_subnet" "vm_sub" {
    prohibit_public_ip_on_vnic = true
    cidr_block = "10.0.1.0/24"
    compartment_id = oci_identity_compartment.demo.id
    vcn_id = oci_core_vcn.lb_demo_vcn.id
    route_table_id = oci_core_route_table.app_rt.id

    dns_label = "vmsub"
    display_name = "VM-Sub"
}

resource "oci_core_service_gateway" "service_gateway" {
  compartment_id = oci_identity_compartment.demo.id
  display_name   = "SGW"

  services {
    service_id = data.oci_core_services.all_oci_services.services.0.id
  }

  vcn_id = oci_core_vcn.lb_demo_vcn.id
}

resource "oci_core_nat_gateway" "nat_gateway" {
    compartment_id = oci_identity_compartment.demo.id
    vcn_id = oci_core_vcn.lb_demo_vcn.id
}