#!/bin/sh

set -e

_detect_os() {
  os="$(uname)"
  case "$os" in
  Darwin) echo "darwin" ;;
  Linux) echo "linux" ;;
  *)
    echo "Unsupported system: $os" 1>&2
    return 1
    ;;
  esac
  unset arch
}

_detect_arch() {
  arch="$(uname -m)"
  case "$arch" in
  amd64 | x86_64) echo "amd64" ;;
  arm64 | aarch64) echo "arm64" ;;
  armv7l | armv8l | arm) echo "arm" ;;
  *)
    echo "Unsupported processor architecture: $arch" 1>&2
    return 1
    ;;
  esac
  unset arch
}

_download_url() {
  echo "https://github.com/octohelm/dagger/releases/download/latest/dagger_${OS}_${ARCH}.tar.gz"
}

OS="$(_detect_os)"
ARCH="$(_detect_arch)"
DOWNLOAD_URL="$(_download_url)"
INSTALL_PATH=/usr/local/bin

rm -rf /tmp/dagger
mkdir -p /tmp/dagger
echo "Downloading dagger from ${DOWNLOAD_URL}"
wget -c "${DOWNLOAD_URL}" -O - | tar -xz -C "/tmp/dagger"
chmod 755 /tmp/dagger/dagger

mkdir -p -- "${INSTALL_PATH}"
mv -f /tmp/dagger/dagger "${INSTALL_PATH}/dagger"
echo "$(dagger version) is now executable in ${INSTALL_PATH}"
