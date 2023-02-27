# set the MQL5_IMAGE_NAME variable
# It should consist of repo name, image name and version
# use hyphens as separator
MQL5_IMAGE_NAME = gcr.io/ticker-beats/docker-mt5
# set the MQL5_IMAGE_VERSION variable
# It should consist of the version of the image
# use hyphens as separator
MQL5_IMAGE_VERSION = 2
# set the MQL5_IMAGE_TAG variable
# It should consist of the MQL5_IMAGE_NAME and MQL5_IMAGE_VERSION
# use colon as separator
MQL5_IMAGE_TAG = $(MQL5_IMAGE_NAME):$(MQL5_IMAGE_VERSION)
# set the MQL5_IMAGE_LATEST variable
# It should consist of the MQL5_IMAGE_NAME and latest
# use colon as separator
MQL5_IMAGE_LATEST = $(MQL5_IMAGE_NAME):latest

.PHONY: mql5-build
mql5-build: ## builds the project using docker build
	docker build --no-cache -t $(MQL5_IMAGE_TAG) .
	docker tag $(MQL5_IMAGE_TAG) $(MQL5_IMAGE_LATEST)
	# docker push $(MQL5_IMAGE_TAG)
	# docker push $(MQL5_IMAGE_LATEST)

.PHONY: mql5-start
mql5-start:
	docker-compose up -d

.PHONY: mql5-stop
mql5-stop:
	docker-compose down

.PHONY: mql5-deploy
mql5-deploy: 
	docker-compose down
	./clone-mt5-docker-from-ocean.sh
	docker-compose up -d