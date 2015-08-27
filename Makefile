
install:
	@curl -O https://raw.githubusercontent.com/lehmannro/assert.sh/v1.1/assert.sh

test:
	@find . -name "test.sh" | xargs bash

.PHONY: install test
