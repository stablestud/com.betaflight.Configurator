# com.betaflight.Configurator
Flatpak build configurations for the [betaflight/betaflight-configurator: Cross platform configuration tool for the Betaflight firmware](https://github.com/betaflight/betaflight-configurator)

## Creating a update

When updating the flatpak to a new Betaflight Configurator release the following has to be done:
- Change in `generate-sources.sh` the Betaflight to the wanted version.
- Generate updated sources by running `generate-sources.sh`
- Update version information in `com.betaflight.Configurator.appdata.xml`
- Build the flatpak `flatpak-builder build-dir com.betaflight.Configurator.yml`
- If build goes through, manually test the build by running the flatpak
