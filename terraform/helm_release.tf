resource "kubernetes_namespace" "argocd" {
  metadata {
    name = "argocd"

    labels = {
      name        = "argocd"
      description = "argocd"
    }
  }
}


resource "helm_release" "argocd" {
  depends_on = [kubernetes_namespace.argocd]

  name       = "argocd"
  chart      = "argo-cd"
  repository = "https://argoproj.github.io/argo-helm"
  version    = "6.9.3"
  timeout    = "1500"
  namespace  = "argocd"
  values = ["${file("argo-values.yaml")}"]
}