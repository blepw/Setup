#!/bin/bash

# shellcheck disable=SC2034
# shellcheck disable=SC2034

red="$(tput setaf 1)"
green="$(tput setaf 2)"
yellow="$(tput setaf 3)"
blue="$(tput setaf 4)"
orange="$(tput setaf 208)"
light_cyan="$(tput setaf 51)"
white="$(tput setaf 7)"
magenta="$(tput setaf 5)"
reset="$(tput setaf 0)"


os="Ubuntu"
version="25.04"
script_version="2"


banner() {
       echo "${white}
    ___  ____  ____  _  _  ____
  / ___)(  __)(_  _)/ )( \(  _ \\
  \___ \ ) _)   )(  ) \/ ( ) __/
  (____/(____) (__) \____/(__)

   Version :${orange} ${os} ${version}${reset}
   ${white}Script version :${orange} ${script_version}

${reset}"
}


sudo_check() {
    if [ "${EUID}" -ne 0 ]; then
        echo "${white}[${red}!${white}] ${red}Run this as root"
        exit
    else
        echo "${blue}[${green}*${blue}] Root."
        return 0
    fi
}


check() {
    echo "${blue}[${yellow}!${blue}] ${white}Checking required packages... ${reset}"

    declare -A packages=(
        [git]="git"
        [snap]="snapd"
        [fish]="fish"
    )

    for cmd in "${!packages[@]}"; do
        if command -v "$cmd" &> /dev/null; then
            echo "${blue}[${green}+${blue}]${magenta} $cmd ${white}is already installed."
        else
            echo "${white}[${red}!${white}] ${magenta}$cmd ${white} not found. Installing ${packages[$cmd]}..."
            sudo apt update -y
            sudo apt install -y "${packages[$cmd]}"
            if [[ "$cmd" == "snap" ]]; then
                sudo systemctl enable --now snapd
            fi
        fi
    done

    echo "${blue}[${green}+${blue}] ${white}All required programs checked. ${reset}"
}


internet_connection() {
    ping -c 1 8.8.8.8 > /dev/null 2>&1
    if [ $? -eq 0 ]; then
        echo "${blue}[${green}+${blue}] Connected to the internet ${reset}"
    else
        echo "${white}[${red}!${white}] No internet connection ${reset}"
        exit 1
    fi
}

bashrc_configs() {
    FISH_CONFIG="$HOME/.config/fish/functions/fish_prompt.fish"
    mkdir -p "$(dirname "$FISH_CONFIG")"
    cat > "$FISH_CONFIG" <<'EOF'
function fish_prompt

    # Time in [HH:MM:SS]
    set -l time_str (set_color white)"["(set_color cyan)(date "+%H:%M:%S")(set_color white)"]"(set_color normal)

    # Username@host
    set -l user (whoami)
    set -l host (hostname | cut -d. -f1)
    set -l userhost (set_color blue)$user(set_color normal)"@"(set_color white)$host(set_color normal)

    # Directory (~ for home) in blue
    set -l cwd (set_color blue)(prompt_pwd)(set_color normal)

    set BLUE (set_color blue)
    set RESET (set_color normal)

    # ASCII art in blue
    echo -e "$BLUE"
    echo """
⢠⣴⣾⣿⣿⣶⣶⣤⣀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀ ⠀ ⠀⠀⠀⠀⠀                 ⠀⠀⠀⠀⠀⣀⣤⣶⣶⣿⣿⣷⣦⡄
⠀⠉⠻⣿⣿⣿⣿⡟⠛⠷⣦⣀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣀⣴⠾⠛⢻⣿⣿⣿⣿⠟⠉⠀
⠀⠀⠀⠈⢻⣿⣿⣿⠀⠀⠈⠙⠳⢦⡀⠀⠀⠀⠀⠀⠀⠀⡎⢱ ⡀ ⢀ ⡇ ⢎⡑ ⣏⡉ ⡎⠑     ⠀⣀⡴⠞⠋⠁⠀⠀⣿⣿⣿⡟⠁⠀⠀⠀
⠀⠀⠀⠀⠀⢻⣿⣿⡄⠀⠀⠀⠀⠀⠈⠑⠂⠀⠀⠀⠀⠀⠣⠜ ⠱⠱⠃ ⠣ ⠢⠜ ⠧⠤ ⠣⠔⠀⠀ ⠀⠐⠊⠁⠀⠀⠀⠀⠀⢠⣿⣿⡟⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⡀⢹⣿⡇⠀⠀⠀⠀⠀⠀⠀⠀⣄⠀⠀                     ⠀⣠⠄⠀⠀⠀⠀⠀⠀⠀⢸⣿⡏⢀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠘⢷⣿⣷⠀⠀⠀⠀⠀⠀⠀⠀⠈⠻⢶⣤⣄⣀⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣀⣠⣤⡶⠟⠁⠀⠀⠀⠀⠀⠀⠀⠀⣾⣿⡾⠃⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⣌⣻⣿⣇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠉⠛⠿⢿⣿⣿⣷⣶⣶⣶⣶⣶⣶⣾⣿⣿⣿⠿⠛⠉⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣸⣿⣟⡡⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⢸⣿⣿⢿⣆⠀⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠉⠛⠿⣿⣿⣿⣿⠿⠛⠉⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⠀⣰⡿⣿⣿⡇⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⢀⣾⣿⠏⠀⢻⣷⣿⣄⠀⠀⠀⠀⠠⣀⠀⠀⢀⠀⠀⠀⠀⠀⠀⠙⠋⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⠄⠀⠀⠀⠀⣠⣿⣾⡟⠀⠹⣿⣷⡀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⢀⣾⣿⠏⠀⠀⠀⠙⠿⣿⣷⣦⣄⡀⠀⠈⠑⢦⣬⣦⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣴⣥⡴⠊⠁⠀⢀⣠⣴⣾⣿⠿⠋⠀⠀⠀⠹⣿⣷⡀⠀⠀⠀⠀
⠀⠀⠀⠀⣾⣿⠃⠀⠀⠀⠲⠶⠿⣿⣿⠿⠟⠛⠲⠄⠀⠐⠺⢿⣿⣶⣄⠀⠀⠀⠀⠀⠀⣠⣴⣿⡿⠗⠂⠀⠠⠖⠛⠻⠿⣿⣿⠿⠶⠖⠀⠀⠀⠘⣿⣷⠀⠀⠀⠀
⠀⠀⠀⢰⣿⠃⠀⠀⣠⠂⠀⠠⠚⢉⣤⣶⣿⣿⣿⣿⣶⣄⡀⠀⠈⠙⠻⣿⣶⣶⣶⣶⣿⠿⠛⠁⠀⢀⣤⣶⣿⣿⣿⣿⣶⣤⡉⠓⠄⠀⠐⢄⠀⠀⠘⣿⡆⠀⠀⠀
⠀⠀⠀⢸⠇⠀⢀⣾⠁⠀⠀⠀⠀⠻⣿⡿⠋⢡⣿⣿⠟⢿⣷⡄⠀⠀⣄⢀⠙⠿⡿⠋⡁⢠⠀⠀⢠⣾⣿⣿⡿⠻⡌⠙⢿⣿⠟⠀⠀⠀⠀⠈⢷⡄⠀⢸⡇⠀⠀⠀
⠀⠀⠀⢸⠀⠀⣼⣷⠀⠀⠀⠀⠀⠀⠸⣇⠀⠸⣿⣿⣷⡾⠙⢿⡄⠀⠈⠳⣷⣤⣤⣾⡞⠁⠀⢠⡿⠉⢿⣿⣿⣾⠇⠀⣸⠇⠀⠀⠀⠀⠀⠀⣾⣷⠀⠀⡇⠀⠀⠀
⠀⠀⠀⢸⠀⠀⣸⡟⠀⠀⠀⠀⠀⠀⠀⠹⣄⠀⠈⠉⠉⣀⣴⣿⡷⠀⠀⠀⠈⠛⠛⠁⠀⠀⠀⢿⣿⣦⣀⠉⠉⠁⠀⣰⠏⠀⠀⠀⠀⠀⠀⠀⢹⣇⠀⠀⡇⠀⠀⠀
⠀⠀⠀⠸⠀⠀⣿⣿⡄⠀⠀⠀⠀⠀⠀⠀⠈⠙⠛⠋⠩⠕⠛⠁⠀⠀⠀⠀⢠⣾⠻⡄⠀⠀⠀⠀⠈⠛⠪⠍⠛⠛⠋⠁⠀⠀⠀⠀⠀⠀⠀⢀⣿⣿⠀⠀⠇⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠘⣿⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣾⣿⠀⢿⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⣿⠋⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⢸⣿⣷⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣿⣿⠀⣿⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣾⣿⡇⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠈⠘⢿⣿⣄⣄⠀⠀⠀⠀⠀⠠⠤⢤⣤⡀⠀⠀⠀⠀⠀⢸⣿⢰⡏⠀⠀⠀⠀⠀⢀⣤⡤⠤⠤⠀⠀⠀⠀⠀⢠⣄⣿⡿⠃⠁⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠠⠿⠿⠿⠶⢄⡀⠀⠀⠐⠒⠒⠾⢿⣷⣄⠀⠀⠀⠈⣿⣿⠁⠀⠀⠀⣠⣾⡿⠷⠒⠒⠂⠀⠀⢀⡠⠶⠿⠿⠿⠄⠀⠀⠀⠀⠀⠀⠀⠀⠀
 ⠀⠀⠀⠀⠀                 ⠈⠻⣷⣄⠀⠀⢹⡏⠀⠀⣠⣾⠟⠁               ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠙⢷⣦⣄⣠⣴⡾⠋⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠙⠻⠿⠋⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
"""
    echo -e "$RESET"

    # Prompt here
    echo -n -s $time_str " " $userhost " " $cwd " > "
end
EOF

    # Ensure ~/.bashrc launches fish at the end
    if ! grep -Fxq "fish" "$HOME/.bashrc"; then
        echo -e "\n# Start fish shell" >> "$HOME/.bashrc"
        echo "fish" >> "$HOME/.bashrc"
    fi

    echo "${blue}[${green}+${blue}] Fish prompt configured and .bashrc updated to launch fish. ${reset}"
}


create_dirs(){
    echo "${blue}[${yellow}!${blue}] ${white}Creating directories in home"
    mkdir -p ~/Decompile
    mkdir -p ~/github
}


appearance() {
    echo "${blue}[${yellow}!${blue}] ${white} Set Desktop background ${reset}"
    gsettings set org.gnome.desktop.background primary-color '#000000'
    gsettings set org.gnome.desktop.background color-shading-type 'solid'
    gsettings set org.gnome.desktop.background picture-uri ''
    gsettings set org.gnome.desktop.background picture-uri-dark ''

    echo "${blue}[${yellow}!${blue}] ${white} Changing dock appearance ${reset}"
    gsettings set org.gnome.shell.extensions.dash-to-dock extend-height false

    echo "${blue}[${yellow}!${blue}] ${white} Changing icon theme ${reset}"
    gsettings set org.gnome.desktop.interface icon-theme 'Yaru-blue'

    echo "${blue}[${green}+${blue}] Done ${reset}"
}

github() {
    echo "${blue}[${yellow}*${blue}] ${white}Installing rtl8192eu drivers ${reset}"
    git clone https://github.com/clnhub/rtl8192eu-linux
    cd rtl8192eu-linux/ || return
    ./install_wifi.sh
}

apps() {
    # Social apps
    echo "${blue}[${yellow}!${blue}] ${white}Installing Social apps..."
    social_apps=(
        telegram-desktop
        discord
        session-desktop
        signal-desktop
        wire
    )
    for app in "${social_apps[@]}"; do
        sudo snap install "$app"
    done

    # IDEs
    echo "${blue}[${yellow}!${blue}] ${white}Installing IDEs..."
    ide_apps=(
        "pycharm-community --classic"
        "code --classic"
        sublime-text
    )
    for ide in "${ide_apps[@]}"; do
        sudo snap install "$ide"
    done

    # Browsers
    echo "${blue}[${yellow}!${blue}] ${white}Installing Browsers..."
    browser_apps=(
        brave-browser
        chromium
    )
    for browser in "${browser_apps[@]}"; do
        sudo snap install "$browser"
    done

    # Notes/Schematics apps
    echo "${blue}[${yellow}!${blue}] ${white}Installing Notes/Schematics apps..."
    notes_apps=(
        obsidian
        joplin-desktop
        drawio
    )
    for app in "${notes_apps[@]}"; do
        sudo snap install "$app"
    done

    # Others
    echo "${blue}[${yellow}!${blue}] ${white}Installing Other apps..."
    other_apps=(
        auto-cpufreq
        qbittorrent
        torrhunt
    )
    for app in "${other_apps[@]}"; do
        sudo snap install "$app"
    done

    echo "${blue}[${green}+${blue}] ${white}All applications installed. ${reset}"

    # =================================================================================
    # Tor Browser
    echo "${blue}[${yellow}!${blue}] ${white}Installing Tor Browser...${reset}"
    sudo apt install -y torbrowser-launcher

    # Balena Etcher
    echo "${blue}[${yellow}!${blue}] ${white}Installing Balena Etcher...${reset}"
    curl -1sLf 'https://dl.cloudsmith.io/public/balena/etcher/setup.deb.sh' | sudo -E bash
    sudo apt install -y balena-etcher-electron

    # Ricochet Refresh
    echo "${blue}[${yellow}!${blue}] ${white}Installing Ricochet Refresh...${reset}"
    sudo snap install ricochet-refresh

    # MEGAsync
    echo "${blue}[${yellow}!${blue}] ${white}Installing MEGAsync (mega.nz client)...${reset}"
    wget -qO megasync.deb https://mega.nz/linux/repo/xUbuntu_24.04/amd64/megasync-xUbuntu_24.04_amd64.deb
    sudo apt install -y ./megasync.deb
    rm megasync.deb

    # Foobar2000
    echo "${blue}[${yellow}!${blue}] ${white}Installing Foobar2000...${reset}"
    sudo snap install foobar2000 --wine


    echo "${blue}[${green}+${blue}] ${white}Done! All requested apps installed."

}

install_maltego() {
    set -e

    echo "${blue}[${yellow}*${blue}] ${white}Checking Java runtime...${reset}"
    if ! command -v java &>/dev/null; then
        echo "${blue}[${yellow}!${blue}] ${white}Java not found. Installing default-jre...${reset}"
        sudo apt update -y
        sudo apt install -y default-jre
        echo "${blue}[${green}+${blue}] ${white}Java installed.${reset}"
    else
        echo "${blue}[${green}+${blue}] ${white}Java already installed: $(java -version 2>&1 | head -n1)${reset}"
    fi

    DOWNLOADS_DIR="$HOME/Downloads"
    mkdir -p "$DOWNLOADS_DIR"
    echo "${blue}[${green}+${blue}] ${white}Downloads folder ready at $DOWNLOADS_DIR${reset}"

    echo "${blue}[${yellow}*${blue}] ${white}Downloading Maltego .deb into $DOWNLOADS_DIR ...${reset}"
    MALTEGO_URL="https://maltego-downloads.s3.us-east-2.amazonaws.com/linux/Maltego.v4.6.0.deb"
    MALTEGO_DEB="$DOWNLOADS_DIR/Maltego.deb"

    wget -O "$MALTEGO_DEB" "$MALTEGO_URL"
    echo "${blue}[${green}+${blue}] ${white}Download complete: $MALTEGO_DEB${reset}"

    echo "${blue}[${yellow}*${blue}] ${white}Installing Maltego...${reset}"
    sudo apt install -y "$MALTEGO_DEB" || {
        echo "${blue}[${yellow}!${blue}] ${white}Trying dpkg + fix...${reset}"
        sudo dpkg -i "$MALTEGO_DEB" || true
        sudo apt -f install -y
    }
    echo "${blue}[${green}+${blue}] ${white}Maltego installed. You can run it with: maltego${reset}"
}


# Prerequisites
prereq() {
    echo "${blue}[${yellow}*${blue}] ${white}Installing prerequisites"
    apt-get install -y linux-headers-generic build-essential dkms git neofetch default-jdk megatools python3-tk libunwind8 libxss1 libgconf-2-4
    apt-get install -y gnome-tweaks wget terminator snapd
    apt-get install net-tools -yy

    echo "${blue}[${green}+${blue}] ${white}Done${reset}"
}


# fix
configuration() {
    echo "${blue}[${yellow}*${blue}] ${white}Setting up auto-cpufreq${reset}"

    if ! snap list | grep -q "auto-cpufreq"; then
        echo "${blue}[${yellow}!${blue}] ${white}auto-cpufreq not found. Installing...${reset}"
        sudo snap install auto-cpufreq
    else
        echo "${blue}[${yellow}!${blue}] ${white}auto-cpufreq already installed.${reset}"
    fi

    read -rp "${blue}[${yellow}?${blue}] ${white}Do you want to enable auto-cpufreq now? (y/N): ${reset}" choice
    case "$choice" in
        [Yy]*)
            echo "${blue}[${yellow}!${blue}] ${white}Enabling auto-cpufreq service...${reset}"
            sudo systemctl enable --now snap.auto-cpufreq.service.service
            ;;
        [Nn]*|"")
            echo "${blue}[${yellow}!${blue}] ${white}Skipping auto-cpufreq enable.${reset}"
            ;;
        *)
            echo "${blue}[${yellow}!${blue}] ${white}Invalid choice. Skipping.${reset}"
            ;;
    esac
}


install_resilio_sync() {
    set -e

    echo "${blue}[${yellow}*${blue}] ${white}Installing Resilio Sync...${reset}"

    echo "${blue}[${yellow}*${blue}] ${white}Adding Resilio Sync repository...${reset}"
    echo "deb http://linux-packages.resilio.com/resilio-sync/deb resilio-sync non-free" | \
        sudo tee /etc/apt/sources.list.d/resilio-sync.list >/dev/null
    echo "${blue}[${green}+${blue}] ${white}Repository added.${reset}"

    echo "${blue}[${yellow}*${blue}] ${white}Adding GPG key...${reset}"
    wget -qO - https://linux-packages.resilio.com/resilio-sync/key.asc | \
        sudo apt-key add - >/dev/null
    echo "${blue}[${green}+${blue}] ${white}GPG key added.${reset}"

    echo "${blue}[${yellow}*${blue}] ${white}Updating package list...${reset}"
    sudo apt update
    echo "${blue}[${green}+${blue}] ${white}Package list updated.${reset}"

    echo "${blue}[${yellow}*${blue}] ${white}Installing Resilio Sync...${reset}"
    sudo apt install -y resilio-sync
    echo "${blue}[${green}+${blue}] ${white}Resilio Sync installed and running.${reset}"
}



update() {
    echo "${blue}[${green}*${blue}] ${white}Updating system"
    apt-get update -y && apt-get full-upgrade -y
    echo "${blue}[${green}+${blue}] ${white}Done${reset}"
}


# ==============================================================================================

# run
sudo_check
internet_connection
check
banner

create_dirs

# installations
update
prereq
apps
install_maltego
install_resilio_sync
github

# configs
configuration
bashrc_configs
appearance

#end
update
