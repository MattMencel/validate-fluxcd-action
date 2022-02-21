#!/usr/bin/env bash

# This script downloads the Flux OpenAPI schemas, then it validates the
# Flux custom resources and the kustomize overlays using kubeconform.

# Prerequisites
# - yq v4.6
# - kustomize v4.1
# - kubeconform v0.4
# - kubepug v1.3

set -o errexit

K8S_TARGET_VERSION=$1

echo "INFO - Downloading Flux OpenAPI schemas"
mkdir -p /tmp/flux-crd-schemas/master-standalone-strict
curl -sL https://github.com/fluxcd/flux2/releases/latest/download/crd-schemas.tar.gz | tar zxf - -C /tmp/flux-crd-schemas/master-standalone-strict

find . -type f -name '*.yaml' -print0 | while IFS= read -r -d $'\0' file; do
  echo "INFO - Validating $file"
  yq e 'true' "$file" >/dev/null
done

kubeconform_config="-strict -ignore-missing-schemas -schema-location default -schema-location /tmp/flux-crd-schemas -verbose"

echo "INFO - Validating clusters"
find ./clusters -maxdepth 2 -type f -name '*.yaml' -print0 | while IFS= read -r -d $'\0' file; do
  kubeconform $kubeconform_config ${file}
  if [[ ${PIPESTATUS[0]} != 0 ]]; then
    exit 1
  fi
done

# mirror kustomize-controller build options
kustomize_flags="--load-restrictor=LoadRestrictionsNone --reorder=legacy"
kustomize_config="kustomization.yaml"

echo "INFO - Validating kustomize overlays"
find . -type f -name $kustomize_config -print0 | while IFS= read -r -d $'\0' file; do
  echo "INFO - Validating kustomization ${file/%$kustomize_config/}"
  kustomize build "${file/%$kustomize_config/}" $kustomize_flags |
    kubeconform $kubeconform_config
  if [[ ${PIPESTATUS[0]} != 0 ]]; then
    exit 1
  fi
done

kubepug_flags="--error-on-deprecated --error-on-deleted --k8s-version ${K8S_TARGET_VERSION} --input-file /dev/stdin"

echo "INFO - Deprecations in kustomize overlays"
find . -type f -name $kustomize_config -print0 | while IFS= read -r -d $'\0' file; do
  echo "INFO - Deprecation check on kustomization ${file/%$kustomize_config/}"
  kustomize build "${file/%$kustomize_config/}" $kustomize_flags |
    kubepug $kubepug_flags
  if [[ ${PIPESTATUS[0]} != 0 ]]; then
    exit 1
  fi
done
