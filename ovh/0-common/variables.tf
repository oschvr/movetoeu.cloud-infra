variable "ovh_endpoint" {
  description = "OVH API endpoint"
  type        = string
  default     = "ovh-eu"

  validation {
    condition     = contains(["ovh-eu", "ovh-us", "ovh-ca"], var.ovh_endpoint)
    error_message = "Endpoint must be one of: ovh-eu, ovh-us, ovh-ca"
  }
}

variable "ovh_application_key" {
  description = "OVH API application key"
  type        = string
  sensitive   = true
}

variable "ovh_application_secret" {
  description = "OVH API application secret"
  type        = string
  sensitive   = true
}

variable "ovh_consumer_key" {
  description = "OVH API consumer key"
  type        = string
  sensitive   = true
}

variable "ovh_project_id" {
  description = "OVH Public Cloud project ID"
  type        = string
}

variable "project_description" {
  description = "Description for the Public Cloud project"
  type        = string
  default     = "Managed by movetoeu.cloud Terraform"
}
