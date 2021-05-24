.PHONY: all build install run sources clean cleanall

SOURCES=src-appdata.json src-btfl.json src-nwjs.json src-yarn.json src-nodejspkgs.json
APPDATA=com.betaflight.Configurator.appdata.xml

all: install

build: $(SOURCES)
	flatpak-builder build-dir com.betaflight.Configurator.yml --force-clean
install: $(SOURCES) $(APPDATA)
	flatpak-builder build-dir com.betaflight.Configurator.yml --force-clean --user --install
run:
	flatpak run --user com.betaflight.Configurator
clean:
	rm --verbose --force $(SOURCES) $(APPDATA)
cleanall: clean
	rm --verbose --force --recursive build-dir .flatpak-builder
sources: clean
	./generate-sources.sh
$(SOURCES) $(APPDATA): sources
