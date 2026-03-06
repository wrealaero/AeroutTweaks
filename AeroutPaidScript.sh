#!/bin/bash

VERSION="2.3"                       
INSTALL_DIR="$HOME/.aerout"
LOCAL_SCRIPT="$INSTALL_DIR/aerout.sh"
REMOTE_SCRIPT_URL="https://raw.githubusercontent.com/wrealaero/AeroutTweaks/refs/heads/main/AeroutPaidScript.sh"
REMOTE_VERSION_URL="https://raw.githubusercontent.com/wrealaero/AeroutTweaks/refs/heads/main/version.txt"

is_pipe_install() {
    [[ ! -f "$0" ]]
}

do_install() {
    echo -e "\033[1;36mInstalling Aerout to $INSTALL_DIR ...\033[0m"
    mkdir -p "$INSTALL_DIR"
    echo -e "\033[1;33mDownloading latest version...\033[0m"
    curl -s -o "$LOCAL_SCRIPT" "$REMOTE_SCRIPT_URL"
    chmod +x "$LOCAL_SCRIPT"
    echo -e "\033[1;32mInstallation complete! Running Aerout now...\033[0m"
    exec "$LOCAL_SCRIPT" "$@"
}

check_for_updates() {
    if [[ ! -f "$LOCAL_SCRIPT" ]]; then
        return 0  
    fi

    remote_version=$(curl -s "$REMOTE_VERSION_URL" | head -1 | tr -d '[:space:]')
    if [[ -z "$remote_version" ]]; then
        return 0 
    fi

    if [[ "$remote_version" != "$VERSION" ]]; then
        echo -e "\033[1;33m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
        echo -e "\033[1;33m  A new version of Aerout is out\033[0m"
        echo -e "\033[1;37m  Current: $VERSION   →   New: $remote_version\033[0m"
        echo -e "\033[1;33m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
        read -p "Update now? (y/n): " update_choice
        if [[ "$update_choice" =~ ^[Yy]$ ]]; then
            echo -e "\033[1;34mDownloading update...\033[0m"
            cp "$LOCAL_SCRIPT" "$LOCAL_SCRIPT.bak"
            curl -s -o "$LOCAL_SCRIPT" "$REMOTE_SCRIPT_URL"
            chmod +x "$LOCAL_SCRIPT"
            echo -e "\033[1;32mUpdate complete! Restarting...\033[0m"
            exec "$LOCAL_SCRIPT" "$@"
        else
            echo -e "\033[1;33mContinuing with current version.\033[0m"
        fi
    fi
}

if is_pipe_install; then
    if [[ -f "$LOCAL_SCRIPT" ]]; then
        local_version=$(grep '^VERSION=' "$LOCAL_SCRIPT" | head -1 | cut -d'"' -f2)
        remote_version=$(curl -s "$REMOTE_VERSION_URL" | head -1 | tr -d '[:space:]')

        if [[ -n "$local_version" && "$local_version" != "$VERSION" ]]; then
            echo -e "\033[1;33m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
            echo -e "\033[1;33m  A new version of Aerout is available (v$VERSION)\033[0m"
            echo -e "\033[1;37m  Your installed version: $local_version\033[0m"
            echo -e "\033[1;33m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
            read -p "Update now? (y/n): " update_choice
            if [[ "$update_choice" =~ ^[Yy]$ ]]; then
                echo -e "\033[1;34mDownloading update...\033[0m"
                cp "$LOCAL_SCRIPT" "$LOCAL_SCRIPT.bak"
                curl -s -o "$LOCAL_SCRIPT" "$REMOTE_SCRIPT_URL"
                chmod +x "$LOCAL_SCRIPT"
                echo -e "\033[1;32mUpdate complete! Restarting...\033[0m"
                exec "$LOCAL_SCRIPT" "$@"
            else
                echo -e "\033[1;33mContinuing with current version.\033[0m"
            fi
        fi
        exec "$LOCAL_SCRIPT" "$@"
    else
        echo -e "\033[1;36m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
        echo -e "\033[1;36m  Welcome to AeroutTweaks! Would you like to install it permanently?\033[0m"
        echo -e "\033[1;37m  This will save the script to $INSTALL_DIR\033[0m"
        echo -e "\033[1;37m  and let you auto‑update in the future.\033[0m"
        echo -e "\033[1;36m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
        read -p "Install now? (y/n): " install_choice
        if [[ "$install_choice" =~ ^[Yy]$ ]]; then
            do_install "$@"
        else
            echo -e "\033[1;33mRunning Aerout once (not installed).\033[0m"
        fi
    fi
fi

type_text() {
  text="$1"
  color="$2"
  speed="${3:-0.02}"
  for (( i=0; i<${#text}; i++ )); do
    echo -ne "${color}${text:$i:1}"
    if [[ "${text:$i:1}" != " " ]]; then
      sleep "$speed"
    fi
  done
  echo -e "\033[0m"
}

is_apple_silicon() {
  [[ $(uname -m) == "arm64" ]]
}

get_mac_version() {
  sw_vers -productVersion
}

confirm_action() {
  local action="$1"
  local warning="$2"
  if [[ -n "$warning" ]]; then
    echo -e "\033[1;31mWARNING: $warning\033[0m"
  fi
  read -p "Continue? (y/n): " confirm
  [[ "$confirm" =~ ^[Yy]$ ]]
}

backup_settings() {
  local backup_dir="$HOME/.aerout_backups"
  mkdir -p "$backup_dir"
  
  if [[ ! -f "$backup_dir/dock_settings.bak" ]]; then
    defaults read com.apple.dock > "$backup_dir/dock_settings.bak" 2>/dev/null
  fi
  
  if [[ ! -f "$backup_dir/power_settings.bak" ]]; then
    pmset -g > "$backup_dir/power_settings.bak"
  fi
  
  if [[ ! -f "$backup_dir/network_settings.bak" ]]; then
    networksetup -getdnsservers Wi-Fi > "$backup_dir/network_settings.bak"
  fi
  
  echo -e "\033[1;32mSettings saved to $backup_dir\033[0m"
}

intro() {
  clear
  echo -e "\033[1;35m
   █████╗ ███████╗██████╗  ██████╗ ██╗   ██╗████████╗
  ██╔══██╗██╔════╝██╔══██╗██╔═══██╗██║   ██║╚══██╔══╝
  ███████║█████╗  ██████╔╝██║   ██║██║   ██║   ██║
  ██╔══██║██╔══╝  ██╔══██╗██║   ██║██║   ██║   ██║
  ██║  ██║███████╗██║  ██║╚██████╔╝╚██████╔╝   ██║
  ╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝ ╚═════╝  ╚═════╝    ╚═╝
  \033[0m"
  echo -e "\033[1;35m═══════════════════════════════════════════════════════\033[0m"
  type_text "              AEROUT V${VERSION} - FREE VERSION" "\033[1;36m" 0.01
  echo -e "\033[1;35m═══════════════════════════════════════════════════════\033[0m"
  sleep 0.5
  type_text "Making your Mac run faster and better" "\033[1;33m" 0.03
  sleep 0.5
  type_text "Safe changes that work on any Mac" "\033[1;32m" 0.03
  sleep 1
  echo -e "\033[1;36mTip: Close other apps to get the best speed\033[0m"
  sleep 2

  backup_settings
}

main_menu() {
  clear
  local mac_version=$(get_mac_version)
  local cpu_type=$(is_apple_silicon && echo "Apple Silicon" || echo "Intel")
  
  echo -e "\033[1;35m═══════════════════════════════════════════════\033[0m"
  echo -e "\033[1;36m           AEROUT V${VERSION} FREE MENU \033[0m"
  echo -e "\033[1;35m═══════════════════════════════════════════════\033[0m"
  echo -e "\033[1;37m     Mac: macOS $mac_version | CPU: $cpu_type\033[0m"
  echo -e "\033[1;35m═══════════════════════════════════════════════\033[0m"
  echo -e "\033[1;33m[1]  Clean System           \033[1;37m- Get more space and speed\033[0m"
  echo -e "\033[1;34m[2]  Speed Up Internet      \033[1;37m- Faster web and games\033[0m"
  echo -e "\033[1;32m[3]  Smoother Mac           \033[1;37m- Makes your Mac run nicer\033[0m"
  echo -e "\033[1;35m[4]  Save Battery           \033[1;37m- Use less power\033[0m"
  echo -e "\033[1;31m[5]  High Performance       \033[1;37m- More power for big tasks\033[0m"
  echo -e "\033[1;36m[6]  Game Mode              \033[1;37m- Make your game run better\033[0m"
  echo -e "\033[1;33m[7]  Undo Tweaks            \033[1;37m- Go back to normal settings\033[0m"
  echo -e "\033[1;31m[8]  Exit\033[0m"
  echo -e "\033[1;35m═══════════════════════════════════════════════\033[0m"
  echo -ne "\033[1;36m Choose a number (1-8): \033[0m"
  read -r choice
  
  case "$choice" in
    1) clean_cache ;;
    2) network_menu ;;
    3) ui_tweaks ;;
    4) battery_optimizer ;;
    5) performance_boost ;;
    6) game_optimizer ;;
    7) revert_changes ;;
    8) exit_safe ;;
    *) echo -e "\033[1;31m Not a valid choice. Try again.\033[0m"; sleep 1; main_menu ;;
  esac
}

clean_cache() {
  clear
  echo -e "\033[1;35m═══════════════════════════════════════════════\033[0m"
  echo -e "\033[1;36m          SYSTEM CLEANER \033[0m"
  echo -e "\033[1;35m═══════════════════════════════════════════════\033[0m"

  local initial_space=$(df -h / | awk 'NR==2 {print $4}')
  
  echo -e "\033[1;34m[1]  Quick Clean - Fast and safe\033[0m"
  echo -e "\033[1;33m[2]  Deep Clean - Clears more space (needs your password)\033[0m"
  echo -e "\033[1;31m[3]  Clean Browsers - Chrome, Safari, Firefox\033[0m"
  echo -e "\033[1;32m[4]  Back to Menu\033[0m"
  echo -ne "\033[1;36m Pick an option (1-4): \033[0m"
  read -r cache_choice

  
  case "$cache_choice" in
    1)
      echo -e "\033[1;34m Cleaning up...\033[0m"
      if confirm_action "Clean temporary files" "This is safe and won't delete anything important"; then
        rm -rf ~/Library/Caches/* 2>/dev/null
        rm -rf ~/Library/Logs/* 2>/dev/null
        rm -rf ~/Library/Saved\ Application\ State/* 2>/dev/null

        local final_space=$(df -h / | awk 'NR==2 {print $4}')
        echo -e "\033[1;32m All cleaned\033[0m"
        echo -e "\033[1;32m Space before: $initial_space | Space now: $final_space\033[0m"
      else
        echo -e "\033[1;33m Canceled\033[0m"
      fi
      ;;
    2)
      echo -e "\033[1;33m Doing a deep clean...\033[0m"
      if confirm_action "Deep clean" "You'll need your password to clean more system stuff"; then
        rm -rf ~/Library/Caches/* 2>/dev/null
        rm -rf ~/Library/Logs/* 2>/dev/null
        rm -rf ~/Library/Saved\ Application\ State/* 2>/dev/null

        find ~/Library/Containers -name "*.Trash" -type d -exec rm -rf {} \; 2>/dev/null
        find ~/Library/Application\ Support -name "Caches" -type d -exec rm -rf {}/* \; 2>/dev/null

        sudo rm -rf /Library/Caches/* 2>/dev/null
        sudo rm -rf /private/var/log/asl/*.asl 2>/dev/null

        local final_space=$(df -h / | awk 'NR==2 {print $4}')
        echo -e "\033[1;32m Deep clean done\033[0m"
        echo -e "\033[1;32m Space before: $initial_space | Space now: $final_space\033[0m"
      else
        echo -e "\033[1;33m Canceled\033[0m"
      fi
      ;;
    3)
      echo -e "\033[1;31m Cleaning browsers...\033[0m"
      if confirm_action "Clean browsers" "This will clear history and saved site data"; then
        if [ -d ~/Library/Caches/Google/Chrome ]; then
          rm -rf ~/Library/Caches/Google/Chrome/* 2>/dev/null
          rm -rf ~/Library/Application\ Support/Google/Chrome/Default/Cache/* 2>/dev/null
        fi

        if [ -d ~/Library/Caches/com.apple.Safari ]; then
          rm -rf ~/Library/Caches/com.apple.Safari/* 2>/dev/null
          rm -rf ~/Library/Safari/LocalStorage/* 2>/dev/null
        fi

        if [ -d ~/Library/Caches/Firefox ]; then
          rm -rf ~/Library/Caches/Firefox/Profiles/*/*.sqlite 2>/dev/null
          rm -rf ~/Library/Application\ Support/Firefox/Profiles/*/cache2/* 2>/dev/null
        fi

        local final_space=$(df -h / | awk 'NR==2 {print $4}')
        echo -e "\033[1;32m Browsers cleaned\033[0m"
        echo -e "\033[1;32m Space before: $initial_space | Space now: $final_space\033[0m"
      else
        echo -e "\033[1;33m Canceled\033[0m"
      fi
      ;;
    4)
      main_menu
      return
      ;;
    *)
      echo -e "\033[1;31m That's not a valid option. Try again\033[0m"
      ;;
  esac

  sleep 2
  clean_cache
}

network_menu() {
  clear
  echo -e "\033[1;35m═══════════════════════════════════════════════\033[0m"
  echo -e "\033[1;36m          NETWORK TURBO \033[0m"
  echo -e "\033[1;35m═══════════════════════════════════════════════\033[0m"
  
  echo -e "\033[1;34m[1]  Refresh Network       - Fix Wi-Fi issues\033[0m"
  echo -e "\033[1;33m[2]  Change DNS Server     - Make internet faster\033[0m"
  echo -e "\033[1;32m[3]  Gaming Mode           - Lower ping and better gameplay\033[0m"
  echo -e "\033[1;31m[4]  Speed Test            - Check your current speed\033[0m"
  echo -e "\033[1;36m[5]  Back to Menu\033[0m"
  echo -ne "\033[1;36m Pick an option (1-5): \033[0m"
  read -r network_choice

  case "$network_choice" in
    1) flush_dns ;;
    2) dns_menu ;;
    3) gaming_network ;;
    4) speed_test ;;
    5) main_menu; return ;;
    *) echo -e "\033[1;31m That's not a valid option. Try again\033[0m"; sleep 1; network_menu ;;
  esac

  sleep 2
  network_menu
}


flush_dns() {
  echo -e "\033[1;34m Refreshing your internet settings...\033[0m"

  sudo dscacheutil -flushcache >/dev/null 2>&1
  sudo killall -HUP mDNSResponder >/dev/null 2>&1
  echo -e "\033[1;32m Internet settings updated\033[0m"

  echo -e "\033[1;34m Checking your connection...\033[0m"
  ping -c 3 8.8.8.8
  echo -e "\033[1;32m Everything looks good. You are online\033[0m"
}

dns_menu() {
  clear
  echo -e "\033[1;35m═══════════════════════════════════════════════\033[0m"
  echo -e "\033[1;36m          PICK A DNS SERVER \033[0m"
  echo -e "\033[1;35m═══════════════════════════════════════════════\033[0m"
  echo -e "\033[1;33m[1]  Cloudflare (1.1.1.1)    - Fast and private\033[0m"
  echo -e "\033[1;33m[2]  Google (8.8.8.8)        - Very reliable\033[0m"
  echo -e "\033[1;33m[3]  Quad9 (9.9.9.9)         - Great for security\033[0m"
  echo -e "\033[1;33m[4]  AdGuard (94.140.14.14)  - Blocks ads\033[0m"
  echo -e "\033[1;33m[5]  Reset DNS              - Use your regular one\033[0m"
  echo -ne "\033[1;36m Choose one (1-5): \033[0m"
  read -r dns_choice

  case "$dns_choice" in
    1)
      sudo networksetup -setdnsservers Wi-Fi 1.1.1.1 1.0.0.1
      echo -e "\033[1;32m You're now using Cloudflare DNS\033[0m"
      ;;
    2)
      sudo networksetup -setdnsservers Wi-Fi 8.8.8.8 8.8.4.4
      echo -e "\033[1;32m You're now using Google DNS\033[0m"
      ;;
    3)
      sudo networksetup -setdnsservers Wi-Fi 9.9.9.9 149.112.112.112
      echo -e "\033[1;32m You're now using Quad9 DNS\033[0m"
      ;;
    4)
      sudo networksetup -setdnsservers Wi-Fi 94.140.14.14 94.140.15.15
      echo -e "\033[1;32m You're now using AdGuard DNS\033[0m"
      ;;
    5)
      sudo networksetup -setdnsservers Wi-Fi "Empty"
      echo -e "\033[1;32m Back to default DNS\033[0m"
      ;;
    *)
      echo -e "\033[1;31m That's not a valid option. Try again\033[0m"
      ;;
  esac

  echo -e "\033[1;34m Checking if it works...\033[0m"
  ping -c 3 google.com
}

gaming_network() {
  echo -e "\033[1;32m Getting your Mac ready for gaming\033[0m"

  if confirm_action "Game mode" "This will make your internet faster for games"; then
    echo -e "\033[1;34m Making your connection quicker...\033[0m"

    local backup_dir="$HOME/.aerout_backups"
    mkdir -p "$backup_dir"
    sysctl net.inet.tcp | grep -E 'delayed_ack|mssdflt' > "$backup_dir/network_tcp_settings.bak"

    sudo sysctl -w net.inet.tcp.delayed_ack=0 >/dev/null 2>&1
    sudo sysctl -w net.inet.tcp.mssdflt=1460 >/dev/null 2>&1

    echo -e "\033[1;34m Refreshing the network...\033[0m"
    sudo route flush >/dev/null 2>&1
    sudo dscacheutil -flushcache >/dev/null 2>&1
    sudo killall -HUP mDNSResponder >/dev/null 2>&1

    echo -e "\033[1;32m Game Mode is now ON. Enjoy lower ping\033[0m"
    echo -e "\033[1;33m This turns off when you restart your Mac\033[0m"
  else
    echo -e "\033[1;33m You chose not to turn on Game Mode\033[0m"
  fi
}

speed_test() {
  echo -e "\033[1;34mLets test your internet speed\033[0m"

  echo -e "\033[1;36mFirst, testing your ping...\033[0m"
  echo -e "\033[1;37mGoogle (8.8.8.8):\033[0m"
  ping -c 5 8.8.8.8

  echo -e "\033[1;37mCloudflare (1.1.1.1):\033[0m"
  ping -c 5 1.1.1.1

  if command -v curl &>/dev/null; then
    echo -e "\033[1;36mNow checking download and upload speeds...\033[0m"
    curl -s https://raw.githubusercontent.com/sivel/speedtest-cli/master/speedtest.py | python - --simple
  else
    echo -e "\033[1;33mSpeed test tool not found\033[0m"
    echo -e "\033[1;34mTo get full speed tests, install speedtest-cli:\033[0m"
    echo -e "\033[1;32m   brew install speedtest-cli\033[0m"
  fi
}

ui_tweaks() {
  clear
  echo -e "\033[1;35m═══════════════════════════════════════════════\033[0m"
  echo -e "\033[1;36m         MAC SMOOTHER \033[0m"
  echo -e "\033[1;35m═══════════════════════════════════════════════\033[0m"
  
  echo -e "\033[1;34m[1]  Faster Animations       - Speed up your Mac's look\033[0m"
  echo -e "\033[1;33m[2]  Better Dock             - Make your Dock snappier\033[0m"
  echo -e "\033[1;32m[3]  Faster Finder           - Browse files quicker\033[0m"
  echo -e "\033[1;31m[4]  Reset UI Settings       - Back to normal\033[0m"
  echo -e "\033[1;36m[5]  Back to Main Menu\033[0m"
  echo -ne "\033[1;36mPick an option (1-5): \033[0m"
  read -r ui_choice
  
  case "$ui_choice" in
    1) speed_animations ;;
    2) dock_tweaks ;;
    3) finder_tweaks ;;
    4) reset_ui ;;
    5) main_menu; return ;;
    *) echo -e "\033[1;31mNot a valid choice, try again\033[0m"; sleep 1; ui_tweaks ;;
  esac
  
  sleep 2
  ui_tweaks
}

speed_animations() {
  echo -e "\033[1;34mSpeeding up animations...\033[0m"
  if confirm_action "Faster animations" "Makes your Mac feel quicker"; then
    local backup_dir="$HOME/.aerout_backups"
    mkdir -p "$backup_dir"
    local timestamp
    timestamp=$(date +"%Y%m%d_%H%M%S")

    defaults read NSGlobalDomain > "$backup_dir/animation_settings_$timestamp.bak" 2>/dev/null

    defaults read com.apple.dock > "$backup_dir/dock_settings_$timestamp.bak" 2>/dev/null

    defaults write NSGlobalDomain NSWindowResizeTime -float 0.1
    defaults write com.apple.dock expose-animation-duration -float 0.15
    defaults write com.apple.dock springboard-show-duration -float 0.15
    defaults write com.apple.dock springboard-hide-duration -float 0.15

    killall Dock >/dev/null 2>&1
    killall Finder >/dev/null 2>&1

    echo -e "\033[1;32mAnimations are faster now\033[0m"
    echo -e "\033[1;33mUse 'Reset UI' to restore defaults\033[0m"
  else
    echo -e "\033[1;33mCanceled\033[0m"
  fi
}


dock_tweaks() {
  echo -e "\033[1;34mTweaking Dock...\033[0m"
  if confirm_action "Dock tweaks" "Makes Dock faster"; then
    local backup_dir="$HOME/.aerout_backups"
    mkdir -p "$backup_dir"
    local timestamp
    timestamp=$(date +"%Y%m%d_%H%M%S")
    defaults read com.apple.dock > "$backup_dir/dock_settings_$timestamp.bak" 2>/dev/null

    defaults write com.apple.dock autohide-delay -float 0
    defaults write com.apple.dock autohide-time-modifier -float 0.5
    defaults write com.apple.dock no-glass -bool true
    defaults write com.apple.dock mru-spaces -bool false

    killall Dock >/dev/null 2>&1

    echo -e "\033[1;32mDock improved\033[0m"
    echo -e "\033[1;33mUse 'Reset UI' to restore defaults\033[0m"
  else
    echo -e "\033[1;33mCanceled\033[0m"
  fi
}

finder_tweaks() {
  echo -e "\033[1;34mSpeeding up Finder...\033[0m"
  if confirm_action "Finder tweaks" "Makes file browsing faster"; then
    local backup_dir="$HOME/.aerout_backups"
    mkdir -p "$backup_dir"
    local timestamp
    timestamp=$(date +"%Y%m%d_%H%M%S")
    defaults read com.apple.finder > "$backup_dir/finder_settings_$timestamp.bak" 2>/dev/null

    defaults write com.apple.finder DisableAllAnimations -bool true
    defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false
    defaults write com.apple.finder FXPreferredViewStyle -string "Nlsv"
    defaults write com.apple.finder ShowPathbar -bool true
    defaults write com.apple.finder ShowStatusBar -bool true

    killall Finder >/dev/null 2>&1

    echo -e "\033[1;32mYour Finder is now faster\033[0m"
    echo -e "\033[1;33mUse 'Reset UI' to restore defaults\033[0m"
  else
    echo -e "\033[1;33mCanceled\033[0m"
  fi
}

reset_ui() {
  echo -e "\033[1;34mResetting UI...\033[0m"
  if confirm_action "Reset UI" "Puts everything back to normal"; then
    defaults delete NSGlobalDomain NSWindowResizeTime 2>/dev/null
    defaults delete com.apple.dock autohide-delay 2>/dev/null
    defaults delete com.apple.dock autohide-time-modifier 2>/dev/null
    defaults delete com.apple.dock expose-animation-duration 2>/dev/null
    defaults delete com.apple.dock no-glass 2>/dev/null
    defaults delete com.apple.dock mru-spaces 2>/dev/null
    defaults delete com.apple.finder DisableAllAnimations 2>/dev/null
    defaults delete com.apple.finder FXEnableExtensionChangeWarning 2>/dev/null
    defaults delete com.apple.finder FXPreferredViewStyle 2>/dev/null

    killall Dock >/dev/null 2>&1
    killall Finder >/dev/null 2>&1
    
    echo -e "\033[1;32mUI back to normal\033[0m"
  else
    echo -e "\033[1;33mCanceled\033[0m"
  fi
}

battery_optimizer() {
  clear
  echo -e "\033[1;35m═══════════════════════════════════════════════\033[0m"
  echo -e "\033[1;36m         BATTERY SAVER \033[0m"
  echo -e "\033[1;35m═══════════════════════════════════════════════\033[0m"
  
  echo -e "\033[1;34m[1] Balanced Mode          - Good mix\033[0m"
  echo -e "\033[1;33m[2] Max Battery            - Last longer\033[0m"
  echo -e "\033[1;32m[3] Performance Mode       - More power\033[0m"
  echo -e "\033[1;31m[4] Reset Power Settings   - Back to normal\033[0m"
  echo -e "\033[1;36m[5] Back to Menu\033[0m"
  echo -ne "\033[1;36mPick an option (1-5): \033[0m"
  read -r battery_choice
  
  case "$battery_choice" in
    1) balanced_power ;;
    2) max_battery ;;
    3) performance_power ;;
    4) reset_power ;;
    5) main_menu; return ;;
    *) echo -e "\033[1;31mNot a valid choice\033[0m"; sleep 1; battery_optimizer ;;
  esac
  
  sleep 2
  battery_optimizer
}

balanced_power() {
  echo -e "\033[1;34mBalanced mode...\033[0m"
  if confirm_action "Balanced mode" "Good for everyday use"; then
    local backup_dir="$HOME/.aerout_backups"
    mkdir -p "$backup_dir"
    pmset -g > "$backup_dir/power_settings.bak"

    sudo pmset -b displaysleep 5
    sudo pmset -b sleep 15
    sudo pmset -b disksleep 10
    
    echo -e "\033[1;32mBalanced mode on\033[0m"
  else
    echo -e "\033[1;33mCanceled\033[0m"
  fi
}

max_battery() {
  echo -e "\033[1;34mMax battery mode...\033[0m"
  if confirm_action "Max battery" "Lasts longer but slower"; then
    local backup_dir="$HOME/.aerout_backups"
    mkdir -p "$backup_dir"
    pmset -g > "$backup_dir/power_settings.bak"

    sudo pmset -b displaysleep 2
    sudo pmset -b sleep 5
    sudo pmset -b disksleep 5
    sudo pmset -b lessbright 1

    if ! is_apple_silicon; then
      sudo pmset -b lowpowermode 1
    fi
    
    echo -e "\033[1;32mMax battery mode on\033[0m"
    echo -e "\033[1;33mYour Mac might feel slower\033[0m"
  else
    echo -e "\033[1;33mCanceled\033[0m"
  fi
}

performance_power() {
  echo -e "\033[1;34mPerformance mode...\033[0m"
  if confirm_action "Performance mode" "Uses more battery"; then
    local backup_dir="$HOME/.aerout_backups"
    mkdir -p "$backup_dir"
    pmset -g > "$backup_dir/power_settings.bak"

    sudo pmset -b displaysleep 15
    sudo pmset -b sleep 30
    sudo pmset -b disksleep 0
    sudo pmset -b lessbright 0

    if ! is_apple_silicon; then
      sudo pmset -b lowpowermode 0
    fi
    
    echo -e "\033[1;32mPerformance mode on\033[0m"
    echo -e "\033[1;33mWill use more battery\033[0m"
  else
    echo -e "\033[1;33mCanceled\033[0m"
  fi
}

reset_power() {
  echo -e "\033[1;34mResetting power...\033[0m"
  if confirm_action "Reset power" "Back to normal settings"; then
    sudo pmset -b displaysleep 10
    sudo pmset -b sleep 15
    sudo pmset -b disksleep 10
    sudo pmset -b lessbright 0
    
    if ! is_apple_silicon; then
      sudo pmset -b lowpowermode 0
    fi
    
    echo -e "\033[1;32mPower settings normal\033[0m"
  else
    echo -e "\033[1;33mCanceled\033[0m"
  fi
}

performance_boost() {
  clear
  echo -e "\033[1;35m═══════════════════════════════════════════════\033[0m"
  echo -e "\033[1;36m         PERFORMANCE MODE \033[0m"
  echo -e "\033[1;35m═══════════════════════════════════════════════\033[0m"
  
  echo -e "\033[1;34m[1] Free Up Memory         - More RAM available\033[0m"
  echo -e "\033[1;33m[2] App Launch Boost       - Opens apps faster\033[0m"
  echo -e "\033[1;32m[3] System Tweaks          - Better performance\033[0m"
  echo -e "\033[1;31m[4] Reset Performance      - Back to normal\033[0m"
  echo -e "\033[1;36m[5] Back to Menu\033[0m"
  echo -ne "\033[1;36mPick an option (1-5): \033[0m"
  read -r perf_choice
  
  case "$perf_choice" in
    1) memory_optimization ;;
    2) app_launch_boost ;;
    3) system_responsiveness ;;
    4) reset_performance ;;
    5) main_menu; return ;;
    *) echo -e "\033[1;31mNot a valid choice\033[0m"; sleep 1; performance_boost ;;
  esac
  
  sleep 2
  performance_boost
}

memory_optimization() {
  echo -e "\033[1;34mFreeing up memory...\033[0m"

  local initial_free=$(vm_stat | grep "Pages free" | awk '{print $3}' | sed 's/\.//')
  local initial_free_mb=$((initial_free * 4096 / 1048576))
  
  if confirm_action "Free memory" "Makes more RAM available"; then
    echo -e "\033[1;36mClearing memory...\033[0m"

    sudo purge

    local final_free=$(vm_stat | grep "Pages free" | awk '{print $3}' | sed 's/\.//')
    local final_free_mb=$((final_free * 4096 / 1048576))
    local freed_mb=$((final_free_mb - initial_free_mb))
    
    echo -e "\033[1;32mMemory freed up\033[0m"
    echo -e "\033[1;32mBefore: ${initial_free_mb}MB, After: ${final_free_mb}MB\033[0m"
    echo -e "\033[1;32mFreed: ${freed_mb}MB\033[0m"
  else
    echo -e "\033[1;33mCanceled\033[0m"
  fi
}

app_launch_boost() {
  echo -e "\033[1;34mSpeeding up app launches...\033[0m"
  if confirm_action "App launch boost" "Makes apps open faster"; then
    echo -e "\033[1;36mCleaning caches...\033[0m"

    rm -rf ~/Library/Caches/com.apple.LaunchServices/* 2>/dev/null

    /System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister -kill -r -domain local -domain system -domain user
    
    echo -e "\033[1;32mApps will launch faster\033[0m"
    echo -e "\033[1;33mFirst launch might be slow\033[0m"
  else
    echo -e "\033[1;33mCanceled\033[0m"
  fi
}

system_responsiveness() {
  echo -e "\033[1;34mImproving system speed...\033[0m"
  if confirm_action "System tweaks" "Makes your Mac faster"; then
    local backup_dir="$HOME/.aerout_backups"
    mkdir -p "$backup_dir"

    echo -e "\033[1;36mApplying tweaks...\033[0m"

    if [[ $(system_profiler SPHardwareDataType | grep "Model Identifier" | grep -c "iMac\|Mac Pro\|Mac mini") -gt 0 ]]; then
      sudo pmset -a sms 0
    fi

    sudo tmutil disablelocal 2>/dev/null

    sudo mdutil -i off /Volumes/* 2>/dev/null
    
    echo -e "\033[1;32mSystem faster now\033[0m"
  else
    echo -e "\033[1;33mCanceled\033[0m"
  fi
}

reset_performance() {
  echo -e "\033[1;34mResetting performance...\033[0m"
  if confirm_action "Reset performance" "Back to normal settings"; then
    sudo mdutil -i on /Volumes/* 2>/dev/null

    sudo tmutil enablelocal 2>/dev/null

    if [[ $(system_profiler SPHardwareDataType | grep "Model Identifier" | grep -c "MacBook") -gt 0 ]]; then
      sudo pmset -a sms 1
    fi
    
    echo -e "\033[1;32mPerformance settings normal\033[0m"
  else
    echo -e "\033[1;33mCanceled\033[0m"
  fi
}


game_optimizer() {
  clear
  echo -e "\033[1;35m═══════════════════════════════════════════════\033[0m"
  echo -e "\033[1;36m         GAME BOOST \033[0m"
  echo -e "\033[1;35m═══════════════════════════════════════════════\033[0m"
  
  echo -e "\033[1;34m[1] Roblox Optimizer      - Better FPS and Performance\033[0m"
  echo -e "\033[1;33m[2] General Game Boost    - All games\033[0m"
  echo -e "\033[1;31m[3] Reset Game Settings   - Back to normal\033[0m"
  echo -e "\033[1;36m[4] Back to Menu\033[0m"
  echo -ne "\033[1;36mPick an option (1-4): \033[0m"
  read -r game_choice
  
  case "$game_choice" in
    1) roblox_optimize ;;
    2) general_game_boost ;;
    3) reset_game_settings ;;
    4) main_menu; return ;;
    *) echo -e "\033[1;31mNot a valid choice\033[0m"; sleep 1; game_optimizer ;;
  esac
  
  sleep 2
  game_optimizer
}

roblox_optimize() {
  echo -e "\033[1;34mOptimizing Roblox...\033[0m"
  if confirm_action "Optimize Roblox" "Better FPS and performance"; then
    # Install FPS Unlocker
    echo -e "\033[1;36mDownloading FPS Unlocker...\033[0m"
    curl -sfLO https://github.com/wrealaero/rbxfpsunlocker-osx/raw/refs/heads/main/install_fps_unlocker || {
      echo -e "\033[1;31mFailed to download FPS Unlocker\033[0m"
      return 1
    }
    
    chmod +x install_fps_unlocker
    ./install_fps_unlocker || {
      echo -e "\033[1;31mFailed to install FPS Unlocker\033[0m"
      return 1
    }
    
    # Additional Roblox optimizations
    local backup_dir="$HOME/.aerout_backups/roblox"
    mkdir -p "$backup_dir"
    
    local settings_dir=$(find ~/Library/Application\ Support/Roblox -name "ClientSettings" -type d 2>/dev/null)
    
    if [ -z "$settings_dir" ]; then
      settings_dir=~/Library/Application\ Support/Roblox/ClientSettings
      mkdir -p "$settings_dir"
    fi

    echo '{
  "DFIntTaskSchedulerTargetFps": 120,
  "FFlagDisableNewIGMinDUA": true,
  "FFlagFixGraphicsQuality": true,
  "FFlagHandleAltEnterFullscreenManually": false,
  "FFlagDisablePostFx": true,
  "DFIntMaxFrameBufferSize": 1,
  "FFlagReduceTextureMemory": true
}' > "$settings_dir/ClientAppSettings.json"
    
    echo -e "\033[1;32mRoblox optimized\033[0m"
    echo -e "\033[1;33mRestart Roblox to see changes\033[0m"
  else
    echo -e "\033[1;33mCanceled\033[0m"
  fi
}

steam_optimize() {
  echo -e "\033[1;34mOptimizing Steam...\033[0m"
  if confirm_action "Optimize Steam" "Better game performance"; then
    local backup_dir="$HOME/.aerout_backups/steam"
    mkdir -p "$backup_dir"

    if [ -f ~/Library/Application\ Support/Steam/steam.cfg ]; then
      cp ~/Library/Application\ Support/Steam/steam.cfg "$backup_dir/steam.cfg.bak"
    fi

    echo -e "@nShaderPrecache 0\n@fShaderPrecacheSize 0\n@nMaxBackgroundDownloadRateKbs 0" > ~/Library/Application\ Support/Steam/steam.cfg
    
    echo -e "\033[1;32mSteam optimized\033[0m"
    echo -e "\033[1;33mRestart Steam to see changes\033[0m"
  else
    echo -e "\033[1;33mCanceled\033[0m"
  fi
}

general_game_boost() {
  echo -e "\033[1;34mBoosting all games...\033[0m"
  if confirm_action "Game boost" "Better performance for all games"; then
    sudo purge

    killall "Google Chrome" 2>/dev/null
    killall "Firefox" 2>/dev/null
    killall "Safari" 2>/dev/null

    sudo sysctl -w net.inet.tcp.delayed_ack=0 >/dev/null 2>&1
    sudo sysctl -w net.inet.tcp.mssdflt=1460 >/dev/null 2>&1

    sudo pmset -b displaysleep 15
    sudo pmset -b disksleep 0
    sudo pmset -b sleep 0

    if ! is_apple_silicon; then
      sudo pmset -a sms 0
    fi
    
    echo -e "\033[1;32mGames will run better\033[0m"
    echo -e "\033[1;33mSome changes reset after restart\033[0m"
  else
    echo -e "\033[1;33mCanceled\033[0m"
  fi
}

reset_game_settings() {
  echo -e "\033[1;34mResetting game settings...\033[0m"
  if confirm_action "Reset game settings" "Back to normal"; then
    sudo sysctl -w net.inet.tcp.delayed_ack=1 >/dev/null 2>&1

    if ! is_apple_silicon; then
      sudo pmset -a sms 1
    fi
    
    echo -e "\033[1;32mGame settings back to normal\033[0m"
  else
    echo -e "\033[1;33mCanceled\033[0m"
  fi
}

revert_changes() {
  clear
  echo -e "\033[1;35m═══════════════════════════════════════════════\033[0m"
  echo -e "\033[1;36m         REVERT ALL CHANGES \033[0m"
  echo -e "\033[1;35m═══════════════════════════════════════════════\033[0m"
  
  if confirm_action "Revert everything" "Puts your Mac back to normal"; then
    local backup_dir="$HOME/.aerout_backups"
    
    echo -e "\033[1;34mRestoring UI...\033[0m"

    defaults delete NSGlobalDomain NSWindowResizeTime 2>/dev/null
    defaults delete com.apple.dock autohide-delay 2>/dev/null
    defaults delete com.apple.dock autohide-time-modifier 2>/dev/null
    defaults delete com.apple.dock expose-animation-duration 2>/dev/null
    defaults delete com.apple.finder DisableAllAnimations 2>/dev/null
    
    echo -e "\033[1;34mRestoring power...\033[0m"

    sudo pmset -b displaysleep 10
    sudo pmset -b sleep 15
    sudo pmset -b disksleep 10
    sudo pmset -b lessbright 0
    if ! is_apple_silicon; then
      sudo pmset -b lowpowermode 0
    fi
    
    echo -e "\033[1;34mRestoring network...\033[0m"
    sudo networksetup -setdnsservers Wi-Fi "Empty"

    sudo sysctl -w net.inet.tcp.delayed_ack=1 >/dev/null 2>&1
    
    echo -e "\033[1;34mRestoring performance...\033[0m"

    sudo mdutil -i on /Volumes/* 2>/dev/null

    sudo tmutil enablelocal 2>/dev/null

    if [[ $(system_profiler SPHardwareDataType | grep "Model Identifier" | grep -c "MacBook") -gt 0 ]]; then
      sudo pmset -a sms 1
    fi

    killall Dock >/dev/null 2>&1
    killall Finder >/dev/null 2>&1
    
    echo -e "\033[1;32mEverything back to normal\033[0m"
  else
    echo -e "\033[1;33mCanceled\033[0m"
  fi
  
  sleep 2
  main_menu
}

exit_safe() {
  clear
  echo -e "\033[1;35m
   █████╗ ███████╗██████╗  ██████╗ ██╗   ██╗████████╗
  ██╔══██╗██╔════╝██╔══██╗██╔═══██╗██║   ██║╚══██╔══╝
  ███████║█████╗  ██████╔╝██║   ██║██║   ██║   ██║
  ██╔══██║██╔══╝  ██╔══██╗██║   ██║██║   ██║   ██║
  ██║  ██║███████╗██║  ██║╚██████╔╝╚██████╔╝   ██║
  ╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝ ╚═════╝  ╚═════╝    ╚═╝
  \033[0m"
  echo -e "\033[1;35m═══════════════════════════════════════════════\033[0m"
  type_text "         Thanks for using AEROUT V${VERSION}" "\033[1;36m" 0.03
  echo -e "\033[1;35m═══════════════════════════════════════════════\033[0m"
  sleep 1
  type_text "Your Mac should feel quicker now" "\033[1;33m" 0.05
  sleep 1
  type_text "Come back anytime your Mac feels slow again" "\033[1;32m" 0.05
  sleep 2
  exit 0
}

intro
main_menu
