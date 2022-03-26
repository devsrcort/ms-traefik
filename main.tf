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
  ports:
    web:
      redirectTo: websecure
  service:
    annotations:
      service.beta.kubernetes.io/aws-load-balancer-type: nlb
      service.beta.kubernetes.io/aws-load-balancer-ssl-cert: ${var.aws_https_arn}
      service.beta.kubernetes.io/aws-load-balancer-cross-zone-load-balancing-enabled: true
      service.beta.kubernetes.io/aws-load-balancer-internal: true
      service.beta.kubernetes.io/aws-load-balancer-backend-protocol: http
      service.beta.kubernetes.io/aws-load-balancer-ssl-ports: https
    spec:
      externalTrafficPolicy: Local
  containers: 
      --entrypoints.websecure.http.tls=true
      --entrypoints.web-secure.address=:443
      --entrypoints.web.address=:80
      --entrypoints.web.http.redirections.entryPoint.scheme=https
      --entrypoints.web.http.redirections.entrypoint.permanent=true
      --entrypoints.web.http.redirections.entryPoint.to=websecure
  EOF
  ]
}