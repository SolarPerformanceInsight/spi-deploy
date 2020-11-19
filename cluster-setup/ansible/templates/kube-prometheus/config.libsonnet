local k = import 'ksonnet/ksonnet.beta.4/k.libsonnet';
local configMap = k.core.v1.configMap;
local ingress = k.extensions.v1beta1.ingress;
local ingressTls = ingress.mixin.spec.tlsType;
local ingressRule = ingress.mixin.spec.rulesType;
local httpIngressPath = ingressRule.mixin.http.pathsType;
local secret = k.core.v1.secret;
local pvc = k.core.v1.persistentVolumeClaim;
local toleration = k.core.v1.tolerationsType;


(import 'kube-prometheus/kube-prometheus.libsonnet') +
(import 'kube-prometheus/kube-prometheus-anti-affinity.libsonnet') +
(import 'kube-prometheus/kube-prometheus-all-namespaces.libsonnet') +
(import 'kube-prometheus/kube-prometheus-kubeadm.libsonnet')
{
  _config+:: {
    namespace: 'monitoring',
    alertmanager +: {
      config: importstr 'alertmanager-config.yml',
    },
    grafana+:: {
      config+: {
        sections+: {
          server+: {
            root_url: 'http://grafana.solarperformanceinsight.org/',
          },
        },
      },
    },
    prometheus+:: {
      replicas: 1,
    },
  },
  // Configure External URL's per application
  alertmanager+:: {
    alertmanager+: {
      spec+: {
        externalUrl: 'http://alertmanager.solarperformanceinsight.org',
        storage: {
          volumeClaimTemplate:
            pvc.new() +
          pvc.mixin.spec.resources.withRequests({ 'storage': '2Gi'}) +
          pvc.mixin.spec.withAccessModes('ReadWriteOnce')
        },
      },
    },
  },

  prometheus+:: {
    prometheus+: {
      spec+: {
        externalUrl: 'http://prometheus.solarperformanceinsight.org',
        retention: '10d',
        storage: {
          volumeClaimTemplate:
            pvc.new() +
          pvc.mixin.spec.resources.withRequests({ 'storage': '30Gi'}) +
          pvc.mixin.spec.withAccessModes('ReadWriteOnce')
        },
      },
    },
  },
  // Create ingress objects per application
  ingress+:: {
    local auth = {
      'kubernetes.io/ingress.class': 'nginx',
      'nginx.ingress.kubernetes.io/auth-secret': 'default/default-auth',
      'nginx.ingress.kubernetes.io/auth-type': 'basic',
      'nginx.ingress.kubernetes.io/auth-realm': 'Authentication Required',
    },
    'alertmanager-main':
      ingress.new() +
    ingress.mixin.metadata.withName('alertmanager-main') +
    ingress.mixin.metadata.withNamespace($._config.namespace) +
    ingress.mixin.metadata.withAnnotations(auth) +
    ingress.mixin.spec.withTls(
        ingressTls.new() +
        ingressTls.withHosts('alertmanager.solarperformanceinsight.org') +
        ingressTls.withSecretName('spi-tls')
    ) +
    ingress.mixin.spec.withRules(
        ingressRule.new() +
        ingressRule.withHost('alertmanager.solarperformanceinsight.org') +
        ingressRule.mixin.http.withPaths(
            httpIngressPath.new() +
            httpIngressPath.mixin.backend.withServiceName('alertmanager-main') +
            httpIngressPath.mixin.backend.withServicePort('web')
        ),
    ),
    'prometheus-k8s':
      ingress.new() +
    ingress.mixin.metadata.withName('prometheus-k8s') +
    ingress.mixin.metadata.withNamespace($._config.namespace) +
    ingress.mixin.metadata.withAnnotations(auth) +
    ingress.mixin.spec.withTls(
        ingressTls.new() +
        ingressTls.withHosts('prometheus.solarperformanceinsight.org') +
        ingressTls.withSecretName('spi-tls')
    ) +
    ingress.mixin.spec.withRules(
        ingressRule.new() +
        ingressRule.withHost('prometheus.solarperformanceinsight.org') +
        ingressRule.mixin.http.withPaths(
            httpIngressPath.new() +
            httpIngressPath.mixin.backend.withServiceName('prometheus-k8s') +
            httpIngressPath.mixin.backend.withServicePort('web')
        ),
    ),
  },
  grafana +: {
    dashboardDefinitions +: {
      items: [
        x +
        configMap.mixin.metadata.withLabels({'grafana_dashboard': '1'})
        for x in super.items
      ],
    },
  },
}
