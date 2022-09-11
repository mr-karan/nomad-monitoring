job "vmagent" {
  datacenters = ["dc1"]
  type        = "service"

  group "vmagent" {
    count = 1

    network {
      mode = "bridge"

      port "vmagent-http" {
        to = 8429
      }
    }

    task "vmagent" {
      driver = "docker"

      config {
        image = "victoriametrics/vmagent:v1.81.2"
        args = [
          "--promscrape.config=$${NOMAD_TASK_DIR}/prometheus.yml",
          "--remoteWrite.url=${VICTORIAMETRICS_ADDR}"
        ]
      }

      template {
        data        = file(abspath("./configs/prometheus.tpl.yml"))
        destination = "local/prometheus.yml"
        change_mode = "restart"
      }

      template {
        data = <<EOF
  {{- range nomadService "vicky-web" }}
  VICTORIAMETRICS_ADDR=http://{{ .Address }}:{{ .Port }}/api/v1/write
{{ end -}}
EOF

        destination = "local/env"
        env         = true
      }


      resources {
        cpu    = 256
        memory = 300
      }
    }
  }

}