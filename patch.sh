#!/bin/sh

set -e

curl https://github.com/dagger/dagger/compare/main...morlay:handle-cue-panic.patch | git apply -v
curl https://github.com/dagger/dagger/compare/main...morlay:list-all-nested-action.patch | git apply -v
curl https://github.com/dagger/dagger/compare/main...morlay:buildkit-auto-switch.patch | git apply -v
curl https://github.com/dagger/dagger/compare/main...morlay:multi-arch.patch | git apply -v
curl https://github.com/dagger/dagger/compare/main...morlay:cuemod.patch | git apply -v

go mod tidy
