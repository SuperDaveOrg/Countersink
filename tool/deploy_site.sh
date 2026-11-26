#!/usr/bin/env bash
set -euo pipefail

# Build countersink.superdavelab.com and deploy it to Apache on the
# SuperDaveLab host.
#
# Assembles dist/site/ from site/ plus: the logo, the store-listing
# screenshots (fastlane/.../phoneScreenshots — one set of files for the README,
# F-Droid and the page), and the newest *release* APK from dist/release/. The
# page's double-brace placeholders are filled from that release: version,
# date, size, SHA-256, minimum Android version.
#
# The APK and its facts come from the files Nexpill's tool/build_release.sh
# writes: dist/release/countersink-X.Y.Z.apk, its .sha256, and a
# .BUILD-INFO.txt with `kind release` and `name <file>` lines.
#
# With no release there yet, the page is built and deployed all the same,
# saying the beta is coming soon in place of the download. With a release but
# no git tag for it (the first betas come before the repository), the release
# date is the APK's own and the "built from tag" line is left out.
#
# Then rsyncs dist/site/ to the server. Like Ebb's and Nexpill's deploy
# scripts, this never deletes anything remotely — old APKs stay downloadable
# until you remove them by hand.
#
# Usage:
#   tool/deploy_site.sh [--build-only | --dry-run]
#
# Options:
#   --build-only   Assemble dist/site/ and stop (open dist/site/index.html)
#   --dry-run      Assemble, then show what rsync would send; touch nothing
#   -h, --help     Show this help
#
# Environment overrides:
#   SSH_TARGET     default root@davekoons.com
#   REMOTE_DIR     default /var/www/countersink
#   SITE_DOMAIN    default countersink.superdavelab.com (for the post-deploy check)

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SSH_TARGET="${SSH_TARGET:-root@davekoons.com}"
REMOTE_DIR="${REMOTE_DIR:-/var/www/countersink}"
SITE_DOMAIN="${SITE_DOMAIN:-countersink.superdavelab.com}"
SHOTS="fastlane/metadata/android/en-US/images/phoneScreenshots"
MODE=deploy

# Prints the comment block at the top of this file, and nothing after it.
usage() { awk 'NR > 1 && /^#/ { sub(/^# ?/, ""); print; seen = 1; next } seen { exit }' "$0"; }
die() { echo "deploy_site: $*" >&2; exit 1; }
say() { echo "==> $*"; }

while [[ $# -gt 0 ]]; do
  case "$1" in
    --build-only) MODE=build; shift ;;
    --dry-run) MODE=dry; shift ;;
    -h|--help) usage; exit 0 ;;
    *) usage; exit 1 ;;
  esac
done

cd "$REPO"

# --- The release to offer ----------------------------------------------------

apk=""
for info in dist/release/countersink-*.BUILD-INFO.txt; do
  [[ -f $info ]] || continue
  grep -q '^kind *release$' "$info" || continue   # never a snapshot or debug build
  candidate="dist/release/$(sed -n 's/^name *//p' "$info")"
  [[ -f $candidate ]] && apk="$apk$candidate"$'\n'
done
apk="$(printf '%s' "$apk" | sort -V | tail -1)"

# Android's API level, as the version people know.
android_version() {
  case "$1" in
    21) echo 5.0 ;; 22) echo 5.1 ;; 23) echo 6.0 ;; 24) echo 7.0 ;; 25) echo 7.1 ;;
    26) echo 8.0 ;; 27) echo 8.1 ;; 28) echo 9 ;; 29) echo 10 ;; 30) echo 11 ;;
    31) echo 12 ;; 32) echo 12L ;; 33) echo 13 ;; 34) echo 14 ;; 35) echo 15 ;;
    36) echo 16 ;;
    *) echo "API $1" ;;
  esac
}

# The oldest Android an APK installs on, from its badging.
min_android() {
  local sdk aapt
  sdk="${ANDROID_HOME:-${ANDROID_SDK_ROOT:-$HOME/Android/Sdk}}"
  aapt="$(ls -d "$sdk"/build-tools/*/ 2>/dev/null | sort -V | tail -1)aapt"
  [[ -x $aapt ]] || die "no aapt under $sdk/build-tools"
  android_version "$("$aapt" dump badging "$1" | sed -n "s/^sdkVersion:'\([0-9]*\)'/\1/p")"
}

# Checks an APK against its .sha256 and prints the hash.
apk_sha256() {
  [[ -f $1.sha256 ]] || die "missing $1.sha256"
  local sha
  sha="$(cut -d' ' -f1 "$1.sha256")"
  [[ "$(sha256sum "$1" | cut -d' ' -f1)" == "$sha" ]] || die "$(basename "$1") doesn't match its .sha256"
  echo "$sha"
}

apk_size() { awk '{ printf "%.0f MB", $1 / 1000000 }' <<< "$(stat -c %s "$1")"; }

if [[ -n $apk ]]; then
  APK_FILE="$(basename "$apk")"
  VERSION="$(sed -E 's/^countersink-(.+)\.apk$/\1/' <<< "$APK_FILE")"
  APK_SHA256="$(apk_sha256 "$apk")"
  APK_SIZE="$(apk_size "$apk")"
  MIN_ANDROID="$(min_android "$apk")"
  # The tag's date, not the build's: the day the version was released. Before
  # there is a tag, the day the APK was built.
  if RELEASE_DATE="$(git log -1 --format=%cd --date=format:'%B %-d, %Y' "v$VERSION" 2>/dev/null)"; then
    TAGGED=1
  else
    TAGGED=0
    RELEASE_DATE="$(date -r "$apk" +'%B %-d, %Y')"
    echo "Note: no git tag v$VERSION, so the page leaves out the link to its source."
  fi
else
  # Before the first release: the page says the beta is coming.
  echo "Note: no release APK in dist/release/, so the page says the beta is coming soon."
  VERSION="" APK_FILE="" TAGGED=0
  MIN_ANDROID="7.0"   # minSdk 24
fi
YEAR="$(date +%Y)"

# --- Assemble -----------------------------------------------------------------

OUT="dist/site"
say "Building $OUT for Countersink ${VERSION:-(no release yet)}"
rm -rf "$OUT"
mkdir -p "$OUT/assets/screenshots" "$OUT/downloads"
cp -r site/. "$OUT/"
cp assets/brand/countersink_logo_512.png "$OUT/assets/logo.png"
if compgen -G "$SHOTS/*.png" > /dev/null; then
  cp "$SHOTS"/*.png "$OUT/assets/screenshots/"
fi
[[ -n $apk ]] && cp "$apk" "$apk.sha256" "$OUT/downloads/"

# Every screenshot the page shows has to be there.
missing=0
for shot in $(grep -o 'assets/screenshots/[A-Za-z0-9_]*\.png' site/index.html | sort -u); do
  [[ -f $OUT/$shot ]] && continue
  echo "    missing $SHOTS/$(basename "$shot")"
  missing=1
done
if (( missing )); then
  [[ $MODE == build ]] || die "the page shows screenshots that don't exist (above)"
  echo "Note: screenshots missing (above); the page will show gaps."
fi

# The stylesheet's URL changes with its content, so a browser holding an old
# copy can't pair it with new markup.
CSS_HASH="$(sha256sum site/style.css | cut -c1-10)"

# Keep the blocks that apply and drop the others, markers and all.
keep() { sed -i -e "/<!-- \/\?$1 -->/d" "$OUT/index.html"; }
drop() { sed -i -e "/<!-- $1 -->/,/<!-- \/$1 -->/d" "$OUT/index.html"; }
if [[ -n $apk ]]; then
  keep RELEASE; drop NO-RELEASE
  if (( TAGGED )); then keep TAGGED; else drop TAGGED; fi
  sed -i \
    -e "s|{{VERSION}}|$VERSION|g" \
    -e "s|{{APK_FILE}}|$APK_FILE|g" \
    -e "s|{{APK_SIZE}}|$APK_SIZE|g" \
    -e "s|{{APK_SHA256}}|$APK_SHA256|g" \
    -e "s|{{RELEASE_DATE}}|$RELEASE_DATE|g" \
    "$OUT/index.html"
else
  drop RELEASE; keep NO-RELEASE
  # The structured data can't name a version or a download that isn't there.
  sed -i -e '/"softwareVersion":/d' -e '/"downloadUrl":/d' "$OUT/index.html"
fi
sed -i \
  -e "s|{{CSS_HASH}}|$CSS_HASH|g" \
  -e "s|{{MIN_ANDROID}}|$MIN_ANDROID|g" \
  -e "s|{{YEAR}}|$YEAR|g" \
  "$OUT/index.html"

if grep -o '{{[A-Z_]*}}' "$OUT/index.html" | sort -u | grep .; then
  die "unfilled placeholders above in $OUT/index.html"
fi

if [[ -n $apk ]]; then
  echo "    $APK_FILE ($APK_SIZE), released $RELEASE_DATE"
  echo "    sha256 $APK_SHA256"
fi

case "$MODE" in
  build)
    say "Built. Preview: $REPO/$OUT/index.html"
    exit 0 ;;
  dry)
    say "Dry run: what would go to $SSH_TARGET:$REMOTE_DIR"
    rsync -avzn "$OUT/" "$SSH_TARGET:$REMOTE_DIR/"
    exit 0 ;;
esac

# --- Deploy -------------------------------------------------------------------

say "Deploying to $SSH_TARGET:$REMOTE_DIR (never deletes remote files)"
ssh "$SSH_TARGET" "mkdir -p '$REMOTE_DIR'"
rsync -avz "$OUT/" "$SSH_TARGET:$REMOTE_DIR/"

say "Checking https://$SITE_DOMAIN/"
if curl -fsS -o /dev/null "https://$SITE_DOMAIN/${APK_FILE:+downloads/$APK_FILE}" -r 0-0; then
  echo "    live: https://$SITE_DOMAIN/ serves ${APK_FILE:-the page}"
else
  echo "    not reachable yet — if the subdomain isn't set up, that's expected."
  echo "    Files are on the server in $REMOTE_DIR."
fi
