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

### Heavy compiling project, with native buildkit, need to write to filesystem and use `core.#Source` to combine them

```shell
BUILDKIT_HOST=tcp://buildkit-amd64:1234 dagger do build amd64
BUILDKIT_HOST=tcp://buildkit-arm64:1234 dagger do build arm64
dagger do ship
```

```cue
client: filesystem:  {
	"./build/output/amd64": write: contents: actions.build.amd64.output
	"./build/output/arm64": write: contents: actions.build.arm64.output
}

actions: build: {
	amd64:  docker.#Run & {}
	arm64:  docker.#Run & {}
}

actions: ship: {
	_compiled:  {
		for arch in ["amd64", "arm64"] {
            "\(arch)": core.#Source & {
                path: "./build/output/\(arch)"
            },	
		}
	}
	
	_images: {
		for arch in ["amd64", "arm64"] {
				"\(arch)": docker.#Build & {
						steps: [
								docker.#Pull & {
										source: "",
										platform: "linux/\(arch)"
								},
								docker.#Copy & {
										contents: _compiled."\(arch)".output
										dest: "/"
								}
						]
				}	
		}
	}
	
	docker.#Push & {
		dest: "x"
		images: {
				for arch in ["amd64", "arm64"] {
					"linux/\(arch)": _images."\(arch)".output
				}
		}
  }
}
```
