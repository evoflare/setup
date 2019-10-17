# On-premises Hosting

1. Set DNS records for a domain name pointing to your machine. Open ports 80 and 443 on the machine.

2. Install [Docker](https://docs.docker.com/engine/installation/) and [Docker Compose](https://docs.docker.com/compose/install/).

3. Run command  

 Bash (Linux, Mac)
```
curl -Lso evoflare.sh https://evoflare.live/bash && chmod +x evoflare.sh
./evoflare.sh install
./evoflare.sh start
```
PowerShell (Windows)
```
Invoke-RestMethod -OutFile evoflare.ps1 -Uri https://evoflare.live/ps
.\evoflare.ps1 -install
.\evoflare.ps1 -start
```

4. Test your deployment.