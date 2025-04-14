#!/bin/sh

namespace="travel-db"
target=""
name="my-grant"

function usage {
    echo "Use: `basename $0` access_grant_name"
    echo ""
    echo "Options:"
    echo "    -n string, --namespace string        Namespace name to read AccessGrant information"
    echo "    -t string, --target string           Target namespace name for the produced AccessToken"
    exit 1
}

function validate_name {
    if ! echo "${2}" | grep -qE '^[a-z0-9]([-a-z0-9]*[a-z0-9])?$'; then
        echo "Invalid ${1}: ${2}"
        usage
    fi
}

while [ $# -gt 0 ]
do
    case "$1" in
        -h|--help)
            usage
            ;;
        -n|--namespace)
            namespace="${2}"
            shift 2
            validate_name Namespace "${namespace}"
            ;;
        --namespace=*)
            namespace="$(echo "$1" | awk -F= '{print $2}')"
            shift
            validate_name Namespace "${namespace}"
            ;;
        -t|--target)
            target="${2}"
            shift 2
            validate_name "Target Namespace" "${target}"
            ;;
        --target=*)
            target="$(echo "$1" | awk -F= '{print $2}')"
            shift
            validate_name "Target Namespace" "${target}"
            ;;
        *)
            [ "${name}" != "" ] && \
                echo "Invalid argument: ${1}" && \
                exit 1
            name="${1}"
            shift
            validate_name "Grant Name" "${name}"
    esac
done

[ -z "${name}" ] && echo "AccessGrant name not provided" && exit 1

TEMPLATE="apiVersion: skupper.io/v2alpha1
kind: AccessToken
metadata:
  name: token-{{.metadata.name}}
spec:
  ca: {{printf \"%q\" .status.ca}}
  code: {{.status.code}}
  url: {{.status.url}}
"

kubectl -n "${namespace}" get accessgrant "${name}" -o go-template="${TEMPLATE}"