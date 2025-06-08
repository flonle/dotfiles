#!/bin/bash

#WALLPAPER_DIR="$HOME/wallpapers/walls"
#menu() {
    #find "${WALLPAPER_DIR}" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.gif" \) | awk '{print "img:"$0}'
#}

    #choice=$(menu | wofi -c ~/.config/wofi/wallpaper -s ~/.config/wofi/style-wallpaper.css --show dmenu --prompt "Select Wallpaper:" -n)
    #selected_wallpaper=$(echo "$choice" | sed 's/^img://')
    #swww img "$selected_wallpaper" --transition-type any --transition-fps 60 --transition-duration .5
    hyprctl hyprpaper reload ,"$1"
    wal -i "$1" --cols16
    swaync-client --reload-css
    #cat ~/.cache/wal/colors-kitty.conf > ~/.config/kitty/current-theme.conf
    pywalfox update
    #color1=$(awk 'match($0, /color2=\47(.*)\47/,a) { print a[1] }' ~/.cache/wal/colors.sh)
    #color2=$(awk 'match($0, /color3=\47(.*)\47/,a) { print a[1] }' ~/.cache/wal/colors.sh)
    #cava_config="$HOME/.config/cava/config"
    #sed -i "s/^gradient_color_1 = .*/gradient_color_1 = '$color1'/" $cava_config
    #sed -i "s/^gradient_color_2 = .*/gradient_color_2 = '$color2'/" $cava_config
    #pkill -USR2 cava 2>/dev/null
    #source ~/.cache/wal/colors.sh && cp -r "$1" ~/wallpapers/pywallpaper.jpg 

