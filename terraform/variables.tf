variable "vm_app" {
  type    = string
  description = "Azure VM Provisioned for a Mini Finance App"
  default = "web-app"
}

variable "resource_group_name" {
  default = "mini-finance-app-ansible"
}

variable "location" {
  default = "South Africa North"
}
