# Bundle Installer

Shell script to install Android App Bundles via ADB. No GUI, no ads, no bullshit.

## Why?

Got tired of bundle installers that spam you with ads every 5 seconds. This does the job without the bloat.

## Setup

**System install:**
```bash
curl -o /usr/local/bin/install-bundle https://raw.githubusercontent.com/R0rt1z2/install-bundle/main/install-bundle.sh
chmod +x /usr/local/bin/install-bundle
```

**User install:**
```bash
mkdir -p ~/.local/bin
curl -o ~/.local/bin/install-bundle https://raw.githubusercontent.com/R0rt1z2/install-bundle/main/install-bundle.sh
chmod +x ~/.local/bin/install-bundle
```

Add `~/.local/bin` to your PATH if it isn't already.

## Usage

```bash
install-bundle app.apkm
install-bundle game.xapk
install-bundle whatever.zip
```

## Requirements

- ADB installed
- Device connected with USB debugging on

That's it. Works with any ZIP containing split APKs.
