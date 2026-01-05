PYTHON ?= python
DIR := ${CURDIR}
PY_PATH=$(DIR)
export PYTHONPATH=$(PY_PATH)
RUN_PY = $(PYTHON) -m
# Black is configured in pyproject.toml
BLACK_CMD = $(RUN_PY) black .
# NOTE: exclude any virtual environment subdirectories here
PY_FIND_COMMAND = find -name '*.py' \
	! -path './.git/*' \
	! -path './venv/*' \
	! -path './venv-dev/*' \
	! -path './.venv/*' \
	! -path './__pycache__/*' \
	! -path './*/__pycache__/*'
MYPY_CONFIG=$(PY_PATH)/mypy_config.ini

install:
	pip3 install -r requirements.txt

init_dev:
	$(RUN_PY) venv venv-dev
	./venv-dev/bin/python -m pip install --upgrade pip setuptools wheel

install_dev:
	./venv-dev/bin/python -m pip install -r requirements.txt

run_isort:
	isort $(shell $(PY_FIND_COMMAND))

run_black:
	$(BLACK_CMD)

format: run_isort run_black
	echo "Formatting..."

check_format:
	$(BLACK_CMD) --check --diff

run_mypy:
	$(RUN_PY) mypy $(shell $(PY_FIND_COMMAND)) --config-file $(MYPY_CONFIG) --no-namespace-packages

run_pylint:
	$(RUN_PY) pylint $(shell $(PY_FIND_COMMAND))

autopep8:
	autopep8 --in-place --aggressive --aggressive $(shell $(PY_FIND_COMMAND))

lint: check_format run_mypy run_pylint
	echo "Linting..."

lint_full: lint

test:
	$(RUN_PY) unittest discover -s test/ -p 'test_*.py' -v

server:
	$(RUN_PY) app --port 8080 --host localhost

.PHONY: install init_dev install_dev run_black run_isort format check_format run_mypy run_pylint lint lint_full test server
