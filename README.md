# com.betaflight.Configurator
Flatpak build configuration for the [betaflight/betaflight-configurator: Cross platform configuration tool for the Betaflight firmware](https://github.com/betaflight/betaflight-configurator)

## Installing Betaflight Configurator

### Prerequisites

Even though the application runs in its own sandbox, some changes are still required on the host.
1. Create `udev` rules
2. Add yourself to a group capable of talking to serial ports

Precise How-To steps can be found at [Installing Betaflight · betaflight/betaflight Wiki](https://github.com/betaflight/betaflight/wiki/Installing-Betaflight#platform-specific-linux)

Note: the `i386` architecture is no longer supported from flathub, therefore we cannot create a flatpak for it.
However `amd64` and `armv7` architectures  are fully supported.

## Creating an update

When updating the flatpak to a new Betaflight Configurator release the following has to be done:
- Change the Betaflight version in `generate-sources.sh`
- Generate required sources for the update by running `generate-sources.sh` or `make sources`
- Build the flatpak `flatpak-builder build-dir com.betaflight.Configurator.yml` or `make build`
- If build goes through, manually test the build by running the flatpak `make install` `make run`

## Generated files

The following files are auto generated and should not be changed manually.    
Instead run `generate-sources.sh` to generate the latest sources based on the selected Betaflight Configurator Version in `generate-sources.sh`

- `src-appdata.json`
- `src-app.json`
- `com.betaflight.Configurator.appdata.xml`

### Errors in logs

Following errors can be ignored as they do not affect the betaflight-configurator
- `Failed to load module "pk-gtk-module"`
- `Failed to load module "canberra-gtk-module"`
- `Failed to parse extension manifest.`
- `Too short EDID data: manufacturer id`
- `Failed to connect to the bus: Failed to connect to socket /run/dbus/system_bus_socket: No such file or directory`
- `InitializeSandbox() called with multiple threads in process gpu-process.`
- `GetVSyncParametersIfAvailable() failed for X times!`
