
include .env
export

run:
	docker-compose up -d
	go run cmd/server/main.go

build:
	go build -o login-system cmd/server/main.go

docker-up:
	docker-compose up --build -d

docker-down:
	docker-compose down

test:
	go test ./...