dep:
	git submodule foreach -q --recursive 'git add . && git reset --hard'
	git submodule update --init
	git submodule update --force --remote

patch: dep
	cd dagger && sh ../patch.sh

install:
	cd ./dagger && go install -ldflags '-X go.dagger.io/dagger/version.Version=v0.3.0' ./cmd/dagger

do:
	dagger do export
	dagger do ship

debug:
	tar -tf ./build/output/dagger_darwin_arm64.tar.gz
