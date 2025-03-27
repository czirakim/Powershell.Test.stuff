# Powershell.Test.stuff

These are some scripts that can be used to test access to URLs, file shares, RDP access, and SSH access. 
<br>These can be useful when you need to test access from a new/remote office, remote VPN user, home office, etc.
<br>
<br> conn_test.ps1 - is a script for testing access to the Internet. It pings different DNS server,s and it shows you your public IP.
<br> dns_testing.ps1 - is a script that checks the domain names from a list of URLs.
<br> vpn_testing_ps1 - is a script that tests access to URLs, file shares, RDP access, SSH access
<br> conn_tool.ps1 - this is an interactive tool to test a specific protocol (rdp, ssh,file-share) to a specific host provided by user in the CLI
<br> It can also do multiple tests, like: ssh, port,rdp
<br> process_csv.ps1 - This script takes a CSV file with routing info, exported from a device, and processes it (subnet and remote device name), and then exports to another destination CSV file (subnet and remote location)
<br> iplookup.ps1 - This script takes an IP as an argument(CLI) and determines which site this IP is from. It needs a destination CSV file processed by process_csv.ps1
<br>
<div style="text-align: center;">
  <img width="306" alt="Screenshot 2025-03-18 161736" src="https://github.com/user-attachments/assets/60100b9a-e0e0-457e-8f15-293434bd2fbc" />
</div>

# Credits
This was written by Mihai Cziraki
