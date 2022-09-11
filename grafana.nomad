job "grafana" {
  datacenters = ["dc1"]
  type        = "service"

  group "grafana" {
    count = 1

    volume "grafana" {
      type      = "host"
      read_only = false
      source    = "grafana"
    }

    network {
      mode = "bridge"

      port "grafana-http" {
        to = 3000
      }
    }

    task "grafana" {
      driver = "docker"

      service {
        name     = "grafana-web"
        provider = "nomad"
        tags     = ["grafana", "web"]
        port     = "grafana-http"
      }

      env {
        GF_LOG_LEVEL          = "DEBUG"
        GF_LOG_MODE           = "console"
        GF_SERVER_HTTP_PORT   = "$${NOMAD_PORT_http}"
        GF_PATHS_PROVISIONING = "/local/grafana/provisioning"
      }

      volume_mount {
        volume      = "grafana"
        destination = "/var/lib/grafana"
        read_only   = false
      }

      user = "root"

      config {
        image = "grafana/grafana:9.1.4-ubuntu"
        ports = ["grafana-http"]
      }

      resources {
        cpu    = 256
        memory = 300
      }

      template {
        data        = <<EOF
apiVersion: 1
datasources:
  - name: Prometheus
    type: prometheus
    access: proxy
    {{- range nomadService "vicky-web" }}
    url: http://{{.Address}}:{{.Port}}
    {{ end -}}
EOF
        destination = "/local/grafana/provisioning/datasources/datasources.yaml"
      }

      template {
        data        = <<EOF
apiVersion: 1
providers:
  - name: dashboards
    type: file
    updateIntervalSeconds: 30
    options:
      foldersFromFilesStructure: true
      path: /local/grafana/provisioning/dashboards
EOF
        destination = "/local/grafana/provisioning/dashboards/dashboards.yaml"
      }

      template {
        data            = file(abspath("./dashboards/allocations.json"))
        destination     = "local/grafana/provisioning/dashboards/nomad/allocations.json"
        left_delimiter  = "[["
        right_delimiter = "]]"
      }
      template {
        data            = file(abspath("./dashboards/clients.json"))
        destination     = "local/grafana/provisioning/dashboards/nomad/clients.json"
        left_delimiter  = "[["
        right_delimiter = "]]"
      }
      template {
        data            = file(abspath("./dashboards/server.json"))
        destination     = "local/grafana/provisioning/dashboards/nomad/server.json"
        left_delimiter  = "[["
        right_delimiter = "]]"
      }
    }
  }

}