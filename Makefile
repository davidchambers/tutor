ESLINT = node_modules/.bin/eslint --config node_modules/sanctuary-style/eslint-es6.json --env node --report-unused-disable-directives
MOCHA = node_modules/.bin/mocha --reporter spec
XYZ = node_modules/.bin/xyz --message X.Y.Z --tag X.Y.Z --repo git@github.com:davidchambers/tutor.git

LIB = $(shell find lib -name '*.js')
TEST = $(shell find test -name '*.js')
FIXTURES = $(patsubst %,%.html,$(shell find test/fixtures -type f -not -name '*.html'))


.PHONY: all
all:


.PHONY: fixtures
fixtures: $(FIXTURES)

test/fixtures/%.html: test/fixtures/%
	xargs curl --location --silent -- <$< >$@


.PHONY: clean
clean:
	@rm -f -- $(FIXTURES)


.PHONY: lint
lint:
	# $(ESLINT) \
	#   --rule 'max-len: [error, {code: 79, ignoreStrings: true, ignoreUrls: true}]' \
	#   --rule 'object-shorthand: [error, always]' \
	#   -- $(LIB)
	$(ESLINT) \
	  --global describe \
	  --global it \
	  --rule 'max-len: [error, {code: 79, ignoreStrings: true, ignoreUrls: true}]' \
	  --rule 'object-shorthand: [error, always]' \
	  -- $(TEST)


.PHONY: release-major release-minor release-patch
release-major release-minor release-patch:
	@$(XYZ) --increment $(@:release-%=%)


.PHONY: setup
setup:
	npm install


.PHONY: test
test: all
	$(MOCHA) --grep '^\$$' --invert --timeout 15000


.PHONY: testcli
testcli: all
	$(MOCHA) --grep '^\$$' --timeout 30000
