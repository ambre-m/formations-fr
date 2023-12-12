SHELL = /bin/sh

version := $(shell git describe --all --long)
date := $(shell date --rfc-3339=date)
head_hash := $(shell git rev-parse --short HEAD)

params = -a revnumber=$(head_hash) -a revdate=$(date)

docs = README.asc consultante_au_forfait.asc

contributors = contributors.txt

dir_html := html
htmls := $(patsubst %.asc,$(dir_html)/%.html,$(docs))

dir_pdf := pdf
pdfs := $(patsubst %.asc,$(dir_pdf)/%.pdf,$(docs))

all: html pdf

.SUFFIXES:
.DELETE_ON_ERROR:
.PHONY: $(contributors) clean

$(contributors):
	@echo 'Generating contributors list'
	@echo "Contributors as of" $(head_hash) ":" > $(contributors)
	@git shortlog -s HEAD | grep -v -E '(Straub|Chacon|dependabot)' | cut -f 2- | sort | column -c 120 >> $(contributors)

clean:
	-rm $(contributors)

# rules for html

.PHONY: .make_dir_html html
.make_dir_html:
	@mkdir -p $(dir_html)

html: .make_dir_html $(htmls)

$(dir_html)/%.html: %.asc .make_dir_html $(contributors)
	@echo 'Converting to HTML...'
	asciidoctor -D $(dir_html) $(params) -a data-uri $<
	@echo "produced $@"

# rules for pdf

.PHONY: .make_dir_pdf pdf
.make_dir_pdf:
	@mkdir -p $(dir_pdf)

pdf: .make_dir_pdf $(pdfs)

$(dir_pdf)/%.pdf: %.asc .make_dir_pdf $(contributors)
	@echo 'Converting to PDF...'
	asciidoctor-pdf -D $(dir_pdf) $(params) $<
	@echo "produced $@"
