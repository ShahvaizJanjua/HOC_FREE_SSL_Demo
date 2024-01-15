resource "oci_load_balancer_load_balancer" "lb_ssl" {
    compartment_id = oci_identity_compartment.demo.id
    display_name = "lb_ssl"
    shape = "flexible"
    subnet_ids = [oci_core_subnet.lb_sub.id]
    network_security_group_ids = [oci_core_network_security_group.lb_nsg.id]
    shape_details {
        maximum_bandwidth_in_mbps = "10"
        minimum_bandwidth_in_mbps = "10"
    }
}

resource "oci_load_balancer_backend_set" "certbot_backend_set" {
    health_checker {
        protocol = "TCP"
        port = "22"
    }
    load_balancer_id = oci_load_balancer_load_balancer.lb_ssl.id
    name = "CertbotBackendSet"
    policy = "ROUND_ROBIN"
}

resource "oci_load_balancer_backend" "certbot_backend" {
    backendset_name = "CertbotBackendSet"
    ip_address = oci_core_instance.CertBotVM.private_ip
    load_balancer_id = oci_load_balancer_load_balancer.lb_ssl.id
    port = "80"
}

resource "oci_load_balancer_listener" "certbot_listener" {
    default_backend_set_name = oci_load_balancer_backend_set.certbot_backend_set.name
    load_balancer_id = oci_load_balancer_load_balancer.lb_ssl.id
    name = "Certbot_Listener"
    port = "80"
    protocol = "HTTP"
}

resource "oci_load_balancer_backend_set" "websrv_backend_set" {
    health_checker {
        protocol = "TCP"
        port = "22"
    }
    load_balancer_id = oci_load_balancer_load_balancer.lb_ssl.id
    name = "WebBackendSet"
    policy = "ROUND_ROBIN"
}

resource "oci_load_balancer_backend" "websrv_backend" {
    backendset_name = "WebBackendSet"
    ip_address = oci_core_instance.WebServer.private_ip
    load_balancer_id = oci_load_balancer_load_balancer.lb_ssl.id
    port = "8080"
}

resource "oci_load_balancer_listener" "websrv_listener" {
    default_backend_set_name = oci_load_balancer_backend_set.websrv_backend_set.name
    load_balancer_id = oci_load_balancer_load_balancer.lb_ssl.id
    name = "Web_Listener"
    port = "8080"
    protocol = "HTTP"
}