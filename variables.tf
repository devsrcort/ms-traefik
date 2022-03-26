variable "kubernetes_cluster_id" {
  type = string
}

variable "kubernetes_cluster_cert_data" {
  type = string
}

variable "kubernetes_cluster_endpoint" {
  type = string
}

variable "kubernetes_cluster_name" {
  type = string
}

variable "eks_nodegroup_id" {
  type = string
}

variable "aws_region" {
  type = string
}

variable "aws_https_arn" {
  type = string
  default = "arn:aws:acm:ap-northeast-2:282608367958:certificate/8ca62161-c34a-46b7-9af8-29fab77ad397" 
}
