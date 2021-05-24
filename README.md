# com.betaflight.Configurator
Flatpak build configuration for the [betaflight/betaflight-configurator: Cross platform configuration tool for the Betaflight firmware](https://github.com/betaflight/betaflight-configurator)

## Creating a update

When updating the flatpak to a new Betaflight Configurator release the following has to be done:
- Change in `generate-sources.sh` the Betaflight to the wanted version.
- Generate updated sources by running `generate-sources.sh`
- Update version information in `com.betaflight.Configurator.appdata.xml`
- Build the flatpak `flatpak-builder build-dir com.betaflight.Configurator.yml`
- If build goes through, manually test the build by running the flatpak

## Generated files

The following files are auto generated and should not be changed by hand.    
Instead run `generate-sources.sh` to generate the latest sources based on the selected Betaflight Configurator Version in `generate-sources.sh`

- `src-btfl.yml`
- `src-nwjs.yml`
- `src-yarn.yml`
- `src-nodejspkgs.yml`

