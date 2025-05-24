include .env

up:
	docker-compose up --build -d

stop: 
	docker-compose down -v

logs:
	docker-compose logs

