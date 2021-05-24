.PHONY: all build install run generate clean cleanall

SOURCES=src-appdata.yml src-btfl.yml src-nwjs.yml src-yarn.yml src-nodejspkgs.yml
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
generate: clean
	./generate-sources.sh
$(SOURCES) $(APPDATA): generate
