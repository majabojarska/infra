#!/usr/bin/env bash

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)
FLUXCD_DIR=$(realpath "${SCRIPT_DIR}/..")
CLUSTERS_DIR="${FLUXCD_DIR}/clusters"

# Ensure all cluster kustomizations are valid
for CLUSTER_DIR in "${CLUSTERS_DIR}"/*/; do
    pushd "${CLUSTER_DIR}" > /dev/null || exit 1

    # validate if we can create and build a flux-system like kustomization file
    if ! kustomize build . -o /dev/null; then
        echo "Error building flux-system kustomization for cluster ${PWD}"
    fi

    echo "Kustomization built successfully: ${CLUSTER_DIR}"

    popd > /dev/null || exit 1
done
