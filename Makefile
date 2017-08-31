
IMAGE = highloadcupru_web

run:
	docker-compose up --build

fire: build
	docker run --rm -it \
		--net host \
		--name highloadcupru_web_1 \
		-v /home/kron/Documents/projects/highloadcup.ru/data:/tmp/data:ro \
		-v /home/kron/Documents/projects/hlcupdocs/data/TRAIN/data:/tmp/data_unpack:ro \
		-v /home/kron/Documents/projects/highloadcup.ru/root/opt:/tmp/opt \
		$(IMAGE)

build:
	docker build -t $(IMAGE) .

push:
	docker tag $(IMAGE) stor.highloadcup.ru/travels/various_dodo
	docker push stor.highloadcup.ru/travels/various_dodo

.PHONY: build clean
