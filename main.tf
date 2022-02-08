provider "helm" {
  kubernetes {
    // load_config_file       = false
    cluster_ca_certificate = base64decode(var.kubernetes_cluster_cert_data)
    host                   = var.kubernetes_cluster_endpoint
    exec {
      api_version = "client.authentication.k8s.io/v1alpha1"
      command     = "aws-iam-authenticator"
      args        = ["token", "-i", "${var.kubernetes_cluster_name}"]
    }
  }
}

provider "aws" {
  region = var.aws_region
}

resource "helm_release" "traefik-ingress" {
  name       = "ms-traefik-ingress"
  chart      = "traefik"
  repository = "https://helm.traefik.io/traefik"
  namespace = "kube-system"
  values = [<<EOF
  service:
    annotations:
      service.beta.kubernetes.io/aws-load-balancer-type: nlb
      service.beta.kubernetes.io/aws-load-balancer-ssl-cert: arn:aws:acm:ap-northeast-2:282608367958:certificate/2ef62f13-bee0-4efc-a2b7-cf5fc1fd3f71
      service.beta.kubernetes.io/aws-load-balancer-backend-protocol: tls
      service.beta.kubernetes.io/aws-load-balancer-ssl-ports: 443
      service.beta.kubernetes.io/aws-load-balancer-cross-zone-load-balancing-enabled: true
      service.beta.kubernetes.io/aws-load-balancer-internal: true
      externalTrafficPolicy: Local
  containers: 
    args: 
      --entrypoints.websecure.http.tls=true
      --entrypoints.websecure.http.tls.domains[0].main=srt-wallet.io
      --entrypoints.websecure.http.tls.domains[0].sans=*.srt-wallet.io
  EOF
  ]
}