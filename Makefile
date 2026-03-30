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

$(IMAGES)/%.svg: $(DIAGRAMS)/%.typ
	@typst compile --format svg "$<" "$@"
	@echo "$@"

site: $(DOCS)/.nojekyll
	@cp "$(DOCS_DIR)style/site.css" "$(DOCS)/style.css"
	@cd "$(PLOTS)" && uv run python index.py
	@echo "$(DOCS)/index.html"

$(DOCS)/.nojekyll: | $(DOCS)
	@touch "$@"

$(BUILD) $(DOCS):
	@mkdir -p "$@"

clean:
	@rm -f $(DOCS)/*.pdf $(BUILD)/*.typ

.PHONY: clean site
