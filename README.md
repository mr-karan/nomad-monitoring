<a href="https://zerodha.tech"><img src="https://zerodha.tech/static/images/github-badge.svg" align="right" /></a>

# Nomad Monitoring

A collection of [Nomad](https://www.nomadproject.io/) jobspecs and [Grafana](https://grafana.com/) dashboards to provide an easy for end-to-end Nomad cluster monitoring.

## Running locally

To run a local Nomad agent (running as a server and client), run the following:

```bash
make run-nomad
```

To deploy Grafana, [Victoriametrics](https://victoriametrics.com/) and `vmagent`, run:

```bash
make deploy
```

## Dashboards

- Server: Monitor overall health, and resource usage of a Nomad cluster, Raft usage, RPC usage etc.
- Client: Monitor resource usage for each Nomad clients.
- Allocations: Monitor resource metrics like CPU, Memory and Disk for each allocation across namespaces.

![](docs/screenshots/calert.png)
![](docs/screenshots/calert.png)
![](docs/screenshots/calert.png)

## Collecting Metrics

Nomad comes with an in-built publication of [metrics](https://www.nomadproject.io/docs/operations/monitoring-nomad) which makes it easier to collect metrics without running any 3-rd party tool. To enable Prometheus metrics, configure the [`telemetry`](https://www.nomadproject.io/docs/configuration/telemetry) stanza in each Nomad agent:

```hcl
telemetry {
  collection_interval        = "15s"
  disable_hostname           = true
  prometheus_metrics         = true
  publish_allocation_metrics = true
  publish_node_metrics       = true
}
```

This repository demonstrates the usage of [`vmagent`](https://github.com/VictoriaMetrics/VictoriaMetrics/blob/master/docs/vmagent.md) which is a lightweight metrics collection agent. Prometheus also [ships with an agent only mode](https://prometheus.io/blog/2021/11/16/agent/) which can be used alternatively. I find `vmagent` has a better overall UX for config (easier relabelling rules, splitting of `scrape_configs` as multiple files) and lightweight resource usage hence it's my de-facto choice for collecting Prometheus metrics.

## Storing Metrics

Victoriametrics is used as a TSDB to store metrics. Victoriametrics can support a large number of active timeseries in memory and is efficient at storing large batches of timeseries on disk as well. `vmagent` is configured to use `remote_write` protocol and send the metrics collected to Victoriametrics. Retention period can be configured in Victoriametrics' end.

## Notes

### Nomad Services

Since Nomad 1.3, `nomad` comes with it's own service discovery mechanism. It allows to discover services within the namespaces with the usage of templating a file. However, as of now it cannot discover services outside a particular namespace which makes it hard to deploy a central `vmagent`. Until Nomad services come with that feature the two choices that exist right now:

- Use `consul` for service discovery and use `consul_sd_config` in `vmagent` to discover.
- Deploy `vmagent` for each namespace and discover services via Nomad service discovery itself. Use them with `static_config`.

## TODO

- Add alert rules
