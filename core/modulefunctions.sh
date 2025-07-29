#I mostly made this file to seperate the module functions which i find more important than the general functions
#and also so it can be catagorized better
nmapscan() {
  clear
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

arppoisoning() {
  clear
  local MODULE_NAME="ARP Poisoning"
  local SCRIPT_PATH="modules/arppoisoning.py"
  local REQUIRED_TOOLS=("python3" "pip3")
  local REQUIRED_PY_MODULES=("scapy")

  if ! check_dependencies "${REQUIRED_TOOLS[@]}"; then
    echo -e "${RED} ${MODULE_NAME} aborted due to missing dependencies.${RESET}"
    pause_and_return
    return
  fi

  if ! check_py_modules "${REQUIRED_PY_MODULES[@]}"; then
    echo -e "${YELLOW}Missing Python module(s) required by ${MODULE_NAME}.${RESET}"
    read -rp "Attempt to install them now? (y/n): " install_choice
    if [[ "$install_choice" =~ ^[Yy]$ ]]; then
      pip3 install "${REQUIRED_PY_MODULES[@]}"
      if ! check_py_modules "${REQUIRED_PY_MODULES[@]}"; then
        echo -e "${RED}Installation failed. Please install manually with pip3.${RESET}"
        pause_and_return
        return
      fi
    else
      echo -e "${RED}${MODULE_NAME} aborted due to missing Python dependencies.${RESET}"
      pause_and_return
      return
    fi
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

# This starts to get well commented because ive had some issues with it..
passwordcrack() {
  clear
  local MODULE_NAME="Password Cracking"
  local SCRIPT_PATH="modules/passwordcracker.py"
  local REQUIRED_TOOLS=("john" "python3")

  if ! check_dependencies "${REQUIRED_TOOLS[@]}"; then
    echo -e "${RED} ${MODULE_NAME} aborted due to missing dependencies.${RESET}"
    echo -e "${YELLOW}Please install John the Ripper to use this module.${RESET}"
    pause_and_return
    return
  fi

  if ! check_py_modules "${REQUIRED_PY_MODULES[@]}"; then
    echo -e "${YELLOW}Missing Python module(s) required by ${MODULE_NAME}.${RESET}"
    read -rp "Attempt to install them now? (y/n): " install_choice
    if [[ "$install_choice" =~ ^[Yy]$ ]]; then
      pip3 install "${REQUIRED_PY_MODULES[@]}"
      if ! check_py_modules "${REQUIRED_PY_MODULES[@]}"; then
        echo -e "${RED}Installation failed. Please install manually with pip3.${RESET}"
        pause_and_return
        return
      fi
    else
      echo -e "${RED}${MODULE_NAME} aborted due to missing Python dependencies.${RESET}"
      pause_and_return
      return
    fi
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
  
  # Add wordlist to arguments if it waslocal REQUIRED_PY_MODULES=("") provided
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

dosattack() {
  clear
  local MODULE_NAME="Denial of Service Attack"
  local SCRIPT_PATH="modules/dosattack.py"
  local REQUIRED_TOOLS=("python3")
  local REQUIRED_PY_MODULES=("scapy")

  if ! check_dependencies "${REQUIRED_TOOLS[@]}"; then
    echo -e "${RED} ${MODULE_NAME} aborted due to missing dependencies.${RESET}"
    pause_and_return
    return
  fi

  if ! check_py_modules "${REQUIRED_PY_MODULES[@]}"; then
    echo -e "${YELLOW}Missing Python module(s) required by ${MODULE_NAME}.${RESET}"
    read -rp "Attempt to install them now? (y/n): " install_choice
    if [[ "$install_choice" =~ ^[Yy]$ ]]; then
      pip3 install "${REQUIRED_PY_MODULES[@]}"
      if ! check_py_modules "${REQUIRED_PY_MODULES[@]}"; then
        echo -e "${RED}Installation failed. Please install manually with pip3.${RESET}"
        pause_and_return
        return
      fi
    else
      echo -e "${RED}${MODULE_NAME} aborted due to missing Python dependencies.${RESET}"
      pause_and_return
      return
    fi
  fi

  echo "$(timestamp) - User selected ${MODULE_NAME}" >> "$LOGFILE"
  echo -e "${GREEN}${MODULE_NAME} selected!${RESET}"
  echo -e "${YELLOW}Warning: Launching attacks against systems you do not own is illegal.${RESET}"

  local target_ip target_port attack_type duration
  read -rp "Enter Target IP: " target_ip
  read -rp "Enter Target Port: " target_port
  read -rp "Enter Attack Type (udp/syn): " attack_type
  read -rp "Enter Duration in Seconds (e.g., 60): " duration

  if [[ -z "$target_ip" || -z "$target_port" || -z "$attack_type" || -z "$duration" ]]; then
      echo -e "${RED}All fields are required. Aborting.${RESET}"
      pause_and_return
      return
  fi

  clear
  echo -e "${YELLOW}Starting Denial of Service attack...${RESET}"
  # Sudo is used because creating raw sockets for attacks like SYN floods requires root.
  sudo python3 "$SCRIPT_PATH" "$target_ip" "$target_port" "$attack_type" --duration "$duration"

  pause_and_return
}

# This function handles the SSH Brute-Force module
sshbrute() {
  local MODULE_NAME="SSH Brute-Force"
  local SCRIPT_PATH="modules/sshbrute.py"
  local REQUIRED_TOOLS=("python3")
  local REQUIRED_PY_MODULES=("paramiko")

  if ! check_dependencies "${REQUIRED_TOOLS[@]}"; then
    echo -e "${RED} ${MODULE_NAME} aborted due to missing dependencies.${RESET}"
    pause_and_return
    return
  fi

  if ! check_py_modules "${REQUIRED_PY_MODULES[@]}"; then
    echo -e "${YELLOW}Missing Python module(s) required by ${MODULE_NAME}.${RESET}"
    read -rp "Attempt to install them now? (y/n): " install_choice
    if [[ "$install_choice" =~ ^[Yy]$ ]]; then
      pip3 install "${REQUIRED_PY_MODULES[@]}"
      if ! check_py_modules "${REQUIRED_PY_MODULES[@]}"; then
        echo -e "${RED}Installation failed. Please install manually with pip3.${RESET}"
        pause_and_return
        return
      fi
    else
      echo -e "${RED}${MODULE_NAME} aborted due to missing Python dependencies.${RESET}"
      pause_and_return
      return
    fi
  fi

  echo "$(timestamp) - User selected ${MODULE_NAME}" >> "$LOGFILE"
  echo -e "${GREEN}${MODULE_NAME} selected!${RESET}"
  echo -e "${YELLOW}This module will guide you through setting up an SSH brute-force attack.${RESET}"

  # --- Collect Target Information ---
  local target_host user_arg wordlist_path port threads
  read -rp "Enter the target IP address or hostname: " target_host
  if [[ -z "$target_host" ]]; then
    echo -e "${RED}No target specified. Returning to menu.${RESET}"
    pause_and_return
    return
  fi

  # --- Collect User/Userlist Informatilocal REQUIRED_PY_MODULES=("")on ---
  read -rp "Provide a [s]ingle user or a [u]serlist file? (s/u): " user_choice
  case "$user_choice" in
    s|S)
      read -rp "Enter the single username: " single_user
      if [[ -z "$single_user" ]]; then
        echo -e "${RED}No username provided. Aborting.${RESET}"
        pause_and_return
        return
      fi
      user_arg="-u ${single_user}"
      ;;
    u|U)
      read -rp "Enter the path to the userlist file: " userlist_file
      if [[ ! -f "$userlist_file" ]]; then
        echo -e "${RED}Userlist file not found at '${userlist_file}'. Aborting.${RESET}"
        pause_and_return
        return
      fi
      user_arg="-U ${userlist_file}"
      ;;
    *)
      echo -e "${RED}Invalid choice. Returning to menu.${RESET}"
      pause_and_return
      return
      ;;
  esac

  # --- Collect Wordlist Information ---
  read -rp "Enter the path to the password wordlist: " wordlist_path
  if [[ ! -f "$wordlist_path" ]]; then
    echo -e "${RED}Wordlist file not found at '${wordlist_path}'. Aborting.${RESET}"
    pause_and_return
    return
  fi

  # --- Collect Optional Parameters ---
  read -rp "Enter the target port [default: 22]: " port
  port=${port:-22} # Set to 22 if user enters nothing

  read -rp "Enter the number of threads [default: 5]: " threads
  threads=${threads:-5} # Set to 5 if user enters nothing

  # --- Execute the Python Script ---
  clear
  # Note: We do not use quotes around user_arg so that "-u user" is treated as two arguments
  python3 "$SCRIPT_PATH" "$target_host" ${user_arg} -w "$wordlist_path" -p "$port" -t "$threads"

  pause_and_return
}

subdomainenum() {
  clear
  local MODULE_NAME="Subdomain Enumeration"
  local SCRIPT_PATH="modules/subdomainenum.py"
  local REQUIRED_TOOLS=("python3")

  if ! check_dependencies "${REQUIRED_TOOLS[@]}"; then
    echo -e "${RED} ${MODULE_NAME} aborted due to missing dependencies.${RESET}"
    pause_and_return
    return
  fi

  echo "$(timestamp) - User selected ${MODULE_NAME}" >> "$LOGFILE"
  echo -e "${GREEN}${MODULE_NAME} selected!${RESET}"
  echo -e "${YELLOW}This module performs DNS brute-forcing to find subdomains.${RESET}"
  
  # --- Gather User Input ---
  local target_domain wordlist_path thread_count output_file
  
  read -rp "Enter the target domain (e.g., example.com): " target_domain
  if [[ -z "$target_domain" ]]; then
    echo -e "${RED}No target domain provided. Returning to menu.${RESET}"
    pause_and_return
    return
  fi

  read -rp "Enter the number of threads [Default: 30]: " thread_count
  # Set default to 30 if user input is empty
  thread_count=${thread_count:-30}

  read -erp "Enter filename to save results (optional, press Enter to skip): " output_file

  # --- Build the command arguments array ---
  local args=()
  args+=("$target_domain")
  args+=("-w" "$wordlist_path")
  args+=("-t" "$thread_count")

  # Add the output file argument only if the user provided a filename
  if [[ -n "$output_file" ]]; then
    args+=("-o" "$output_file")
  fi

  # --- Execute the Python script ---
  clear
  echo -e "${YELLOW}Starting subdomain enumeration...${RESET}"
  python3 "$SCRIPT_PATH" "${args[@]}"

  pause_and_return
}