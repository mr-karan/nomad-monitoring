job "victoriametrics" {
  datacenters = ["dc1"]
  type        = "service"

  group "victoriametrics" {
    count = 1

    volume "victoriametrics" {
      type      = "host"
      read_only = false
      source    = "victoriametrics"
    }

    network {
      mode = "bridge"

      port "vicky-http" {
        to = 8428
      }
    }

    task "victoriametrics" {
      driver = "docker"

      service {
        name     = "vicky-web"
        provider = "nomad"
        tags     = ["victoriametrics", "web"]
        port     = "vicky-http"
      }

      volume_mount {
        volume      = "victoriametrics"
        destination = "/storage"
        read_only   = false
      }

      config {
        image = "victoriametrics/victoria-metrics:v1.81.2"
        ports = ["vicky-http"]
        args = [
          "--storageDataPath=/storage",
          "--retentionPeriod=1",
          "--httpListenAddr=:8428"
        ]
      }

      resources {
        cpu    = 256
        memory = 300
      }
    }
  }

}