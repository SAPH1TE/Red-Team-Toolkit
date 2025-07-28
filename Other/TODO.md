 **COMPLETE**
   -Setup menu system
   -get a launcher/initalization mechanic
   -make the script easily modifiable (make all of the variables and functions fetched from 1 file)
   -setup in depth logging system
   -more stuff im too lazy to list
   - Bash is the launcher, interface, and executor. Python is the (semi) muscle.  
   - Nail argument passing, error handling, and output parsing like a boss.

 **MINOR**
   -setup temporary storing for attack information when the user selects a option for the target in a file called Temp.json
   -polish the menusystem, not to a large extent
   -setup checks at the beggining of the script to ensure compatability 

 **Add package/dependency check on attack selection**  
   - For every attack option, verify required tools exist on the system.  
   - Provide clear error messages and installation tips if missing.

 **Modularize & clean up codebase for maintainability & readability**  
   - Organize by feature (e.g., `functions.sh`, `attacks/lan.sh`, `attacks/wan.sh`, etc.)  
   - Use consistent naming, formatting, and document every function.

 **Implement LAN Attacks**  
   - ARP spoofing, MITM proxy (mitmproxy), netdiscover, bettercap, arp poisoning flows.

 **Implement WAN Attacks**  
   - Port scanning (nmap + NSE scripts), DoS/DDoS tools (hping3, slowloris), banner grabbing.

 **Implement Web Application Attacks**  
   - SQL injection, XSS, CSRF testing, automated tools like sqlmap, burp integrations.

 **Implement Brute Force Attacks**  
   - Hydra, medusa, custom brute force scripts for services (ssh, ftp, http auth).
   - Let the user fetch a preset passphrase list if one is not detected

 **Implement Payload Generation**  
   - msfvenom integration, custom shellcode builders, obfuscated payloads.

 **Implement Post-Exploitation Tools**  
    - Privilege escalation, lateral movement tools, persistence script runners.

 **Implement Social Engineering Tools**  
    - Phishing kit deployment, email spoofing tools, awareness simulation scripts.

 **Implement Bypass & Obfuscation Techniques**  
    - AV evasion, code obfuscation, sandbox detection bypass scripts.

 **Implement Custom Shell Spawner**  
    - Reverse shell templates, bind shells, encrypted shell spawners.

 **Implement Wireless Attacks**  
    - Aircrack-ng suite, WiFi deauth, EvilAP setups, cracking WPA/WPA2.

 **Implement Docker / Container Escapes**  
    - Container breakout exploits, privilege escalation inside containers.

 **Implement Reverse Shell Templates**  
    - Snippets and scripts for reverse shells in multiple languages.

 **Implement Credential Harvesting**  
    - Keyloggers, phishing credential collectors, memory dumpers.

 **Implement Malware Dropper Builder**  
    - Custom dropper generators and payload delivery mechanisms.

 **Implement Tunneling / Pivoting Tools**  
    - SSH tunnels, proxychains, socks proxies setup scripts.

 **Implement Persistence Techniques**  
    - Cron jobs, autostart entries, scheduled tasks, service implants.

 **Implement Evasion & Sandbox Detection**  
    - Anti-debug, anti-VM detection, sandbox evasion tools.

 **Implement Anti-Forensics Tools**  
    - Log cleaners, timestomping utilities, rootkit deployment.

 **Implement UAC / Privilege Escalation**  
    - Windows UAC bypass, privilege escalation exploits and scripts.

 **Implement Active Directory Exploits**  
    - BloodHound automation, kerberoasting, golden ticket crafting.

 **Implement Linux Privesc / Enumeration**  
    - LinPEAS automation, kernel exploits, manual enumeration helpers.

 **Implement Windows Exploit Launchpad**  
    - Windows exploit frameworks integration, script automation.

 **Implement Steganography Tools**  
    - Image/audio/video stego utilities for hiding/extracting payloads.

 **Implement Fileless Attack Scripts**  
    - PowerShell memory attacks, in-memory malware loaders.

 **Implement Supply Chain Attack Simulators**  
    - Dependency hijacking, malicious package injection simulators.

 **Implement Mobile Attack Vectors (Android/iOS)**  
    - ADB exploits, Frida scripts, mobile pentest tools integration.

 **Implement Cloud Exploitation (AWS/GCP/Azure)**  
    - Cloud misconfiguration scanners, abuse scripts, privilege escalation.

 **Implement Exfiltration Methods (Covert Channels)**  
    - DNS tunnels, ICMP data exfiltration, covert channel scripts.

 **Implement Flipper Zero Jailbreaking and applying**
   -complete unleashed firmware setup, 

**Now what?**
   - Publish version 0.1a to github, thats what!