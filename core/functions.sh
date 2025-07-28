
check_dependencies() {
  local missing=()
  for tool in "$@"; do
    if ! command -v "$tool" &>/dev/null; then
      missing+=("$tool")
    fi
  done

  if [ ${#missing[@]} -ne 0 ]; then
    echo -e "${RED} Missing required tools:${RESET}"
    for tool in "${missing[@]}"; do
      echo -e " - ${YELLOW}${tool}${RESET}"
    done
    return 1
  fi
  return 0
}

timestamp() {
  date '+%Y-%m-%d %H:%M:%S'
}

pause_and_return() {
  read -rp "↩  Press Enter to go back..."
}



PrintAsciiColored() {
  echo -e "${BOLD}${YELLOW}$1${RESET}"
  sleep 0.1
}

echored() {
  echo -e "${RED}$1${RESET}"
}

print_ascii() {
  clear
  PrintAsciiColored "      ___           ___                         ___           ___           ___           ___      "
  PrintAsciiColored "     /__/\         /  /\                       /  /\         /  /\         /__/\         /  /\     "
  PrintAsciiColored "    _\_ \:\       /  /:/_                     /  /:/        /  /::\       |  |::\       /  /:/_    "
  PrintAsciiColored "   /__/\ \:\     /  /:/ /\    ___     ___    /  /:/        /  /:/\:\      |  |:|:\     /  /:/ /\   "
  PrintAsciiColored "  _\_ \:\ \:\   /  /:/ /:/_  /__/\   /  /\  /  /:/  ___   /  /:/  \:\   __|__|:|\:\   /  /:/ /:/_  "
  PrintAsciiColored " /__/\ \:\ \:\ /__/:/ /:/ /\ \  \:\ /  /:/ /__/:/  /  /\ /__/:/ \__\:\ /__/::::| \:\ /__/:/ /:/ /\ "
  PrintAsciiColored " \  \:\ \:\/:/ \  \:\/:/ /:/  \  \:\  /:/  \  \:\ /  /:/ \  \:\ /  /:/ \  \:\~~\__\/ \  \:\/:/ /:/ "
  PrintAsciiColored "  \  \:\ \::/   \  \::/ /:/    \  \:\/:/    \  \:\  /:/   \  \:\  /:/   \  \:\        \  \::/ /:/  "
  PrintAsciiColored "   \  \:\/:/     \  \:\/:/      \  \::/      \  \:\/:/     \  \:\/:/     \  \:\        \  \:\/:/   "
  PrintAsciiColored "    \  \::/       \  \::/        \__\/        \  \::/       \  \::/       \  \:\        \  \::/    "
  PrintAsciiColored "     \__\/         \__\/                       \__\/         \__\/         \__\/         \__\/     "
  sleep 1
  clear
  echored           "╔═════════════════════════════════════════════════════════════════════════════════════════════════╗"
  echored           "║          ONLY RUN THIS IF YOU KNOW WHAT YOU ARE DOING! USE THIS ON TARGETS WITH CONSENT         ║ "
  echored           "║                    ONLY DO THIS WITHIN SAFE AND ETHICAL CONFINMENTS                             ║"
  echored           "╚═════════════════════════════════════════════════════════════════════════════════════════════════╝"
  echo -e    "${CYAN} Please note this tool has been designed for debian based systems such as kali, parrot, mint, ect  ${RESET}"
  read -rp "Press enter to continue..."
  clear
}

sudocheck() {
    local require_root="${ROOTADVISED:-true}"

    if [[ "$require_root" == "true" ]]; then
        if (( EUID != 0 )); then
            echo "$(date '+%Y-%m-%d %H:%M:%S') - Script requested sudo privileges" >> "$LOGFILE"
            echo -e "${RED}[!] Root privileges required. Requesting sudo password...${RESET}"
            exec sudo bash "$0" "$@"
        else
            echo "$(date '+%Y-%m-%d %H:%M:%S') - Script was run with root privileges" >> "$LOGFILE"
        fi
    else
        if (( EUID == 0 )); then
            echo "$(date '+%Y-%m-%d %H:%M:%S') - Warning: Script run as root, but root is not required" >> "$LOGFILE"
            echo -e "${YELLOW}[!] Root access not advised, but script is running as root.${RESET}"
        else
            echo "$(date '+%Y-%m-%d %H:%M:%S') - Script run without root privileges (as advised)" >> "$LOGFILE"
        fi
    fi
}

check_wifi() {
    local require_wifi="${WIFIADVISED:-true}"

    if [[ "$require_wifi" != "true" ]]; then
        echo "$(date '+%Y-%m-%d %H:%M:%S') - Skipped internet connectivity check (WIFIADVISED=false)" >> "$LOGFILE"
        return 0
    fi

    if ping -q -c 1 -W 2 1.1.1.1 >/dev/null 2>&1; then
        echo "$(date '+%Y-%m-%d %H:%M:%S') - Internet connectivity check passed" >> "$LOGFILE"
        return 0
    else
        echo -e "${RED}[!] No internet connection detected. Running this script without WiFi is NOT advised.${RESET}"
        echo "$(date '+%Y-%m-%d %H:%M:%S') - No internet connection detected" >> "$LOGFILE"
        return 1
    fi
}

check_bash_version() {
    local REQUIRED_VERSION_MAJOR
    local REQUIRED_VERSION_MINOR

    IFS='.' read -r REQUIRED_VERSION_MAJOR REQUIRED_VERSION_MINOR <<< "$REQUIRED_BASH_VERSION"

    local CURRENT_MAJOR="${BASH_VERSINFO[0]}"
    local CURRENT_MINOR="${BASH_VERSINFO[1]}"

    if (( CURRENT_MAJOR > REQUIRED_VERSION_MAJOR )) || \
       { (( CURRENT_MAJOR == REQUIRED_VERSION_MAJOR )) && (( CURRENT_MINOR >= REQUIRED_VERSION_MINOR )); }; then
        echo "$(date '+%Y-%m-%d %H:%M:%S') - Bash version check passed: ${CURRENT_MAJOR}.${CURRENT_MINOR}" >> "$LOGFILE"
    else
        echo -e "${RED}[!] Bash version ${REQUIRED_BASH_VERSION} or higher is required. You are running ${CURRENT_MAJOR}.${CURRENT_MINOR}.${RESET}"
        echo "$(date '+%Y-%m-%d %H:%M:%S') - Bash version check failed: ${CURRENT_MAJOR}.${CURRENT_MINOR}" >> "$LOGFILE"
        exit 1
    fi
}


check_resolution() {
    local REQUIRED_COLS REQUIRED_ROWS
    REQUIRED_COLS="${REQUIRED_RES_COLS:-100}"
    REQUIRED_ROWS="${REQUIRED_RES_ROWS:-30}"

    local current_cols current_rows
    current_cols=$(tput cols)
    current_rows=$(tput lines)

    if (( current_cols < REQUIRED_COLS || current_rows < REQUIRED_ROWS )); then
        echo -e "${RED}[!] Terminal size too small: ${current_cols}x${current_rows}. Minimum required is ${REQUIRED_COLS}x${REQUIRED_ROWS}.${RESET}"
        echo "$(date '+%Y-%m-%d %H:%M:%S') - Terminal size check failed: ${current_cols}x${current_rows}" >> "$LOGFILE"
        return 1
    else
        echo "$(date '+%Y-%m-%d %H:%M:%S') - Terminal size check passed: ${current_cols}x${current_rows}" >> "$LOGFILE"
    fi
    return 0
}

clearlog() {
  echo "$(date '+%Y-%m-%d %H:%M:%S') - User initiated log file clearing" >> "$LOGFILE"
  read -rp "Are you sure you want to permanently clear the log file? (y/N): " confirm
  if [[ "$confirm" == "y" || "$confirm" == "Y" ]]; then
    > "$LOGFILE"
    echo "Log file has been cleared."
    echo "$(date '+%Y-%m-%d %H:%M:%S') - Log file was cleared by user" >> "$LOGFILE"
  else
    echo "Log clearing cancelled."
    echo "$(date '+%Y-%m-%d %H:%M:%S') - User cancelled log file clearing" >> "$LOGFILE"
  fi
  sleep 1
}