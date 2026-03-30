DOCS_DIR := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))
DOCS     := $(DOCS_DIR)docs
BUILD    := $(DOCS_DIR).cache/typst-build
IMAGES   := $(DOCS_DIR)images
DIAGRAMS := $(DOCS_DIR)diagrams
PLOTS    := $(DOCS_DIR)plots
TEMPLATE := $(DOCS_DIR)style/ajd.typ
FILTER   := $(DOCS_DIR)ajd.lua

export MPLCONFIGDIR              := $(DOCS_DIR).cache/matplotlib
export TYPST_PACKAGE_CACHE_PATH  := $(DOCS_DIR).cache/typst
export FONTCONFIG_CACHE          := $(DOCS_DIR).cache/fontconfig

%.pdf: %.org $(TEMPLATE) $(FILTER) | $(BUILD) $(DOCS)
	@pandoc "$<" -t typst \
	  --metadata template=/style/ajd.typ \
	  --lua-filter="$(FILTER)" \
	  -s -o "$(BUILD)/$(notdir $*).typ"
	@typst compile --root "$(DOCS_DIR)" "$(BUILD)/$(notdir $*).typ" "$(DOCS)/$(notdir $*).pdf"
	@echo "$(DOCS)/$(notdir $*).pdf"

%.html: %.org $(FILTER) $(DOCS_DIR)style/document.css | $(DOCS)
	@cp "$(DOCS_DIR)style/document.css" "$(DOCS)/document.css"
	@pandoc "$<" -t html \
	  --lua-filter="$(FILTER)" \
	  --css=document.css \
	  --syntax-highlighting=monochrome \
	  -s -o "$(DOCS)/$(notdir $*).html"
	@echo "$(DOCS)/$(notdir $*).html"

$(IMAGES)/%.svg: $(DIAGRAMS)/%.typ
	@typst compile --format svg "$<" "$@"
	@echo "$@"

ORGS := $(wildcard $(DOCS_DIR)*.org)
HTMLS := $(ORGS:$(DOCS_DIR)%.org=%.html)
PDFS  := $(ORGS:$(DOCS_DIR)%.org=%.pdf)

site: $(HTMLS) $(PDFS) $(DOCS)/.nojekyll

$(DOCS)/.nojekyll: | $(DOCS)
	@touch "$@"

$(BUILD) $(DOCS):
	@mkdir -p "$@"

clean:
	@rm -f $(DOCS)/*.pdf $(DOCS)/*.html $(BUILD)/*.typ

.PHONY: clean site
