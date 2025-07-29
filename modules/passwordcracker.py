# modules/passwordcracker.py

import os
import argparse
import subprocess
import sys

def display_banner():
    """Displays a banner for the module."""
    print("\n" + "="*50)
    print(" " * 12 + "Password Cracking Module")
    print(" " * 15 + "using John the Ripper")
    print("="*50 + "\n")

def crack_passwords(hash_file, wordlist=None, hash_format=None):
    """
    Uses John the Ripper to crack passwords from a hash file.
    """
    if not os.path.exists(hash_file):
        print(f"[!] Error: Hash file not found at '{hash_file}'")
        return

    # Add an ethical warning.
    print("[!] LEGAL & ETHICAL WARNING:")
    print("[!] Cracking passwords without proper authorization is illegal.")
    print("[!] Ensure you have explicit permission to test the target hashes.\n")

    # --- IMPROVED SESSION AWARENESS BLOCK ---
    rec_file = "john.rec"
    command = []  # Initialize command list

    if os.path.exists(rec_file):
        print(f"[*] An existing session file ('{rec_file}') was found.")
        resume_choice = input("Do you want to [r]esume the last session or [s]tart a new one? (r/s): ").lower().strip()
        
        if resume_choice == 'r':
            print("[*] Attempting to resume session...")
            command = ['john', '--restore']
        elif resume_choice == 's':
            print("[*] A new session will be started. The old 'john.rec' will be ignored for this run.")
            # By doing nothing here, we let the logic below build a new command.
            pass
        else:
            print("[!] Invalid choice. Aborting.")
            return

    # This block now runs if it's the very first session OR if the user chose 's' to start a new one.
    if not command:
        command = ['john']
        if wordlist:
            if not os.path.exists(wordlist):
                print(f"[!] Error: Wordlist not found at '{wordlist}'")
                return
            command.append(f"--wordlist={wordlist}")
        else:
            print("[*] No wordlist specified. John will use its default cracking modes (brute-force, etc.).")
        
        if hash_format:
            command.append(f"--format={hash_format}")
        
        command.append(hash_file)

    print(f"\n[*] Preparing to run command: {' '.join(command)}")

    try:
        process = subprocess.Popen(command, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, text=True)
        print("[*] John the Ripper is running. Output will be displayed below:")
        print("-" * 50)
        
        for line in iter(process.stdout.readline, ''):
            print(line.strip())
        
        process.wait()
        rc = process.poll()
        print("-" * 50)
        
        # After the process finishes, always run --show to display cracked passwords.
        print("\n[*] Cracking process finished. Displaying cracked passwords:")
        subprocess.run(['john', '--show', hash_file])

        if rc != 0:
             print(f"\n[!] John the Ripper may have exited with an error (code {rc}).")
             print("[!] Common issues: incorrect hash format, corrupted session file, or no passwords cracked in the current mode.")
             print("[!] Try specifying the format explicitly with '--format=<format>'.")

    except FileNotFoundError:
        print("\n[!] Error: 'john' command not found.")
        print("[!] Please ensure John the Ripper is installed and in your system's PATH.")
        print("[!] On Debian/Ubuntu, use: sudo apt install john")
    except Exception as e:
        print(f"\n[!] An unexpected error occurred: {e}")

def main():
    display_banner()
    parser = argparse.ArgumentParser(
        description="A wrapper for John the Ripper to simplify password cracking.",
        formatter_class=argparse.RawTextHelpFormatter
    )
    parser.add_argument("hash_file", help="Path to the file containing password hashes.")
    parser.add_argument("-w", "--wordlist", help="Optional: Path to a wordlist file.", required=False)
    parser.add_argument("-f", "--format", help="Optional: Specify the hash format (e.g., raw-md5, nt, sha256crypt).", required=False)
    
    if len(sys.argv) == 1:
        parser.print_help(sys.stderr)
        sys.exit(1)

    args = parser.parse_args()

    crack_passwords(args.hash_file, args.wordlist, args.format)

if __name__ == "__main__":
    main()