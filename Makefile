PROJECT_NAME := "infra"

help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

setup: ## setup required things
	python3 -m pip install -U -r requirements.txt
	python3 -m pip install -U -r requirements-dev.txt
	pre-commit install
	pre-commit install-hooks

puml-svg: ## render plantuml diagrams as svg
	cd docs/
	find . -name "*.puml" -exec plantuml -tsvg {} \;

puml-png: ## render plantuml diagrams as png
	cd docs/
	find . -name "*.puml" -exec plantuml -tsvg {} \;

pre-commit-all: ## run pre-commit on all files
	pre-commit run --all-files

pre-commit: ## run pre-commit
	pre-commit run
