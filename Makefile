default: build
all: build

ICED=node_modules/.bin/iced
BUILD_STAMP=build-stamp
TEST_STAMP=test-stamp

default: build
all: build

lib/%.js: src/%.iced
	$(ICED) -I browserify -c -o `dirname $@` $<

$(BUILD_STAMP): \
	lib/base.js \
	lib/config.js \
	lib/constants.js \
	lib/getopt.js \
	lib/installer.js \
	lib/keyset.js \
	lib/keyset_setup.js \
	lib/keyset_install.js \
	lib/log.js \
	lib/main.js \
	lib/npm.js \
	lib/package.js \
	lib/request.js
	date > $@

clean:
	find lib -type f -name *.js -exec rm {} \;

build: $(BUILD_STAMP) 

setup: 
	npm install -d

test:

.PHONY: test setup
