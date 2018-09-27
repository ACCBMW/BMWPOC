#############################################################################
# Don't make any changes to this script                                     #
# File :    postgreshealthchecks.sh                                         #
# Purpose : The purpose of this script is to report Database health check   #
#                                                                           #
# History:                                                                  #
# Name                   Date                                Version        #
# ***********************************************************************   #
# PostgreSQL Health Script                                          1.0     #
#############################################################################
#! /bin/bash
#sndmail:raj.kce2912@gmail.com

#Checking if this script is being executed as ROOT. For maintaining proper directory structure, this script must be run from a root user.
if [ $EUID != 0 ]
then
  echo "Please run this script as root so as to see all details! Better run with sudo."
  exit 1
fi
dte=`date`
hstname=`hostname`
ip_add=`ifconfig | grep "inet" | head -2 | awk {'print$2'}| cut -f2 -d: `
UP1=$(service postgresql status);
if [ "$?" -gt "0" ]; then
INSTSTAT=("Not Running")
else
INSTSTAT=("Running")
fi
host_name=`hostname`
sr_version=`psql -V | awk '{print $2;print $3}'`
load_avg=`cat /proc/loadavg  | awk {'print$1,$2,$3'} | sed 's/ /,/g'`
ram_usage=`free -m | head -2 | tail -1 | awk {'print$3'}`
ram_total=`free -m | head -2 | tail -1 | awk {'print$2'}`
mem_pct=`free -m | awk 'NR==2{printf "%.2f%%\t\t", $3*100/$2 }'`
cpu_pct=`top -bn1 | grep load | awk '{printf "%.2f%%\t\t\n", $(NF-2)}'`
mnt_pnt=`df -kh | grep -w "/" | awk  '{print$3}' | tr -d G`
latest_file=`ls -l /var/lib/pgsql/data/log | tail -1 | awk '{print$9}'`
postgres_logs=`cat /var/lib/pgsql/data/log/$latest_file | grep -i error`
#Creating a directory if it doesn't exist to store reports first, for easy maintenance.
if [ ! -d ${HOME}/health_reports ]
then
  mkdir ${HOME}/health_reports
fi
#find ${HOME}/health_reports/ -mtime +1 -exec rm {} \;
find ${HOME}/health_reports/ -exec rm {} \;
html="${HOME}/health_reports/PostgreSQL-Patching-Report.html"
#email_add="raj.kce2912@gmail.com"
for i in `ls /home`; do sudo du -sh /home/$i/* | sort -nr | grep G; done > /tmp/dir.txt
#Generating HTML file
echo "<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">" >> $html
echo "<html>" >> $html
echo "<link rel="stylesheet" href="https://unpkg.com/purecss@0.6.2/build/pure-min.css">" >> $html
echo "<body bgcolor="#80A8C3">" >> $html
echo "<fieldset>" >> $html
echo "<center>" >> $html
echo "<h2><u>PostgreSQL Server Patching Report</u></h2>" >> $html
echo "<h4><legend>Version 1.0</legend></h4>" >> $html
echo "</center>" >> $html
echo "</fieldset>" >> $html
echo "<br>" >> $html
echo "<center>" >> $html
############################################PostgreSQL Instance Details#######################################################################
echo "<h3><u>PostgreSQL Instance Details</u> </h3>" >> $html
echo "<table class="pure-table">" >> $html
echo "<thead>" >> $html
echo "<tr>" >> $html
echo "<th>Hostname</th>" >> $html
#echo "<th>IP Address</th>" >> $html
echo "<th>Service Status</th>" >> $html
#echo "<th>Postgres Service Status</th>" >> $html
echo "<th>Postgresql Version</th>" >> $html
#echo "<th>Uptime</th>" >> $html
#echo "<th>Date & Time</th>" >> $html
echo "</tr>" >> $html
echo "</thead>" >> $html
echo "<tbody>" >> $html
echo "<tr>" >> $html
echo "<td>$hstname</td>" >> $html
#echo "<td>$ip_add</td>" >> $html
echo "<td><font color="Red">$INSTSTAT</font></td>" >> $html
echo "<td>$sr_version</td>" >> $html
#echo "<td>$dte</td>" >> $html
echo "</tr>" >> $html
echo "</tbody>" >> $html
echo "</table>" >> $html

########################################### Resource Status #######################################################################
echo "<h3><u>Resource Utilization</u> </h3>" >> $html
#echo "<br>" >> $html
echo "<table class="pure-table">" >> $html
echo "<thead>" >> $html
echo "<tr>" >> $html
echo "<th>CPU utilization (%)</th>" >> $html
echo "<th>Disk Utilization (MB)</th>" >> $html
echo "<th>Total RAM (MB)</th>" >> $html
echo "<th>Memory Utilization (%)</th>" >> $html
echo "</tr>" >> $html
echo "</thead>" >> $html
echo "<tbody>" >> $html
echo "<tr>" >> $html
echo "<td><center>$cpu_pct</center></td>" >> $html
echo "<td><center>$mnt_pnt</center></td>" >> $html
echo "<td><center>$ram_total</center></td>" >> $html
echo "<td><center>$mem_pct</center></td>" >> $html
echo "</tr>" >> $html
echo "</tbody>" >> $html
echo "</table>" >> $html
########################################### Disk Utilization #######################################################################
echo "<h3><u>PostgreSQL Error Logs</u> </h3>" >> $html
echo "<table class="pure-table">" >> $html
echo "<thead>" >> $html
echo "<tr>" >> $html
echo "<th><center>Patching Error Logs</center></th>" >> $html
echo "</tr>" >> $html
echo "</thead>" >> $html
echo "<tbody>" >> $html
echo "<tr>" >> $html
echo "<td>$postgres_logs</td>" >> $html
echo "</tr>" >> $html
echo "</tbody>" >> $html
echo "</table>" >> $html
echo "<br />" >> $html
echo "</table>" >> $html
echo "</body>" >> $html
echo "</html>" >> $html
#echo "Report has been generated in ${HOME}/health_reports with file-name = $html. Report has also been sent to $email_add."
#Sending Email to the user
#mailx -a $html -s "PostgreSQL Health Report" rajkishore.com < /dev/null

