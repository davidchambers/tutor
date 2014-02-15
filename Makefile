.PHONY: all clean fixtures release setup test testcli

bin = node_modules/.bin

JS_FILES = $(patsubst src/%.coffee,lib/%.js,$(shell find src -type f))
FIXTURES = $(patsubst %,%.html,$(shell find test/fixtures -type f -not -name '*.html'))

all: $(JS_FILES)

fixtures: $(FIXTURES)

lib/%.js: src/%.coffee
	@mkdir -p $(@D)
	@cat $< | $(bin)/coffee --compile --stdio > $@

test/fixtures/%.html: test/fixtures/%
	@curl "$(shell cat $<)" --output $@ --silent

clean:
	@rm -rf node_modules
	@rm -f $(JS_FILES)
	@rm -f $(FIXTURES)

release:
ifndef VERSION
	$(error VERSION not set)
endif
	@rm -rf lib
	@make
	@sed -i '' 's/"version": "[^"]*"/"version": "$(VERSION)"/' package.json
	@git commit --all --message $(VERSION)
	@git tag $(VERSION)
	@echo 'remember to run `npm publish`'

setup:
	@npm install

test: all
	@$(bin)/mocha --compilers coffee:coffee-script/register --grep '^\$$' --invert --timeout 5000

testcli: all
	@$(bin)/mocha --compilers coffee:coffee-script/register --grep '^\$$' --timeout 10000
