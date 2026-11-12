# SDDM login

**Supported platform: Arch Linux + Hyprland only.**

Minimal right-aligned login: sharp wallpaper, geometric clock and aligned username, password and session controls. This standalone redesign supersedes the earlier Twin Halo snapshot.

SDDM handles login and session selection. The sibling Slumber repo covers the in-session lockscreen, display-off mode, notifications and charging controls. No PAM or bootloader changes are needed.

## Prepare and preview

Requires Python3, ImageMagick (`magick`), Qt6 SDDM (`sddm-greeter-qt6`), QtQuick, Controls and Layouts. No QtQuick.Effects shader is required. Bring your own wallpaper; images are not uploaded.

Choose a directory that does not exist:

```bash
python3 prepare.py --wallpaper "$HOME/Pictures/Wallpapers/hehe.jpg" --output /tmp/rdp-login-preview
sddm-greeter-qt6 --test-mode --theme /tmp/rdp-login-preview
```

Preparation copies the selected wallpaper and validates the complete theme in SDDM's software-rendered test mode. Missing dependencies, conversion errors or invalid QML stop before writing the output directory. Existing output directories are refused. Remove only your disposable preview directory before preparing again.

The wallpaper is static and sharp, with no shader or animation dependency. Password submission starts immediately, independent of animation. Failure clears and masks the password and restores focus. Text messages stay plain text. Missing background images retain a dark background with usable controls.

## Install and recover

On the source machine, the existing guarded installer in `Linux/End-4/slumber/install-system.py` manages `/usr/share/sddm/themes/rdp-slumber` and `/etc/sddm.conf.d/90-rdp-slumber.conf`. Use that installer and its printed backup for updates to this existing installation; it also manages the battery helper. See the sibling `slumber/source/README.md` for exact commands. It checks existing file hashes, validates the staged theme, backs up changes and rolls back partial writes. It never restarts SDDM.

For an independent first installation, use a separate theme name. Check configuration precedence (`Current`/`ThemeDir` in `/etc/sddm.conf` and config directories) first. Both paths below must be absent; if either exists, stop and review/back up it:

```bash
sudo test ! -e /usr/share/sddm/themes/rdp-login
sudo test ! -e /etc/sddm.conf.d/91-rdp-login.conf
```

Only after both checks succeed and the native preview loads:

```bash
sudo install -d -m755 /usr/share/sddm/themes/rdp-login
sudo install -m644 /tmp/rdp-login-preview/Main.qml /tmp/rdp-login-preview/metadata.desktop /tmp/rdp-login-preview/theme.conf /tmp/rdp-login-preview/wallpaper.jpg /usr/share/sddm/themes/rdp-login/
printf '[Theme]\nCurrent=rdp-login\n' | sudo tee /etc/sddm.conf.d/91-rdp-login.conf
```

This takes effect at the next normal login. Keep Breeze installed. Never restart SDDM with unsaved apps. To return to the earlier theme selection, move only this new override aside:

```bash
sudo mv /etc/sddm.conf.d/91-rdp-login.conf /etc/sddm.conf.d/91-rdp-login.conf.disabled
```

For future source updates, retain private backups, preview first and use the guarded canonical installer rather than overwriting local edits. Git pull updates source only.

## Historical verification

Canonical `test_sddm.py` passed: offline/deterministic blur preparation, conversion failure before writes, invalid-QML refusal, actual SDDM software rendering and missing-image loading, native mock-auth validation, duplicate suppression, password clearing/masking, focus and bounded motion. Actual Enter/Escape/Tab were exercised in a disposable preview. A normal password login and reboot after installation still need user verification; test mode cannot prove those.

The exact theme and shared `theme_tools.py` hashes are recorded in `SOURCE.json`. Original author/MIT theme declaration remains in `theme/metadata.desktop`; no personal wallpaper, credentials or private notes are included.

## Current redesign validation
Native SDDM software-rendered preflight passes with the wallpaper and with missing wallpaper. Real password login and power operations require physical verification. The canonical Linux installer still contains the previous design; do not use it to deploy this standalone revision.
