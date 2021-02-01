NAME        = sample-go-project
VERSION     = $(shell git describe --always --match "v*")
BRANCH      = $(shell git rev-parse --abbrev-ref HEAD)
IMAGE_REPO  = asajaroff/$(NAME)
CACHE_TAG   = $(IMAGE_REPO):cache-$(BRANCH)
TAG         = $(IMAGE_REPO):$(VERSION)

.PHONY: default install build push chart-update git-prep git-push install-docker install-buildx install-yq go-run go-build

# Global targets

default: build

install: install-docker install-buildx install-yq

#
# Docker image building and pushing
#
# * https://github.com/docker/buildx
#
run:
	docker run $(TAG) 


build:
	docker buildx build \
	  --build-arg BUILD_DATE=$(shell date -u +'%Y-%m-%dT%H:%M:%SZ') \
	  --build-arg BUILD_VCS_REF=$(shell git rev-parse --short HEAD) \
	  --build-arg BUILD_VERSION=$(VERSION) \
	  -t $(TAG) \
	  --load \
	  .

push:
	docker buildx build \
	  --build-arg BUILD_DATE=$(shell date -u +'%Y-%m-%dT%H:%M:%SZ') \
	  --build-arg BUILD_VCS_REF=$(shell git rev-parse --short HEAD) \
	  --build-arg BUILD_VERSION=$(VERSION) \
	  --cache-from=type=registry,ref=$(CACHE_TAG) \
	  --cache-to=type=registry,ref=$(CACHE_TAG),mode=max \
	  -t $(TAG) \
	  --push \
	  --progress=plain \
	  .

#
# Install dependencies
#
install-yq:
	sudo add-apt-repository ppa:rmescandon/yq -y
	sudo apt update
	sudo apt install yq -y

install-docker:
	curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
	sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(shell lsb_release -cs) stable"
	sudo apt-get update
	sudo apt-get -y -o Dpkg::Options::="--force-confnew" install docker-ce

install-buildx:
	mkdir -p ~/.docker/cli-plugins
	curl -L https://github.com/docker/buildx/releases/download/v0.3.1/buildx-v0.3.1.linux-amd64 -o ~/.docker/cli-plugins/docker-buildx
	chmod 755 ~/.docker/cli-plugins/docker-buildx
	docker buildx create --name container --use 

go-run:
	go run src/main.go

go-build:
	go build src/main.go -o sample-go-project