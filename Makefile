
IMAGE = highloadcup

run:
	docker-compose up --build

build:
	docker build -t highloadcup .

.PHONY: build clean
