#!/usr/bin/env bash

# -- find .pk3 files and move into wolf3d roms folder -- #
for i in *.pk3; do
   [[ -f "$i" ]] || continue
   mv "$i" "$HOME/RetroPie/roms/ports/wolf3d"
   filenames="\"$i\" $filenames" ## Should fix globbing and prints output in quotes
done
[[ -n "$filenames" ]] || { echo "Error: No additional pk3-files found in $PWD"; sleep 10s; exit; }

# -- read user input for filename change -- #
echo What should we call the mod?
read filename
echo "Renamed mod to $filename"

# -- create .ecwolf file from users input -- #
cat > "$HOME/RetroPie/roms/ports/wolf3d/$filename.ecwolf" << EOF
cd "."
"/opt/retropie/ports/ecwolf/ecwolf" --data WL6 --file $filenames
wait \$!
EOF

# -- create runcommand.sh file from users input -- #
cat > "$HOME/RetroPie/roms/ports/$filename.sh" << EOF
#!/bin/bash
"/opt/retropie/supplementary/runcommand/runcommand.sh" 0 _PORT_ "ecwolf" "$HOME/RetroPie/roms/ports/wolf3d/$filename.ecwolf"
EOF

# -- installation message -- #
echo "$filename mod installed for ECWolf. Press enter button to continue."

read
# -- end --#
