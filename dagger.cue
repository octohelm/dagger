package main

import (
	"strings"

	"dagger.io/dagger"

	"github.com/innoai-tech/runtime/cuepkg/golang"
	"github.com/innoai-tech/runtime/cuepkg/debian"
)

dagger.#Plan

client: env: {
	VERSION: string | *"v0.3.0"
	GIT_SHA: string | *"152749e64aad80297f4bcb29e565426144383f81"
	GIT_REF: string | *""

	GOPROXY:   string | *""
	GOPRIVATE: string | *""
	GOSUMDB:   string | *""

	GH_USERNAME: string | *""
	GH_PASSWORD: dagger.#Secret

	LINUX_MIRROR:                  string | *""
	CONTAINER_REGISTRY_PULL_PROXY: string | *""
}

client: filesystem: "build/output": write: contents: actions.go.archive.output

actions: go: golang.#Project & {
	mirror: {
		linux: client.env.LINUX_MIRROR
		pull:  client.env.CONTAINER_REGISTRY_PULL_PROXY
	}

	auths: "ghcr.io": {
		username: client.env.GH_USERNAME
		secret:   client.env.GH_PASSWORD
	}

	source: {
		path: "./dagger"
	}

	version:  "\(client.env.VERSION)"
	revision: "\(client.env.GIT_SHA)"

	goos: ["linux", "darwin"]
	goarch: ["amd64", "arm64"]
	main: "./cmd/dagger"
	ldflags: [
		"-s -w",
		"-X \(go.module)/version.Version=\(go.version)-\(strings.SliceRunes(go.revision, 0, 7))",
		"-X \(go.module)/version.Revision=\(go.revision)",
	]

	env: {
		GOFLAGS:   "-buildvcs=false"
		GOPROXY:   client.env.GOPROXY
		GOPRIVATE: client.env.GOPRIVATE
		GOSUMDB:   client.env.GOSUMDB
	}

	build: {
		image: "mirror": mirror
	}

	ship: {
		name: "ghcr.io/octohelm/dagger"
		tag:  version

		from: "docker.io/library/debian:bullseye-slim"
		steps: [
			debian.#InstallPackage & {
				packages: {
					"ca-certificates": _
					"git":             _
				}
			},
		]
	}
}
