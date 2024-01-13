
##  Таким образом мы подключаем переменные  ##
include .env
##  Первая цель. Запускается по-умолчанию при вызове make без параметров.  ##
##  Запускаем сервис в релизном варианте.  ##
start: startRelease

##  Запуск контейнеров в режиме отладки  ##
startDebug:
			docker compose \
			-f docker-compose.yml \
#			-f docker-compose.debug.yml \
			up \
			-d --force-recreate

##  Запуск контейнеров в режиме релиз  ##
startRelease:
			docker compose \
			-f docker-compose.yml \
			up \
			-d --force-recreate

##  Остановка контейнеров  ##
down:
			docker compose \
			-f docker-compose.yml \
#			-f docker-compose.debug.yml \
			down  \
			--remove-orphans


##  Остановка и очистка контейнеров  ##
.PHONY: clean
clean:
			docker compose \
			-f docker-compose.yml \
#			-f docker-compose.debug.yml \
			down  \
			--remove-orphans \
			-v

##  Остановка и очистка контейнеров, а так же удаление всех данных с диска  ##
.PHONY: cleanAll
cleanAll: clean
			rm -rf *.d .env

install: .env directories

##  При отсутствии файла с переменными среды будет создан файл со значениями по умолчанию  ##
.env:
	cp .env.example .env


##  При отсутствии, создаем директории для проекта  ##
directories: config.d logs.d data.d crypto.d

config.d:
	mkdir "config.d"
logs.d:
	mkdir "logs.d"
data.d:
	mkdir "data.d"
crypto.d:
	mkdir "crypto.d"

##  Создаем DH группу  ##
_install_crypto: crypto.d/dh4016.pem

crypto.d/dh4016.pem:
	openssl dhparam -out $(GIT_DHPARAM) 512 &>/dev/null