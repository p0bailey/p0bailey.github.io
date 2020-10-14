#Authored by Phillip Bailey
.PHONY: all
.SILENT:
SHELL := /bin/bash

TIMESTAMP=`date +'%y.%m.%d %H:%M:%S'`

all:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST)  | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

run: ## Run blog locally
	bundle install && bundle exec jekyll serve --livereload 

deploy_to_gh: ## deploy to github
	git add -A && git commit -m "Blog update: $(TIMESTAMP)" && git push origin master || true
