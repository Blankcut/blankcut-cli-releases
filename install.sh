#!/usr/bin/env bash
#
# install.sh -- one-line installer for the blankcut CLI.
#
# Public install (once releases are published):
#   curl -fsSL https://raw.githubusercontent.com/Blankcut/blankcut-cli-releases/main/install.sh | bash
#
# Org members, from the private repo:
#   gh api -H "Accept: application/vnd.github.raw" \
#     /repos/Blankcut/blankcut-cli/contents/cli/install.sh | bash
#
# Where the binary comes from (BLANKCUT_SOURCE):
#   auto     (default) the public releases repo if it has a release, else the
#            private repo through `gh` -- so this behaves exactly as before
#            until the first public release exists.
#   public   only the public releases repo, plain curl, no GitHub login.
#   private  only the private repo through an authenticated `gh`.
#
# Either way the archive is checked against the release's checksums.txt, and
# when `cosign` is installed and the release carries a signature, checksums.txt
# is itself verified against the release workflow's identity first.
#
# Requirements: curl (public) or an authenticated `gh` (private); tar
# (Darwin/Linux) or unzip (Windows); shasum or sha256sum.
#
# Overrides:
#   BLANKCUT_VERSION=v0.18.1 bash install.sh        # pin a version
#   BLANKCUT_INSTALL_DIR=~/bin bash install.sh      # custom destination
#   BLANKCUT_SOURCE=private bash install.sh         # force the private path

set -euo pipefail

REPO="${BLANKCUT_REPO:-Blankcut/blankcut-cli}"
PUBLIC_REPO="${BLANKCUT_PUBLIC_REPO:-Blankcut/blankcut-cli-releases}"
SOURCE="${BLANKCUT_SOURCE:-auto}"
VERSION="${BLANKCUT_VERSION:-latest}"
INSTALL_DIR="${BLANKCUT_INSTALL_DIR:-/usr/local/bin}"

err() { echo "install.sh: $*" >&2; exit 1; }

# --- Choose a source -------------------------------------------------------

# public_latest prints the newest tag in the public releases repo, or nothing.
# GitHub redirects /releases/latest to /releases/tag/<tag>; with no releases it
# 404s, which is what keeps `auto` on the private path until publishing starts.
public_latest() {
  command -v curl >/dev/null 2>&1 || return 0
  local url
  url=$(curl -fsSLI -o /dev/null -w '%{url_effective}' "https://github.com/${PUBLIC_REPO}/releases/latest" 2>/dev/null) || return 0
  case "$url" in
    */releases/tag/v*) echo "${url##*/}" ;;
  esac
}

require_gh() {
  command -v gh >/dev/null 2>&1 \
    || err "gh CLI not found. Install: https://cli.github.com/ (the private install path downloads through an authenticated gh)."
  gh auth status >/dev/null 2>&1 || err "gh is not authenticated. Run 'gh auth login' first."
}

case "$SOURCE" in
  public)
    command -v curl >/dev/null 2>&1 || err "curl is required for the public install path"
    ;;
  private)
    require_gh
    ;;
  auto)
    if [[ -n "$(public_latest)" ]]; then SOURCE=public; else SOURCE=private; require_gh; fi
    ;;
  *) err "BLANKCUT_SOURCE must be auto, public or private" ;;
esac
echo "==> Source: $SOURCE"

# --- Detect platform -------------------------------------------------------

uname_s=$(uname -s)
uname_m=$(uname -m)

case "$uname_s" in
  Darwin)  os="Darwin"  ext="tar.gz"  ;;
  Linux)   os="Linux"   ext="tar.gz"  ;;
  MINGW*|MSYS*|CYGWIN*) os="Windows" ext="zip" ;;
  *) err "unsupported OS: $uname_s" ;;
esac

case "$uname_m" in
  x86_64|amd64)  arch="amd64" ;;
  arm64|aarch64) arch="arm64" ;;
  *) err "unsupported arch: $uname_m" ;;
esac

# GoReleaser doesn't publish windows/arm64; the .goreleaser.yaml `ignore`
# block enforces that. Surface a useful error instead of a 404 download.
if [[ "$os" == "Windows" && "$arch" == "arm64" ]]; then
  err "no windows/arm64 build published; use WSL or x64 emulation"
fi

asset="blankcut_${os}_${arch}.${ext}"
echo "==> Detected platform: $os/$arch (asset: $asset)"

# --- Resolve version -------------------------------------------------------

if [[ "$VERSION" == "latest" ]]; then
  if [[ "$SOURCE" == "public" ]]; then
    VERSION=$(public_latest)
    [[ -z "$VERSION" ]] && err "no public releases found in $PUBLIC_REPO yet"
  else
    # gh release view --json tagName --jq .tagName -- but `latest` only
    # works if a release is marked as latest. Use `release list` for
    # robustness.
    VERSION=$(gh release list --repo "$REPO" --limit 1 --json tagName --jq '.[0].tagName' 2>/dev/null || true)
    [[ -z "$VERSION" ]] && err "no releases found for $REPO"
  fi
fi
# The version becomes part of a URL and a path; accept only a release tag.
[[ "$VERSION" =~ ^v[0-9]+\.[0-9]+\.[0-9]+$ ]] || err "not a release tag: $VERSION"
echo "==> Installing version: $VERSION"

# --- Download + verify -----------------------------------------------------

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

echo "==> Downloading $asset + checksums.txt to $tmp"
if [[ "$SOURCE" == "public" ]]; then
  base="https://github.com/${PUBLIC_REPO}/releases/download/${VERSION}"
  curl -fsSL -o "$tmp/$asset" "$base/$asset" || err "download failed: $base/$asset"
  curl -fsSL -o "$tmp/checksums.txt" "$base/checksums.txt" || err "download failed: $base/checksums.txt"
  # Signature over checksums.txt (cosign keyless, bound to the release
  # workflow). Verified when cosign is available; the checksum check below
  # runs regardless.
  if curl -fsSL -o "$tmp/checksums.txt.sigstore.json" "$base/checksums.txt.sigstore.json" 2>/dev/null; then
    if command -v cosign >/dev/null 2>&1; then
      cosign verify-blob \
        --bundle "$tmp/checksums.txt.sigstore.json" \
        --certificate-identity-regexp '^https://github\.com/Blankcut/blankcut-cli/\.github/workflows/release\.yml@refs/(tags/v[0-9]+\.[0-9]+\.[0-9]+|heads/main)$' \
        --certificate-oidc-issuer "https://token.actions.githubusercontent.com" \
        "$tmp/checksums.txt" >/dev/null 2>&1 \
        || err "signature verification failed for checksums.txt ($VERSION)"
      echo "==> Signature OK (cosign)"
    else
      echo "==> Signature present; install cosign to verify it too (checksum still verified)"
    fi
  fi
else
  gh release download "$VERSION" \
    --repo "$REPO" \
    --pattern "$asset" \
    --pattern "checksums.txt" \
    --dir "$tmp"
fi

# Pick the right sha tool: macOS ships `shasum`, Linux usually `sha256sum`.
if command -v sha256sum >/dev/null 2>&1; then
  expected=$(grep "  $asset$" "$tmp/checksums.txt" | awk '{print $1}')
  actual=$(sha256sum "$tmp/$asset" | awk '{print $1}')
elif command -v shasum >/dev/null 2>&1; then
  expected=$(grep "  $asset$" "$tmp/checksums.txt" | awk '{print $1}')
  actual=$(shasum -a 256 "$tmp/$asset" | awk '{print $1}')
else
  err "neither sha256sum nor shasum is installed; cannot verify download"
fi

if [[ "$expected" != "$actual" ]]; then
  err "checksum mismatch for $asset (expected $expected, got $actual)"
fi
echo "==> Checksum OK"

# --- Extract + install -----------------------------------------------------

mkdir -p "$tmp/extract"
if [[ "$ext" == "tar.gz" ]]; then
  tar -xzf "$tmp/$asset" -C "$tmp/extract"
else
  command -v unzip >/dev/null 2>&1 || err "unzip is required for Windows archives"
  unzip -q "$tmp/$asset" -d "$tmp/extract"
fi

binary="$tmp/extract/blankcut"
[[ "$os" == "Windows" ]] && binary="$tmp/extract/blankcut.exe"
[[ -f "$binary" ]] || err "expected $binary inside archive, not found"

# Pick an install dir we can actually write to. Default /usr/local/bin
# usually requires sudo on macOS; respect that without surprise-sudoing.
if [[ ! -w "$INSTALL_DIR" ]]; then
  if [[ "$INSTALL_DIR" == "/usr/local/bin" ]] && command -v sudo >/dev/null 2>&1; then
    echo "==> $INSTALL_DIR is not writable by current user; using sudo"
    sudo install -m 755 "$binary" "$INSTALL_DIR/blankcut"
  else
    err "$INSTALL_DIR is not writable. Set BLANKCUT_INSTALL_DIR to a writable location (e.g. ~/bin)."
  fi
else
  install -m 755 "$binary" "$INSTALL_DIR/blankcut"
fi

echo "==> Installed blankcut $VERSION to $INSTALL_DIR/blankcut"
echo

# Verify by running the binary we just wrote, and print ONLY its version.
#
# This was `--help 2>&1 | head -3`, and both halves were wrong. `head` closing
# the pipe early can SIGPIPE the binary, and being the script's LAST command
# that status became the script's own -- so a completed install exited 141 and
# every caller read it as a failure. The help text was also the wrong thing to
# show: it does not tell you which version you now have, which is the one fact
# worth confirming after an install.
"$INSTALL_DIR/blankcut" --version
