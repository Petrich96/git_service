
##  Таким образом мы подключаем переменные  ##
include .env

##  Первая цель. Запускается по-умолчанию при вызове make без параметров.  ##
##  Запускаем сервис в релизном варианте.  ##
start: startRelease


##  Мини-установка: создание рабочих директорий, подготовка конфигов ##
directories = config.d logs.d data.d crypto.d

.PHONY: install
install: $(directories) _install_crypto _install_gitlab_config


##  Запуск контейнеров в режиме отладки  ##
startDebug: install
			docker compose \
			-f docker-compose.yml \
			up \
			-d --force-recreate


##  Запуск контейнеров в режиме релиз  ##
startRelease: install
			docker compose \
			-f docker-compose.yml \
			up \
			-d --force-recreate


##  Остановка контейнеров  ##
down:
			docker compose \
			-f docker-compose.yml \
			down  \
			--remove-orphans


##  Остановка и очистка контейнеров  ##
.PHONY: clean
clean:
			docker compose \
			-f docker-compose.yml \
			down  \
			--remove-orphans \
			-v


##  Остановка и очистка контейнеров, а так же удаление всех данных с диска  ##
.PHONY: cleanAll
cleanAll: clean
			rm -rf *.d .env


##  При отсутствии файла с переменными среды будет создан файл со значениями по умолчанию  ##
.env:
			cp .env.example .env


##  Создание директорий  ##
$(directories): %.d:
			mkdir -p "$@"
			chmod -R 700 "$@"


## Копирование конфига GitLab в целевую директорию  ##
_install_gitlab_config: $(GIT_CONFIGRB)

$(GIT_CONFIGRB):
			cp gitlab.rb $(GIT_CONFIGRB)

##  Создаем DH группу  ##
_install_crypto: $(GIT_DHPARAM)

$(GIT_DHPARAM):
			openssl dhparam -out $(GIT_DHPARAM) 4096 &>/dev/null
