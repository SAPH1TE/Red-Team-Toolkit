# modules/subdomainenum.py

import sys
import subprocess

def main():
    if len(sys.argv) < 2:
        print("[-] Usage: python3 subdomain_enum.py <domain>")
        sys.exit(1)

    target_domain = sys.argv[1]
    output_file = f"subdomains_{target_domain}.txt"

    confirm = input("Are you sure you want to proceed? Do not execute this without permission. (Type 'yes' to confirm): ")
    if confirm.lower().strip() != 'yes':
        print("[*] Attack aborted by user.")
        sys.exit(0)
                 
    print(f"\033[93m[*] Starting subdomain enumeration for {target_domain}...\033[0m")

    try:
        # Run assetfinder command
        process = subprocess.run(
            ["assetfinder", "--subs-only", target_domain],
            capture_output=True,
            text=True,
            check=True
        )

        subdomains = process.stdout.strip().split('\n')
        
        if not subdomains or not subdomains[0]:
            print("\033[91m[-] No subdomains found.\033[0m")
            return

        # Save the output to a file and print to console
        with open(output_file, "w") as f:
            for sub in subdomains:
                print(sub)
                f.write(sub + '\n')
        
        print(f"\n\033[92m[+] Scan complete. {len(subdomains)} subdomains found.\033[0m")
        print(f"\033[92m[+] Results saved to {output_file}\033[0m")

    except subprocess.CalledProcessError as e:
        print(f"\033[91m[-] An error occurred while running assetfinder: {e.stderr}\033[0m")
    except Exception as e:
        print(f"\033[91m[-] A general error occurred, ensure assetfinder is installed.: {e}\033[0m")

if __name__ == "__main__":
    main()