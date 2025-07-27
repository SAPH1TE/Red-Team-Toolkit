nmapScan() {
  REQUIRED_TOOLS=("nmap" "python3")
  MISSING_TOOLS=()

  for tool in "${REQUIRED_TOOLS[@]}"; do
    if ! command -v "$tool" &>/dev/null; then
      MISSING_TOOLS+=("$tool")
    fi
  done

  if [ ${#MISSING_TOOLS[@]} -eq 0 ]; then
    echo "$(date '+%Y-%m-%d %H:%M:%S') - User selected Nmap Scanning" >> "$LOGFILE"
    echo -e "${GREEN}Nmap Scanning selected!${RESET}"
    read -rp "Enter the target IP address: " target
    if [[ -n "$target" ]]; then
      python3 Modules/nmap_scanner.py "$target"
    else
      echo -e "${RED}No target specified. Returning to menu.${RESET}"
    fi
    read -rp "Press enter to return to the toolbox menu..."
  else
    echo -e "${RED} Required tools missing:${RESET}"
    for missing in "${MISSING_TOOLS[@]}"; do
      echo -e " - ${YELLOW}$missing${RESET}"
    done
    echo -e "${RED}Vulnerability scanning aborted. Please install the missing packages above to continue.${RESET}"
    read -rp "Press enter to return to the toolbox menu..."
    break
  fi
}

ProxyConnect() {
  # This is highly commented because this was hell to make... let alone make work
  # List of Python modules to check, using their import names
  REQUIRED_MODULES=("requests" "socks")
  MISSING_MODULES=()

  # First, check for the python3 executable itself
  if ! command -v python3 &>/dev/null; then
    echo -e "${RED}Error: python3 is not installed or not in PATH.${RESET}"
    read -rp "Press enter to return to the toolbox menu..."
    return # Use return instead of break in a function
  fi

  # Now, loop through the Python modules and try to import them
  for module in "${REQUIRED_MODULES[@]}"; do
    # Ask python3 to import the module. Redirect output to hide it.
    # If the import fails, the command will have a non-zero exit code.
    if ! python3 -c "import $module" &>/dev/null; then
      MISSING_MODULES+=("$module")
    fi
  done

  # Check if the list of missing modules is empty
  if [ ${#MISSING_MODULES[@]} -eq 0 ]; then
    echo -e "${GREEN}All dependencies found. Starting Proxy Connector...${RESET}"
    # This path might need to be adjusted depending on your folder structure
    python3 Modules/proxy_connect.py
    read -rp "Press enter to return to the toolbox menu..."
  else
    echo -e "${RED}Required Python libraries are missing:${RESET}"
    for missing in "${MISSING_MODULES[@]}"; do
      # Provide helpful installation instructions
      echo -e " - ${YELLOW}$missing${RESET} (Install with: ${CYAN}pip install ${missing} ${RESET} or your system's package manager)"
    done
    echo -e "${RED}Proxy connection aborted. Please install the missing libraries.${RESET}"
    read -rp "Press enter to return to the toolbox menu..."
  fi
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
  echored           "==================================================================================================="
  echored           "-----------ONLY RUN THIS IF YOU KNOW WHAT YOU ARE DOING! USE THIS ON TARGETS WITH CONSENT----------"
  echored           "---------------------ONLY DO THIS WITHIN SAFE AND ETHICAL CONFINMENTS------------------------------"
  echored           "==================================================================================================="
  read -rp "Press enter to continue..."
  clear
}

sudocheck() {
  if (( EUID != 0 )); then
    echo "$(date '+%Y-%m-%d %H:%M:%S') - Script requested sudo privileges" >> "$LOGFILE"
    echo -e "${RED} Root privileges check failed. Requesting sudo password... ${RESET}"
    exec sudo bash "$0" "$@"
  else
    echo "$(date '+%Y-%m-%d %H:%M:%S') - Script was run with root privileges" >> "$LOGFILE"
  fi
}

check_wifi() {
    if ping -q -c 1 -W 2 1.1.1.1 >/dev/null 2>&1; then
        return 0
    else
        echo -e "${RED}[!] No internet connection detected. Running this script without WiFi is NOT advised.${RESET}"
        echo "$(date '+%Y-%m-%d %H:%M:%S') - No internet connection was detected" >> "$LOGFILE"
        return 1
    fi
}



check_resolution() {
    local min_cols=100
    local min_rows=30
    local cols=$(tput cols)
    local rows=$(tput lines)

    if (( cols < min_cols || rows < min_rows )); then
        echo -e "${RED}[!] Terminal size too small: ${cols}x${rows}. Resize your window to at least ${min_cols}x${min_rows} to have the UI display properly.${RESET}"
        echo "$(date '+%Y-%m-%d %H:%M:%S') - Terminal size was too small: ${cols}x${rows}" >> "$LOGFILE"
        return 1
    fi
    return 0
}