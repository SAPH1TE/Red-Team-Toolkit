 **COMPLETE**
   -Setup menu system
   -get a launcher/initalization mechanic
   -make the script easily modifiable (make all of the variables and functions fetched from 1 file)
   -setup in depth logging system
   -bash is the launcher, interface, and executor. Python is the (semi) muscle.  
   -nail argument passing, error handling, and output parsing like a boss.
   -setup temporary storing for attack information when the user selects a option for the target in a file called Temp.json (instead did nmaps xml export for being more robust)
   -polish the menusystem, not to a large extent
   -setup checks at the beggining of the script to ensure compatability 
   -Organize by feature (e.g., `functions.sh`, `modules/lan.sh`, `modules/wan.sh`, etc.)  
   -Use consistent naming, formatting, and document every function.
   -more stuff im too lazy to list
   -DoS/DDoS Module (eg a hping3, slowloris wrapper?).



 **Add package/dependency check on attack selection**  
   - For every attack option, verify required tools exist on the system.  
   - Provide clear error messages and installation tips if missing.

 **Implement LAN Attacks**  
   - MITM proxy (mitmproxy), netdiscover, bettercap.

 **Implement Web Application Attacks**  
   - SQL injection, XSS, CSRF testing, automated tools like sqlmap, burp integrations.

 **Implement Brute Force Attacks**  
   - Hydra, medusa, custom brute force scripts for services (ssh, ftp, http auth) and use bash and python as the wrapper.
   - Let the user fetch a preset passphrase list if one is not detected

 **Implement Payload Generation**  
   - msfvenom integration, custom shellcode builders, obfuscated payloads.


**Now what?**
   - Publish version 1.1.Xa to github, thats what!