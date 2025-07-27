#!/bin/bash
# Always put this block at the top of the **core** project scripts, it is essential for the script to work!
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
source "${SCRIPT_DIR}/functions.sh" && source "${SCRIPT_DIR}/variables.sh"
trap "echo -e '\n${RED}Interrupted. Logging and exiting.${RESET}'; echo \"$(date '+%Y-%m-%d %H:%M:%S') - User force quit\" >> \"$LOGFILE\"; exit 1" SIGINT

#Home menu function
menu() {
  while true; do
    clear
    echo -e "|================================|"
    echo -e "|-------------HOME---------------|"
    echo -e "|================================|"
    echo -e "|1) Red Team Toolbox             |"
    echo -e "|2) Credits                      |"
    echo -e "|3) Help                         |"
    echo -e "|4) ${RED}Exit${RESET}                         |"
    echo -e "|================================|"
    read -rp "Choose (1-4): " choice

    echo "$(date '+%Y-%m-%d %H:%M:%S') - User selected option: $choice" >> "$LOGFILE"

    case $choice in
        1) Toolbox ;;
        2) Credits ;;
        3) Help ;;
        4)
            echo -e "${CYAN}Cya!${RESET}"
            echo "$(date '+%Y-%m-%d %H:%M:%S') - User exited the menu" >> "$LOGFILE"
            exit 0
            ;;
        *)
            echo "..u fr?, that's not even on the menu. Try again!"
            echo "$(date '+%Y-%m-%d %H:%M:%S') - User entered invalid option: $choice" >> "$LOGFILE"
            sleep 1
            ;;
    esac
  done
}

#  Red Team Toolbox Menu
Toolbox() {
  while true; do
    echo "$(date '+%Y-%m-%d %H:%M:%S') - User entered toolbox" >> "$LOGFILE"
    clear
    echo -e "|==================================================|"
    echo -e "|----------------${RED}RED${RESET} TEAM TOOLBOX------------------|"
    echo -e "|==================================================|"
    echo -e "| 1) ${YELLOW}LAN Attacks${RESET}                                   |"
    echo -e "| 2) ${YELLOW}WAN Attacks${RESET}                                   |"
    echo -e "| 3) ${YELLOW}Web Application Attacks${RESET}                       |"
    echo -e "| 4) ${YELLOW}Brute Force Attacks${RESET}                           |"
    echo -e "| 5) ${GREEN}Nmap Scanning${RESET}                                 |"
    echo -e "| 6) ${YELLOW}Payload Generation${RESET}                            |"
    echo -e "| 7) ${YELLOW}Post-Exploitation Tools${RESET}                       |"
    echo -e "| 8) ${YELLOW}Social Engineering Tools${RESET}                      |"
    echo -e "| 9) ${YELLOW}Bypass & Obfuscation Techniques${RESET}               |"
    echo -e "|10) ${YELLOW}Custom Shell Spawner${RESET}                          |"
    echo -e "|11) ${YELLOW}Wireless Attacks${RESET}                              |"
    echo -e "|12) ${YELLOW}Docker / Container Escapes${RESET}                    |"
    echo -e "|13) ${YELLOW}Reverse Shell Templates${RESET}                       |"
    echo -e "|14) ${YELLOW}Credential Harvesting${RESET}                         |"
    echo -e "|15) ${YELLOW}Malware Dropper Builder${RESET}                       |"
    echo -e "|16) ${YELLOW}Tunneling / Pivoting Tools${RESET}                    |"
    echo -e "|17) ${YELLOW}Persistence Techniques${RESET}                        |"
    echo -e "|18) ${YELLOW}Evasion & Sandbox Detection${RESET}                   |"
    echo -e "|19) ${YELLOW}Anti-Forensics Tools${RESET}                          |"
    echo -e "|20) ${YELLOW}UAC / Privilege Escalation${RESET}                    |"
    echo -e "|21) ${YELLOW}Active Directory Exploits${RESET}                     |"
    echo -e "|22) ${YELLOW}Linux Privesc / Enumeration${RESET}                   |"
    echo -e "|23) ${YELLOW}Windows Exploit Kit${RESET}                           |"
    echo -e "|24) ${YELLOW}Steganography Tools${RESET}                           |"
    echo -e "|25) ${YELLOW}Fileless Attack Scripts${RESET}                       |"
    echo -e "|26) ${YELLOW}Supply Chain Attack Simulators${RESET}                |"
    echo -e "|27) ${YELLOW}Mobile Attack Vectors (Android/iOS)${RESET}           |"
    echo -e "|28) ${YELLOW}Cloud Exploitation (AWS/GCP/Azure)${RESET}            |"
    echo -e "|29) ${YELLOW}Exfiltration Methods (Covert Channels)${RESET}        |"
    echo -e "|30) ${YELLOW}Flipper Zero Privilege Escalation${RESET}             |"
    echo -e "|31) ${YELLOW}Connect To A Proxy${RESET}                            |"
    echo -e "|==================================================|"
    echo -e "|32) ${RED}Back${RESET}                                          |"
    echo -e "|==================================================|"
    echo -e "${RED}YELLOW MAY INDICATE THAT THIS FEATURE IS NOT ${RESET}"
    echo -e "${RED}FULLY IMPLEMENTED YET BUT IN DEVELOPMENT${RESET}"
    read -rp "Choose (1-32): " choice

    echo "$(date '+%Y-%m-%d %H:%M:%S') - User selected toolbox option: $choice" >> "$LOGFILE"

    case $choice in
        1) LAN_Attacks ;;
        2) WAN_Attacks ;;
        3) WebApp_Attacks ;;
        4) BruteForce ;;
        5) nmapScan ;;
        6) PayloadGen ;;
        7) PostEx ;;
        8) SE_Tools ;;
        9) Bypass_Obf ;;
        10) ShellSpawner ;;
        11) Wireless ;;
        12) DockerEsc ;;
        13) ReverseShells ;;
        14) CredHarvest ;;
        15) MalwareDropperBuilder ;;
        16) TunnelingTools ;;
        17) PersistenceTechniques ;;
        18) EvasionDetection ;;
        19) AntiForensics ;;
        20) UAC_PrivEsc ;;
        21) ActiveDirectoryExploits ;;
        22) LinuxPrivesc ;;
        23) WindowsExploitKit ;;
        24) SteganographyTools ;;
        25) FilelessScripts ;;
        26) SupplyChainSim ;;
        27) MobileVectors ;;
        28) CloudExploitation ;;
        29) ExfiltrationMethods ;;
        30) FlipperZeroPrivEsc ;;
        31) ProxyConnect ;;
        32) break ;;
        *)
            echo -e "${RED}Bro... that’s not on the menu Try again.${RESET}"
            echo "$(date '+%Y-%m-%d %H:%M:%S') - User entered invalid toolbox option: $choice" >> "$LOGFILE"
            sleep 1
            ;;
    esac
  done
}


# Credits Section
Credits() {
  echo "$(date '+%Y-%m-%d %H:%M:%S') - User viewed credits" >> "$LOGFILE"
  clear
  echo -e "|================================|"
  echo -e "|-------------CREDITS------------|"
  echo -e "|================================|"
  cat "$CREDITS_FILE"
  echo -e "|================================|"
  read -rp "Press enter key to go back..."
  echo "$(date '+%Y-%m-%d %H:%M:%S') - User returned from credits" >> "$LOGFILE"
}

# Help Section
Help() {
  echo "$(date '+%Y-%m-%d %H:%M:%S') - User viewed help" >> "$LOGFILE"
  clear
  echo -e "|================================|"
  echo -e "|-------------HELP---------------|"
  echo -e "|================================|"
  cat "$HELP_FILE"
  echo -e "|================================|"
  read -rp "Press enter key to go back..."
  echo "$(date '+%Y-%m-%d %H:%M:%S') - User returned from help" >> "$LOGFILE"
}

# if all goes well, it should start the main menu
menu
