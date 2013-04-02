.PHONY: all clean fixtures release setup test testcli testcore

bin = node_modules/.bin

all: $(shell find src/*.coffee src/**/*.coffee | sed -e 's/^src/lib/' -e 's/coffee$$/js/')

fixtures: test/fixtures/index.html $(shell find test/fixtures/**/* -regex '[^.]*' -exec echo {}.html \;)

lib/%.js: src/%.coffee
	@mkdir -p $(@D)
	@cat $< | $(bin)/coffee --compile --stdio > $@

test/fixtures/%.html: test/fixtures/%
	@curl "$(shell cat $<)" --output $@ --silent

clean:
	@rm -rf node_modules
	@rm -rf test/fixtures
	@git checkout -- lib test/fixtures

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

test:
	@$(bin)/mocha --compilers coffee:coffee-script test/tutor.coffee --timeout 10000
testcore:
	@$(bin)/mocha --compilers coffee:coffee-script test/tutor.coffee --grep "tutor\.command" --invert
testcli:
	@$(bin)/mocha --compilers coffee:coffee-script test/tutor.coffee --timeout 10000 --grep "tutor\.command"
