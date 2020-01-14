#!/bin/bash

ROOT="$(git rev-parse --show-toplevel)"

LIBRETRO_CORES_SH_DIR="${ROOT}/retropie/scriptmodules/libretrocores"
LIBRETRO_CORES_BB_DIR="${ROOT}/results"

WORKDIR="${ROOT}/workdir"
mkdir -p ${WORKDIR}

function append_line() {
	local file=${1}
	local line=${2}
	echo -e "${line}" >> ${file}
}

pushd ${LIBRETRO_CORES_SH_DIR}
	for file in `find . -iname \*.sh`; do
		source ${file}
		name=${file##*lr-}
		name=${name%*.sh}
		license_url=${rp_module_licence##* }
		
		repo=`grep ${file} -e 'gitPullOrClone'`
		repo="${repo##*https://}"
		repo="${repo%% *}"
		echo ${repo}
		
		license_file="${WORKDIR}/license-${name}"
		[ ! -f ${license_file} ] && wget -O "" "${license_url}"
		license_md5=`md5sum ${license_file}`
		license_md5=${license_md5%% *}
		
		[[ -z ${repo} ]] && continue
		

		mkdir -p ${LIBRETRO_CORES_BB_DIR}/${name}-libretro
		recipe="${LIBRETRO_CORES_BB_DIR}/${name}-libretro/${name}-libretro.bb"
		echo -n > ${recipe}
		append_line ${recipe} "DESCRIPTION = \"${rp_module_desc}\"\n"
		append_line ${recipe} "LICENSE = \"${rp_module_licence%% *}\""
		append_line ${recipe} "LIC_FILES_CHKSUM = \"file://${rp_module_licence##*/};md5sum=${license_md5}\"\n"
		append_line ${recipe} "PR = \"r1\"\n"
		append_line ${recipe} "inherit libretro\n"
		append_line ${recipe} "S = \"\${WORKDIR}/git\""
		append_line ${recipe} "SRC_URI = \"gitsm://${repo};protocol=https\""
		append_line ${recipe} "SRCREV = \"\${AUTOREV}\""
		
		
	done
popd


