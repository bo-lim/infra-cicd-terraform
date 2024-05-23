resource "kubernetes_namespace" "frontend_ns" {
  metadata {
    name = "frontend-ns"

    labels = {
      tier = "frontend"
    }
  }
  depends_on = [module.gke]
}

resource "kubernetes_namespace" "db_ns" {
  metadata {
    name = "db-ns"

    labels = {
      tier = "database"
    }
  }
  depends_on = [module.gke]
}

resource "kubernetes_namespace" "job_ns" {
  metadata {
    name = "job-ns"

    labels = {
      tier = "backend"
    }
  }
  depends_on = [module.gke]
}

resource "kubernetes_namespace" "member_ns" {
  metadata {
    name = "member-ns"

    labels = {
      tier = "backend"
    }
  }
  depends_on = [module.gke]
}

resource "kubernetes_namespace" "apply_ns" {
  metadata {
    name = "apply-ns"

    labels = {
      tier = "backend"
    }
  }
  depends_on = [module.gke]
}

resource "kubernetes_persistent_volume" "mongo_data_pv" {
  metadata {
    name = "mongo-data-pv"

    labels = {
      pv = "mongo"
    }
  }

  spec {
    capacity = {
      storage = "5Gi"
    }

    access_modes = ["ReadWriteMany"]
    storage_class_name = "standard"

    persistent_volume_source {
      host_path {
        path = "data/db"
      }
    }
  }
  depends_on = [module.gke]
}


resource "kubernetes_persistent_volume_claim" "mongo_data" {
  metadata {
    name      = "mongo-data"
    namespace = kubernetes_namespace.db_ns.metadata[0].name
  }

  spec {
    access_modes = ["ReadWriteMany"]
    storage_class_name = "standard"
    resources {
      requests = {
        storage = "5Gi"
      }
    }
    volume_name = "${kubernetes_persistent_volume.mongo_data_pv.metadata.0.name}"
  }
  
  depends_on = [kubernetes_namespace.db_ns,kubernetes_persistent_volume.mongo_data_pv]
}

resource "kubernetes_secret" "mongo_creds" {
  metadata {
    name      = "mongo-creds"
    namespace = "db-ns"
  }

  data = {
    password = "password123"

    username = "adminuser"
  }
  depends_on = [kubernetes_namespace.db_ns]
}

resource "kubernetes_namespace" "ingress_nginx" {
  metadata {
    name = "ingress-nginx"

    labels = {
      "app.kubernetes.io/instance" = "ingress-nginx"

      "app.kubernetes.io/name" = "ingress-nginx"
    }
  }
  depends_on = [module.gke]
}

resource "kubernetes_service_account" "ingress_nginx" {
  metadata {
    name      = "ingress-nginx"
    namespace = "ingress-nginx"

    labels = {
      "app.kubernetes.io/component" = "controller"

      "app.kubernetes.io/instance" = "ingress-nginx"

      "app.kubernetes.io/managed-by" = "Helm"

      "app.kubernetes.io/name" = "ingress-nginx"

      "app.kubernetes.io/version" = "1.0.0"

      "helm.sh/chart" = "ingress-nginx-4.0.1"
    }
  }
  depends_on = [kubernetes_namespace.ingress_nginx]
  automount_service_account_token = true
}

resource "kubernetes_config_map" "ingress_nginx_controller" {
  metadata {
    name      = "ingress-nginx-controller"
    namespace = "ingress-nginx"

    labels = {
      "app.kubernetes.io/component" = "controller"

      "app.kubernetes.io/instance" = "ingress-nginx"

      "app.kubernetes.io/managed-by" = "Helm"

      "app.kubernetes.io/name" = "ingress-nginx"

      "app.kubernetes.io/version" = "1.0.0"

      "helm.sh/chart" = "ingress-nginx-4.0.1"
    }
  }
  depends_on = [kubernetes_namespace.ingress_nginx]
}

resource "kubernetes_cluster_role" "ingress_nginx" {
  metadata {
    name = "ingress-nginx"

    labels = {
      "app.kubernetes.io/instance" = "ingress-nginx"

      "app.kubernetes.io/managed-by" = "Helm"

      "app.kubernetes.io/name" = "ingress-nginx"

      "app.kubernetes.io/version" = "1.0.0"

      "helm.sh/chart" = "ingress-nginx-4.0.1"
    }
  }

  rule {
    verbs      = ["list", "watch"]
    api_groups = [""]
    resources  = ["configmaps", "endpoints", "nodes", "pods", "secrets"]
  }

  rule {
    verbs      = ["get"]
    api_groups = [""]
    resources  = ["nodes"]
  }

  rule {
    verbs      = ["get", "list", "watch"]
    api_groups = [""]
    resources  = ["services"]
  }

  rule {
    verbs      = ["get", "list", "watch"]
    api_groups = ["networking.k8s.io"]
    resources  = ["ingresses"]
  }

  rule {
    verbs      = ["create", "patch"]
    api_groups = [""]
    resources  = ["events"]
  }

  rule {
    verbs      = ["update"]
    api_groups = ["networking.k8s.io"]
    resources  = ["ingresses/status"]
  }

  rule {
    verbs      = ["get", "list", "watch"]
    api_groups = ["networking.k8s.io"]
    resources  = ["ingressclasses"]
  }
  depends_on = [kubernetes_namespace.ingress_nginx]
}

resource "kubernetes_cluster_role_binding" "ingress_nginx" {
  metadata {
    name = "ingress-nginx"

    labels = {
      "app.kubernetes.io/instance" = "ingress-nginx"

      "app.kubernetes.io/managed-by" = "Helm"

      "app.kubernetes.io/name" = "ingress-nginx"

      "app.kubernetes.io/version" = "1.0.0"

      "helm.sh/chart" = "ingress-nginx-4.0.1"
    }
  }

  subject {
    kind      = "ServiceAccount"
    name      = "ingress-nginx"
    namespace = "ingress-nginx"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "ingress-nginx"
  }
  depends_on = [kubernetes_namespace.ingress_nginx]
}

resource "kubernetes_role" "ingress_nginx" {
  metadata {
    name      = "ingress-nginx"
    namespace = "ingress-nginx"

    labels = {
      "app.kubernetes.io/component" = "controller"

      "app.kubernetes.io/instance" = "ingress-nginx"

      "app.kubernetes.io/managed-by" = "Helm"

      "app.kubernetes.io/name" = "ingress-nginx"

      "app.kubernetes.io/version" = "1.0.0"

      "helm.sh/chart" = "ingress-nginx-4.0.1"
    }
  }

  rule {
    verbs      = ["get"]
    api_groups = [""]
    resources  = ["namespaces"]
  }

  rule {
    verbs      = ["get", "list", "watch"]
    api_groups = [""]
    resources  = ["configmaps", "pods", "secrets", "endpoints"]
  }

  rule {
    verbs      = ["get", "list", "watch"]
    api_groups = [""]
    resources  = ["services"]
  }

  rule {
    verbs      = ["get", "list", "watch"]
    api_groups = ["networking.k8s.io"]
    resources  = ["ingresses"]
  }

  rule {
    verbs      = ["update"]
    api_groups = ["networking.k8s.io"]
    resources  = ["ingresses/status"]
  }

  rule {
    verbs      = ["get", "list", "watch"]
    api_groups = ["networking.k8s.io"]
    resources  = ["ingressclasses"]
  }

  rule {
    verbs          = ["get", "update"]
    api_groups     = [""]
    resources      = ["configmaps"]
    resource_names = ["ingress-controller-leader"]
  }

  rule {
    verbs      = ["create"]
    api_groups = [""]
    resources  = ["configmaps"]
  }

  rule {
    verbs      = ["create", "patch"]
    api_groups = [""]
    resources  = ["events"]
  }
  depends_on = [kubernetes_namespace.ingress_nginx]
}

resource "kubernetes_role_binding" "ingress_nginx" {
  metadata {
    name      = "ingress-nginx"
    namespace = "ingress-nginx"

    labels = {
      "app.kubernetes.io/component" = "controller"

      "app.kubernetes.io/instance" = "ingress-nginx"

      "app.kubernetes.io/managed-by" = "Helm"

      "app.kubernetes.io/name" = "ingress-nginx"

      "app.kubernetes.io/version" = "1.0.0"

      "helm.sh/chart" = "ingress-nginx-4.0.1"
    }
  }

  subject {
    kind      = "ServiceAccount"
    name      = "ingress-nginx"
    namespace = "ingress-nginx"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = "ingress-nginx"
  }
  depends_on = [kubernetes_namespace.ingress_nginx]
}

resource "kubernetes_service" "ingress_nginx_controller_admission" {
  metadata {
    name      = "ingress-nginx-controller-admission"
    namespace = "ingress-nginx"

    labels = {
      "app.kubernetes.io/component" = "controller"

      "app.kubernetes.io/instance" = "ingress-nginx"

      "app.kubernetes.io/managed-by" = "Helm"

      "app.kubernetes.io/name" = "ingress-nginx"

      "app.kubernetes.io/version" = "1.0.0"

      "helm.sh/chart" = "ingress-nginx-4.0.1"
    }
  }

  spec {
    port {
      name        = "https-webhook"
      port        = 443
      target_port = "webhook"
    }

    selector = {
      "app.kubernetes.io/component" = "controller"

      "app.kubernetes.io/instance" = "ingress-nginx"

      "app.kubernetes.io/name" = "ingress-nginx"
    }

    type = "ClusterIP"
  }
  depends_on = [kubernetes_namespace.ingress_nginx]
}

resource "kubernetes_service" "ingress_nginx_controller" {
  metadata {
    name      = "ingress-nginx-controller"
    namespace = "ingress-nginx"

    labels = {
      "app.kubernetes.io/component" = "controller"

      "app.kubernetes.io/instance" = "ingress-nginx"

      "app.kubernetes.io/managed-by" = "Helm"

      "app.kubernetes.io/name" = "ingress-nginx"

      "app.kubernetes.io/version" = "1.0.0"

      "helm.sh/chart" = "ingress-nginx-4.0.1"
    }
  }

  spec {
    port {
      name        = "http"
      protocol    = "TCP"
      port        = 80
      target_port = "http"
    }

    port {
      name        = "https"
      protocol    = "TCP"
      port        = 443
      target_port = "https"
    }

    selector = {
      "app.kubernetes.io/component" = "controller"

      "app.kubernetes.io/instance" = "ingress-nginx"

      "app.kubernetes.io/name" = "ingress-nginx"
    }

    type = "NodePort"
  }
  depends_on = [kubernetes_namespace.ingress_nginx]
}

resource "kubernetes_deployment" "ingress_nginx_controller" {
  metadata {
    name      = "ingress-nginx-controller"
    namespace = "ingress-nginx"
    annotations = {
      "cluster-autoscaler.kubernetes.io/safe-to-evict" = "true"
    }

    labels = {
      "app.kubernetes.io/component" = "controller"

      "app.kubernetes.io/instance" = "ingress-nginx"

      "app.kubernetes.io/managed-by" = "Helm"

      "app.kubernetes.io/name" = "ingress-nginx"

      "app.kubernetes.io/version" = "1.0.0"

      "helm.sh/chart" = "ingress-nginx-4.0.1"
    }
  }

  spec {
    selector {
      match_labels = {
        "app.kubernetes.io/component" = "controller"

        "app.kubernetes.io/instance" = "ingress-nginx"

        "app.kubernetes.io/name" = "ingress-nginx"
      }
    }

    template {
      metadata {
        labels = {
          "app.kubernetes.io/component" = "controller"

          "app.kubernetes.io/instance" = "ingress-nginx"

          "app.kubernetes.io/name" = "ingress-nginx"
        }
      }

      spec {
        volume {
          name = "webhook-cert"

          secret {
            secret_name = "ingress-nginx-admission"
          }
        }

        container {
          name  = "controller"
          image = "k8s.gcr.io/ingress-nginx/controller:v1.0.0@sha256:0851b34f69f69352bf168e6ccf30e1e20714a264ab1ecd1933e4d8c0fc3215c6"
          args  = ["/nginx-ingress-controller", "--election-id=ingress-controller-leader", "--controller-class=k8s.io/ingress-nginx", "--configmap=$(POD_NAMESPACE)/ingress-nginx-controller", "--validating-webhook=:8443", "--validating-webhook-certificate=/usr/local/certificates/cert", "--validating-webhook-key=/usr/local/certificates/key"]

          port {
            name           = "http"
            container_port = 80
            protocol       = "TCP"
          }

          port {
            name           = "https"
            container_port = 443
            protocol       = "TCP"
          }

          port {
            name           = "webhook"
            container_port = 8443
            protocol       = "TCP"
          }

          env {
            name = "POD_NAME"

            value_from {
              field_ref {
                field_path = "metadata.name"
              }
            }
          }

          env {
            name = "POD_NAMESPACE"

            value_from {
              field_ref {
                field_path = "metadata.namespace"
              }
            }
          }

          env {
            name  = "LD_PRELOAD"
            value = "/usr/local/lib/libmimalloc.so"
          }

          resources {
            requests = {
              cpu = "100m"

              memory = "90Mi"
            }
          }

          volume_mount {
            name       = "webhook-cert"
            read_only  = true
            mount_path = "/usr/local/certificates/"
          }

          liveness_probe {
            http_get {
              path   = "/healthz"
              port   = "10254"
              scheme = "HTTP"
            }

            initial_delay_seconds = 10
            timeout_seconds       = 1
            period_seconds        = 10
            success_threshold     = 1
            failure_threshold     = 5
          }

          readiness_probe {
            http_get {
              path   = "/healthz"
              port   = "10254"
              scheme = "HTTP"
            }

            initial_delay_seconds = 10
            timeout_seconds       = 1
            period_seconds        = 10
            success_threshold     = 1
            failure_threshold     = 3
          }

          lifecycle {
            pre_stop {
              exec {
                command = ["/wait-shutdown"]
              }
            }
          }

          image_pull_policy = "IfNotPresent"

          security_context {
            capabilities {
              add  = ["NET_BIND_SERVICE"]
              drop = ["ALL"]
            }

            run_as_user                = 101
            allow_privilege_escalation = true
          }
        }

        termination_grace_period_seconds = 300
        dns_policy                       = "ClusterFirst"

        node_selector = {
          "kubernetes.io/os" = "linux"
        }

        service_account_name = "ingress-nginx"
      }
    }

    revision_history_limit = 10
  }
  depends_on = [kubernetes_namespace.ingress_nginx]
}

resource "kubernetes_ingress_class" "nginx" {
  metadata {
    name = "nginx"

    labels = {
      "app.kubernetes.io/component" = "controller"

      "app.kubernetes.io/instance" = "ingress-nginx"

      "app.kubernetes.io/managed-by" = "Helm"

      "app.kubernetes.io/name" = "ingress-nginx"

      "app.kubernetes.io/version" = "1.0.0"

      "helm.sh/chart" = "ingress-nginx-4.0.1"
    }
  }

  spec {
    controller = "k8s.io/ingress-nginx"
  }
  depends_on = [kubernetes_namespace.ingress_nginx]
}

resource "kubernetes_validating_webhook_configuration" "ingress_nginx_admission" {
  metadata {
    name = "ingress-nginx-admission"

    labels = {
      "app.kubernetes.io/component" = "admission-webhook"
      "app.kubernetes.io/instance" = "ingress-nginx"
      "app.kubernetes.io/managed-by" = "Helm"
      "app.kubernetes.io/name" = "ingress-nginx"
      "app.kubernetes.io/version" = "1.0.0"
      "helm.sh/chart" = "ingress-nginx-4.0.1"
    }
  }

  webhook {
    name = "validate.nginx.ingress.kubernetes.io"

    client_config {
      service {
        namespace = "ingress-nginx"
        name      = "ingress-nginx-controller-admission"
        path      = "/networking/v1/ingresses"
      }
    }

    rule {
      operations     = ["CREATE", "UPDATE"]
      api_groups     = ["networking.k8s.io"]
      api_versions   = ["v1"]
      resources      = ["ingresses"]
    }

    failure_policy            = "Fail"
    match_policy              = "Equivalent"
    side_effects              = "None"
    admission_review_versions = ["v1"]
  }
  depends_on = [kubernetes_namespace.ingress_nginx]
}


resource "kubernetes_service_account" "ingress_nginx_admission" {
  metadata {
    name      = "ingress-nginx-admission"
    namespace = "ingress-nginx"

    labels = {
      "app.kubernetes.io/component" = "admission-webhook"

      "app.kubernetes.io/instance" = "ingress-nginx"

      "app.kubernetes.io/managed-by" = "Helm"

      "app.kubernetes.io/name" = "ingress-nginx"

      "app.kubernetes.io/version" = "1.0.0"

      "helm.sh/chart" = "ingress-nginx-4.0.1"
    }

    annotations = {
      "helm.sh/hook" = "pre-install,pre-upgrade,post-install,post-upgrade"

      "helm.sh/hook-delete-policy" = "before-hook-creation,hook-succeeded"
    }
  }
  depends_on = [kubernetes_namespace.ingress_nginx]
}

resource "kubernetes_cluster_role" "ingress_nginx_admission" {
  metadata {
    name = "ingress-nginx-admission"

    labels = {
      "app.kubernetes.io/component" = "admission-webhook"

      "app.kubernetes.io/instance" = "ingress-nginx"

      "app.kubernetes.io/managed-by" = "Helm"

      "app.kubernetes.io/name" = "ingress-nginx"

      "app.kubernetes.io/version" = "1.0.0"

      "helm.sh/chart" = "ingress-nginx-4.0.1"
    }

    annotations = {
      "helm.sh/hook" = "pre-install,pre-upgrade,post-install,post-upgrade"

      "helm.sh/hook-delete-policy" = "before-hook-creation,hook-succeeded"
    }
  }

  rule {
    verbs      = ["get", "update"]
    api_groups = ["admissionregistration.k8s.io"]
    resources  = ["validatingwebhookconfigurations"]
  }
  depends_on = [kubernetes_namespace.ingress_nginx]
}

resource "kubernetes_cluster_role_binding" "ingress_nginx_admission" {
  metadata {
    name = "ingress-nginx-admission"

    labels = {
      "app.kubernetes.io/component" = "admission-webhook"

      "app.kubernetes.io/instance" = "ingress-nginx"

      "app.kubernetes.io/managed-by" = "Helm"

      "app.kubernetes.io/name" = "ingress-nginx"

      "app.kubernetes.io/version" = "1.0.0"

      "helm.sh/chart" = "ingress-nginx-4.0.1"
    }

    annotations = {
      "helm.sh/hook" = "pre-install,pre-upgrade,post-install,post-upgrade"

      "helm.sh/hook-delete-policy" = "before-hook-creation,hook-succeeded"
    }
  }

  subject {
    kind      = "ServiceAccount"
    name      = "ingress-nginx-admission"
    namespace = "ingress-nginx"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "ingress-nginx-admission"
  }
  depends_on = [kubernetes_namespace.ingress_nginx]
}

resource "kubernetes_role" "ingress_nginx_admission" {
  metadata {
    name      = "ingress-nginx-admission"
    namespace = "ingress-nginx"

    labels = {
      "app.kubernetes.io/component" = "admission-webhook"

      "app.kubernetes.io/instance" = "ingress-nginx"

      "app.kubernetes.io/managed-by" = "Helm"

      "app.kubernetes.io/name" = "ingress-nginx"

      "app.kubernetes.io/version" = "1.0.0"

      "helm.sh/chart" = "ingress-nginx-4.0.1"
    }

    annotations = {
      "helm.sh/hook" = "pre-install,pre-upgrade,post-install,post-upgrade"

      "helm.sh/hook-delete-policy" = "before-hook-creation,hook-succeeded"
    }
  }

  rule {
    verbs      = ["get", "create"]
    api_groups = [""]
    resources  = ["secrets"]
  }
  depends_on = [kubernetes_namespace.ingress_nginx]
}

resource "kubernetes_role_binding" "ingress_nginx_admission" {
  metadata {
    name      = "ingress-nginx-admission"
    namespace = "ingress-nginx"

    labels = {
      "app.kubernetes.io/component" = "admission-webhook"

      "app.kubernetes.io/instance" = "ingress-nginx"

      "app.kubernetes.io/managed-by" = "Helm"

      "app.kubernetes.io/name" = "ingress-nginx"

      "app.kubernetes.io/version" = "1.0.0"

      "helm.sh/chart" = "ingress-nginx-4.0.1"
    }

    annotations = {
      "helm.sh/hook" = "pre-install,pre-upgrade,post-install,post-upgrade"

      "helm.sh/hook-delete-policy" = "before-hook-creation,hook-succeeded"
    }
  }

  subject {
    kind      = "ServiceAccount"
    name      = "ingress-nginx-admission"
    namespace = "ingress-nginx"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = "ingress-nginx-admission"
  }
  depends_on = [kubernetes_namespace.ingress_nginx]
}

resource "kubernetes_job" "ingress_nginx_admission_create" {
  metadata {
    name      = "ingress-nginx-admission-create"
    namespace = "ingress-nginx"

    labels = {
      "app.kubernetes.io/component" = "admission-webhook"

      "app.kubernetes.io/instance" = "ingress-nginx"

      "app.kubernetes.io/managed-by" = "Helm"

      "app.kubernetes.io/name" = "ingress-nginx"

      "app.kubernetes.io/version" = "1.0.0"

      "helm.sh/chart" = "ingress-nginx-4.0.1"
    }

    annotations = {
      "helm.sh/hook" = "pre-install,pre-upgrade"

      "helm.sh/hook-delete-policy" = "before-hook-creation,hook-succeeded"
    }
  }

  spec {
    template {
      metadata {
        name = "ingress-nginx-admission-create"

        labels = {
          "app.kubernetes.io/component" = "admission-webhook"

          "app.kubernetes.io/instance" = "ingress-nginx"

          "app.kubernetes.io/managed-by" = "Helm"

          "app.kubernetes.io/name" = "ingress-nginx"

          "app.kubernetes.io/version" = "1.0.0"

          "helm.sh/chart" = "ingress-nginx-4.0.1"
        }
      }

      spec {
        container {
          name  = "create"
          image = "k8s.gcr.io/ingress-nginx/kube-webhook-certgen:v1.0@sha256:f3b6b39a6062328c095337b4cadcefd1612348fdd5190b1dcbcb9b9e90bd8068"
          args  = ["create", "--host=ingress-nginx-controller-admission,ingress-nginx-controller-admission.$(POD_NAMESPACE).svc", "--namespace=$(POD_NAMESPACE)", "--secret-name=ingress-nginx-admission"]

          env {
            name = "POD_NAMESPACE"

            value_from {
              field_ref {
                field_path = "metadata.namespace"
              }
            }
          }

          image_pull_policy = "IfNotPresent"
        }

        restart_policy = "OnFailure"

        node_selector = {
          "kubernetes.io/os" = "linux"
        }

        service_account_name = "ingress-nginx-admission"

        security_context {
          run_as_user     = 2000
          run_as_non_root = true
        }
      }
    }
  }
  depends_on = [kubernetes_namespace.ingress_nginx]
}

resource "kubernetes_job" "ingress_nginx_admission_patch" {
  metadata {
    name      = "ingress-nginx-admission-patch"
    namespace = "ingress-nginx"

    labels = {
      "app.kubernetes.io/component" = "admission-webhook"

      "app.kubernetes.io/instance" = "ingress-nginx"

      "app.kubernetes.io/managed-by" = "Helm"

      "app.kubernetes.io/name" = "ingress-nginx"

      "app.kubernetes.io/version" = "1.0.0"

      "helm.sh/chart" = "ingress-nginx-4.0.1"
    }

    annotations = {
      "helm.sh/hook" = "post-install,post-upgrade"

      "helm.sh/hook-delete-policy" = "before-hook-creation,hook-succeeded"
    }
  }

  spec {
    template {
      metadata {
        name = "ingress-nginx-admission-patch"

        labels = {
          "app.kubernetes.io/component" = "admission-webhook"

          "app.kubernetes.io/instance" = "ingress-nginx"

          "app.kubernetes.io/managed-by" = "Helm"

          "app.kubernetes.io/name" = "ingress-nginx"

          "app.kubernetes.io/version" = "1.0.0"

          "helm.sh/chart" = "ingress-nginx-4.0.1"
        }
      }

      spec {
        container {
          name  = "patch"
          image = "k8s.gcr.io/ingress-nginx/kube-webhook-certgen:v1.0@sha256:f3b6b39a6062328c095337b4cadcefd1612348fdd5190b1dcbcb9b9e90bd8068"
          args  = ["patch", "--webhook-name=ingress-nginx-admission", "--namespace=$(POD_NAMESPACE)", "--patch-mutating=false", "--secret-name=ingress-nginx-admission", "--patch-failure-policy=Fail"]

          env {
            name = "POD_NAMESPACE"

            value_from {
              field_ref {
                field_path = "metadata.namespace"
              }
            }
          }

          image_pull_policy = "IfNotPresent"
        }

        restart_policy = "OnFailure"

        node_selector = {
          "kubernetes.io/os" = "linux"
        }

        service_account_name = "ingress-nginx-admission"

        security_context {
          run_as_user     = 2000
          run_as_non_root = true
        }
      }
    }
  }
  depends_on = [kubernetes_namespace.ingress_nginx]
}