#!/usr/bin/env bash 

# this script is used to get the kubeconfig via pks cli   

set -o errexit
set -o nounset

main () {
    if [ $PKS ]; then
        fetch_pks
    elif [ -n $KUBE_CONFIG ]; then
        fetch_kubeconfig
    else 
        echo "Error: You need to specify either PKS or provide a KUBE_CONFIG"
    fi


}

fetch_pks() {
    # Thanks to William Arroyo
    # https://github.com/warroyo/pks-api/blob/master/get-credentials.md

    # get an access token from UAA
    my_token=$(curl "https://$PKS_API:8443/oauth/token" -k -X POST \
        -H 'Content-Type: application/x-www-form-urlencoded' \
        -H 'Accept: application/json' \
        -d "response_type=token&client_id=pks_cli&client_secret=&grant_type=password&username=$PKS_USER&password=$PKS_PASSWORD" | jq -r .access_token)

    # take the access token above and get the kubeconfig from the PKS API
    curl "https://$PKS_API:9021/v1/clusters/$PKS_CLUSTER/binds" -k -s -X POST \
        -H 'Accept: application/json' \
        -H 'Content-Type: application/json' \
        -H "Authorization: Bearer $my_token" > config.json


    # get the acess token needed for the cluster from UAA
    curl "https://$PKS_API:8443/oauth/token" -k -s -X POST \
        -H 'Content-Type: application/x-www-form-urlencoded' \
        -H 'Accept: application/json' \
        -d "response_type=token&client_id=pks_cluster_client&client_secret=&grant_type=password&username=$PKS_USER&password=$PKS_PASSWORD" > token.json

    # set the credentials in the kubeconfig
    kubectl config set-credentials $PKS_USER --auth-provider-arg=id-token=$(cat token.json | jq -r .id_token) --kubeconfig=./config.json

    kubectl config set-credentials $PKS_USER --auth-provider-arg=refresh-token=$(cat token.json | jq -r .refresh_token) --kubeconfig=./config.json

    if [[ -f config ]]; then
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
    kubectl apply -f yelb-github/deployments/platformdeployment/Kubernetes/yaml/pks-yelb-lb-harbor.yaml -n $K8S_NAMESPACE --kubeconfig=./config.json
}

main