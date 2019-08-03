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
    getDepends libsdl2-dev libsdl2-mixer-dev libsdl2-net-dev zlib1g-dev libsdl1.2-dev libsdl-mixer1.2-dev libsdl-net1.2-dev
}

function sources_ecwolf() {
    downloadAndExtract "https://bitbucket.org/ecwolf/ecwolf/get/5065aaefe055.zip"
    mv ecwolf-ecwolf-5065aaefe055 ecwolf
}

function build_ecwolf() {
    cd ecwolf
    #### Patch: better use applyPatch??
    wget -N -q https://raw.githubusercontent.com/crcerror/ECWolf-RPI/master/ecwolf_keyboardpatch.diff
    patch -p0 -i ecwolf_keyboardpatch.diff
    #### Patch: better use applyPatch??
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
    if [[ -z $(ls "$romdir/ports/wolf3d") ]]; then
        cd "$__tmpdir"
        # Get shareware game data of Wolfenstein 3D and Spear of Destiny
        downloadAndExtract "http://maniacsvault.net/ecwolf/files/shareware/wolf3d14.zip" "$romdir/ports/wolf3d"
        downloadAndExtract "http://maniacsvault.net/ecwolf/files/shareware/soddemo.zip" "$romdir/ports/wolf3d"
    fi
}

function _add_games_ecwolf(){
    local ecw_bin="$1"
    local ext path game

    declare -A games=(
        ['wl1']="Wolfenstein 3D (demo)"
        ['wl6']="Wolfenstein 3D"
        ['sod']="Wolfenstein 3D - Spear of Destiny"
        ['sd1']="Wolfenstein 3D - Spear of Destiny"
        ['sdm']="Wolfenstein 3D - Spear of Destiny (demo)"
        ['n3d']="Wolfenstein 3D - Super Noahâ€™s Ark 3D"
        ['sd2']="Wolfenstein 3D - SoD MP2 - Return to Danger"
        ['sd3']="Wolfenstein 3D - SoD MP3 - Ultimate Challenge"
    )
    
    pushd "$romdir/ports/wolf3d" #Needed for the find command! Do not remove!
    for game in "${!games[@]}"; do
        ecw=$(find . -iname "*.$game" -print -quit)   #-print -quit finish after first hit
        [[ -n "$ecw" ]] || continue                   # try next file extension
        ext="${ecw##*.}"                              # Obtain extension in correct format
        path="${ecw%/*}"; path="${path#*/}"

        #Adding shell files
        addPort "$md_id" "ecwolf" "${games[$game]}" "pushd $romdir/ports/wolf3d; bash %ROM%; popd" "$romdir/ports/wolf3d/${games[$game]}.ecwolf"
        #Preparing .ecwolf files
        _add_ecwolf_files_ecwolf "$romdir/ports/wolf3d/${games[$game]}.ecwolf" "$path" "$ext" "$ecw_bin"
    done
    popd
}

function _add_ecwolf_files_ecwolf() {
cat >"$1" <<_EOF_
cd "$2"
"$4" --data $3
wait \$!
_EOF_
}

function add_games_ecwolf() {
    _add_games_ecwolf "$md_inst/ecwolf"
}

function configure_ecwolf() {
    mkRomDir "ports/wolf3d"

    moveConfigDir "$home/.local/share/ecwolf" "$md_conf_root/ecwolf"
    moveConfigDir "$home/.config/ecwolf" "$md_conf_root/ecwolf"

    # Check if some wolfenstein files are present and upload shareware files
    [[ "$md_mode" == "install" ]] && game_data_ecwolf
    # Configure present files
    [[ "$md_mode" == "install" ]] && add_games_ecwolf
    # Change permission of all files in wolf3d dir to std. user
    chown -R $user:$user "$romdir/ports/wolf3d"
}
