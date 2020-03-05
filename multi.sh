#!/bin/bash
 


subs()
{
python /home/jatin/Documents/tools/Sublist3r/sublist3r.py -d $1 -o $2/domains
amass enum -d $1 -o $2/amass_domains

#CERT DOMAINS[ADD IN SORT AND TEST]
curl -s https://certspotter.com/api/v0/certs\?domain\=$1 | jq '.[].dns_names[]' | sed 's/\"//g' | sed 's/\*\.//g' | sort -u | grep $1 > $2/crtspot
curl -s https://crt.sh/?q\=%.$1\&output\=json | jq -r '.[].name_value' | sed 's/\*\.//g' | sort -u > $2/crt

#SORT
echo $2
cat $2/domains $2/amass_domains $2/crtspot $2/crt | sort | uniq  > $2/sorted.txt

#TODO 
#BRUTE
#SOME MORE TOOLS
#HTTPROBE

echo ''
#httprobe
cat $2/sorted.txt | httprobe1 | grep https
cat $2/sorted.txt | httprobe1 | grep https > $2/probed
echo ''
echo ''
}


screenshots()
{
python /home/jatin/Documents/tools/webscreenshot/webscreenshot.py -i $1/sorted.txt -o $1/screenshots
echo ''
echo ''



}

nmapscan()
{

if [[ $1 == 'F' ]]; then
	nmap -p- $3 -o $2/nmap/$3
elif [[ $1 == 'B' ]]; then
	cat $2/sorted.txt | while read liney; do nmap -sV -o $2/nmap/$liney $liney;echo ''; done
fi
}

headers()
{
for i in $(cat $1/sorted.txt); do curl -i $i | head -n25 >  $1/headers/$i; done
}


githubdorks()
{
read -p  '[+] Enter organisation name ' org
echo ''

echo '[+] Visit the below urls and check for potential leaks while scans going on'
echo ''
while IFS= read -r line
do
echo 'https://github.com/search?q=org%3A'$org'+'$line
#save in a file
done < dorks

}






echo " _    _ _    _ _   _ _______ ______ _____  "
echo "| |  | | |  | | \ | |__   __|  ____|  __ \ "
echo '| |__| | |  | |  \| |  | |  | |__  | |__) |'
echo '|  __  | |  | | . ` |  | |  |  __| |  _  / '
echo "| |  | | |__| | |\  |  | |  | |____| | \ \ "
echo '|_|  |_|\____/|_| \_|  |_|  |______|_|  \_\'
echo '				 	 [*] By Hackddict'
echo ''
echo ''


echo "[+] Starting Scan,FOR FULL NMAP SCAN CHANGE THE SCAN VARIABLE INSIDE SCRIPT!!"
sleep 3
echo "Enter domain/file name: "
while IFS= read -r input
do
domain=$input


  
scan="B" 
line='/home/jatin/Documents/bb/'$domain
mkdir $line
mkdir $line/screenshots
mkdir $line/dir
mkdir $line/nmap
mkdir $line/headers
githubdorks
subs  "$domain" "$line"
screenshots "$line"
nmapscan "$scan" "$line" "$domain"
headers "$line"

#done
done < scope
