# OVault

OVault is a super simple OTP app that lets you view and manage OTPs for all your accounts. Set up OTPs by scanning QR codes with your devices Camera App, or by manually providing the OTP secret to the app.

<a href="https://apps.apple.com/us/app/ovault/id6736616639?itscg=30200&itsct=apps_box_badge&mttnsubad=6736616639" style="display: inline-block;">
      <img src="https://toolbox.marketingtools.apple.com/api/v2/badges/download-on-the-app-store/black/en-us?releaseDate=1728864000" alt="Download on the App Store" style="width: 120px; height: 42px; vertical-align: middle; object-fit: contain;" />
</a>

## Features

- Copy OTP codes to Clipboard from the app
- View OTP codes on your Home Screen or your Mac Notification Centre using our Widgets, without ever needing to open the app
- Scan QR codes for adding OTPs both in-app or using your devices Camera app
- Reveal your OTP secrets to allow for effortless migration of OTPs to other devices or OTP apps
- OTP data is synchronised using iCloud Keychain, so it is available across all your devices and syncs between device upgrades
- 100% local-only processing. No data (not even usage data) is sent to any services outside of your iCloud Keychain (if enabled on your device)

## Screenshots

<p float="left">
  <img alt="iOS Main Screen" src="Docs/Screenshots/ios-main-screen.png" width="30%" />

  <img alt="iOS Widgets" src="Docs/Screenshots/ios-widgets.png" width="30%" />

  <img alt="iOS Add OTP" src="Docs/Screenshots/ios-add-otp.png" width="30%" />
</p>

## Installation

The primary method of installation for OVault is through the [iOS and macOS App Stores](https://apps.apple.com/us/app/ovault/id6736616639?itscg=30200&itsct=apps_box_badge&mttnsubad=6736616639).

For macOS, we do offer the application for download on our [GitHub Releases](https://github.com/JustAman62/ovault/releases/latest) page. Simply open the [latest release](https://github.com/JustAman62/ovault/releases/latest) and download the DMG file attached to it. Open this DMG, then drag OVault.app to the Applications folder shown.

## Development

### Packaging

`.dmg` images containing `OVault.app` are created to allow for manual distribution of the mac app. These are created using `create-dmg` which can be installed using `brew install create-dmg`. These DMGs are notarized to ensure end-users can open them.

Once installed, simply execute the build script and a new image will be created at `./build-output/OVault-<version>.dmg`.

```sh
sh ./Scripts/create-dmg.sh
```

Note: the installer background image must be 72dpi to fill our the Finder window correctly. You can set this manually on the png by executing:

```sh
sips --setProperty dpiWidth 72 --setProperty dpiHeight 72 ./Scripts/installer-background.png
```
