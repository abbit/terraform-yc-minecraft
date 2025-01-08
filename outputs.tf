output "server-ip-port" {
  value = "${yandex_compute_instance.this.network_interface[0].nat_ip_address}:${var.server_port}"
}

output "server-address" {
  value = trim(var.dns_zone, ".")
}
