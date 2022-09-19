
COMMIT := $(shell git rev-parse --short HEAD)
BRANCH := $(shell git rev-parse --abbrev-ref HEAD)


.PHONY: test
test:
	dart test ./test

.PHONY: build-test-proto
build-test-proto:
	mkdir -p test/rpc && \
	protoc --proto_path=./test/proto --dart_out=./test/rpc ./test/proto/greet.proto
