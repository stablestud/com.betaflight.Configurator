# com.betaflight.Configurator
Flatpak build configuration for the [betaflight/betaflight-configurator: Cross platform configuration tool for the Betaflight firmware](https://github.com/betaflight/betaflight-configurator)

## Creating an update

When updating the flatpak to a new Betaflight Configurator release the following has to be done:
- Change the Betaflight version in `generate-sources.sh`
- Generate required sources for the update by running `generate-sources.sh` or `make sources`
- Build the flatpak `flatpak-builder build-dir com.betaflight.Configurator.yml` or `make build`
- If build goes through, manually test the build by running the flatpak `make install` `make run`

## Generated files

The following files are auto generated and should not be changed by hand.    
Instead run `generate-sources.sh` to generate the latest sources based on the selected Betaflight Configurator Version in `generate-sources.sh`

- `src-appdata.json`
- `src-btfl.json`
- `src-nwjs.json`
- `src-yarn.json`
- `src-nodejspkgs.json`
- `com.betaflight.Configurator.appdata.xml`
