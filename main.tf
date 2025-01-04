locals {
  name_prefix = "minecraft-server"
}

# network

resource "yandex_vpc_network" "this" {
  name = "${local.name_prefix}-network"
}

resource "yandex_vpc_security_group" "this" {
  name       = "${local.name_prefix}-sg"
  network_id = yandex_vpc_network.this.id

  ingress {
    description    = "minecraft server port"
    protocol       = "ANY"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = var.server_port
  }

  ingress {
    description    = "ssh port"
    protocol       = "ANY"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 22
  }

  egress {
    description    = "all"
    protocol       = "ANY"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "yandex_vpc_subnet" "this" {
  name           = "${local.name_prefix}-subnet"
  zone           = var.zone
  network_id     = yandex_vpc_network.this.id
  v4_cidr_blocks = ["10.0.0.0/24"]
}

resource "yandex_vpc_address" "public" {
  name = "${local.name_prefix}-public_ip"

  external_ipv4_address {
    zone_id = var.zone
  }
}

# instance

data "yandex_compute_image" "ubuntu" {
  family = "ubuntu-2204-lts"
}


resource "yandex_compute_disk" "boot_disk" {
  name     = "${local.name_prefix}-boot_disk"
  image_id = data.yandex_compute_image.ubuntu.image_id
  zone     = var.zone

  type = "network-ssd"
  size = 30
}

resource "yandex_compute_instance" "this" {
  name        = "${local.name_prefix}-instance"
  zone        = var.zone
  platform_id = "standard-v3"

  allow_stopping_for_update = true

  boot_disk {
    disk_id = yandex_compute_disk.boot_disk.id
  }

  resources {
    cores         = 2
    memory        = 4
    core_fraction = 100
  }

  network_interface {
    subnet_id          = yandex_vpc_subnet.this.id
    security_group_ids = [yandex_vpc_security_group.this.id]
    nat                = true
    nat_ip_address     = yandex_vpc_address.public.external_ipv4_address[0].address
  }

  metadata = {
    enable-oslogin = true
    ssh-keys       = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
    user-data      = file("${path.module}/cloud-init.yaml")
  }
}
