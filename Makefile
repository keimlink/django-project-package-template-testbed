.DEFAULT_GOAL := help

TEMPLATE ?= https://github.com/keimlink/django-project-package-template/archive/master.zip
TESTBED := testbed
VENV := .venv

.PHONY: help
help:
	@grep -E '^[\.a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

$(VENV):
	python3 -m venv $(VENV)
	$(VENV)/bin/python3 -m pip install --upgrade pip setuptools
	$(VENV)/bin/python3 -m pip install --requirement requirements.txt --upgrade

$(TESTBED):
	mkdir $(TESTBED)

.PHONY: clean
clean: ## Clean testbed
	rm -fr $(VENV) $(TESTBED)

$(TESTBED)/src: | $(VENV) $(TESTBED)
	$(VENV)/bin/python3 -m django startproject --extension=cfg,gitignore,gitkeep,in,md,sublime-project \
		--template=$(TEMPLATE) $(shell ./bin/project.py) $(TESTBED)
	./bin/testbed.sh setup

.PHONY: migrate
migrate: | $(TESTBED)/src ## Run database migrations (for development)
	./bin/testbed.sh migrate

.PHONY: createsuperuser
createsuperuser: | $(TESTBED)/src ## Create superuser (for development)
	./bin/testbed.sh createsuperuser

.PHONY: runserver
runserver: | $(TESTBED)/src ## Start runserver
	./bin/testbed.sh runserver

$(TESTBED)/.git: | $(TESTBED)/src
	./bin/testbed.sh git-init

$(TESTBED)/dist: | $(TESTBED)/.git
	./bin/testbed.sh wheel

.PHONY: wheel
wheel: | $(TESTBED)/dist ## Build wheel of project (for deployment)

$(TESTBED)/.deploy: | wheel
	./bin/testbed.sh deploy

$(TESTBED)/staticfiles: | $(TESTBED)/.deploy
	./bin/testbed.sh collectstatic

.PHONY: server
server: | $(TESTBED)/staticfiles ## Start WSGI server
	./bin/testbed.sh server
