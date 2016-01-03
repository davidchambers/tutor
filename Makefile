COFFEE = node_modules/.bin/coffee
MOCHA = node_modules/.bin/mocha --compilers coffee:coffee-script/register
XYZ = node_modules/.bin/xyz --message X.Y.Z --tag X.Y.Z --repo git@github.com:davidchambers/tutor.git --script scripts/prepublish

SRC = $(shell find src -name '*.coffee')
LIB = $(patsubst src/%.coffee,lib/%.js,$(SRC))
FIXTURES = $(patsubst %,%.html,$(shell find test/fixtures -type f -not -name '*.html'))


.PHONY: all
all: $(LIB)

lib/%.js: src/%.coffee
	$(COFFEE) --compile --output $(@D) -- $<


.PHONY: fixtures
fixtures: $(FIXTURES)

test/fixtures/%.html: test/fixtures/%
	xargs curl --location --silent -- <$< >$@


.PHONY: clean
clean:
	@rm -f -- $(LIB)
	@rm -f -- $(FIXTURES)


.PHONY: release-major release-minor release-patch
release-major release-minor release-patch:
	@$(XYZ) --increment $(@:release-%=%)


.PHONY: setup
setup:
	npm install
	make clean
	git update-index --assume-unchanged -- $(LIB)


.PHONY: test
test: all
	$(MOCHA) --grep '^\$$' --invert --timeout 5000


.PHONY: testcli
testcli: all
	$(MOCHA) --grep '^\$$' --timeout 10000
