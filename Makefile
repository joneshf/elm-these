.SUFFIXES:
Makefile:;

NODE_MODULES := node_modules
ELM_MANIFESTS := elm.json
ELM_SOURCES := src/Dict/Simple.elm src/These.elm
ELM_STUFF := elm-stuff
NPM_MANIFESTS := package.json package-lock.json

NPM_BIN := $(NODE_MODULES)/.bin
ELM := $(NPM_BIN)/elm

.DEFAULT_GOAL := build

$(NPM_BIN)/%: $(NPM_MANIFESTS)
	npm install
	touch $@

.PHONY: build
build: $(ELM) $(ELM_MANIFESTS) $(ELM_SOURCES)
	$(ELM) make --output /dev/null

.PHONY: bump
bump: $(ELM)
	$(ELM) bump

.PHONY: clean
clean:
	rm -fr \
	  $(ELM_STUFF) \
	  $(NODE_MODULES)

.PHONY: diff
diff: $(ELM)
	$(ELM) diff

.PHONY: publish
publish: $(ELM)
	$(ELM) publish
