# Skymod

Packwiz-based Minecraft 1.21.1 NeoForge modpack.

## Downloads

GitHub releases are built automatically from version tags.

- Prism auto-updating instance: `skymod-<version>-prism-packwiz.zip`
- Modrinth pack: `skymod-<version>.mrpack`
- CurseForge pack: `skymod-<version>-curseforge.zip`

## Prism Auto-Updating Install

Import the Prism zip from a GitHub release with `Add Instance -> Import from zip`.

The Prism instance runs `packwiz-update.sh` as its pre-launch command. That script runs `packwiz-installer-bootstrap.jar` with Prism's Java and syncs from:

```text
https://cdn.jsdelivr.net/gh/Deep-Season-SMP/skymod@main/pack.toml
```

Once installed, the Prism instance updates itself before each launch.

The raw GitHub URL must be reachable by players. If the repository is private, either make the repository public or build releases with `PACKWIZ_URL` pointed at another public static host.

## Making a Release

Update the `version` in `pack.toml`, commit it to `main`, and push. GitHub Actions creates the matching `v<version>` tag and release automatically.

```sh
git add pack.toml
git commit -m "Bump pack version to 1.1.0"
git push origin main
```

The release workflow builds and attaches the Prism, Modrinth, and CurseForge packs.

You can also build locally:

```sh
./scripts/build-release.sh
```
