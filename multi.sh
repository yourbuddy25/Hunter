#!/bin/bash
 

#TODO
#1. Change domains to sorted.txt
#2. Change read file to raw input
#3. 0 day scanners modules(Fingerprint, JIRA, WEBMIN , etc.)
#4. Options/command line  args for different things


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

#googledork()
#{

#}


report()
{

echo "<!DOCTYPE html>" >> $1/report.html
echo "<html>" >> $1/report.html
echo "<head><meta name=\"viewport\" content=\"width=device-width, initial-scale=1\">" >> $1/report.html
echo "<style> " >> $1/report.html
echo "* {" >> $1/report.html  
echo "box-sizing: border-box; " >> $1/report.html
echo "}" >> $1/report.html
echo ".column {" >> $1/report.html
echo "float: left;" >> $1/report.html
echo "width: 33.33%;" >> $1/report.html
echo "padding: 10px;" >> $1/report.html
echo "height: 350px; " >> $1/report.html
echo "}" >> $1/report.html
echo "</style></head><body>"   >> $1/report.html
echo "<center><h1>"$input" report generated</h1>" >> $1/report.html

for i in $(cat $1/sorted.txt);do
#screenshots
shots=$1'/screenshots/'
filey=`ls $1/screenshots/ |grep $i`
echo "<div><p>"$filey"</p></div>" >> $1/report.html
#echo "<div>" >> $1/report.html
echo  "<div class=\"column\" style=\"background-color:#aaa;\">" >> $1/report.html
echo   "<h2>Screenshot</h2>" >> $1/report.html
echo    "<a href=\""$shots$filey"\"><img src=\""$shots$filey"\" width=\"600\" height=\"250\" /></a></div>" >> $1/report.html

#Nmap
echo "<div class=\"column\" style=\"background-color:#bbb;\">" >> $1/report.html
echo "<h2>Nmap</h2>" >> $1/report.html
echo "<div style=\"border:1px solid black;width:600px;height:250px;overflow:scroll;overflow-y:scroll;overflow-x:hidden;\">" >> $1/report.html
echo "<p style=\"height:250%;\">" >> $1/report.html
cat $1/nmap/$i >> $1/report.html
echo "</p>" >> $1/report.html
echo "</div>  </div>" >> $1/report.html

#Headers
echo "<div class=\"column\" style=\"background-color:#ccc;\">" >> $1/report.html
echo "<h2>Headers</h2>" >> $1/report.html
echo "<div style=\"border:1px solid black;width:600px;height:250px;overflow:scroll;overflow-y:scroll;overflow-x:hidden;\"><p style=\"height:250%;\">" >> $1/report.html
cat $1/headers/$i >> $1/report.html
echo "</p></div></div>" >> $1/report.html; 
done

echo "</body></html>" >> $1/report.html

}




dirsearch()
{
cat $1/sorted.txt | while read linez; do /home/jatin/Documents/tools/dirsearch/dirsearch.py -u $2 -w /home/jatin/Documents/wordlists/seclists_dir -e php -t 25 --plain-text-report=$1/dir/$linez; done
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
subs  "$domain" "$line"
screenshots "$line"
nmapscan "$scan" "$line" "$domain"
headers "$line"
#report  "$line"
#dirsearch "$line" "$domain"
  #sublist3r.py -d $domain -o $line/domains
  #webscreenshot.py -i $line/domains -o $line/screenshots
  #mkdir $line/nmap 2>/dev/null 
  #mkdir $line/dirsearch 2>/dev/null
 # python /home/jatin/Documents/recon/recon/gobust.py $line/domains  
  #nmap -sS \-o $line/nmap/$line+tcp $domain
  #python dirsearch.py -u $domain -w /home/jatin/Documents/wordlists/seclists_dir -e php
  #dir=/home/jatin/Documents/tools/dirsearch/reports/$domain/'
  #cp $dir/* $line/dirsearch/$domain/
#done
done < scope
