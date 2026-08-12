#!/usr/bin/env bash

set -euo pipefail

if [[ $# -ne 2 ]]; then
  echo "Usage: tool/publish_first_party_release.sh <vX.Y.Z> <signed-apk-path>" >&2
  exit 1
fi

tag="$1"
apk_path="$2"
if [[ ! "$tag" =~ ^v[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
  echo "Release tag must use vX.Y.Z." >&2
  exit 1
fi
if [[ ! -f "$apk_path" ]]; then
  echo "Signed APK not found: $apk_path" >&2
  exit 1
fi

version="${tag#v}"
package_version_spec="$(sed -n 's/^version: //p' pubspec.yaml)"
package_version="${package_version_spec%%+*}"
build_number="${package_version_spec##*+}"
if [[ "$package_version" != "$version" ]]; then
  echo "Tag $tag does not match pubspec version $package_version." >&2
  exit 1
fi

public_origin="${PUBLIC_ORIGIN:-https://fittin.hammerscholar.net}"
ecs_target="${ECS_TARGET:-wsf@39.103.152.153}"
release_root="${ECS_PUBLIC_RELEASE_ROOT:-/home/wsf/nginx-fittin/public-releases}"
apk_name="fittin-$tag-android.apk"
working_dir="$(mktemp -d -t fittin-release.XXXXXX)"
trap 'rm -rf "$working_dir"' EXIT

cp "$apk_path" "$working_dir/$apk_name"
sha256="$({ shasum -a 256 "$working_dir/$apk_name" 2>/dev/null || sha256sum "$working_dir/$apk_name"; } | awk '{print $1}')"
printf '%s  %s\n' "$sha256" "$apk_name" > "$working_dir/SHA256SUMS"
printf '%s\n' \
  '<!doctype html><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1">' \
  "<title>Fittin $tag</title><h1>Fittin $tag</h1>" \
  "<p>Android build $build_number</p><p><a href=\"$apk_name\">Download signed Android APK</a></p>" \
  "<p>SHA-256: <code>$sha256</code></p>" > "$working_dir/index.html"
printf '%s\n' \
  "{\"version\":\"$version\",\"buildNumber\":$build_number,\"releasePageUrl\":\"$public_origin/releases/$tag/\",\"androidApkUrl\":\"$public_origin/releases/$tag/$apk_name\",\"sha256\":\"$sha256\"}" \
  > "$working_dir/latest.json"

ssh -t "$ecs_target" "mkdir -p '$release_root/$tag'"
scp "$working_dir/$apk_name" "$working_dir/SHA256SUMS" "$working_dir/index.html" \
  "$ecs_target:$release_root/$tag/"
scp "$working_dir/latest.json" "$ecs_target:$release_root/latest.json.tmp"
ssh "$ecs_target" "mv '$release_root/latest.json.tmp' '$release_root/latest.json'"

curl -fsS --max-time 20 "$public_origin/releases/latest.json" | grep -Fq "\"version\":\"$version\""
curl -fsSI --max-time 20 "$public_origin/releases/$tag/$apk_name"
echo "Published first-party Android release $tag."
