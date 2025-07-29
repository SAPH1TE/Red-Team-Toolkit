#!/bin/bash

# --- Red Teaming Toolkit: System Readiness Checker & Installer ---
# This script checks dependencies for each module, reports the status,
# and then offers to install any missing packages.

# --- Configuration ---
# Define modules and their dependencies here.
# Format: "System-Package-1 System-Package-2|Python-Package-1 Python-Package-2"
# Use a pipe "|" to separate system packages from Python packages.
declare -A MODULE_DEPS
MODULE_DEPS["Nmap Scanner"]="nmap|argparse" # argparse is standard, but good practice to list
MODULE_DEPS["Password Cracker"]="john|argparse"
MODULE_DEPS["ARP Poisoning"]="python3-pip|scapy" # scapy is the key dependency here
# Let's formally add the proxy module from your temp code.
MODULE_DEPS["Proxy Tester"]="python3-pip|requests|free_proxy"

# --- Colors for Output ---
C_RESET='\e[0m'
C_RED='\e[0;31m'
C_GREEN='\e[0;32m'
C_YELLOW='\e[1;33m'
C_BLUE='\e[0;34m'

# --- State-Tracking Arrays ---
declare -A MODULE_STATUS
declare -A MODULE_MISSING_DEPS
ALL_MISSING_SYS_DEPS=()
ALL_MISSING_PY_DEPS=()

# --- Functions ---

print_separator() {
    printf -- '-%.0s' {1..70}
    printf "\n"
}

# Master function to check all dependencies and populate status arrays
run_dependency_check() {
    echo -e "${C_BLUE}[*] Running dependency check for all modules...${C_RESET}"
    # Reset missing dependency lists before checking
    ALL_MISSING_SYS_DEPS=()
    ALL_MISSING_PY_DEPS=()

    for module in "${!MODULE_DEPS[@]}"; do
        deps_string="${MODULE_DEPS[$module]}"
        sys_deps="${deps_string%|*}"
        py_deps="${deps_string#*|}"

        # If a module has no python deps, the string will be the same after splitting
        if [[ "$sys_deps" == "$py_deps" ]]; then
            py_deps=""
        fi

        missing_for_this_module=""
        all_deps_met=true

        # Check system dependencies
        for dep in $sys_deps; do
            if ! command -v "$dep" &> /dev/null; then
                all_deps_met=false
                missing_for_this_module+="$dep(system) "
                ALL_MISSING_SYS_DEPS+=("$dep")
            fi
        done

        # Check Python dependencies
        for dep in $py_deps; do
            # free_proxy's import name is different from its pip name
            local import_name=$dep
            if [[ "$dep" == "free_proxy" ]]; then
                import_name="fp"
            fi
            if ! python3 -c "import $import_name" &> /dev/null; then
                all_deps_met=false
                missing_for_this_module+="$dep(python) "
                ALL_MISSING_PY_DEPS+=("$dep")
            fi
        done

        if $all_deps_met; then
            MODULE_STATUS["$module"]="${C_GREEN}Ready${C_RESET}"
            MODULE_MISSING_DEPS["$module"]=""
        else
            MODULE_STATUS["$module"]="${C_RED}Unavailable${C_RESET}"
            MODULE_MISSING_DEPS["$module"]="$missing_for_this_module"
        fi
    done
}

# Master function to display the status report
display_status_report() {
    echo ""
    print_separator
    echo -e "${C_YELLOW}System Readiness Report${C_RESET}"
    print_separator
    printf "%-25s | %-15s | %s\n" "Module Name" "Status" "Missing Dependencies"
    print_separator

    for module in "${!MODULE_DEPS[@]}"; do
        status="${MODULE_STATUS[$module]}"
        missing="${MODULE_MISSING_DEPS[$module]}"
        printf "%-25s | ${status} | ${C_RED}%s${C_RESET}\n" "$module" "$missing"
    done
    print_separator
    echo ""
}

# Master function to handle installation
handle_installation() {
    # Get unique lists of missing packages
    unique_sys_deps=$(echo "${ALL_MISSING_SYS_DEPS[@]}" | tr ' ' '\n' | sort -u | tr '\n' ' ')
    unique_py_deps=$(echo "${ALL_MISSING_PY_DEPS[@]}" | tr ' ' '\n' | sort -u | tr '\n' ' ')

    if [[ -z "$unique_sys_deps" && -z "$unique_py_deps" ]]; then
        echo -e "${C_GREEN}[*] All dependencies are met. Your toolkit is fully operational!${C_RESET}"
        return
    fi

    echo -e "${C_YELLOW}[!] Some modules are unavailable due to missing dependencies.${C_RESET}"
    echo -e "${C_YELLOW} It is not completley advised to download all packages due to bloat.${C_RESET}"
    read -p "Do you want to attempt to install all missing packages now? (y/n): " choice

    if [[ "$choice" != "y" && "$choice" != "Y" ]]; then
        echo "[*] Installation skipped. You can run this installer again later."
        return
    fi

    # Install System Packages
    if [[ ! -z "$unique_sys_deps" ]]; then
        echo -e "${C_BLUE}[*] Installing system packages: $unique_sys_deps...${C_RESET}"
        sudo apt-get update && sudo apt-get install -y $unique_sys_deps
        if [[ $? -ne 0 ]]; then
            echo -e "${C_RED}[!] ERROR: Failed to install one or more system packages. Please try installing them manually.${C_RESET}"
        fi
    fi

    # Install Python Packages
    if [[ ! -z "$unique_py_deps" ]]; then
        echo -e "${C_BLUE}[*] Installing Python packages: $unique_py_deps...${C_RESET}"
        python3 -m pip install $unique_py_deps
         if [[ $? -ne 0 ]]; then
            echo -e "${C_RED}[!] ERROR: Failed to install one or more Python packages. Please try installing them manually.${C_RESET}"
        fi
    fi
}


# --- Main Execution ---
clear
echo "========================================================"
echo "    Red Teaming Toolkit: System Readiness Checker"
echo "========================================================"
echo "This script will check your system and report which"
echo "modules are ready to use."
echo ""

# 1. Check for root privileges (needed for installation)
if [[ $EUID -ne 0 ]]; then
   echo -e "${C_YELLOW}[!] This script may need to install packages using sudo.${C_RESET}"
   echo "[!] You may be prompted for your password during installation."
   sudo -v || exit 1
fi

# 2. Run initial check and show report
run_dependency_check
display_status_report

# 3. Offer to install missing packages
handle_installation

# 4. Re-run the check and display the final report
echo ""
echo -e "${C_BLUE}[*] Re-running check to verify installation...${C_RESET}"
run_dependency_check
display_status_report

echo "[*] Setup process complete."