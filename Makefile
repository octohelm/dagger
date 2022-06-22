reset:
	git submodule foreach -q --recursive 'git add . && git reset --hard'

dep: reset
	git submodule update --init
	git submodule update --force --remote

patch: dep
	cd dagger && sh ../patch.sh

install: patch
	cd ./dagger && go install -ldflags '-X go.dagger.io/dagger/version.Version=v0.3.0' ./cmd/dagger