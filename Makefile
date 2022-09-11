.PHONY: run-nomad _dirs deploy

_dirs:
	sudo mkdir -p /data/grafana /data/victoriametrics

run-nomad:
	sudo nomad agent -config=agent.hcl

deploy: _dirs
	nomad run victoriametrics.nomad
	nomad run vmagent.nomad
	nomad run grafana.nomad
