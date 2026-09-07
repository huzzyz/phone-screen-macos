# Phone Screen for macOS

Phone Screen launches [scrcpy](https://github.com/Genymobile/scrcpy) after finding an Android 11 or newer device that has Wireless debugging enabled.

Android changes the wireless ADB port when Wireless debugging restarts. ADB discovery can also miss a device that macOS can see over DNS-SD. Phone Screen checks active ADB transports, asks ADB for advertised devices, falls back to native macOS DNS-SD, and verifies the connection before opening scrcpy.

## Requirements

- macOS 11 or newer
- Android platform-tools and scrcpy:

  ```bash
  brew install android-platform-tools scrcpy
  ```

- A phone paired once through **Developer options > Wireless debugging > Pair device with pairing code**

## Use

1. Enable Wireless debugging on the phone.
2. Keep the phone unlocked for a few seconds.
3. Open **Phone Screen**.

Phone Screen shows a macOS alert when it cannot find the phone. It does not enable debugging remotely or bypass Android's pairing controls.

## Build and test

```bash
make test
make build
make package
```

The app appears at `dist/Phone Screen.app`. `make package` also creates a ZIP archive and SHA-256 checksum. The build uses an ad-hoc signature for local installation. Public releases should use a Developer ID signature and Apple notarization.

## Install

```bash
make install
```

The installer moves an existing Phone Screen app to a timestamped backup on the Desktop before installing the new build.

## Security

Wireless ADB provides control of the phone. Use it only on networks you trust, keep Android's pairing prompt private, and disable Wireless debugging when you finish.

## License

MIT. scrcpy is a separate project maintained by Genymobile and Romain Vimont.
