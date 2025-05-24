include .env

up:
	docker-compose --project-name ${PROJECT_NAME} up 

stop:
	docker-compose down -v