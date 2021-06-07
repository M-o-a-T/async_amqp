.PHONY: doc test update pypi upload test update reports jenkins-test livehtml tag

# need to use python3 sphinx-build
PATH := /usr/share/sphinx/scripts/python3:${PATH}

PACKAGE = async_amqp
PYTHON ?= python3

PYTEST ?= env PYTHONPATH=. ${PYTHON} $(shell which pytest-3)
TEST_OPTIONS ?= -xv --cov=async_amqp # -vv --full-trace
PYLINT_RC ?= .pylintrc

BUILD_DIR ?= build
INPUT_DIR ?= docs

# Sphinx options (are passed to build_docs, which passes them to sphinx-build)
#   -W       : turn warning into errors
#   -a       : write all files
#   -b html  : use html builder
#   -i [pat] : ignore pattern

SPHINXOPTS ?= -a -W -b html
AUTOSPHINXOPTS := -i *~ -i *.sw* -i Makefile*

SPHINXBUILDDIR ?= $(BUILD_DIR)/sphinx/html
ALLSPHINXOPTS ?= -d $(BUILD_DIR)/sphinx/doctrees $(SPHINXOPTS) docs

doc:
	sphinx3-build -a $(INPUT_DIR) build

livehtml: docs
	sphinx3-autobuild $(AUTOSPHINXOPTS) $(ALLSPHINXOPTS) $(SPHINXBUILDDIR)

test:
	$(PYTEST) $(TEST_OPTIONS) tests


pylint:
	pylint aioamqp


### semi-private targets used by polyconseil's CI (copy-pasted from blease) ###

.PHONY: reports jenkins-test jenkins-quality

reports:
	mkdir -p reports

jenkins-test: reports
	$(MAKE) test TEST_OPTIONS="--cov=$(PACKAGE) \
		--cov-report xml:reports/xmlcov.xml \
		--junitxml=reports/TEST-$(PACKAGE).xml \
		-v \
		$(TEST_OPTIONS)"

jenkins-quality: reports
	pylint --rcfile=$(PYLINT_RC) $(PACKAGE) > reports/pylint.report || true

update:
	pip install -r ci/test-requirements.txt

tagged: 
	git describe --tags --exact-match
	test $$(git ls-files -m | wc -l) = 0

pypi:   tagged
	#python3 setup.py sdist upload
	python3 setup.py sdist
	twine upload dist/async_amqp-$(shell git describe --tags --exact-match).tar.gz

upload: pypi
	git push --tags

.PHONY: all tagged pypi upload test check doc

