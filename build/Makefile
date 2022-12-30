# set the IMAGE_NAME variable
# It should consist of repo name, image name and version
# use hyphens as separator
IMAGE_NAME = gcr.io/ticker-beats/docker-mt5
# set the IMAGE_VERSION variable
# It should consist of the version of the image
# use hyphens as separator
IMAGE_VERSION = 1
# set the IMAGE_TAG variable
# It should consist of the IMAGE_NAME and IMAGE_VERSION
# use colon as separator
IMAGE_TAG = $(IMAGE_NAME):$(IMAGE_VERSION)
# set the IMAGE_LATEST variable
# It should consist of the IMAGE_NAME and latest
# use colon as separator
IMAGE_LATEST = $(IMAGE_NAME):latest

.PHONY: build
build: ## builds the project using docker build
	docker build --no-cache -t $(IMAGE_TAG) .
	docker tag $(IMAGE_TAG) $(IMAGE_LATEST)
	# docker push $(IMAGE_TAG)
	# docker push $(IMAGE_LATEST)

.PHONY: start
start:
	docker-compose up -d

.PHONY: stop
stop:
	docker-compose down

.PHONY: restart
restart:
	docker stop docker-mt5_mt5_1
	./clone-mt5-docker-from-ocean.sh
	docker start docker-mt5_mt5_1

.PHONY: rebuild
rebuild: stop start restart