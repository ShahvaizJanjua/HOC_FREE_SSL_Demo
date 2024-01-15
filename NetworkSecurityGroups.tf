resource "oci_core_network_security_group" "lb_nsg" {
    compartment_id = oci_identity_compartment.demo.id
    vcn_id = oci_core_vcn.lb_demo_vcn.id

    display_name = "lb_nsg"
}

resource "oci_core_network_security_group_security_rule" "lb_nsg_ingress" {
    network_security_group_id = oci_core_network_security_group.lb_nsg.id
    direction = "INGRESS"
    protocol = 6
    description = "Allow Public Access"
    source = "0.0.0.0/0"
    source_type = "CIDR_BLOCK"
    for_each = toset(["80","443"])

    tcp_options {
        source_port_range {
            max = each.key
            min = each.key
        }
    }
}

resource "oci_core_network_security_group_security_rule" "lb_nsg_egress" {
    depends_on = [
      oci_core_network_security_group.crtbot_nsg,
      oci_core_network_security_group.websrvr_nsg
    ]
    network_security_group_id = oci_core_network_security_group.lb_nsg.id
    direction = "EGRESS"
    protocol = 6
    for_each = {"80" : oci_core_network_security_group.crtbot_nsg.id,
        "22" : oci_core_network_security_group.crtbot_nsg.id,
        "8080" : oci_core_network_security_group.websrvr_nsg.id}

    description = "Access VMs"
    destination = each.value
    destination_type = "NETWORK_SECURITY_GROUP"

    tcp_options {
        destination_port_range {
            max = each.key
            min = each.key
        }
    }
}

resource "oci_core_network_security_group" "crtbot_nsg" {
    compartment_id = oci_identity_compartment.demo.id
    vcn_id = oci_core_vcn.lb_demo_vcn.id
    display_name = "crtbot_nsg"
}

resource "oci_core_network_security_group_security_rule" "crtbot_nsg_ingress" {
    network_security_group_id = oci_core_network_security_group.crtbot_nsg.id
    direction = "INGRESS"
    protocol = 6
    description = "ACME Challenge"
    source = oci_core_network_security_group.lb_nsg.id
    source_type = "NETWORK_SECURITY_GROUP"

    tcp_options {
        source_port_range {
            max = 80
            min = 80
        }
    }
}

resource "oci_core_network_security_group" "websrvr_nsg" {
    compartment_id = oci_identity_compartment.demo.id
    vcn_id = oci_core_vcn.lb_demo_vcn.id
    display_name = "websrvr_nsg"
}

resource "oci_core_network_security_group_security_rule" "websrvr_nsg_ingress" {
    network_security_group_id = oci_core_network_security_group.websrvr_nsg.id
    direction = "INGRESS"
    protocol = 6
    source = oci_core_network_security_group.lb_nsg.id
    source_type = "NETWORK_SECURITY_GROUP"

    for_each = toset(["22","8080"])

    tcp_options {
        source_port_range {
            max = each.key
            min = each.key
        }
    }
}