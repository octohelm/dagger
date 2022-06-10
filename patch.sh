#!/bin/sh

set -e

curl https://github.com/dagger/dagger/compare/main...morlay:multi-arch.patch | git apply -v
curl https://github.com/dagger/dagger/compare/main...morlay:cuemod.patch | git apply -v

go mod tidy
