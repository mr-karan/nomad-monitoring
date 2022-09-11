datacenter = "dc1"
data_dir   = "/opt/nomad/data"

log_level = "INFO"

bind_addr = "0.0.0.0"

server {
  enabled          = true
  bootstrap_expect = 1
}

client {
  enabled = true

  reserved {
    cores          = 1
    memory         = 1024
    disk           = 1024
    reserved_ports = "22"
  }

  meta {
    env = "dev"
  }

  host_volume "grafana" {
    path      = "/data/grafana"
    read_only = false
  }

  host_volume "victoriametrics" {
    path      = "/data/victoriametrics"
    read_only = false
  }
}

plugin "docker" {
  config {
    allow_privileged = true
    volumes {
      enabled = true
    }
    extra_labels = ["job_name", "job_id", "task_group_name", "task_name", "namespace", "node_name", "node_id"]
  }
}

plugin "raw_exec" {
  config {
    enabled = true
  }
}

telemetry {
  collection_interval        = "15s"
  disable_hostname           = true
  prometheus_metrics         = true
  publish_allocation_metrics = true
  publish_node_metrics       = true
}
