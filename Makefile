.PHONY: test build package install

test:
	bash tests/test-launcher.sh

build:
	bash scripts/build-app.sh

package:
	bash scripts/package.sh

install:
	bash scripts/install.sh
