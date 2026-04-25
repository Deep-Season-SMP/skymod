#!/usr/bin/env bash
set -euo pipefail

PACK_SLUG="${PACK_SLUG:-skymod}"
PACK_NAME="${PACK_NAME:-Skymod}"
PACK_VERSION="${PACK_VERSION:-$(git describe --tags --always --dirty 2>/dev/null || date +%Y%m%d)}"
PACKWIZ_URL="${PACKWIZ_URL:-https://raw.githubusercontent.com/Deep-Season-SMP/skymod/main/pack.toml}"
DIST_DIR="${DIST_DIR:-dist}"

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

rm -rf "$DIST_DIR"
mkdir -p "$DIST_DIR"

echo "Refreshing packwiz index..."
packwiz refresh

echo "Building Modrinth pack..."
packwiz modrinth export -o "$DIST_DIR/${PACK_SLUG}-${PACK_VERSION}.mrpack"

echo "Building CurseForge pack..."
packwiz curseforge export -o "$DIST_DIR/${PACK_SLUG}-${PACK_VERSION}-curseforge.zip" -s client

echo "Building Prism auto-updating packwiz instance..."
tmp_dir="$(mktemp -d)"
trap 'rm -rf "$tmp_dir"' EXIT

instance_dir="$tmp_dir/$PACK_NAME"
mkdir -p "$instance_dir/minecraft"

cat > "$instance_dir/mmc-pack.json" <<'JSON'
{
    "components": [
        {
            "cachedName": "LWJGL 3",
            "cachedVersion": "3.3.3",
            "cachedVolatile": true,
            "dependencyOnly": true,
            "uid": "org.lwjgl3",
            "version": "3.3.3"
        },
        {
            "cachedName": "Minecraft",
            "cachedRequires": [
                {
                    "suggests": "3.3.3",
                    "uid": "org.lwjgl3"
                }
            ],
            "cachedVersion": "1.21.1",
            "important": true,
            "uid": "net.minecraft",
            "version": "1.21.1"
        },
        {
            "cachedName": "NeoForge",
            "cachedRequires": [
                {
                    "equals": "1.21.1",
                    "uid": "net.minecraft"
                }
            ],
            "cachedVersion": "21.1.228",
            "uid": "net.neoforged",
            "version": "21.1.228"
        }
    ],
    "formatVersion": 1
}
JSON

cat > "$instance_dir/instance.cfg" <<CFG
[General]
ConfigVersion=1.2
InstanceType=OneSix
name=$PACK_NAME
iconKey=default
notes=Auto-updating packwiz instance. Updates from $PACKWIZ_URL before each launch.
OverrideCommands=true
PreLaunchCommand=/bin/sh packwiz-update.sh
PostExitCommand=
WrapperCommand=
LogPrePostOutput=true
OverrideMemory=true
MinMemAlloc=1024
MaxMemAlloc=8096
OverrideJavaLocation=false
AutomaticJava=true
ExportAuthor=Vin
ExportName=$PACK_NAME
ExportSummary=Auto-updating Prism instance for $PACK_NAME
ExportVersion=$PACK_VERSION
CFG

cat > "$instance_dir/minecraft/packwiz-update.sh" <<CFG
#!/bin/sh
set -eu

if [ -f "../instance.cfg" ]; then
  JAVA_PATH=\$(awk -F= '/^JavaPath=/{print substr(\$0, index(\$0, "=") + 1); exit}' "../instance.cfg")
  if [ -n "\${JAVA_PATH:-}" ] && [ -x "\$JAVA_PATH" ]; then
    exec "\$JAVA_PATH" -jar packwiz-installer-bootstrap.jar "$PACKWIZ_URL"
  fi
fi

if [ -n "\${INST_JAVA:-}" ] && [ -x "\$INST_JAVA" ]; then
  exec "\$INST_JAVA" -jar packwiz-installer-bootstrap.jar "$PACKWIZ_URL"
fi

if command -v java >/dev/null 2>&1; then
  exec java -jar packwiz-installer-bootstrap.jar "$PACKWIZ_URL"
fi

echo "Could not find Java. Prism did not provide INST_JAVA and java is not on PATH." >&2
exit 1
CFG
chmod +x "$instance_dir/minecraft/packwiz-update.sh"

curl -L --fail --silent --show-error \
  "https://github.com/packwiz/packwiz-installer-bootstrap/releases/latest/download/packwiz-installer-bootstrap.jar" \
  -o "$instance_dir/minecraft/packwiz-installer-bootstrap.jar"

(cd "$tmp_dir" && zip -qr "$ROOT_DIR/$DIST_DIR/${PACK_SLUG}-${PACK_VERSION}-prism-packwiz.zip" "$PACK_NAME")

echo "Built release artifacts:"
ls -lh "$DIST_DIR"
