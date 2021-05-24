#! /usr/bin/env sh
# Script that updates the source files required by betaflgith to be downloaded for flatpaks offline build

btfl_repo="https://github.com/betaflight/betaflight-configurator.git"
btfl_version="10.7.0"

# Fallback version to use if version could not be extracted from sources
nwjs_i386_fallback_version="0.44.2"
nwjs_amd64_fallback_version="${nwjs_i386_fallback_version}"
nwjs_armv7_fallback_version="0.27.6"

node_generator="flatpak-builder-tools/node/flatpak-node-generator.py"
builder_tools="${node_generator}"

xml_appdata_file="com.betaflight.Configurator.appdata.xml"

src_btfl="src-btfl.json"
src_yarnpkg="src-yarnpkg.json"
src_nodejspkgs="src-nodejspkgs.json"
src_nwjs="src-nwjs.json"
src_appdata="src-appdata.json"

generated_files="${src_btfl} ${src_yarnpkg} ${src_nodejspkgs} ${src_appdata} ${xml_appdata_file}"

here="$(cd "$(dirname "${0}")" && pwd)"

btfl_gitfile="${btfl_repo##*/}"
btfl_dirname="${btfl_gitfile%%.*}"

check_deps() {
	unset error
	deps="python git mktemp wget sha256sum sed rm tee dirname cat"

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

check_submodule() {
	unset error
	for i in ${builder_tools}; do
		if [ ! -f "${here}/submodules/${i}" ]; then
			echo "Error: 'submodules/${i}' missing" 1>&2
			error="true"
		fi
	done

	if [ -n "${error}" ]; then
		echo "Did you initialize the git submodules?" 1>&2
		echo "'git submodule init' 'git submodule update'" 1>&2
		exit 1
	fi
}

clone_repo() {
	tmp_path="$(mktemp --directory)"
	git -C "${tmp_path}" clone "${btfl_repo}" 
	git -C "${tmp_path}/${btfl_dirname}" checkout "tags/${btfl_version}"
	btfl_commit="$(git -C "${tmp_path}/${btfl_dirname}" log --max-count=1 --pretty="format:%H")"
	btfl_date="$(git -C "${tmp_path}/${btfl_dirname}" log --max-count=1 --pretty="format:%ct")"
}

remove_sources() {
	rm --verbose --force ${generated_files}
}

gen_btfl_src() {
	tee "${src_btfl}" <<EOF
[ 
	{
		"type": "git",
		"url": "${btfl_repo}",
		"tag": "${btfl_version}",
		"commit": "${btfl_commit}",
		"dest": "${btfl_dirname}"
	}
]
EOF
}

gen_yarnpkg_src() {
	yarnpkg_version="$(sed -z 's/.*\nyarn@[\^~]\([0-9.-]*\)[:,]\n.*/\1/g' "${tmp_path}/${btfl_dirname}/yarn.lock")"
	yarnpkg_file="yarn-v${yarnpkg_version}.tar.gz"
	yarnpkg_url="https://github.com/yarnpkg/yarn/releases/download/v${yarnpkg_version}/${yarnpkg_file}"
	wget --directory-prefix "${tmp_path}" "${yarnpkg_url}"
	yarnpkg_sha256sum="$(sha256sumof "${tmp_path}/${yarnpkg_file}")"
	tee "${src_yarnpkg}" <<EOF
[ 
	{
		"type": "archive",
		"url": "${yarnpkg_url}",
		"sha256": "${yarnpkg_sha256sum}",
		"dest": "yarnpkg"
	}
]
EOF
}

gen_nodejs_src() {
	"${here}/submodules/${node_generator}" -o "${here}/${src_nodejspkgs}" yarn "${tmp_path}/${btfl_dirname}/yarn.lock"
	cat "${here}/${src_nodejspkgs}"
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

nwjs_make_url_i386() {
	version="${1?unset}"
	nwjs_i386_file="nwjs-v${version}-linux-ia32.tar.gz"
	nwjs_i386_url="https://dl.nwjs.io/v${version}/${nwjs_i386_file}"
}

nwjs_make_url_amd64() {
	version="${1?unset}"
	nwjs_amd64_file="nwjs-v${version}-linux-x64.tar.gz"
	nwjs_amd64_url="https://dl.nwjs.io/v${version}/${nwjs_amd64_file}"
}

nwjs_make_url_armv7() {
	version="${1?unset}"
	nwjs_armv7_file="nwjs-v${version}-linux-arm.tar.gz"
	nwjs_armv7_url="https://github.com/LeonardLaszlo/nw.js-armv7-binaries/releases/download/v${version}/${nwjs_armv7_file}"
}

nwjs_make_url_sha256sum() {
	version="${1?unset}"
	echo "https://dl.nwjs.io/v${version}/SHASUMS256.txt"
}

nwjs_get_file() {
	url="${1?unset}"
	filename="${2?unset}"
	wget "${url}" -O "${tmp_path}/${filename}"
	return "${?}"
}

gen_nwjs_src() {
	nwjs_armv7_version="$(grep '^\(const\|var\) nwArmVersion = ' "${tmp_path}/${btfl_dirname}/gulpfile.js" | sed "s/^\(const\|var\) nwArmVersion = '\([0-9.-]*\)'.*/\2/g")"
	nwjs_i386_version="$(sed -z "s/.*\(const\|var\) nwBuilderOptions[^v]*version: '\([0-9.-]*\)'.*/\2/g" "${tmp_path}/${btfl_dirname}/gulpfile.js")"
	nwjs_amd64_version="${nwjs_i386_version}"

	nwjs_make_url_i386 "${nwjs_i386_version}"
	nwjs_i386_url_sha256sum="$(nwjs_make_url_sha256sum "${nwjs_i386_version}")"
	nwjs_make_url_amd64 "${nwjs_amd64_version}"
	nwjs_amd64_url_sha256sum="$(nwjs_make_url_sha256sum "${nwjs_amd64_version}")"
	nwjs_make_url_armv7 "${nwjs_armv7_version}"
	if ! nwjs_get_file "${nwjs_i386_url_sha256sum}" "${nwjs_i386_file}.sha256sum"; then
		echo "Warning: failed to get version of NW.js for i386, using fallback version '${nwjs_i386_fallback_version}'"
		nwjs_i386_version="${nwjs_i386_fallback_version}"
		nwjs_make_url_i386 "${nwjs_i386_version}"
		nwjs_i386_url_sha256sum="$(nwjs_make_url_sha256sum "${nwjs_i386_version}")"
		nwjs_get_file "${nwjs_i386_url_sha256sum}" "${nwjs_i386_file}.sha256sum"
	fi
	nwjs_i386_sha256sum="$(sha256sumfromfile "${tmp_path}/${nwjs_i386_file}.sha256sum" "${nwjs_i386_file}")"

	if ! nwjs_get_file "${nwjs_amd64_url_sha256sum}" "${nwjs_amd64_file}.sha256sum"; then
		echo "Warning: failed to get version of NW.js for x86_64, using fallback version '${nwjs_amd64_fallback_version}'"
		nwjs_amd64_version="${nwjs_amd64_fallback_version}"
		nwjs_make_url_amd64 "${nwjs_amd64_version}"
		nwjs_amd64_url_sha256sum="$(nwjs_make_url_sha256sum "${nwjs_amd64_version}")"
		nwjs_get_file "${nwjs_amd64_url_sha256sum}" "${nwjs_amd64_file}.sha256sum"
	fi
	nwjs_amd64_sha256sum="$(sha256sumfromfile "${tmp_path}/${nwjs_amd64_file}.sha256sum" "${nwjs_amd64_file}")"

	if ! nwjs_get_file "${nwjs_armv7_url}" "${nwjs_armv7_file}"; then
		echo "Warning: failed to get version of NW.js for arm, using fallback version '${nwjs_armv7_fallback_version}'"
		nwjs_armv7_version="${nwjs_armv7_fallback_version}"
		nwjs_make_url_armv7 "${nwjs_armv7_version}"
		nwjs_get_file "${nwjs_armv7_url}" "${nwjs_armv7_file}"
	fi
	nwjs_armv7_sha256sum="$(sha256sumof "${tmp_path}/${nwjs_armv7_file}")"

	tee "${src_nwjs}" <<EOF
[ 
	{
		"type": "archive",
		"only-arches": ["i386"],
		"url": "${nwjs_i386_url}",
		"sha256": "${nwjs_i386_sha256sum}",
		"dest": "betaflight-configurator/cache/${nwjs_i386_version}-normal/linux32"
	},
	{
		"type": "archive",
		"only-arches": ["x86_64"],
		"url": "${nwjs_amd64_url}",
		"sha256": "${nwjs_amd64_sha256sum}",
		"dest": "betaflight-configurator/cache/${nwjs_amd64_version}-normal/linux64"
	},
	{
		"type": "archive",
		"only-arches": ["arm"],
		"url": "${nwjs_armv7_url}",
		"sha256": "${nwjs_armv7_sha256sum}",
		"dest": "betaflight-configurator/cache/${nwjs_armv7_version}-normal/linux32"
	}
]
EOF
}

gen_appdata() {
	tee "${xml_appdata_file}" <<EOF
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
  <url type="homepage">https://github.com/betaflight/betaflight/wiki</url>
  <screenshots>
    <screenshot type="default">https://people.gnome.org/~alexl/betaflight-screenshot-1.png</screenshot>
    <screenshot>https://people.gnome.org/~alexl/betaflight-screenshot-2.png</screenshot>
    <screenshot>https://people.gnome.org/~alexl/betaflight-screenshot-3.png</screenshot>
  </screenshots>
  <releases>
    <release version="${btfl_version}" date="$(date --date="@${btfl_date}" "+%Y-%m-%d")"/>
  </releases>
  <categories>
    <category>Utility</category>
  </categories>
</component>
EOF
	echo
	appdata_sha256sum="$(sha256sumof "${xml_appdata_file}")"
	tee "${src_appdata}" <<EOF
[ 
	{
		"type": "file",
		"path": "com.betaflight.Configurator.appdata.xml",
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
	unset count
	echo "[$(( ++count ))] Check for dependencies"
	check_deps
	echo "[$(( ++count ))] Check for submodules"
	check_submodule
	echo "[$(( ++count ))] Clone ${btfl_gitfile} repository to tmp directory"
	trap cleanup EXIT TERM INT
	clone_repo
	echo "[$(( ++count ))] Remove current sources"
	remove_sources
	echo "[$(( ++count ))] Generate ${btfl_dirname} sources (${src_btfl})"
	gen_btfl_src
	echo "[$(( ++count ))] Generate yarnpkg sources (${src_yarnpkg})"
	gen_yarnpkg_src
	echo "[$(( ++count ))] Generate nodejs package sources (${src_nodejspkgs})"
	gen_nodejs_src
	echo "[$(( ++count ))] Generate NW.js sources (${src_nwjs})"
	gen_nwjs_src
	echo "[$(( ++count ))] Update XML Appdata ()"
	gen_appdata
	echo "[$(( ++count ))] Cleanup garbage"
	cleanup
}

main
