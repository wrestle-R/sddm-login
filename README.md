# SDDM login

My wallpaper-based SDDM login screen, pulled into its own repo so the theme and setup are easy to find.

## Version

This is the committed baseline from Linux `e9baeebf24fa0917f94c9394ef3f3fcef29e7f31`. The main desktop thread is currently reworking the layout and animations; **that redesign is not included yet**. `SOURCE.json` records the exact source and file hashes.

SDDM is the login/session chooser. This package does not theme the bootloader or the in-session lockscreen. The sibling `slumber` repo covers locking and display-off behaviour.

## Files and dependencies

`theme/Main.qml` contains the login form, session selection, power controls and entry animation. `metadata.desktop` declares SDDM Theme API 2.0 / Qt 6. `theme.conf` records the wallpaper filename. The QML imports QtQuick, QtQuick.Controls, QtQuick.Layouts and QtQuick.Effects; these modules and a Qt 6 SDDM greeter must be installed before previewing.

Bring your own JPEG as `theme/wallpaper.jpg`. The original used `~/Pictures/Wallpapers/hehe.jpg`; personal wallpaper files are deliberately gitignored and not uploaded. The source code currently loads the fixed filename `wallpaper.jpg`.

## Preview first

From this repo, copy a wallpaper and run the greeter in test mode as your regular user:

```bash
cp "$HOME/Pictures/Wallpapers/hehe.jpg" theme/wallpaper.jpg
sddm-greeter-qt6 --test-mode --theme "$PWD/theme"
```

This opens a native test window; it does not replace the running login manager. Check the wallpaper, keyboard focus, form layout, session list and animation. Test mode does not prove real password authentication. Save work before testing a normal logout/login later.

## Install without restarting SDDM

Use a separate theme name so the original desktop package is preserved. First inspect existing choices:

```bash
rg -n 'Current=|ThemeDir=' /etc/sddm.conf /etc/sddm.conf.d /usr/lib/sddm/sddm.conf.d
```

Some paths may not exist. Review effective config precedence, including any `Current` in `/etc/sddm.conf`, before choosing the override. On the source machine the original package uses `/etc/sddm.conf.d/90-rdp-slumber.conf`.

For a first installation, ensure BOTH paths below do not already exist; if either exists, stop and back up/review it rather than overwriting. These commands create new paths and do not restart SDDM:

```bash
sudo test ! -e /usr/share/sddm/themes/rdp-login
sudo test ! -e /etc/sddm.conf.d/91-rdp-login.conf
```

Proceed only if both checks succeeded:

```bash
sudo install -d -m 755 /usr/share/sddm/themes/rdp-login
sudo install -m 644 theme/Main.qml theme/metadata.desktop theme/theme.conf theme/wallpaper.jpg /usr/share/sddm/themes/rdp-login/
printf '[Theme]\nCurrent=rdp-login\n' | sudo tee /etc/sddm.conf.d/91-rdp-login.conf
```

The theme becomes active at the next normal login if this override is effective. It keeps SDDM's authentication and session handling. Never restart SDDM with unsaved apps running. Keep a working fallback theme installed.

## Rollback and updates

To disable only this repo's newly created override, move it aside from a working session or TTY:

```bash
sudo mv /etc/sddm.conf.d/91-rdp-login.conf /etc/sddm.conf.d/91-rdp-login.conf.disabled
```

The prior theme selection then applies at the next normal login. Leave the installed theme directory in place until recovery is confirmed. This does not change the historical `90-rdp-slumber.conf` override or Slumber files.

Before later updates, back up the installed theme and active override to a private timestamped directory, preview the new source, and retain that backup through a successful login. Do not overwrite existing local edits blindly. Git pulls update source files only.

## Source

[Original theme](https://github.com/wrestle-R/Linux/tree/e9baeebf24fa0917f94c9394ef3f3fcef29e7f31/End-4/slumber/sddm). Original author and MIT license declaration remain in `theme/metadata.desktop`. No new license grant is inferred for unrelated files.
