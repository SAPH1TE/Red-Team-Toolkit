import sys
import os
import subprocess

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

    command = ['john']
    
    if wordlist:
        if not os.path.exists(wordlist):
            print(f"[!] Error: Wordlist not found at '{wordlist}'")
            return
        command.append(f"--wordlist={wordlist}")
        print(f"[*] Starting attack on {hash_file} with wordlist: {wordlist}")
    else:
        print(f"[*] Starting attack on {hash_file} using John's default modes.")

    if hash_format:
        command.append(f"--format={hash_format}")
        print(f"[*] Using hash format: {hash_format}")

    command.append(hash_file)

    try:
        print(f"[*] Running command: {' '.join(command)}")
        process = subprocess.Popen(command, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, text=True)
        
        while True:
            output = process.stdout.readline()
            if output == '' and process.poll() is not None:
                break
            if output:
                print(output.strip())
        
        rc = process.poll()
        if rc == 0:
            print("\n[*] Cracking process completed. Showing cracked passwords:")
            subprocess.run(['john', '--show', hash_file])
        else:
             print(f"\n[!] John the Ripper exited with an error (code {rc}).")
             print("[!] Ensure the hash file format is correct or try specifying a format.")

    except FileNotFoundError:
        print("\n[!] Error: 'john' command not found.")
        print("[!] Please ensure John the Ripper is installed and in your system's PATH.")
    except Exception as e:
        print(f"\n[!] An unexpected error occurred: {e}")

if __name__ == "__main__":
    display_banner()
    if len(sys.argv) < 2:
        print("Usage: python password_cracker.py <hash_file> [wordlist_file] [--format=hash_format]")
        print("Example: python password_cracker.py hashes.txt wordlist.txt --format=raw-md5")
        sys.exit(1)

    hash_file_path = sys.argv[1]
    wordlist_path = None
    hash_format_arg = None

    # Simple argument parsing
    if len(sys.argv) > 2:
        if "format" in sys.argv[2]:
             hash_format_arg = sys.argv[2].split("=")[1]
        else:
             wordlist_path = sys.argv[2]
    
    if len(sys.argv) > 3:
        if "format" in sys.argv[3]:
            hash_format_arg = sys.argv[3].split("=")[1]

    crack_passwords(hash_file_path, wordlist_path, hash_format_arg)