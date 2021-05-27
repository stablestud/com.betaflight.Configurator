Note: this repo is archived due to the need for network access while building betaflight-configurator.    
However for a (strange?) reason flathub does not allow building flatpaks with network access. And I cannot be bothered to create a workaround for a workaround.

Until Flathub does not allow builds with network connection I don't see any point wasting more time in creating workarounds for workarounds. :(

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
- `src-btfl.json`
- `src-nwjs.json`
- `src-yarn.json`
- `src-nodejspkgs.json`
- `com.betaflight.Configurator.appdata.xml`
