# SolarPeformanceInsight Deployment

This repository contains the necessary scripts and templates to deploy
the SolarPeformanceInsight on a fresh AWS EKS cluster. View cluster
and app metrics at
[https://grafana.solarperformanceinsight.org](https://grafana.solarperformanceinsight.org)
and see the status of app deployments at
[https://argocd.solarperformanceinsight.org](https://argocd.solarperformanceinsight.org)
by logging in via GitHub.

## Cluster Setup

In the `cluster-setup/` folder, you'll find the `cluster.yaml` file that
was used with ``eksctl create cluster -f cluster.yaml`` to create the
initial AWS EKS cluster. One may need to use ``eksctl utils
write-kubeconfig`` with appropriate options to make sure ``kubectl``
can communicate with the new cluster. Once the cluster is created,
various infrastructure components are installed via Ansible:
``ansible-playbook ansible/setup.yml``.


After this is complete (and routes are created to the NLB in Route53)
one should be able to login via GitHub to view metrics in [Grafana](https://grafana.solarperformanceinsight.org)
and see the status of app deployments in [Argo CD](https://argocd.solarperformanceinsight.org).
Access to [Prometheus](https://prometheus.solarperformanceinsight.org)
and [Alertmanager](https://alertmanager.solarperformanceinsight.org)
will require the addition of ``htpasswd`` lines in the
`/k8ssecrets/default-htpasswd` parameter in the SPI AWS Systems
Manager Parameter Store.

## SPI App

The actual SolarPerformanceInsight app is deployed via [Argo
CD](https://argocd.solarperformanceinsight.org) from the applications
defined in the ``applications`` folder.


Each application should reference a folder containing a kustomization overlay
on top of resources found in ``base``. For example, the development application
builds the Kubernetes manifests from the `overlays/development` folder. Any
changes to the application should be done through these manifests to let Argo CD
automatically update the resources once the change is merged. Otherwise,
Argo will likely revert any changes made to the resources to the state describe
in the latest commit.


Application errors are monitored with [Sentry](https://sentry.io/organizations/solar-performance-insight/issues/).
Other application statistics can be found on the appropriate dashboard of the
[Grafana](https://grafana.solarperformanceinsight.org) deployment that monitors
Prometheus metrics for the cluster. Alerts can be configured either directly
in Grafana or through [Alertmanager](https://alertmanager.solarperformanceinsight.org).
Application logs are aggregated via [Loki](https://grafana.solarperformanceinsight.org/explore)
and accessible from the Explore link in Grafana.
