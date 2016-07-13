BASE := $(subst -, ,$(notdir ${CURDIR}))
ORG  := $(word 1, ${BASE})
REPO := $(word 2, ${BASE})
IMG  := quay.io/${ORG}/${REPO}
TAG  := latest

build:
	docker build -t ${IMG}:${TAG}	.

publish: build
	docker push ${IMG}:${TAG}
	@if [ "${TAG}" != "latest" ]; then docker tag ${IMG}:${TAG} ${IMG}:latest && docker push ${IMG}:latest; fi

test: build
	docker-compose up -d
	docker-compose run --rm hdfs-name hdfs dfs -touchz /live-check
	docker-compose run --rm hdfs-name hdfs dfs -ls /live-check
	docker-compose down
