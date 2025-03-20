
include .env
export

run:
	docker-compose up -d
	go run main.go

build:
	go build -o login-system main.go

docker-up:
	docker-compose up --build -d

docker-down:
	docker-compose down

test:
	go test ./...

