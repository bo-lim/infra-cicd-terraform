# Common variables

variable "project_id" {
  type        = string
  description = "project id"
  default     = "gitlab-bolim"

  validation {
    condition     = length(var.project_id) > 0
    error_message = "The project_id must not be empty."
  }
}

variable "region" {
  type        = string
  description = "cluster region"
  default     = "asia-northeast3"

  validation {
    condition     = can(regex("^asia-northeast3", var.region))
    error_message = "The region must start with 'asia-northeast3'."
  }
}

variable "env_name" {
  type        = string
  description = "The environment for the GKE cluster"
  default     = "dev"
}

variable "vpc_name" {
  type        = string
  description = "The VPC name"
  default     = "limbolimbolim"
}

variable "cluster_subnet_name" {
  type        = string
  description = "The Cluster Subnet Name"
  default     = "public-subnet-01"
}

# Cluster variables


variable "cluster_name" {
  type        = string
  description = "name of cluster"
  default     = "terraform-test"
}

variable "network" {
  type        = string
  description = "The VPC network"
  default     = "gke-network"
}

variable "zones" {
  type        = list(string)
  description = "to host cluster in"
  default     = ["asia-northeast3-a"]

  validation {
    condition     = length(var.zones) > 0
    error_message = "At least one zone must be specified."
  }
}

variable "ip_range_pods_name" {
  type        = string
  description = "The secondary ip ranges for pods"
  default     = "subnet-01-pods"
}

variable "ip_range_services_name" {
  type        = string
  description = "The secondary ip ranges for services"
  default     = "subnet-01-services"
}

# ------------------------------------------------------------
# Jenkins Settings
# ------------------------------------------------------------
variable "jenkins_admin_user" {
  type        = string
  description = "Admin user of the Jenkins Application."
  default     = "admin"
}

variable "jenkins_admin_password" {
  type        = string
  description = "Admin password of the Jenkins Application."
  default     = "k8spass#"
}