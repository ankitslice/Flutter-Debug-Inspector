#!/usr/bin/env bash
# Publishes Flutter module + plugin AARs from `flutter build aar` to GitHub Packages (Maven).
# Does not upload io.flutter artifacts — consumers still use download.flutter.io.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
REPO_DIR="${REPO_DIR:-$ROOT/inspector_host_module/build/host/outputs/repo}"

if [[ ! -d "$REPO_DIR" ]]; then
  echo "Missing Maven repo: $REPO_DIR"
  echo "Run: cd inspector_host_module && flutter pub get && flutter build aar"
  exit 1
fi

if [[ -z "${GITHUB_REPOSITORY:-}" ]]; then
  echo "Set GITHUB_REPOSITORY=owner/repo (e.g. myorg/FlutterDebugInspector)"
  exit 1
fi

MAVEN_URL="https://maven.pkg.github.com/${GITHUB_REPOSITORY}"
USERNAME="${GITHUB_ACTOR:-${GPR_USER:-}}"
TOKEN="${GITHUB_TOKEN:-${GPR_TOKEN:-}}"

if [[ -z "$USERNAME" || -z "$TOKEN" ]]; then
  echo "Need GITHUB_ACTOR + GITHUB_TOKEN (CI) or GPR_USER + GPR_TOKEN (local PAT with write:packages)."
  exit 1
fi

SETTINGS="$(mktemp)"
cleanup() { rm -f "$SETTINGS"; }
trap cleanup EXIT

# Maven requires XML-safe credentials; minimal settings file.
xml_escape() {
  printf '%s' "$1" | sed -e 's/&/\&amp;/g' -e 's/</\&lt;/g' -e 's/>/\&gt;/g'
}
USER_X="$(xml_escape "$USERNAME")"
PASS_X="$(xml_escape "$TOKEN")"
cat >"$SETTINGS" <<EOF
<settings xmlns="http://maven.apache.org/SETTINGS/1.0.0"
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
  xsi:schemaLocation="http://maven.apache.org/SETTINGS/1.0.0 https://maven.apache.org/xsd/settings-1.0.0.xsd">
  <servers>
    <server>
      <id>github</id>
      <username>${USER_X}</username>
      <password>${PASS_X}</password>
    </server>
  </servers>
</settings>
EOF

publish_aar() {
  local aar="$1"
  local pom="${aar%.aar}.pom"
  if [[ ! -f "$pom" ]]; then
    echo "WARN: no POM next to $aar — skip"
    return 0
  fi
  echo "Deploying $(basename "$aar")"
  mvn --batch-mode --settings "$SETTINGS" deploy:deploy-file \
    -DrepositoryId=github \
    -Durl="$MAVEN_URL" \
    -Dfile="$aar" \
    -DpomFile="$pom" \
    -Dpackaging=aar
}

aars=()
while IFS= read -r aar; do
  [[ -n "$aar" && -f "$aar" ]] && aars+=("$aar")
done < <(
  (
    find "$REPO_DIR/com/example/inspector_host_module" -name '*.aar' 2>/dev/null || true
    find "$REPO_DIR/com/example/flutter_debug_inspector" -name '*.aar' 2>/dev/null || true
  ) | sort -u
)

if [[ ${#aars[@]} -eq 0 ]]; then
  echo "No AARs found under com/example/inspector_host_module or com/example/flutter_debug_inspector"
  exit 1
fi

for aar in "${aars[@]}"; do
  publish_aar "$aar"
done

echo ""
echo "Done. Repository URL for Gradle:"
echo "  $MAVEN_URL"
echo "See ANDROID_AAR.md → 'Consume from GitHub Packages'."
