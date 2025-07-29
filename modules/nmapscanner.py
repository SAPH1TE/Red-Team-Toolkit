# modules/nmapscanner.py

# Import necessary standard libraries.
import argparse
import subprocess
import sys
import os
import shlex  # For robust parsing of custom flags

# A dictionary of predefined Nmap scan profiles for user convenience.
SCAN_PROFILES = {
    "1": ("Quick Scan", "-T4 -F", "Scans the most common 100 ports quickly."),
    "2": ("Quick Scan Plus", "-sV -T4 -O -F", "Quick scan plus version and OS detection."),
    "3": ("Intense Scan", "-T4 -A -v", "Enables OS/version detection, script scanning, and traceroute."),
    "4": ("Intense Scan + UDP", "-sS -sU -T4 -A -v", "Intense scan that includes UDP ports."),
    "5": ("Intense Scan All TCP Ports", "-p- -T4 -A -v", "Intense scan against all 65535 TCP ports."),
    "6": ("Ping Scan (No Ports)", "-sn", "Discovers online hosts without port scanning."),
    "7": ("Slow Comprehensive Scan", "-sS -sU -T4 -A -v -PE -PP -PS80,443 -PA3389 -PU40125 -PY",
          "A slow, comprehensive TCP/UDP scan using multiple probe types for host discovery.")
}


def display_profiles():
    """Prints the available Nmap scan profiles for the user to choose from."""
    print("\nAvailable Scan Profiles:")
    for key, (name, _, desc) in SCAN_PROFILES.items():
        print(f"  [{key}] {name:<28} ({desc})")
    print("  [c] Custom Scan" + " " * 20 + "(Enter your own flags)")
    print()


def scan_target(target, scan_args_str, output_filename=None):
    """
    Executes an Nmap scan, optionally saving the results to a file.
    This function is designed to be robust against argument parsing errors.

    Args:
        target (str): The IP address, hostname, or network range to scan.
        scan_args_str (str): A string of Nmap flags.
        output_filename (str, optional): The path to save the XML output file.
                                         If None, output is not saved to a file.
                                         Defaults to None.
    """
    print(f"[*] Preparing scan for target: {target}")

    if output_filename:
        print(f"[*] The output file will be: '{output_filename}'")
    else:
        print("[*] Scan output will be displayed on the console only (not saved to a file).")

    try:
        # --- Robust Command Construction ---
        # The command is built as a list of arguments for safety.

        # 1. Start with the program executable.
        command_list = ['nmap']

        # 2. Add the scan profile or custom flags.
        command_list.extend(shlex.split(scan_args_str))
        
        # 3. Add the target to scan.
        command_list.append(target)
        
        # 4. CRITICAL STEP: Conditionally add the output flag and its filename.
        #    This runs only if an output_filename was provided.
        if output_filename:
            command_list.extend(['-oX', output_filename])

    except ValueError as e:
        print(f"[!] Error: Invalid custom flags provided. Could not parse: {e}", file=sys.stderr)
        return

    # For debugging, print the exact command that will be executed.
    print(f"[*] Final command list being executed: {command_list}")
    print(f"[*] Command as string: {' '.join(command_list)}")
    print("-" * 50)

    try:
        # Execute the command by passing the list directly.
        process = subprocess.Popen(
            command_list,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            text=True,
            bufsize=1
        )

        # Stream Nmap's progress to the console in real-time.
        if process.stdout:
            for line in iter(process.stdout.readline, ''):
                print(line, end='')

        # Wait for the scan to finish and capture any final error output.
        _, stderr_final = process.communicate()

        if stderr_final:
            print("\n--- Nmap Errors (STDERR) ---", file=sys.stderr)
            print(stderr_final, file=sys.stderr)
            print("--------------------------", file=sys.stderr)

        print("-" * 50)

        if process.returncode == 0:
            print("[*] Nmap scan completed successfully.")
            # Only perform file checks if we intended to create a file.
            if output_filename:
                if os.path.exists(output_filename):
                    # Verify that the created file is not empty.
                    if os.path.getsize(output_filename) > 0:
                         print(f"[*] Success: XML output saved to '{output_filename}'.")
                    else:
                         print(f"[!] Warning: Output file '{output_filename}' was created but is empty.")
                else:
                    print(f"[!] Warning: Nmap completed, but the output file was not found.")
        else:
            print(f"[!] Nmap exited with an error (Code: {process.returncode}).", file=sys.stderr)

    except FileNotFoundError:
        print("[!] FATAL: 'nmap' command not found. Ensure Nmap is installed and in your system's PATH.",
              file=sys.stderr)
    except Exception as e:
        print(f"[!] An unexpected error occurred during execution: {e}", file=sys.stderr)


def main():
    """The main function that drives the script."""
    parser = argparse.ArgumentParser(
        description="Nmap Scanner Module: A user-friendly wrapper for common Nmap scans.",
        formatter_class=argparse.RawTextHelpFormatter
    )
    parser.add_argument("target", help="The IP address, hostname, or network range to scan.")

    # Show help if the script is run without a target.
    if len(sys.argv) == 1:
        parser.print_help(sys.stderr)
        sys.exit(1)

    args = parser.parse_args()
    display_profiles()

    while True:
        try:
            profile_choice = input("Choose a scan profile number or 'c' for custom: ").strip().lower()
            scan_flags = None

            if profile_choice in SCAN_PROFILES:
                _, scan_flags, _ = SCAN_PROFILES[profile_choice]
            elif profile_choice == 'c':
                scan_flags = input("Enter your custom nmap flags (e.g., -sV -p 80,443 --reason): ")
            else:
                print("[!] Invalid choice. Please select a number from the list or 'c'.")
                continue  # Ask for profile choice again

            # --- NEW: Ask user if they want to save the output ---
            output_filename = None
            save_choice = input("Do you want to save the output to a file? Other modules can use this. [y/N]: ").strip().lower()
            if save_choice in ['y', 'yes']:
                try:
                    filename_prompt = "Enter the output filename (default: nmap_scan_results.xml): "
                    output_filename = input(filename_prompt).strip()
                    if not output_filename:
                        output_filename = "nmap_scan_results.xml"
                except (KeyboardInterrupt, EOFError):
                     print("\n[*] Skipping file save. Exiting.")
                     break
            
            # Execute the scan with the chosen options
            scan_target(args.target, scan_flags, output_filename)
            break # Exit the loop after the scan is initiated

        except (KeyboardInterrupt, EOFError):
            print("\n[*] Exiting.")
            break


if __name__ == "__main__":
    main()