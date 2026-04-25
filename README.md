# Skymod

Packwiz-based Minecraft 1.21.1 NeoForge modpack.

## Downloads

GitHub releases are built automatically from version tags.

- Prism auto-updating instance: `skymod-<version>-prism-packwiz.zip`
- Modrinth pack: `skymod-<version>.mrpack`
- CurseForge pack: `skymod-<version>-curseforge.zip`

## Prism Auto-Updating Install

Import the Prism zip from a GitHub release with `Add Instance -> Import from zip`.

The Prism instance uses `packwiz-installer-bootstrap.jar` as a pre-launch command and syncs from:

```text
https://deep-season-smp.github.io/skymod/pack.toml
```

That URL is published by GitHub Pages from the `main` branch. Once installed, the Prism instance updates itself before each launch.

## Making a Release

Create and push a tag:

```sh
git tag v1.0.0
git push origin v1.0.0
```

The release workflow builds and attaches the Prism, Modrinth, and CurseForge packs.

You can also build locally:

```sh
./scripts/build-release.sh
```
