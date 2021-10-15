# com.betaflight.Configurator
Flatpak build configuration for the [betaflight/betaflight-configurator: Cross platform configuration tool for the Betaflight firmware](https://github.com/betaflight/betaflight-configurator)

## Installing Betaflight Configurator

### Prerequisites

Even though the application runs in its own sandbox, some changes are still required on the host.
1. Create `udev` rules
2. Add yourself to a group capable of talking to serial ports

Precise How-To steps can be found at [Installing Betaflight · betaflight/betaflight Wiki](https://github.com/betaflight/betaflight/wiki/Installing-Betaflight#platform-specific-linux)

Note: the `i386` architecture is no longer supported from flathub, therefore we cannot create a flatpak for it.    
However `amd64` (and `armv7`) architectures are fully supported.

### Installing the flatpak

This flatpak is not yet available for download on flathub.org.    
Therefore you'll need to build the flatpak yourself from the sources.

`make install` to build and install the flatpak into your users flatpak installation.    
Note: the Makefile doesn't use root to install the flatpak, but your per-user installation.    
Therefore to manage Betaflight Configurator must instruct flatpak to use your user installation, this can be done by using the `--user` option.

Examples:
- `flatpak list --user`
- `flatpak remove --user com.betaflight.Configurator` - remove Betaflight Configurator
- `flatpak run --user com.betaflight.Configurator` - start Betaflight Configurator from CLI

###

## Creating an update

When updating the flatpak to a new Betaflight Configurator release the following has to be done:
1. Change the Betaflight version in `generate-sources.sh`
2. Generate required sources for the update by running `generate-sources.sh` or `make sources`
3. Build the flatpak `flatpak-builder build-dir com.betaflight.Configurator.yml` or `make build`
4. If build goes through, manually test the build by running the flatpak `make install` `make run`

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
- `Too short EDID data: manufacturer id` - why would betaflight want to read your monitor id?
- `Failed to connect to the bus: Failed to connect to socket /run/dbus/system_bus_socket: No such file or directory`
- `InitializeSandbox() called with multiple threads in process gpu-process.`
- `GetVSyncParametersIfAvailable() failed for X times!`
