#!/usr/bin/env bash
set -euo pipefail

# Run only against a disposable cluster; this creates and deletes a namespace.
if [ "$#" -ne 1 ] || [ "${HELMSNAP_DISPOSABLE_CLUSTER:-}" != yes ]; then
  echo 'Usage: HELMSNAP_DISPOSABLE_CLUSTER=yes check-bridge-cluster.sh KUBECONFIG' >&2
  exit 2
fi
export KUBECONFIG="$1"
test -f "$KUBECONFIG"
helm version --short | grep -E '^v4\.1\.4\+zapravila\.20261006\.g05fa379$'
helmfile --version | grep -E '^helmfile version v1\.8\.1\+zapravila\.20261006$'
kubectl get --raw=/version | grep -E '"gitVersion"[[:space:]]*:[[:space:]]*"v1\.32\.'

fixture_dir="$(mktemp -d)"
namespace="helmsnap-bridge-$(date +%s)-$$"
cleanup() {
  kubectl delete namespace "$namespace" --wait=false >/dev/null || true
  rm -rf "$fixture_dir"
}
trap cleanup EXIT
kubectl create namespace "$namespace"
mkdir -p "$fixture_dir/chart/templates"
cat > "$fixture_dir/chart/Chart.yaml" <<'EOF'
apiVersion: v2
name: bridge-fixture
version: 0.1.0
EOF
cat > "$fixture_dir/chart/templates/configmap.yaml" <<'EOF'
apiVersion: v1
kind: ConfigMap
metadata:
  name: bridge-fixture
data:
  revision: {{ .Values.revision | quote }}
EOF
cat > "$fixture_dir/helmfile.yaml" <<EOF
releases:
  - name: bridge-fixture
    namespace: $namespace
    chart: ./chart
    values:
      - revision: helmfile
EOF
helm install bridge-fixture "$fixture_dir/chart" -n "$namespace" --set revision=installed --wait --timeout 60s
test "$(kubectl get configmap bridge-fixture -n "$namespace" -o jsonpath='{.data.revision}')" = installed
helm upgrade bridge-fixture "$fixture_dir/chart" -n "$namespace" --set revision=upgraded --wait --timeout 60s
test "$(kubectl get configmap bridge-fixture -n "$namespace" -o jsonpath='{.data.revision}')" = upgraded
helm rollback bridge-fixture 1 -n "$namespace" --wait --timeout 60s
test "$(kubectl get configmap bridge-fixture -n "$namespace" -o jsonpath='{.data.revision}')" = installed
helmfile --file "$fixture_dir/helmfile.yaml" sync --args '--wait --timeout 60s'
test "$(kubectl get configmap bridge-fixture -n "$namespace" -o jsonpath='{.data.revision}')" = helmfile
helm uninstall bridge-fixture -n "$namespace" --wait --timeout 60s
remaining="$(kubectl get configmap bridge-fixture -n "$namespace" --ignore-not-found -o name)"
if [ -n "$remaining" ]; then
  echo 'Uninstall left the fixture ConfigMap behind' >&2
  exit 1
fi
echo 'Bridge install, upgrade, rollback, Helmfile sync and uninstall passed'
