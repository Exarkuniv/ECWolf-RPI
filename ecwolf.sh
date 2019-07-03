#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="ecwolf"
rp_module_desc="ECWolf - ECWolf is an advanced source port for Wolfenstein 3D, Spear of Destiny, and Super 3D Noah's Ark based off of the Wolf4SDL code base. It also supports mods from .pk3 files."
rp_module_licence="GPL2 https://bitbucket.org/ecwolf/ecwolf/raw/5065aaefe055bff5a8bb8396f7f2ca5f2e2cab27/docs/license-gpl.txt"
rp_module_help="For registered version, replace the shareware files by adding your full Wolf3d 1.4 version game files to $romdir/ports/wolf3d/."
rp_module_section="exp"
rp_module_flags=""

function depends_ecwolf() {
    getDepends g++ make cmake libsdl2-dev libsdl2-mixer-dev libsdl2-net-dev mercurial zlib1g-dev libbz2-dev libjpeg-dev libgtk2.0-dev libsdl1.2-dev libsdl-mixer1.2-dev libsdl-net1.2-dev
}

function sources_ecwolf() {
    hg clone https://bitbucket.org/ecwolf/ecwolf
}

function build_ecwolf() {
    cd ecwolf
    cmake . -DCMAKE_BUILD_TYPE=Release -DGPL=ON
    make
}

function install_ecwolf() {
    md_ret_files=(
       'ecwolf/ecwolf'
       'ecwolf/ecwolf.pk3'
    )
}

function game_data_ecwolf() {
    pushd "$romdir/ports/wolf3d"
    rename 'y/A-Z/a-z/' *
    popd
    if [[ ! -f "$romdir/ports/wolf3d/vswap.wl6" && ! -f "$romdir/ports/wolf3d/vswap.wl1" ]]; then
        cd "$__tmpdir"
        # Get shareware game data
        downloadAndExtract "http://maniacsvault.net/ecwolf/files/shareware/wolf3d14.zip" "$romdir/ports/wolf3d" -j -LL
    fi
    if [[ ! -f "$romdir/ports/wolf3d/vswap.sdm" && ! -f "$romdir/ports/wolf3d/vswap.sod" ]]; then
        cd "$__tmpdir"
        # Get shareware game data
        downloadAndExtract "http://maniacsvault.net/ecwolf/files/shareware/soddemo.zip" "$romdir/ports/wolf3d" -j -LL
    fi

    chown -R $user:$user "$romdir/ports/wolf3d"
}

function configure_ecwolf() {
    addPort "$md_id" "ecwolf-spear3d" "ECWolf - Spear3d" "$md_inst/ecwolf --data sdm "
    addPort "$md_id" "ecwolf-wolf3d" "ECWolf - Wolf3d" "$md_inst/ecwolf --data wl1 "

    mkRomDir "ports/wolf3d"

    moveConfigDir "$home/.local/share/ecwolf" "$md_conf_root/wolf3d"
    moveConfigDir "$home/.config/ecwolf" "$romdir/ports/wolf3d"

    [[ "$md_mode" == "install" ]] && game_data_ecwolf
}
