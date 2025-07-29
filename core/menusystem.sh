#!/bin/bash 

# Essential block for core project scripts 
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )" 
source "${SCRIPT_DIR}/functions.sh" && source "${SCRIPT_DIR}/config.sh" && source "${SCRIPT_DIR}/modulefunctions.sh" 
trap "echo -e '\n${RED}Interrupted. Logging and exiting.${RESET}'; echo \"$(date '+%Y-%m-%d %H:%M:%S') - User force quit\" >> \"$LOGFILE\"; exit 1" SIGINT 
 

# Home menu function 
menu() { 
    while true; do 
        clear 
        echo -e "╔══════════════════════════════════════════════════╗" 
        echo -e "║                      ${BOLD}HOME${RESET}                        ║" 
        echo -e "╠══════════════════════════════════════════════════╣" 
        echo -e "║ 1) ${MAGENTA}Main Toolbox${RESET}                                  ║" 
        echo -e "║ 2) ${MAGENTA}Credits${RESET}                                       ║" 
        echo -e "║ 3) ${MAGENTA}Help${RESET}                                          ║" 
        echo -e "╠══════════════════════════════════════════════════╣" 
        echo -e "║ b) ${RED}Exit${RESET}                                          ║" 
        echo -e "╚══════════════════════════════════════════════════╝" 
        read -rp "Choose: " choice  
        echo "$(date '+%Y-%m-%d %H:%M:%S') - User selected option: $choice" >> "$LOGFILE" 
        if [[ -z "$choice" ]]; then
            echo "[!] Error: No option entered. Please try again."
            sleep 1 
            continue 
        fi

        case $choice in 
            1) toolbox ;; 
            2) credits ;; 
            3) help ;; 
            b) 
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

# Red Team Toolbox Menu 
toolbox() { 
    while true; do 
        echo "$(date '+%Y-%m-%d %H:%M:%S') - User entered toolbox" >> "$LOGFILE" 
        clear
        echo -e "╔══════════════════════════════════════════════════╗" 
        echo -e "║              ${RED}RED${RESET} TEAM TOOLBOX                    ║" 
        echo -e "╠══════════════════════════════════════════════════╣" 
        echo -e "║  1) ${YELLOW}Nmap Scanning${RESET}                                ║" 
        echo -e "║  2) ${RED}Connect To A Proxy${RESET}                           ║" 
        echo -e "║  3) ${YELLOW}ARP poisoning${RESET}                                ║" 
        echo -e "║  4) ${YELLOW}Hash Cracking${RESET}                                ║" 
        echo -e "║  5) ${YELLOW}Dos Attack Emulation${RESET}                         ║" 
        echo -e "║  6) ${YELLOW}SSH Brute Force${RESET}                              ║" 
        echo -e "║  7) ${RED}Subdomain enumeration${RESET}                        ║" 
        echo -e "║  8)                                              ║" 
        echo -e "║  9)                                              ║" 
        echo -e "║ 10)                                              ║" 
        echo -e "║ 11)                                              ║" 
        echo -e "║ 12)                                              ║" 
        echo -e "║ 13)                                              ║" 
        echo -e "║ 14)                                              ║" 
        echo -e "║ 15)                                              ║" 
        echo -e "║ 16)                                              ║" 
        echo -e "║ 17)                                              ║" 
        echo -e "║ 18)                                              ║" 
        echo -e "║ 19)                                              ║" 
        echo -e "║ 20)                                              ║" 
        echo -e "║ 21)                                              ║" 
        echo -e "║ 22)                                              ║" 
        echo -e "║ 23)                                              ║" 
        echo -e "║ 24)                                              ║" 
        echo -e "║ 25)                                              ║" 
        echo -e "╠══════════════════════════════════════════════════╣" 
        echo -e "║ b) ${RED}Back${RESET}                                          ║" 
        echo -e "╚══════════════════════════════════════════════════╝" 
        read -rp "Choose: " choice 
        echo "$(date '+%Y-%m-%d %H:%M:%S') - User selected toolbox option: $choice" >> "$LOGFILE" 
        if [[ -z "$choice" ]]; then
            echo "[!] Error: No option entered. Please try again."
            sleep 1 
            continue 
        fi

        case $choice in 
            1) nmapscan ;; 
            2) proxyconnect ;; 
            3) arppoisoning;; 
            4) passwordcrack;; 
            5) dosattack;; 
            6) sshbrute;;  
            7) subdomainenum;; 
            8) ;; 
            9) ;; 
            10) ;; 
            11) ;; 
            12) ;; 
            13) ;; 
            14) ;;  
            15) ;;  
            16) ;; 
            17) ;; 
            18) ;; 
            19) ;; 
            20) ;; 
            21) ;; 
            22) ;; 
            23) ;;
            24) ;; 
            25) ;; 
            b) break ;; 
            *) 
                echo -e "${RED}Bro... that’s not on the menu Try again!${RESET}" 
                echo "$(date '+%Y-%m-%d %H:%M:%S') - User entered invalid toolbox option: $choice" >> "$LOGFILE" 
                sleep 1 
                ;; 
        esac 
    done 
} 

# Credits Section 
credits() { 
    echo "$(date '+%Y-%m-%d %H:%M:%S') - User viewed credits" >> "$LOGFILE" 
    clear 
    echo -e "╔══════════════════════════════════════════════════╗" 
    echo -e "║                    ${BOLD}CREDITS${RESET}                       ║" 
    echo -e "╚══════════════════════════════════════════════════╝" 
    cat "$CREDITS_FILE" 
    echo "\n"
    read -rp "Press enter key to go back..." 
    echo "$(date '+%Y-%m-%d %H:%M:%S') - User returned from credits" >> "$LOGFILE" 
} 

# Help Section 
help() { 
    while true; do 
        clear 
        echo -e "╔══════════════════════════════════════════════════╗" 
        echo -e "║                      ${BOLD}HELP${RESET}                        ║" 
        echo -e "╠══════════════════════════════════════════════════╣" 
        echo -e "║ 1) ${MAGENTA}Clear log.txt${RESET}                                 ║" 
        echo -e "║ 2) ${MAGENTA}View Version${RESET}                                  ║" 
        echo -e "║ 3) ${MAGENTA}How to navigate${RESET}                               ║" 
        echo -e "║ 4) ${MAGENTA}About${RESET}                                         ║" 
        echo -e "╠══════════════════════════════════════════════════╣" 
        echo -e "║ b) ${RED}back${RESET}                                          ║" 
        echo -e "╚══════════════════════════════════════════════════╝" 
        read -rp "Choose: " choice 
        echo "$(date '+%Y-%m-%d %H:%M:%S') - User selected option: $choice" >> "$LOGFILE"
        if [[ -z "$choice" ]]; then
            echo "[!] Error: No option entered. Please try again."
            sleep 1 
            continue 
        fi 

        case $choice in 
            1) clearlog ;; 
            2) version ;; 
            3) navigate ;; 
            4) contribute ;; 
            b)  
                echo "$(date '+%Y-%m-%d %H:%M:%S') - User backed from help" >> "$LOGFILE" 
                break 
                ;; 
            *) 
                echo "..u fr?, that's not even on the menu. Try again!" 
                echo "$(date '+%Y-%m-%d %H:%M:%S') - User entered invalid option: $choice" >> "$LOGFILE" 
                sleep 1 
                ;; 
        esac 
    done 
} 

version() { 
    echo "$(date '+%Y-%m-%d %H:%M:%S') - User viewed version info" >> "$LOGFILE" 
    clear 
    echo -e "╔══════════════════════════════════════════════════╗" 
    echo -e "║                    ${BOLD}VERSION${RESET}                       ║" 
    echo -e "╠══════════════════════════════════════════════════╣" 
    echo -e "║ ${MAGENTA}Version:${VERSION}${RESET}                              ║" 
    echo -e "║ ${MAGENTA}Release Type: ${VERSION} ${RELEASETYPE}${RESET}                   ║" 
    echo -e "╚══════════════════════════════════════════════════╝" 
    pause_and_return 
} 

navigate() { 
    echo "$(date '+%Y-%m-%d %H:%M:%S') - User viewed navigation help" >> "$LOGFILE" 
    clear 
    echo -e "╔══════════════════════════════════════════════════╗" 
    echo -e "║                  ${BOLD}NAVIGATION${RESET}                      ║" 
    echo -e "╠══════════════════════════════════════════════════╣"  
    echo -e "║ - ${MAGENTA}Use ctrl+c to force quit${RESET}                       ║" 
    echo -e "║ - ${MAGENTA}Type the number or letter of the menu option${RESET}   ║" 
    echo -e "║   ${MAGENTA}you want.${RESET}                                      ║"
    echo -e "║                                                  ║" 
    echo -e "║ - ${MAGENTA}Press 'Enter' to select.${RESET}                       ║" 
    echo -e "║ - ${MAGENTA}Use 'b' to return to the previous menu.${RESET}        ║" 
    echo -e "╚══════════════════════════════════════════════════╝" 
    pause_and_return 
} 

contribute() { 
    echo "$(date '+%Y-%m-%d %H:%M:%S') - User viewed contribution help" >> "$LOGFILE" 
    clear 
    echo -e "╔══════════════════════════════════════════════════╗" 
    echo -e "║                    ${BOLD}ABOUT${RESET}                         ║" 
    echo -e "╠══════════════════════════════════════════════════╣" 
    echo -e "║ ${MAGENTA}It is advised to learn more about this through${RESET}   ║"
    echo -e "║ ${MAGENTA}The readme.md file that can be found on github${RESET}   ║"
    echo -e "║ ${MAGENTA}This project is publicly developed and accepting${RESET} ║" 
    echo -e "║ ${MAGENTA}contributions. Although it is currently in a${RESET}     ║" 
    echo -e "║ ${MAGENTA}alpha development phase so expect issues.${RESET}        ║" 
    echo -e "╚══════════════════════════════════════════════════╝" 
    pause_and_return 
} 

# Start the main menu 
menu 