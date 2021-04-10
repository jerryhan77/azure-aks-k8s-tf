variable "client_id" {}

variable "client_secret" {}

variable "dns_zone" {
  description = "DNS Zone"
  default     = "azure.liandisys.com.cn"
}

variable "node_count" {
  description = "number of nodes to deploy"
  default     = 2
}

variable "dns_prefix" {
  description = "DNS Suffix"
  default     = "rockit"
}

variable cluster_name {
  description = "AKS cluster name"
  default     = "rockit"
}

variable resource_group_name {
  description = "name of the resource group to deploy AKS cluster in"
  default     = "rockit"
}

variable location {
  description = "azure location to deploy resources"
  default     = "japaneast"
}

variable log_analytics_workspace_name {
  default = "testLogAnalyticsWorkspaceName"
}

# refer https://azure.microsoft.com/global-infrastructure/services/?products=monitor for log analytics available regions
variable log_analytics_workspace_location {
  default = "japaneast"
}

# refer https://azure.microsoft.com/pricing/details/monitor/ for log analytics pricing
variable log_analytics_workspace_sku {
  default = "PerGB2018"
}

variable subnet_name {
  description = "subnet id where the nodes will be deployed"
  default     = "rockit-subnet"
}

variable vnet_name {
  description = "vnet id where the nodes will be deployed"
  default     = "rockit-vnet"
}

variable subnet_cidr {
  description = "the subnet cidr range"
  default     = ["10.2.32.0/21"]
}

variable kubernetes_version {
  description = "version of the kubernetes cluster"
  default     = "1.18.14"
}

variable "vm_size" {
  description = "size/type of VM to use for nodes"
  default     = "Standard_DS2_v2"
}

variable "os_disk_size_gb" {
  description = "size of the OS disk to attach to the nodes"
  default     = 128
}

variable "max_pods" {
  description = "maximum number of pods that can run on a single node"
  default     = "100"
}

variable "address_space" {
  description = "The address space that is used the virtual network"
  default     = "10.2.0.0/16"
}
variable "min_count" {
  default     = 1
  description = "Minimum Node Count"
}
variable "max_count" {
  default     = 2
  description = "Maximum Node Count"
}
variable "availability_zones" {
  description = "A list of Availability Zones across which the Node Pool should be spread. Changing this forces a new resource to be created."
  default     = ["1", "2"]
}
variable "api_ip_ranges" {
  description = "The IP ranges to whitelist for incoming traffic to the masters"
  default     = [
                "153.150.79.112/32",
                "58.213.92.96/29",
                "58.222.225.208/29",
                "223.112.10.160/29"
            ]
}
variable "acr_ip_ranges" {
  description = "The IP ranges to whitelist for incoming traffic to the acr"
  default     = [
                "153.150.79.112/32",
                "58.213.92.96/29",
                "58.222.225.208/29",
                "223.112.10.160/29"
            ]
}
