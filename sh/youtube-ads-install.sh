echo "!!!Important change light httpd to expose the txt file so that pihole can read it and add to gravity"
echo "line to add is "
echo "server.dir-listing = enable"
echo "and then run:"
echo "/etc/init.d/lighttpd restart"
echo "created for public use"
echo "Start with re-install cleanup."
rm -r /etc/dnsdumpster
rm /var/www/html/youtube-ads-list.txt
rm /etc/pihole/youtube-ads.sh
echo "cleanup done."
echo "need to install python setup tools in debian"
apt-get install python-setuptools
echo "installing python-pip and dnsdumpster."
apt-get install python-pip
pip install --upgrade pip
pip uninstall dnsdumpster
mkdir /etc/dnsdumpster
echo "" > /etc/dnsdumpster/youtube-domains.txt
echo "" > /etc/dnsdumpster/youtube-filtered.txt
echo "" > /etc/dnsdumpster/youtube-ads.txt
cd /etc/dnsdumpster
pip install https://github.com/PaulSec/API-dnsdumpster.com/archive/master.zip --target /etc/dnsdumpster/
pip install https://github.com/PaulSec/API-dnsdumpster.com/archive/master.zip --user
echo "copying dnsdumpster API_example.py script and modify it as ADS_youtube.py."
echo "replacing API_example.py domain '.com' with 'googlevideo.com'."
sed 's/uber.com/googlevideo.com/g' /etc/dnsdumpster/dnsdumpster/API_example.py > /etc/dnsdumpster/dnsdumpster/ADS_youtube-temp.py
echo "remove some script lines from script to resolve XLS base64 errors as it is not required"
awk 'NR!~/^(35|36|37|38)$/' /etc/dnsdumpster/dnsdumpster/ADS_youtube-temp.py > /etc/dnsdumpster/dnsdumpster/ADS_youtube.py
echo "ADS_youtube.py script created."
echo "cleanup temp script file."
rm /etc/dnsdumpster/dnsdumpster/ADS_youtube-temp.py
echo "create update script /etc/pihole/youtube-ads.sh."
echo "youtube-ads.sh is used for maintaining youtube generated list youtube-ads-list.txt in pihole webroot for pihole update access."
echo "echo off" >> /etc/pihole/youtube-ads.sh
echo "rm /etc/dnsdumpster/youtube-domains.txt" >> /etc/pihole/youtube-ads.sh
echo "rm /etc/dnsdumpster/youtube-filtered.txt" >> /etc/pihole/youtube-ads.sh
echo "rm /etc/dnsdumpster/youtube-ads.txt" >> /etc/pihole/youtube-ads.sh
echo "python /etc/dnsdumpster/dnsdumpster/ADS_youtube.py > /etc/dnsdumpster/youtube-domains.txt" >> /etc/pihole/youtube-ads.sh
echo "grep ^r /etc/dnsdumpster/youtube-domains.txt >> /etc/dnsdumpster/youtube-filtered.txt" >> /etc/pihole/youtube-ads.sh
echo "sed 's/\s.*$//' /etc/dnsdumpster/youtube-filtered.txt >> /etc/dnsdumpster/youtube-ads.txt" >> /etc/pihole/youtube-ads.sh
echo "cat /etc/dnsdumpster/youtube-ads.txt > /var/www/html/youtube-ads-list.txt" >> /etc/pihole/youtube-ads.sh
echo "#greps the log for youtube ads and appends to /var/www/html/youtube-ads-list.txt" >> /etc/pihole/youtube-ads.sh
echo "grep r*.googlevideo.com /var/log/pihole.log | awk '{print $6}'| grep -v '^googlevideo.com\|redirector' | sort -nr | uniq >> /var/www/html/youtube-ads-list.txt" >> /etc/pihole/youtube-ads.sh
echo "#removes duplicate lines from /var/www/html/youtube-ads-list.txt" >> /etc/pihole/youtube-ads.sh
echo "perl -i -ne 'print if ! $x{$_}++' /var/www/html/youtube-ads-list.txt" >> /etc/pihole/youtube-ads.sh
echo "#updates pihole blacklist/whitelist" >> /etc/pihole/youtube-ads.sh
echo "pihole -g" >> /etc/pihole/youtube-ads.sh
echo "youtube-ads.sh script created."
echo "chmod script to executable."
chmod +x /etc/pihole/youtube-ads.sh
echo "http://localhost/html/youtube-ads-list.txt" >> /etc/pihole/adlists.list
echo "save current crontab to mycron.sav, add crontab job, to run youtube-ads.sh updater every 15 minutes."
crontab -l > mycron.sav
echo "*/15 * * * * /etc/pihole/youtube-ads.sh" > mycron
crontab mycron
rm mycron
echo "manual update first."
/etc/pihole/youtube-ads.sh
echo "done, now enjoy youtube ad free, thru your pihole."
