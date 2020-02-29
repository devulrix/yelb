#!/usr/env bash 

# this script is used to get the kubeconfig via pks cli   

set -o errexit
set -o nounset
set -o pipefail

main () {
    if [ $PKS ] then
        fetch_pks
    elif [ -n $KUBE_CONFIG ]; then
        fetch_kubeconfig
    else 
        echo "Error: You need to specify either PKS or provide a KUBE_CONFIG"
    fi


}

fetch_pks() {
    pks get-credentials $PKS_CLUSTER -u $PKS_USERNAME -p $PKS_PASSWORD -k

    if [[ -f ~/.kube/config ]]; then
        return 0
    else 
        echo "Error: PKS cloud not fetch kube config "
    fi
}

fetch_kubeconfig() {
    mkdir -p ~/.kube

    if [[ -f ~/.kube/config ]]; then
        return 0
    fi

    if [[ -z $KUBE_CONFIG ]]; then
        echo "Error: KUBE_CONFIG must be specified when ~/.kube/config doesnt exist and PKS is not the source"
        exit 1
    fi

    echo "$KUBE_CONFIG" >~/.kube/config
}

deploy() {
    kubectl apply -f yelb-github/deployments/platformdeployment/Kubernetes/yaml/pks-yelb-lb-harbor.yaml -n $K8S_NAMESPACE
}

main