SolarPerformanceInsight EKS Infrastructure
------------------------------------------

This folder contains Ansible playbooks to setup essential services
once an EKS cluster has been established including:
- [NGINX ingress controller](https://kubernetes.github.io/ingress-nginx/) for
  routing traffic through an AWS Network Load Balancer to specific apps
- [cert-manager](https://cert-manager.io/) to automatically get and renew
  TLS certificates from Let's Encrypt
- [kubernetes-external-secrets](https://github.com/external-secrets/kubernetes-external-secrets)
  to automatically fetch Secrets from AWS SSM to avoid saving them in this repo
- [kubed](https://github.com/appscode/kubed) to automatically sync Secrets
  (including the TLS certs) accross namespaces
- [Argo CD](https://argoproj.github.io/argo-cd/) to automatically deploy
  applications based on changes to Git repos
- [Grafana Loki](https://grafana.com/oss/loki/) to collect and organize
  container logs
- [Prometheus Operator](https://github.com/prometheus-operator/kube-prometheus)
  to install Prometheus and Alertmanager to collect metrics and alert if there
  is an issue
- [Grafana](https://grafana.com/oss/grafana) to visualized metrics from
  Prometheus and view logs from Loki

One should be able to run the ``setup.yml`` Ansible Playbook to setup all of
this infrastructure. Before doing so, make sure ``kubectl`` is installed and
configured to communicate with the appropriate K8s cluster, possibly by setting
the ``KUBE_CONFIG`` env var. This playbook works with Ansible 2.9.6 and also
requires [jsonnet](jsonnet.org), [jsonnet-bundler](https://github.com/jsonnet-bundler/jsonnet-bundler#install),
and [gojsontoyaml](https://github.com/brancz/gojsontoyaml) on your ``PATH``.
