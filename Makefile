.PHONY: all clean fixtures setup test

bin = node_modules/.bin

all: $(shell find src/*.coffee src/**/*.coffee | sed -e 's/^src/lib/' -e 's/coffee$$/js/')

fixtures: test/fixtures/index.html $(shell find test/fixtures/**/* -regex '[^.]*' -exec echo {}.html \;)

lib/gatherer:
	@mkdir -p $@

lib/%.js: src/%.coffee lib/gatherer
	@cat $< | $(bin)/coffee --stdio --print > $@

test/fixtures/%.html: test/fixtures/%
	@curl "$(shell cat $<)" --output $@ --silent

clean:
	@rm -rf node_modules
	@rm -rf test/fixtures
	@git checkout -- lib test/fixtures

setup:
	@npm install

test:
	@$(bin)/mocha --compilers coffee:coffee-script test/tutor.coffee
