#! /usr/bin/env sh

app_version="10.8.0"
app_dl_file="betaflight-configurator_${app_version}_linux64-portable.zip"
app_dl_url="https://github.com/betaflight/betaflight-configurator/releases/download/${app_version}/${app_dl_file}"

appdata_file="com.betaflight.Configurator.appdata.xml"

src_app="src-app.json"
src_appdata="src-appdata.json"

generated_files="${src_app} ${src_appdata}"

check_deps() {
	unset error
	deps="mktemp sha256sum rm tee cut grep"

	for i in ${deps}; do
		if ! command -v "${i}" 1>"/dev/null" 2>&1; then
			echo "Error: command '${i}' missing" 1>&2
			error="true"
		fi
	done

	if [ -n "${error}" ]; then
		echo "Missing dependencies, please install them" 1>&2
		exit 1
	fi
}

mktemp_path() {
	tmp_path="$(mktemp --directory)"
}

remove_sources() {
	rm --verbose --force ${generated_files}
}

gen_app_src() {
	wget --directory-prefix "${tmp_path?unset}" "${app_dl_url}"
	app_sha256sum="$(sha256sumof "${tmp_path}/${app_dl_file}")"
	tee "${src_app}" <<EOF
[
	{
		"type": "archive",
		"url": "${app_dl_url}",
		"sha256": "${app_sha256sum}",
		"dest": "betaflight-configurator"
	}
]
EOF
}

sha256sumof() {
	file="${1?unset}"
	sha256sum "${file}" | cut "--fields=1" --only-delimited --delimiter=' '
}

sha256sumfromfile() {
	shafile="${1?unset}"
	file="${2?unset}"

	echo "$(grep "${file}$" "${shafile}" || echo '')" | cut --fields=1 --only-delimited --delimiter=' '
}

gen_appdata() {
	tee "${appdata_file}" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<component type="desktop">
	<id>com.betaflight.Configurator.desktop</id>
	<metadata_license>CC0-1.0</metadata_license>
	<project_license>GPL-3.0</project_license>
	<name>Betaflight Configurator</name>
	<summary>Crossplatform configuration tool for the Betaflight flight control system</summary>
	<description>
		<p>
			Betaflight Configurator is a crossplatform configuration tool for the Betaflight flight control system.
			It allows you to configure the Betaflight software running on any supported Betaflight target, as well
			as updating the firmware.
			Various types of aircraft are supported by the tool and by Betaflight, e.g. quadcopters, hexacopters, octocopters and fixed-wing aircraft.
		</p>
		<p>
			This configurator is the only configurator with support for Betaflight specific features. It will likely require that you
			run the latest firmware on the flight controller. If you are experiencing any problems please make sure you are running
			the latest firmware version.
		</p>
	</description>
	<content_rating type="oars-1.1" />
	<url type="homepage">https://github.com/betaflight/betaflight-configurator</url>
	<url type="bugtracker">https://github.com/betaflight/betaflight-configurator/issues</url>
	<url type="help">https://github.com/betaflight/betaflight/wiki/Installing-Betaflight#platform-specific-linux</url>
	<url type="donation">https://patreon.com/betaflight/</url>
	<screenshots>
		<screenshot type="default">https://people.gnome.org/~alexl/betaflight-screenshot-1.png</screenshot>
		<screenshot>https://people.gnome.org/~alexl/betaflight-screenshot-2.png</screenshot>
		<screenshot>https://people.gnome.org/~alexl/betaflight-screenshot-3.png</screenshot>
	</screenshots>
	<releases>
		<release version="${app_version}" date="$(date "+%Y-%m-%d")"/>
	</releases>
	<categories>
		<category>Utility</category>
	</categories>
</component>
EOF
	echo
	appdata_sha256sum="$(sha256sumof "${appdata_file}")"
	tee "${src_appdata}" <<EOF
[
	{
		"type": "file",
		"path": "${appdata_file}",
		"sha256": "${appdata_sha256sum}"
	}
]
EOF
}

cleanup() {
	rm --recursive --force "${tmp_path}"
}

main() {
	set -e
	count="1"
	echo "[${count}] Check for dependencies"
	check_deps
	count="$(( count+1 ))"
	echo "[${count}] Creating temporary directory"
	mktemp_path
	trap cleanup EXIT TERM INT
	count="$(( count+1 ))"
	echo "[${count}] Remove current sources"
	remove_sources
	count="$(( count+1 ))"
	echo "[${count}] Generate Betaflight Configurator sources (${src_app})"
	gen_app_src
	count="$(( count+1 ))"
	echo "[${count}] Update XML Appdata ${appdata_file}"
	gen_appdata
	count="$(( count+1 ))"
	echo "[${count}] Cleanup garbage"
	cleanup
}

main
