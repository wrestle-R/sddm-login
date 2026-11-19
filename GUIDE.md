# SDDM login

**Supported platform: Arch Linux + Hyprland only.**

The login screen puts a geometric clock and three aligned controls over a sharp wallpaper. The standalone theme and Slumber installer use the same layout.

SDDM handles login and session selection. The sibling Slumber repo covers the in-session lockscreen, display-off mode, notifications and charging controls. No PAM or bootloader changes are needed.

## Prepare and preview

Requires Python 3, Qt6 SDDM (`sddm-greeter-qt6`), Qt Quick and Qt Quick Controls. Bring your own local wallpaper.

Choose a directory that does not exist:

```bash
python3 prepare.py --wallpaper "$HOME/Pictures/Wallpapers/hehe.jpg" --output /tmp/rdp-login-preview
sddm-greeter-qt6 --test-mode --theme /tmp/rdp-login-preview
```

Preparation copies the selected wallpaper and validates the complete theme in SDDM's software-rendered test mode. Missing dependencies, unreadable wallpaper or invalid QML stop before writing the output directory. Existing output directories are refused. Remove only your disposable preview directory before preparing again.

The wallpaper is static and sharp, with no shader or animation dependency. Password submission starts immediately, independent of animation. Failure clears and masks the password and restores focus. Text messages stay plain text. Missing background images retain a dark background with usable controls.

The optional **Use fingerprint** button is enabled by the Slumber fingerprint installer once `fprintd` is installed and an enrolled finger has been verified. Password sign-in is available immediately. A failed scan returns you to the password field. [Slumber setup and recovery](https://github.com/wrestle-R/slumber/blob/main/source/README.md#optional-fingerprint-sign-in)

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

## Verification

The native SDDM smoke test checks rendering with and without wallpaper. The native mock-auth test checks matching row width, text inset and spacing, duplicate submission, password clearing and masking, focus on failure, and plain-text messages. A normal login is the end-to-end check for real credentials.

`SOURCE.json` records the theme and shared preflight hashes.
