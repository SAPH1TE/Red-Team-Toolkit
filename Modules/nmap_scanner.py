import sys
import subprocess

SCAN_PROFILES = {
    "1": ("Quick Scan", ["-T4", "-F"]),
    "2": ("Quick Scan Plus", ["-sV", "-T4", "-O", "-F"]),
    "3": ("Intense Scan", ["-T4", "-A", "-v"]),
    "4": ("Intense Scan + UDP", ["-sS", "-sU", "-T4", "-A", "-v"]),
    "5": ("Intense Scan All TCP Ports", ["-p-", "-T4", "-A", "-v"]),
    "6": ("Ping Scan", ["-sn"]),
    "7": ("Slow Comprehensive Scan", ["-sS", "-sU", "-T2", "-A", "-PE", "-PP", "-PS80,443", "-PA3389", "-PU40125", "-PY", "-g 53", "--script", "default,safe"])
}

def display_profiles():
    print("\n Available Scan Profiles:")
    for key, (name, _) in SCAN_PROFILES.items():
        print(f"{key}) {name}")
    print()

def scan_target(target, scan_args):
    if not target:
        print(" Error: No target specified.")
        return

    print(f"[*] Running Nmap scan on {target} with args: {' '.join(scan_args)}")
    try:
        result = subprocess.run(
            ['nmap'] + scan_args + [target],
            capture_output=True,
            text=True,
            check=True
        )
        print(result.stdout)
    except FileNotFoundError:
        print(" Error: Nmap is not installed or not in your PATH.")
    except subprocess.CalledProcessError as e:
        print(f" Error during Nmap scan: {e}")
        print(e.stderr)

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: python nmap_scanner.py <target>")
        sys.exit(1)

    target = sys.argv[1]
    display_profiles()
    profile_choice = input(" Choose a scan profile number: ").strip()

    if profile_choice in SCAN_PROFILES:
        _, scan_args = SCAN_PROFILES[profile_choice]
        scan_target(target, scan_args)
    else:
        print("⚠️ Invalid choice. Exiting.")
