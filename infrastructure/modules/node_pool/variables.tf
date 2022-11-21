variable "alicloud_access_key" {
  description = "The Alicloud Access Key ID to launch resources."
}

variable "alicloud_secret_key" {
  description = "The Alicloud Access Secret Key to launch resources."
}

variable "region" {
  description = "The region to launch resources."
  default     = "cn-hangzhou"
}

variable "name" {
  description = "node pool name."
}

variable "vpc_id" {
  description = "The vpc for security group."
}

variable "vswitch_ids" {
  description = "The vpc for security group."
}

variable "cluster_id" {
  description = "The vpc for security group."
}

variable "worker_instance_type" {
  description = "The ecs instance type used to launch worker nodes. Default from instance typs datasource."
  default     = ""
}

variable "worker_disk_category" {
  description = "The system disk category used to launch one or more worker nodes."
  default     = "cloud_efficiency"
}

variable "worker_disk_size" {
  description = "The system disk size used to launch one or more worker nodes."
  default     = "40"
}

variable "worker_data_disk_category" {
  description = "The data disk category used to launch one or more worker nodes."
  default     = "cloud_efficiency"
}

variable "worker_data_disk_size" {
  description = "The data disk size used to launch one or more worker nodes."
  default     = "100"
}

variable "key_name" {
  description = "The vpc for security group."
}
