.PHONY: all build install run sources clean cleanall

SOURCES=src-btfl.json src-appdata.json
APPDATA=com.betaflight.Configurator.appdata.xml

all: sources install

build:
	flatpak-builder build-dir com.betaflight.Configurator.yml --force-clean --build-only
install:
	flatpak-builder build-dir com.betaflight.Configurator.yml --user --force-clean --install
run:
	flatpak run --user com.betaflight.Configurator
clean:
	rm --verbose --force --recursive $(SOURCES) $(APPDATA) build-dir
cleanall: clean
	rm --verbose --force --recursive build-dir .flatpak-builder
sources: clean
	./generate-sources.sh
