# Dagger

Custom dagger with custom features

* cue mod
* much-arch supports

## Install

```shell
curl -sSLf https://raw.githubusercontent.com/octohelm/dagger/main/install.sh | sudo sh
```

## Extra Commander

```shell
# should run init project before all 
dagger project init --name <full_mod_path>
# or
cue mod init <full_mod_path>

# download deps
dagger get ./...

# updates deps
dagger get -u ./...

# install dep with special version or git ref
dagger get github.com/innoai-tech/runtime@main
```

## Multi arch builds

### Simple flow, with qemu, could just use `images`

```cue
actions: ship: docker.#Push & {
	images: [Platform=string]:  docker.#Image 
}
```

### Heavy compiling project, with native buildkit, we could split to use different native buildkits, and combine them.

```shell
BUILDKIT_HOST=tcp://buildkit-amd64:1234 dagger do ship push amd64
BUILDKIT_HOST=tcp://buildkit-arm64:1234 dagger do ship push arm64
dagger do ship push x
```
