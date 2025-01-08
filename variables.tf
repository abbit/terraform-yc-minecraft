variable "zone" {
  description = "(Optional) - YC Zone for server resources."
  type        = string
  default     = "ru-central1-b"
}

variable "server_port" {
  description = "(Optional) - Minecraft server port."
  type        = number
  default     = 25565
}

variable "dns_zone" {
  type = string
}

