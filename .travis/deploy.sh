#!/usr/bin/env bash

set -e -x

docker push quay.io/${QUAY_ORG}/${QUAY_REPO}:${QUAY_TAG}
docker tag quay.io/${QUAY_ORG}/${QUAY_REPO}:${QUAY_TAG} quay.io/${QUAY_ORG}/${QUAY_REPO}:latest
docker push quay.io/${QUAY_ORG}/${QUAY_REPO}:latest
