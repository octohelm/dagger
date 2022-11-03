reset:
	git submodule foreach -q --recursive 'git add . && git reset --hard'

dep: reset
	git submodule update --init
	git submodule update --force --remote
	git submodule foreach -q --recursive 'branch="$$(git config -f $$toplevel/.gitmodules submodule.$$name.branch)"; git switch $$branch'

apply-patch.%:
	cd ./dagger && (curl https://github.com/dagger/dagger/compare/cue-sdk...morlay:$*.patch | git apply -v)

patch: dep
	$(MAKE) apply-patch.cue-sdk-copy-info
	$(MAKE) apply-patch.cue-sdk-handle-cue-panic
	$(MAKE) apply-patch.cue-sdk-list-all-nested-action
	$(MAKE) apply-patch.cue-sdk-buildkit-auto-switch
	$(MAKE) apply-patch.cue-sdk-multi-arch
	$(MAKE) apply-patch.cue-sdk-cuemod
	cd dagger && go mod tidy

install: patch
	cd ./dagger && go install -ldflags '-X go.dagger.io/dagger/version.Version=v0.3.0' ./cmd/dagger