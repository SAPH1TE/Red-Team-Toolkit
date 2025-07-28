nmapscan() {
  local MODULE_NAME="Nmap Scanning"
  local SCRIPT_PATH="modules/nmapscanner.py"
  local REQUIRED_TOOLS=("nmap" "python3")

  if ! check_dependencies "${REQUIRED_TOOLS[@]}"; then
    echo -e "${RED} ${MODULE_NAME} aborted due to missing dependencies.${RESET}"
    pause_and_return
    return
  fi

  echo "$(timestamp) - User selected ${MODULE_NAME}" >> "$LOGFILE"
  echo -e "${GREEN}${MODULE_NAME} selected!${RESET}"

  read -rp " Enter the target IP address: " target
  if [[ -n "$target" ]]; then
    clear
    python3 "$SCRIPT_PATH" "$target"
  else
    echo -e "${RED} No target specified. Returning to menu.${RESET}"
  fi

  pause_and_return
}

arppoison() {
  local MODULE_NAME="ARP Poisoning"
  local SCRIPT_PATH="modules/arppoisoner.py"
  local REQUIRED_TOOLS=("python3" "pip3")

  if ! check_dependencies "${REQUIRED_TOOLS[@]}"; then
    echo -e "${RED} ${MODULE_NAME} aborted due to missing dependencies.${RESET}"
    pause_and_return
    return
  fi

  # Check if scapy is installed and offer to install it
  if ! python3 -c "import scapy" &> /dev/null; then
    echo -e "${YELLOW}Scapy library not found.${RESET}"
    read -rp "Attempt to install it now? (y/n): " install_scapy
    if [[ "$install_scapy" == "y" ]]; then
      pip3 install scapy
      if ! python3 -c "import scapy" &> /dev/null; then
        echo -e "${RED}Failed to install Scapy. Please install it manually ('pip3 install scapy').${RESET}"
        pause_and_return
        return
      fi
    else
        echo -e "${RED}Scapy is required to proceed. Aborting.${RESET}"
        pause_and_return
        return
    fi
  fi
  
  echo "$(timestamp) - User selected ${MODULE_NAME}" >> "$LOGFILE"
  echo -e "${GREEN}${MODULE_NAME} selected!${RESET}"
  echo -e "${YELLOW}This module requires root privileges to run.${RESET}"
  
  clear
  # Run the python script with sudo for network privileges
  sudo python3 "$SCRIPT_PATH"

  pause_and_return
}

#this is mostly well commented because it took me a while to get working... >_<
passwordcrack() {
  local MODULE_NAME="Password Cracking"
  local SCRIPT_PATH="modules/passwordcracker.py"
  local REQUIRED_TOOLS=("john" "python3")

  # Check for required system tools
  if ! check_dependencies "${REQUIRED_TOOLS[@]}"; then
    echo -e "${RED} ${MODULE_NAME} aborted due to missing dependencies.${RESET}"
    echo -e "${YELLOW}Please install John the Ripper to use this module.${RESET}"
    pause_and_return
    return
  fi

  echo "$(timestamp) - User selected ${MODULE_NAME}" >> "$LOGFILE"
  echo -e "${GREEN}${MODULE_NAME} selected!${RESET}"

  # 1. Get path to the hash file (mandatory)
  read -erp " Enter the path to the hash file: " hash_file
  if [[ ! -f "$hash_file" ]]; then
      echo -e "${RED}Error: Hash file not found at '$hash_file'.${RESET}"
      pause_and_return
      return
  fi

  # 2. Get path to the wordlist (optional)
  read -erp " Enter the path to the wordlist (or press Enter to skip): " wordlist
  if [[ -n "$wordlist" && ! -f "$wordlist" ]]; then
      echo -e "${RED}Error: Wordlist file not found at '$wordlist'.${RESET}"
      pause_and_return
      return
  fi

  # 3. Get the hash format (optional)
  read -erp " Enter the hash format (e.g., raw-md5, sha256crypt) or press Enter to skip: " hash_format
  
  clear

  # Build an array to hold the arguments for the Python script
  local args=("$hash_file")
  
  # Add wordlist to arguments if it was provided
  if [[ -n "$wordlist" ]]; then
    args+=("$wordlist")
  fi
  
  # Add hash format to arguments if it was provided
  if [[ -n "$hash_format" ]]; then
    # The Python script expects the format argument like --format=the_format
    args+=("--format=$hash_format")
  fi

  # Execute the Python script with all the collected arguments
  echo -e "${YELLOW}Starting password cracking...${RESET}"
  python3 "$SCRIPT_PATH" "${args[@]}"

  pause_and_return
}