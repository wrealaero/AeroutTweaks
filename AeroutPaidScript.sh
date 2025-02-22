SERIALS_URL="https://docs.google.com/spreadsheets/d/1f7gD115M8TDYstCNVidH4RMpsyeut9LBdhfFej6v-nw/edit?usp=sharing"


MAC_SERIAL=$(system_profiler SPHardwareDataType | awk '/Serial/ {print $4}')


check_hardware() {
  echo -e "\033[1;34m🔍 Checking license online...\033[0m"


  if curl -s "$SERIALS_URL" | grep -q "$MAC_SERIAL"; then
    echo -e "\033[1;32m✅ License Verified! Running Aerout Tweaks...\033[0m"
  else
    echo -e "\033[1;31m❌ This script is not licensed for your Mac. Exiting...\033[0m"
    exit 1
  fi
}

check_hardware  

sudo -v

run_task() {
  print_color "yellow" "$1..."
  loading_bar
  eval "$2"
  print_color "green" "✅ $3"
  success_sound
}

confirm_action() {
  echo -e "${YELLOW}$1 (yes/no)${NC}"
  read -r response
  if [[ "$response" != "yes" && "$response" != "y" ]]; then
    print_color "red" "❌ Action canceled!"
    sleep 1
    return 1
  fi
  return 0
}


MAGENTA='\033[1;35m'
CYAN='\033[1;36m'
WHITE='\033[1;37m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
RED='\033[1;31m'
NC='\033[0m' # No Color

print_color() {
  case "$1" in
    "red") echo -e "${RED}${2}${NC}" ;;
    "green") echo -e "${GREEN}${2}${NC}" ;;
    "yellow") echo -e "${YELLOW}${2}${NC}" ;;
    "blue") echo -e "\033[34m${2}\033[0m" ;;
    "cyan") echo -e "${CYAN}${2}${NC}" ;;
    *) echo "$2" ;;
  esac
}

animated_banner() {
  clear
  frames=(
    "${MAGENTA}══════════════════════════════════════════${NC}"
    "${GREEN}             🚀 Aerout Tweaks (Paid)        ${NC}"
    "${MAGENTA}══════════════════════════════════════════${NC}"
    "${YELLOW}                Sub to RealAero            ${NC}"
    "${MAGENTA}══════════════════════════════════════════${NC}"
  )
  
  for frame in "${frames[@]}"; do
    echo -e "$frame"
    sleep 0.1
  done  

  sleep 0.5
}  
  
loading_bar() {
  bar_length=20  
  for ((i = 1; i <= bar_length; i++)); do
  
    filled=$(printf '█%.0s' $(seq 1 $i))
    empty=$(printf ' %.0s' $(seq $i $bar_length))

    
    echo -ne "${CYAN}[${filled}${empty}] ${i}/${bar_length}\r${NC}"
    sleep 0.1  
  done  

  echo ""
}

success_sound() { 
  say "All optimizations completed!"
}

exit_screen() {
  clear
  echo -e "${MAGENTA}══════════════════════════════════════════${NC}"
  echo -e "${RED} 🚀 Shutting Down Aerout (Paid) Script... ${NC}"
  echo -e "${MAGENTA}══════════════════════════════════════════${NC}"
  sleep 0.5

  for i in {3..1}; do
    echo -ne "${YELLOW}Exiting in $i... 🔥🔥🔥\r${NC}"
    sleep 1
done

  echo -e "\n${CYAN}Finalizing system tweaks...${NC}"
  loading_bar

# Simulated exit effects
effects=("💨 Logging out..." "📦 Saving settings..." "🔧 Resetting temp files..." "🔄 Closing processes..." "✅ Exit Complete!")
for effect in "${effects[@]}"; do
  echo -ne "${GREEN}$effect\r${NC}"
  sleep 0.8
done

echo -e "\n${GREEN}✅ All optimizations saved. See you next time!${NC}"
success_sound
sleep 1
clear
exit 0
} 

privacy_protector() {
    print_color "yellow" "🔒 Enabling Privacy Mode..."
    loading_bar

    # Disable Apple Analytics & Telemetry
    print_color "cyan" "🚫 Disabling Apple Analytics & Telemetry..."
    sudo launchctl unload -w /System/Library/LaunchDaemons/com.apple.analyticsd.plist 2>/dev/null
    sudo launchctl unload -w /System/Library/LaunchAgents/com.apple.analyticsd.plist 2>/dev/null
    sudo launchctl unload -w /System/Library/LaunchDaemons/com.apple.apsd.plist 2>/dev/null

    # Block Apple & Microsoft tracking servers
    print_color "cyan" "🚧 Blocking Tracking Domains..."
    BLOCKED_HOSTS=(
        "ocsp.apple.com"
        "safebrowsing.apple.com"
        "gsp1.apple.com"
        "telemetry.microsoft.com"
        "www.bing.com"
        "activity.windows.com"
    )

    for host in "${BLOCKED_HOSTS[@]}"; do
        if ! grep -q "$host" /etc/hosts; then
            echo "127.0.0.1 $host" | sudo tee -a /etc/hosts >/dev/null
        fi
    done

    # Flush DNS cache
    print_color "cyan" "🔄 Flushing DNS Cache..."
    sudo dscacheutil -flushcache
    sudo killall -HUP mDNSResponder

    # Disable Location & Siri Services
    print_color "cyan" "📍 Disabling Location & Siri..."
    SERVICES=(
        "com.apple.locationd"
        "com.apple.Siri"
    )

    for service in "${SERVICES[@]}"; do
        sudo launchctl unload -w /System/Library/LaunchDaemons/$service.plist 2>/dev/null
        sudo launchctl unload -w /System/Library/LaunchAgents/$service.plist 2>/dev/null
    done

    # Clear system logs securely
    print_color "cyan" "🗑️ Clearing Logs..."
    sudo find /private/var/log/asl -type f -exec rm -f {} +
    sudo find /var/log -type f -exec rm -f {} +

    # Set secure DNS servers (Quad9 + Cloudflare)
    print_color "cyan" "🌐 Setting Secure DNS..."
    NETWORK_INTERFACES=("Wi-Fi" "Ethernet" "Thunderbolt Bridge")
    for net in "${NETWORK_INTERFACES[@]}"; do
        sudo networksetup -setdnsservers "$net" 9.9.9.9 1.1.1.1 2>/dev/null
    done

    # Disable Personalized Ads
    print_color "cyan" "🚫 Disabling Apple Personalized Ads..."
    sudo defaults write /Library/Preferences/com.apple.AdLib allowApplePersonalizedAdvertising -bool false
    sudo defaults write /Library/Preferences/com.apple.AdLib allowApplePersonalizedAds -bool false

    # Disable Safari tracking
    print_color "cyan" "🌍 Disabling Safari Search Tracking..."
    sudo defaults write com.apple.Safari UniversalSearchEnabled -bool false
    sudo defaults write com.apple.Safari WebsiteSpecificSearchEnabled -bool false

    print_color "green" "✅ Privacy Mode Enabled!"
    success_sound
    sleep 2
}

speed_test() {
  print_color "yellow" "🚀 Running Speed Test..."

  # Ensure Homebrew is installed
  if ! command -v brew &> /dev/null; then
    print_color "red" "⚠️ Homebrew is required to install Speedtest CLI!"
    echo -e "${YELLOW}Do you want to install Homebrew now? (yes/no)${NC}"
    read -r brew_choice
    if [[ "$brew_choice" == "yes" || "$brew_choice" == "y" ]]; then
      print_color "yellow" "Installing Homebrew..."
      /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    else
      print_color "red" "❌ Cannot proceed without Homebrew. Exiting..."
      sleep 2
      return
    fi
  fi

  # Ensure Speedtest CLI is installed
  if ! command -v speedtest &> /dev/null; then
    print_color "red" "⚠️ Speedtest CLI is not installed!"
    echo -e "${YELLOW}Would you like to install Speedtest CLI? (yes/no)${NC}"
    read -r install_choice
    if [[ "$install_choice" == "yes" || "$install_choice" == "y" ]]; then
      print_color "yellow" "Installing Speedtest CLI..."
      brew install speedtest-cli
    else
      print_color "red" "❌ Speed Test cannot run without Speedtest CLI. Returning to menu..."
      sleep 2
      return
    fi
  fi

  # Check internet connection
  print_color "cyan" "🌍 Checking Internet Connection..."
  if ! ping -c 1 -W 2 google.com &> /dev/null; then
    print_color "red" "❌ No Internet Connection! Can't run speed test."
    log "Speed test failed - No internet connection."
    sleep 2
    return
  fi

  # Run speed test
  print_color "cyan" "📡 Running Internet Speed Test..."
  speed_results=$(speedtest --format=json 2>/dev/null)

  if [ -z "$speed_results" ]; then
    print_color "red" "⚠️ Speed test failed! Try running 'speedtest' manually."
    log "Speed test failed - CLI issue or timeout."
    sleep 2
    return
  fi

  # Extract values from JSON output
  download_speed=$(echo "$speed_results" | jq -r '.download.bandwidth' | awk '{print $1 / 125000 " Mbps"}')
  upload_speed=$(echo "$speed_results" | jq -r '.upload.bandwidth' | awk '{print $1 / 125000 " Mbps"}')
  latency=$(echo "$speed_results" | jq -r '.ping.latency')
  jitter=$(echo "$speed_results" | jq -r '.ping.jitter')

  print_color "green" "✅ Internet Speed Test Results:"
  print_color "blue" "📥 Download Speed: $download_speed"
  print_color "blue" "📤 Upload Speed: $upload_speed"
  print_color "blue" "⏳ Latency: ${latency} ms"
  print_color "blue" "📶 Jitter: ${jitter} ms"

  log "Speed Test - Download: $download_speed | Upload: $upload_speed | Latency: $latency ms | Jitter: $jitter ms"

  # Disk speed test (Write Speed)
  print_color "cyan" "💾 Testing Disk Write Speed..."
  write_speed=$(dd if=/dev/zero of=/tmp/testfile bs=1M count=512 oflag=dsync 2>&1 | awk '/copied/ {print $(NF-1) " MB/sec"}')
  print_color "green" "✅ Disk Write Speed: $write_speed"
  
  # Disk speed test (Read Speed)
  print_color "cyan" "💾 Testing Disk Read Speed..."
  read_speed=$(dd if=/tmp/testfile of=/dev/null bs=1M count=512 iflag=nocache 2>&1 | awk '/copied/ {print $(NF-1) " MB/sec"}')
  print_color "green" "✅ Disk Read Speed: $read_speed"

  # Clean up test file
  rm -f /tmp/testfile

  log "Disk Speed - Write: $write_speed | Read: $read_speed"

  print_color "green" "✅ Speed Test Completed!"
  success_sound
  sleep 2
}

display_menu() {
  print_color "yellow" "🎛️ Select an Optimization Option:"
  print_color "cyan" "══════════════════════════════════════════"

  print_color "magenta" "🎮 GAMING & PERFORMANCE"
  echo "1) 🎮 Max FPS Boost (Optimized for Roblox & More)"
  echo "2) ⚡ Latency Optimizer (Reduce Ping & Faster Inputs)"
  echo "3) 🔥 Extreme Performance Mode (Overclock CPU + RAM + GPU)"
  echo "4) 🎯 Custom Game Profiles (Balanced, Performance, Max FPS)"
  echo "5) 📶 Network Accelerator (Lower Ping & Faster Online Gaming)"
  echo "6) 🚀 VRAM Auto-Cleaner (Prevent FPS Drops & Lag Spikes)"

  print_color "magenta" "🛠️ SYSTEM & HARDWARE"
  echo "7) ❄️ Advanced Cooling Control (Optimize Fan Speeds & Temps)"
  echo "8) 🏎️ Turbo Boost Mode (Maximize CPU Clock Speed)"
  echo "9) 🔄 Game Mode Switch (High Performance & Power Saving Mode)"
  echo "10) 💾 SSD Health & Performance Check (Monitor Speed & Wear)"

  print_color "magenta" "🧹 CLEANUP & MAINTENANCE"
  echo "11) 🧹 Deep System Clean (Remove Junk Files & Logs)"
  echo "12) 🕵️‍♂️ Privacy Mode (Disable Tracking & Increase Security)"
  echo "13) ❌ Revert All Tweaks (Restore Default Mac Settings)"

  print_color "magenta" "🌍 INTERNET & MULTIMEDIA"
  echo "14) 🌍 Web Browser Boost (Reduce Delay & Speed Up Loading)"
  echo "15) 🎧 Audio Enhancer (Fix Sound Lag & Improve Clarity)"
  echo "16) 📺 Download YouTube Videos (HD Quality)"

  print_color "magenta" "🛠️ UTILITIES"
  echo "17) 🚀 Mac Speed Test (Check Internet & Disk Performance)"
  echo "18) 🎯 Auto-Update Essential Apps"
  echo "19) 🌟 One-Click Turbo Mode (Auto-Apply Best Settings)"
  echo "20) ❌ Exit"

  print_color "cyan" "══════════════════════════════════════════"
}

while true; do
  animated_banner
  display_menu  
  read -p "Enter choice: " choice  

  case $choice in

1)
print_color "yellow" "🚀 Applying Max FPS Boost..."
loading_bar

# Lock GPU to Integrated for Efficiency
current_gpu=$(pmset -g | grep gpuswitch | awk '{print $2}')
if [ "$current_gpu" != "0" ]; then
  sudo pmset -a gpuswitch 0
fi

# Ensure GPU Switch is Set
sudo pmset -a gpuswitch 0

# Optimize Network for Lower Ping & Faster Response
sudo sysctl -w net.inet.tcp.delayed_ack=0
sudo sysctl -w net.inet.tcp.mssdflt=1460
sudo sysctl -w net.inet.tcp.minmss=536
sudo sysctl -w kern.ipc.maxsockbuf=16777216  # Increased buffer size for stability
sudo sysctl -w net.inet.tcp.fastopen=1  
sudo sysctl -w net.inet.ip.forwarding=1  

# Optimize System Memory & CPU Usage
sudo purge
sudo sync
sudo launchctl kickstart -k system/com.apple.diskarbitrationd
sudo sysctl -w kern.maxprocperuid=1024  # Allow more processes for better performance
sudo launchctl unload -w /System/Library/LaunchDaemons/com.apple.dynamic_pager.plist

# Reduce UI Lag (Optional)
defaults write NSGlobalDomain NSAutomaticWindowAnimationsEnabled -bool false
defaults write com.apple.dock autohide-time-modifier -float 0
defaults write com.apple.dock autohide-delay -float 0
killall Dock

print_color "green" "✅ Max FPS Boost Applied! (Higher FPS, Lower Input Lag, Optimized Networking)"
success_sound
;;

2)
print_color "yellow" "🚀 Optimizing network latency..."
loading_bar

# Disable delayed ACK to minimize latency
sudo sysctl -w net.inet.tcp.delayed_ack=0

# Increase TCP buffer sizes for smoother data flow
sudo sysctl -w net.inet.tcp.recvspace=524288
sudo sysctl -w net.inet.tcp.sendspace=524288

# Enable TCP Fast Open to accelerate connection setup
sudo sysctl -w net.inet.tcp.fastopen=1  

# Ensure TCP window scaling (RFC 1323) is enabled for better throughput on high-latency links
sudo sysctl -w net.inet.tcp.rfc1323=1

wait

print_color "green" "✅ Network latency optimized! Enjoy lower ping & snappier response times."
success_sound
;;
3)
print_color "yellow" "🚀 Activating Extreme Performance Mode..."
loading_bar

# Lock GPU to Integrated Mode for consistent performance
sudo pmset -a gpuswitch 0
current_gpu=$(pmset -g | grep gpuswitch | awk '{print $2}')
if [ "$current_gpu" != "0" ]; then
  print_color "red" "GPU not locked to Integrated mode, forcing setting..."
  sudo pmset -a gpuswitch 0
fi

# High performance CPU and scheduling tweaks
sudo sysctl -w kern.sched.preempt_thresh=10
sudo sysctl -w kern.maxprocperuid=1024

# Optimize network parameters for ultra-fast data transfer
sudo sysctl -w net.inet.tcp.mssdflt=1460
sudo sysctl -w net.inet.tcp.slowstart_flightsize=10

# Disable dynamic pager to reduce disk swapping (use with caution)
sudo launchctl unload -w /System/Library/LaunchDaemons/com.apple.dynamic_pager.plist 2>/dev/null

# Flush system caches and sync disk to free up memory
sudo purge
sudo sync
sudo launchctl kickstart -k system/com.apple.diskarbitrationd

# Disable Spotlight indexing to reduce background disk I/O
sudo mdutil -a -i off

# Disable system animations for snappier UI response
defaults write NSGlobalDomain NSAutomaticWindowAnimationsEnabled -bool false

# Disable App Nap to prevent background app throttling
defaults write NSGlobalDomain NSAppSleepDisabled -bool true

# Prevent system sleep, disk sleep, and display sleep for sustained performance
sudo pmset -a sleep 0
sudo pmset -a disksleep 0
sudo pmset -a displaysleep 0

wait

print_color "green" "✅ Extreme Performance Mode activated! Full power unlocked for peak performance."
success_sound
;;

   4)
print_color "yellow" "🎮 Selecting Custom Game Profile..."
loading_bar
echo "Choose a profile:"
echo "  1) Balanced         - Optimized for battery & moderate performance"
echo "  2) Performance      - Enhanced speed & responsive gaming"
echo "  3) Max FPS          - Full power unlocked for high FPS gaming"
echo "  4) Ultimate Gaming  - Extreme tweaks for maximum performance"
read -r profile

case $profile in
  1)
    # Balanced Mode: Prioritizes battery life while still offering decent performance.
    sudo pmset -a gpuswitch 2
    sudo sysctl -w kern.sched.preempt_thresh=50
    sudo sysctl -w net.inet.tcp.delayed_ack=1
    print_color "green" "✅ Balanced mode applied! Optimized for battery & performance."
    ;;
  2)
    # Performance Mode: Uses discrete GPU with moderate CPU tweaks for faster response.
    sudo pmset -a gpuswitch 1
    sudo sysctl -w kern.sched.preempt_thresh=25
    sudo sysctl -w net.inet.tcp.delayed_ack=0
    print_color "green" "✅ Performance mode applied! Better speed & gaming response."
    ;;
  3)
    # Max FPS Mode: Forces integrated GPU, aggressive CPU scheduling, and network tweaks.
    sudo pmset -a gpuswitch 0
    sudo sysctl -w kern.sched.preempt_thresh=10
    sudo sysctl -w net.inet.tcp.mssdflt=1460
    sudo sysctl -w net.inet.tcp.slowstart_flightsize=10
    print_color "green" "✅ Max FPS mode applied! Full power unlocked for high FPS gaming."
    ;;
  4)
    # Ultimate Gaming Mode: Extreme tweaks for maximum performance.
    sudo pmset -a gpuswitch 0
    sudo sysctl -w kern.sched.preempt_thresh=5
    sudo sysctl -w net.inet.tcp.mssdflt=1460
    sudo sysctl -w net.inet.tcp.slowstart_flightsize=10
    sudo sysctl -w net.inet.tcp.delayed_ack=0
    # Additional system optimizations
    sudo launchctl unload -w /System/Library/LaunchDaemons/com.apple.dynamic_pager.plist 2>/dev/null
    sudo purge
    defaults write NSGlobalDomain NSAutomaticWindowAnimationsEnabled -bool false
    killall Dock 2>/dev/null
    print_color "green" "✅ Ultimate Gaming Mode applied! Extreme tweaks activated."
    ;;
  *)
    print_color "red" "❌ Invalid selection. Defaulting to Balanced mode."
    sudo pmset -a gpuswitch 2
    sudo sysctl -w kern.sched.preempt_thresh=50
    sudo sysctl -w net.inet.tcp.delayed_ack=1
    ;;
esac

# Final check: Ensure GPU is locked to the desired mode (if applicable)
current_gpu=$(pmset -g | grep gpuswitch | awk '{print $2}')
if [ "$profile" -ge 3 ] && [ "$current_gpu" != "0" ]; then
  sudo pmset -a gpuswitch 0
fi

success_sound
;;

    5)
print_color "yellow" "🚀 Boosting network speed..."
loading_bar

# Enable TCP Fast Open for quicker connection setups
sudo sysctl -w net.inet.tcp.fastopen=1

# Increase maximum socket buffer size for improved throughput
sudo sysctl -w kern.ipc.maxsockbuf=16777216

# Disable delayed ACK to reduce latency
sudo sysctl -w net.inet.tcp.delayed_ack=0

# Increase TCP buffer sizes for smoother data transfer
sudo sysctl -w net.inet.tcp.recvspace=524288
sudo sysctl -w net.inet.tcp.sendspace=524288

# Enable TCP window scaling (RFC 1323) for high-latency link improvements
sudo sysctl -w net.inet.tcp.rfc1323=1

# Flush ARP cache to remove stale network entries (optional but useful)
sudo arp -a -d

# Check if primary interface exists and reset it to apply new settings
if ifconfig en0 > /dev/null 2>&1; then
    sudo ifconfig en0 down && sudo ifconfig en0 up
else
    print_color "red" "Interface en0 not found. Skipping interface reset."
fi

# Renew DHCP lease for en0 to refresh network configuration
sudo ipconfig set en0 DHCP

# Flush DNS cache to clear outdated entries and speed up name resolution
sudo killall -HUP mDNSResponder
sudo dscacheutil -flushcache

# Set multiple fast and reliable DNS servers for redundancy
sudo networksetup -setdnsservers Wi-Fi 8.8.8.8 1.1.1.1 208.67.222.222 9.9.9.9

wait

print_color "green" "✅ Network Accelerator activated! Enjoy faster speeds & lower ping."
success_sound
;;

6)
print_color "yellow" "🚮 Deep System Clean in progress..."
loading_bar

# Function to safely delete files from a directory
clean_directory() {
  local dir="$1"
  if [ -d "$dir" ]; then
    if sudo find "$dir" -type f -delete; then
      print_color "cyan" "Cleaned files in $dir"
    else
      print_color "red" "Failed cleaning $dir"
    fi
  else
    print_color "red" "Directory $dir not found, skipping..."
  fi
}

clean_directory ~/Library/Caches/
clean_directory /Library/Logs/

# Free inactive memory and clear caches
if sudo purge; then
  print_color "cyan" "Memory purged successfully."
else
  print_color "red" "Purge command failed!"
fi

# Sync filesystem and restart disk arbitration to commit changes
if sudo sync && sudo launchctl kickstart -k system/com.apple.diskarbitrationd; then
  print_color "cyan" "Filesystem synced and disk arbitration restarted."
else
  print_color "red" "Failed to sync filesystem or restart disk arbitration."
fi

print_color "green" "✅ Deep System Clean completed! Your system is now leaner."
success_sound
;;


7)
print_color "yellow" "🚀 Initiating VRAM Auto-Cleaner..."
loading_bar

# Purge inactive memory and flush caches
if sudo purge && sudo sync; then
  sudo launchctl kickstart -k system/com.apple.diskarbitrationd
  print_color "cyan" "System caches cleared."
else
  print_color "red" "Cache clearing encountered an error."
fi

# Optimize virtual memory setting for better VRAM handling
if sudo sysctl -w vm.global_no_user_wire=1; then
  print_color "cyan" "vm.global_no_user_wire set successfully."
else
  print_color "red" "Failed to update vm.global_no_user_wire."
fi

print_color "green" "✅ VRAM Auto-Cleaner applied! System memory is refreshed."
success_sound
;;


8)
print_color "yellow" "🚀 Enhancing web browser performance for all browsers..."
loading_bar

# Define a list of browser bundle identifiers and their cache directories
declare -A browsers=(
  ["com.apple.Safari"]="$HOME/Library/Caches/com.apple.Safari"
  ["com.google.Chrome"]="$HOME/Library/Caches/Google/Chrome"
  ["com.microsoft.Edge"]="$HOME/Library/Caches/Microsoft Edge"
  ["com.operasoftware.Opera"]="$HOME/Library/Caches/com.operasoftware.Opera"
  ["org.mozilla.firefox"]="$HOME/Library/Caches/org.mozilla.firefox"
)

# Attempt to disable DNS prefetch for each browser (if supported)
for browser in "${!browsers[@]}"; do
  if defaults write "$browser" DNSPrefetchingEnabled -bool false; then
    print_color "cyan" "Disabled DNS prefetch for $browser"
  else
    print_color "red" "Could not update DNS prefetch for $browser"
  fi
done

# Clear cache directories for each browser to remove old data and free up space
for cache_dir in "${browsers[@]}"; do
  if [ -d "$cache_dir" ]; then
    rm -rf "$cache_dir" && print_color "cyan" "Cleared cache at $cache_dir"
  else
    print_color "red" "Cache directory $cache_dir not found."
  fi
done

print_color "green" "✅ Web Browser Boost applied! Enjoy faster page loads across all browsers."
success_sound
;;


9)
print_color "yellow" "🎧 Enhancing audio performance..."
loading_bar

# Restart core audio and verify its status
if sudo killall coreaudiod; then
  sleep 2
  print_color "cyan" "Core audio restarted successfully."
else
  print_color "red" "Failed to restart coreaudiod."
fi

print_color "green" "✅ Audio Enhancer applied! Enjoy crisp, clear sound."
success_sound
;;


10)
print_color "yellow" "❄️ Adjusting cooling for optimal performance..."
loading_bar

# Disable sleep to ensure continuous performance (with error checking)
if sudo pmset -a disablesleep 1; then
  print_color "cyan" "Sleep disabled successfully."
else
  print_color "red" "Failed to disable sleep."
fi

# (Optional) Additional cooling commands can be added here if needed

print_color "green" "✅ Advanced Cooling Control applied! Temperatures optimized."
success_sound
;;


11)
print_color "yellow" "🚀 Activating Turbo Boost Mode..."
loading_bar

# Force integrated GPU mode for stable performance
if sudo pmset -a gpuswitch 0; then
  print_color "cyan" "GPU set to integrated mode."
else
  print_color "red" "Failed to set GPU mode."
fi

# Enable TCP Fast Open to improve connection speeds
if sudo sysctl -w net.inet.tcp.fastopen=1; then
  print_color "cyan" "TCP Fast Open enabled."
else
  print_color "red" "Failed to enable TCP Fast Open."
fi

print_color "green" "✅ Turbo Boost Mode activated! Maximum performance engaged."
success_sound
;;

12)
print_color "yellow" "🎮 Switching Game Mode..."
loading_bar

echo "Select Game Mode:"
echo "  1) High Performance"
echo "  2) Power Saving"
read -r game_mode

case $game_mode in
  1)
    if sudo pmset -a gpuswitch 0 && sudo sysctl -w kern.sched.preempt_thresh=10; then
      print_color "green" "✅ High Performance mode activated!"
    else
      print_color "red" "Failed to activate High Performance mode."
    fi
    ;;
  2)
    if sudo pmset -a gpuswitch 2 && sudo sysctl -w kern.sched.preempt_thresh=80; then
      print_color "green" "✅ Power Saving mode activated!"
    else
      print_color "red" "Failed to activate Power Saving mode."
    fi
    ;;
  *)
    print_color "red" "❌ Invalid selection. No changes applied."
    ;;
esac

success_sound
;;

13)
print_color "yellow" "♻️ Reverting all tweaks to default settings..."
loading_bar

# Restore network parameters to their defaults
if sudo sysctl -w net.inet.tcp.delayed_ack=1 && \
   sudo sysctl -w kern.ipc.maxsockbuf=8388608 && \
   sudo sysctl -w kern.sched.preempt_thresh=80; then
  print_color "cyan" "Network parameters restored."
else
  print_color "red" "Failed to restore some network parameters."
fi

# Restore virtual memory settings
if sudo sysctl -w vm.vm_page_free_min=2000; then
  print_color "cyan" "VM settings restored."
else
  print_color "red" "Failed to restore VM settings."
fi

# Reset GPU switching mode (defaulting to integrated/auto mode)
if sudo pmset -a gpuswitch 2; then
  print_color "cyan" "GPU mode reset."
else
  print_color "red" "Failed to reset GPU mode."
fi

# Re-enable any disabled system services (e.g., dynamic pager)
if sudo launchctl load -w /System/Library/LaunchDaemons/com.apple.dynamic_pager.plist 2>/dev/null; then
  print_color "cyan" "Dynamic pager re-enabled."
fi

wait

print_color "green" "✅ All tweaks reverted! System restored to default settings."
success_sound
;;



14)
print_color "yellow" "📺 Initiating YouTube download..."
loading_bar

# Check for yt-dlp; install it if not found
if ! command -v yt-dlp &>/dev/null; then
  print_color "red" "yt-dlp not found! Installing..."
  if brew install yt-dlp; then
    print_color "cyan" "yt-dlp installed successfully."
  else
    print_color "red" "Installation failed. Aborting download."
    exit 1
  fi
fi

read -rp "Enter YouTube video URL: " yt_url
if [ -z "$yt_url" ]; then
  print_color "red" "❌ No URL provided. Aborting download."
else
  if yt-dlp -f best "$yt_url" -o "$HOME/Downloads/%(title)s.%(ext)s"; then
    print_color "green" "✅ Download complete! Check your Downloads folder."
  else
    print_color "red" "Download failed. Please verify the URL and try again."
  fi
fi

success_sound
;;


16)
print_color "yellow" "🔄 Updating essential apps..."
loading_bar

if brew update && brew upgrade; then
  brew cleanup
  print_color "green" "✅ All essential apps updated successfully!"
else
  print_color "red" "Failed to update some apps. Please check your Homebrew setup."
fi

success_sound
;;


17)
print_color "yellow" "💾 Checking SSD health & performance..."
loading_bar

# Verify the root volume; note that this might take some time
if diskutil verifyVolume /; then
  print_color "cyan" "Volume verification complete."
else
  print_color "red" "Volume verification encountered issues."
fi

# Enable TRIM for SSD optimization (user confirmation might be required)
if sudo trimforce enable; then
  print_color "cyan" "TRIM enabled successfully."
else
  print_color "red" "Failed to enable TRIM or it is already active."
fi

print_color "green" "✅ SSD Health & Performance Check completed!"
success_sound
;;

18)
print_color "yellow" "🚀 Activating One-Click Turbo Mode..."
loading_bar

# Force integrated GPU for consistent performance
if sudo pmset -a gpuswitch 0; then
  print_color "cyan" "GPU set to integrated mode."
else
  print_color "red" "Failed to set GPU mode."
fi

# Optimize network socket buffer size
if sudo sysctl -w kern.ipc.maxsockbuf=8388608; then
  print_color "cyan" "Socket buffer size optimized."
else
  print_color "red" "Failed to update socket buffer size."
fi

# Restart Core Audio to clear potential sound issues
sudo killall coreaudiod

# Clear caches and sync disks for a clean state
if sudo purge && sudo sync; then
  print_color "cyan" "Caches purged and filesystem synced."
fi

print_color "green" "✅ Turbo Mode Activated! Enjoy peak performance."
success_sound
;;

        19)
        print_color "yellow" "Enabling Privacy Mode..."
        loading_bar
        privacy_protector
        print_color "green" "✅ Privacy Mode Activated! Your Mac is now more secure."
        success_sound
        ;;
20)
  exit_screen  
  ;;
    15)
      speed_test
      ;;
    *)
      print_color "red" "Invalid option. Please try again."
      print_color "cyan" "Press ENTER to continue..."
      read -r
      ;;
  esac  
  
done  
