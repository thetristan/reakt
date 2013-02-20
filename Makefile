COFFEE = $(shell find "src" -name "*.coffee")
JS = $(COFFEE:src%.coffee=lib%.js)

all: $(JS)

lib/%.js : src/%.coffee
	./node_modules/.bin/coffee --compile --lint --output lib $<

.PHONY: test

test : $(JS)
	./node_modules/.bin/mocha --recursive lib
