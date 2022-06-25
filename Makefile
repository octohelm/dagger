reset:
	git submodule foreach -q --recursive 'git add . && git reset --hard'

dep: reset
	git submodule update --init
	git submodule update --force --remote

apply-patch.%:
	cd ./dagger && (curl https://github.com/dagger/dagger/compare/main...morlay:$*.patch | git apply -v)

patch: dep
	$(MAKE) apply-patch.enhance-copy-info
	$(MAKE) apply-patch.handle-cue-panic
	$(MAKE) apply-patch.list-all-nested-action
	$(MAKE) apply-patch.buildkit-auto-switch
	$(MAKE) apply-patch.multi-arch
	$(MAKE) apply-patch.cuemod
	cd dagger && go mod tidy

install: patch
	cd ./dagger && go install -ldflags '-X go.dagger.io/dagger/version.Version=v0.3.0' ./cmd/dagger