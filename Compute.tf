data "template_file" "cloud-config" {
  template = <<YAML
#cloud-config
runcmd:
 - echo 'Starting Setup' >> /tmp/setup.log
 - sudo systemctl stop firewalld
 - mkdir -p /var/www/html
 - wget --output-document=/var/www/html/index.html https://github.com/ShahvaizJanjua/HOC_FREE_SSL_Demo/blob/main/index.html
 - cd /var/www/html
 - nohup python -m http.server 8080 &
YAML
}

resource "oci_core_instance" "CertBotVM" {
  availability_domain = data.oci_identity_availability_domains.ads.availability_domains[0].name
  compartment_id = oci_identity_compartment.demo.id
  display_name        = "crtbot"
  shape               = "VM.Standard.E4.Flex"

  shape_config {
    ocpus         = 1
    memory_in_gbs = 8
  }

  create_vnic_details {
    subnet_id      = oci_core_subnet.vm_sub.id
    assign_public_ip          = false
    hostname_label            = "crtbot"
    skip_source_dest_check = true
    nsg_ids = [oci_core_network_security_group.crtbot_nsg.id]
  }
  source_details {
    source_type = "image"
    source_id   = data.oci_core_images.os.images[0].id
  }
  metadata = {
    ssh_authorized_keys = file(var.public_key_path)
  }

 agent_config {
        plugins_config {
            desired_state = "ENABLED"
            name = "Bastion"
        }
    }

}

resource "oci_core_instance" "WebServer" {
  availability_domain = data.oci_identity_availability_domains.ads.availability_domains[0].name
  compartment_id = oci_identity_compartment.demo.id
  display_name        = "websrv"
  shape               = "VM.Standard.E4.Flex"

  shape_config {
    ocpus         = 1
    memory_in_gbs = 8
  }

  create_vnic_details {
    subnet_id      = oci_core_subnet.vm_sub.id
    assign_public_ip          = false
    hostname_label            = "websrv"
    skip_source_dest_check = true
    nsg_ids = [oci_core_network_security_group.websrvr_nsg.id]
  }
  source_details {
    source_type = "image"
    source_id   = data.oci_core_images.os.images[0].id
  }
  metadata = {
    ssh_authorized_keys = file(var.public_key_path)
    user_data = "${base64encode(data.template_file.cloud-config.rendered)}"
  }

  agent_config {
        plugins_config {
            desired_state = "ENABLED"
            name = "Bastion"
        }
    }
}
