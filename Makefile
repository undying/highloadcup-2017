
IMAGE = highloadcup

run:
	docker-compose up --build

build:
	docker build -t $(IMAGE) .

push:
	docker tag $(IMAGE) stor.highloadcup.ru/travels/various_dodo
	docker push stor.highloadcup.ru/travels/various_dodo

.PHONY: build clean
