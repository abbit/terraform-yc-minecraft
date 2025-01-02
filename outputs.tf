output "server-public-ip" {
  value = yandex_compute_instance.this.network_interface[0].nat_ip_address
}
