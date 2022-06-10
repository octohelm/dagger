package main

import (
	"strings"

	"dagger.io/dagger"
	"dagger.io/dagger/core"
	"universe.dagger.io/docker"

	"github.com/innoai-tech/runtime/cuepkg/tool"
	"github.com/innoai-tech/runtime/cuepkg/golang"
	"github.com/innoai-tech/runtime/cuepkg/debian"
)

dagger.#Plan & {
	client: {
		env: {
			VERSION: string | *"v0.3.0"
			GIT_SHA: string | *"152749e64aad80297f4bcb29e565426144383f81"
			GIT_REF: string | *""

			GOPROXY:   string | *""
			GOPRIVATE: string | *""
			GOSUMDB:   string | *""

			GH_USERNAME: string | *""
			GH_PASSWORD: dagger.#Secret

			LINUX_MIRROR: string | *""
		}

		filesystem: "build/output": write: contents: actions.export.output
	}

	actions: {
		version: "\(client.env.VERSION)"

		src: core.#Source & {
			path: "./dagger"
		}

		info: golang.#Info & {
			"source": src.output
		}

		build: golang.#Build & {
			source: src.output
			go: {
				os: ["linux", "darwin"]
				arch: ["amd64", "arm64"]
				package: "./cmd/dagger"
				ldflags: [
					"-s -w",
					"-X \(info.module)/version.Version=\(version)-\(strings.SliceRunes(client.env.GIT_SHA, 0, 7))",
					"-X \(info.module)/version.Revision=\(client.env.GIT_SHA)",
				]
			}
			run: env: {
				GOFLAGS:   "-buildvcs=false"
				GOPROXY:   client.env.GOPROXY
				GOPRIVATE: client.env.GOPRIVATE
				GOSUMDB:   client.env.GOSUMDB
			}
			image: mirror: client.env.LINUX_MIRROR
		}

		export: tool.#Export & {
			archive: true
			directories: {
				for _os in build.go.os for _arch in build.go.arch {
					"\(build.go.name)_\(_os)_\(_arch)": build["\(_os)/\(_arch)"].output
				}
			}
		}

		images: {
			for arch in build.go.arch {
				"linux/\(arch)": docker.#Build & {
					steps: [
						debian.#Build & {
							platform: "linux/\(arch)"
							mirror:   client.env.LINUX_MIRROR
							packages: {
								"ca-certificates": _
								"git":             _
							}
						},
						docker.#Copy & {
							contents: build["linux/\(arch)"].output
							source:   "/dagger"
							dest:     "/bin/dagger"
						},
						docker.#Set & {
							config: {
								label: {
									"org.opencontainers.image.source":   "https://github.com/octohelm/dagger"
									"org.opencontainers.image.revision": "\(client.env.GIT_SHA)"
								}
								workdir: "/"
							}
						},
					]
				}
			}
		}

		ship: {
			_push: docker.#Push & {
				dest: "\("ghcr.io/octohelm/dagger"):\(version)"
				"images": {
					for p, image in images {
						"\(p)": image.output
					}
				}
				auth: {
					username: client.env.GH_USERNAME
					secret:   client.env.GH_PASSWORD
				}
			}

			result: _push.result
		}
	}
}
