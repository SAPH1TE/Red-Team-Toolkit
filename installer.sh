#!/bin/bash

# Define the name for the toolkit's directory
toolkit_dir="Red-Team-Toolkit"

#and yes i stole this from the main script, i dont care.    
check_wifi() {
    if ping -q -c 1 -W 2 1.1.1.1 >/dev/null 2>&1; then
        return 0
    else
        echo -e "[!] Failed to ping. Running this script without internet is NOT advised."
        read -rp "Press enter key to exit..." 
        exit 1
    fi
}

check_wifi
echo "Do you want the script to be set up in this folder? (Y/N)"
read -rp "> " choice

case "$choice" in
    y|Y)
        # --- NEW: Check if the directory already exists ---
        if [ -d "$toolkit_dir" ]; then
            echo "Directory '$toolkit_dir' already exists."
            echo "Do you want to remove it and force a fresh install? (Y/N)"
            read -rp "> " reinstall_choice
            
            if [[ "$reinstall_choice" == "y" || "$reinstall_choice" == "Y" ]]; then
                echo "Removing existing directory..."
                rm -rf "$toolkit_dir"
            else
                echo "Install cancelled. To run the existing version, navigate to the '$toolkit_dir' directory and run './launcher.sh'."
                exit 0
            fi
        fi
        # --- END NEW ---

        echo "Cloning Red-Team-Toolkit repo into $(pwd)/$toolkit_dir..."
        if git clone https://github.com/SAPH1TE/Red-Team-Toolkit.git "$toolkit_dir"; then
            echo "Successfully downloaded!"
            
            launcher_path="$toolkit_dir/launcher.sh"
            if [[ -f "$launcher_path" ]]; then
                chmod +x "$launcher_path"
                echo -e "\nMade launcher executable."
                echo "To run the toolkit, use the commands:"
                echo "cd $toolkit_dir && ./launcher.sh"
            else
                echo "Error: launcher.sh not found in the '$toolkit_dir' directory."
            fi
            
        else
            echo "Git clone failed. Please check your internet connection."
            exit 1
        fi
        ;;
    n|N)
        echo "Alright then, Peace out!"
        exit 0
        ;;
    *)
        echo "That option does NOT appear to be a choice. Try again."
        sleep 1
        exec "$0" # restart script
        ;;
esac