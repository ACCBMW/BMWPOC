#################################################################################################################
# Name:              SQL Server(s) Health Report								#
# Created By:        Anurag Biala										#
# Team:              IO-Capability 										#
# Version:           1.0											#
# Functionality:     This Script will be used to report the daily Health checks of SQL servers			#
#		     												#  
#											 			#
# Environment:       SQL Server 2008 or above in windows server 2008 or above environment			#
# Email ID:          Point if Contact in case of any Issue 							#
#                    “IS-ScriptFactory@accenture.com”								#
# Disclaimer:        Test this script in test environment before deploying in production.			#
#														#
#################################################################################################################


######backup highlight Limit##########

#### mention Hours for full backup
$Fbkp=48

#### mention Hours for differential backup
$Dbkp=24

######################################

$i=$null
$s=$null

###########List server name####################
#$Servers = Get-Content "Servers.txt"
##############################################
[System.Reflection.Assembly]::LoadWithPartialName('Microsoft.SqlServer.SMO') | out-null

$bodyM = "<table cellpadding=3 cellspacing=1  bgcolor=#FF8F2F style='font-family:verdana; font-size:7pt;'>"
$bodyM += "<tr bgcolor=#DDDDDD><TH>InstanceName</TH><TH>Status</TH>"
$body = "<table cellpadding=3 cellspacing=1  bgcolor=#FF8F2F style='font-family:verdana; font-size:7pt;'>"
$body += "<tr bgcolor=#DDDDDD><TH>ServerName</TH><TH>Instance Name</TH><TH>SQL Server</TH><TH>Uptime</TH><TH>Databases</TH><TH>Status</Th><TH>Size(MB)</TH><TH>DataSpaceUsage(KB)</Th><TH>SpaceAvailable(KB)</TH></tr>"


#ForEach ($Server in $Servers) {


#######################Get Instance name########################
########
$s=$null
#######
$server = $env:COMPUTERNAME
Try{
Get-WmiObject -computer $env:COMPUTERNAME win32_service -ErrorAction Stop >.\tmp.txt
$instances = Get-WmiObject -ComputerName $server win32_service | where {(($_.name -eq "MSSQLSERVER") -or ($_.name -like "MSSQL$*"))} | select-object name
}catch {  $ErrorMessage = $_.Exception.Message ; $errrun11=11

$body += "<tr bgcolor=white align=center><td><b>$server</b></td><TD colspan=12 align=left><font color=red>$ErrorMessage</font></TD></tr>"
}


If ($errrun11 -ne "11") {

foreach ($instance in $instances) {

$Instname="$($instance.name)"

if ($instance.name -like "MSSQLSERVER") { $instance1=$server} else {
$instance =  $($instance.name).Split("$")
$instance1="$server\$($instance[1])"
$Instname="$($instance[1])"
}
if ( $($instance[1]) -ne "MICROSOFT##WID" )
{
#######Instance name#########
$instance1
####end Instance name#########
try {

$srv = New-Object ('Microsoft.SqlServer.Management.Smo.Server') "$instance1"
$SJruns=$srv.JobServer.Jobs | Where-Object {$_.CurrentRunStatus -eq "running"} | Select Name,LastRunDate,nextrundate,CurrentRunStatus
$dbstest=$srv.Databases
$dbstest >tmp.txt
} catch {$ErrorMessage = $_.Exception.Message; $runerr=7
###Servername####

If ($s -eq $null) {$Srnm=$server} else {$Srnm=$null}
#If ($i -eq $null) {$Instnm=$instance1} else {$Instnm=$null}
#$i++
$s++
################
$body += "<tr bgcolor=white align=center><td><b>$Srnm</b></td><td><b>$instance1</b></td><TD colspan=11 align=left><font color=red>$ErrorMessage</font></TD></tr>"
}

If ($runerr -ne 7) {

################################################################




[System.Reflection.Assembly]::LoadWithPartialName('Microsoft.SqlServer.SMO') | out-null


####
$i=$null
####
	$SQLServer=$null

 	$SQLServer = New-Object ('Microsoft.SqlServer.Management.Smo.Server') $instance1 
#############
	try{ Foreach($Database in $SQLServer.Databases){ break}} catch {$SQLServer=$null}

if (!$SQLServer) { $body += "<tr bgcolor=#D3D3D3 align=center><TD colspan=10 align=center><font color=red><B>$instance</B></font></TD></tr>" } else {

	#$body += "<tr bgcolor=#D3D3D3 align=center><TD colspan=10 align=center><B>$Server</B></TD></tr>"



###############Database Start Time###########
$UpTime=$null

if($SQLServer.Databases['tempdb']) {

        $udb = $SQLServer.Databases['tempdb']
        $CreateDate = $udb.CreateDate        
        $Time = (Get-Date) – $CreateDate
        
        $UpTime ="$($Time.DAYS) days $($Time.HOURS) hrs $($Time.MINUTES) mins $($Time.SECONDS) sec"

	}  

################end atabase Start Time########

	Foreach($Database in $SQLServer.Databases)
	{
	$out=$Database.LastBackupDate
        $outt=((Get-Date) - $out).TotalHours

        $out1=$Database.LastDifferentialBackupDate
        $outt1=((Get-Date) - $out1).TotalHours

        $out2=$Database.LastLogBackupDate
        $outt2=((Get-Date) - $out2).TotalHours
	                   
                                        
	#<TD>$($Database.RecoveryModel)</TD>
#####################

	if($Database.LastBackupDate -eq "01/01/0001 00:00:00") {$LFBD="No Full Backup"} 
	elseif ( $outt -gt '48' -and ($Database.Name -NotContains ('master','model','msdb','tempdb') ) ) {$LFBD="<font color=red >$out</font>"}
	else { $LFBD=$out}
	###$LFBD	

	#<TD>$LFBD</TD>
#####################

	if($Database.LastDifferentialBackupDate -eq "01/01/0001 00:00:00") { $LDBD ="No Diff Backup"}
	elseif ( $outt1 -gt '24') {$LDBD="<font color=red >$out1</font>"}
	else { $LDBD=$out1}
	###$LDBD
        
	#<TD>$DFBD</TD> 
###################### 
	if($Database.LastLogBackupDate -eq "01/01/0001 00:00:00") { $LLBD ="No Log Backup"}
	elseif($Database.RecoveryModel -Match "Simple"){$LLBD ="N/a"}

	elseif ( $outt2 -gt '24') {$LLBD="<font color=red >$out2</font>"}
	else { $LLBD=$out2}
	###$LLBD
        
	#<TD>$LLBD</TD> 
######################  
 

################SQL Agent Check#################
$Sqlagt = Get-WmiObject -ComputerName $server win32_service | where {($_.displayname -like "SQL Server ($instname)") -and ($_.displayname -like "*($instname)*")}
If ($($Sqlagt.state) -eq "Running") {$AGTsts="<font color=green>$($Sqlagt.state)</font>"} else { $AGTsts="<font color=red>$($Sqlagt.state)</font>"}

################end SQL Agent Check#################

################Database Status#######################

If ($($Database.Status) -like "*offline*") {$DB1sts="<font color=red>$($Database.Status)</font>"} 
#elseIf ($($Database.Status) -like "*restoring*") {$DB1sts="<font color=yellow>$($Database.Status)</font>"}
elseIf ($($Database.Status) -like "*normal*") {$DB1sts="<font color=green>Online</font>"} 
else { $DB1sts="$($Database.Status)"}

###Servername####

If ($s -eq $null) {$Srnm=$server} else {$Srnm=$null}
If ($i -eq $null) {$Instnm=$instance1; $Agtst=$Agtsts; $upt=$uptime} else {$Instnm=$Agtst=$upt=$null}

$i++
$s++
################

	$body += "<tr bgcolor=white align=left><TD><b>$srnm</b></TD><TD><b>$Instnm</b></TD><TD>$Agtst</TD><TD>$upt</TD><TD><b>$($Database.Name)</b></TD><TD>$DB1sts</TD></TD><TD>$($Database.Size)</TD><TD>$($Database.DataSpaceUsage)</TD><TD>$($Database.SpaceAvailable)</TD></TR>"
	
$i++
$s++
	} #Foreach($Database in $SQLServer.Databases)
} #if (!$SQLServer)

#$body += "</Table>"
#$bodyM += "<tr bgcolor=white align=left><TD>$instance1</TD><TD>$body</TD></tr>"

#$body=$null
	


} else {$runerr=$ErrorMessage=$null}#If ($runerr -ne 7)
 
} #foreach ($instance in $instances)

#}
 #else {$errrun11=$null} #If ($errrun11 -ne "11")

} #ForEach ($Server in $Servers)
}
$body += "</Table>"
#$bodyM += "</Table>"

###########################################################################

$msgBody = "<table  cellpadding=3 cellspacing=1  bgcolor=#FF8F2F>"
$msgBody += "<tr align=center>"
$msgBody += "<td bgcolor=#DDDDDD><FONT face=Verdana size=1.5 ><b>MSSQL Deployment Report</b></font></td>"
$msgBody += "</tr>"
$msgBody += "<tr>"
$msgBody += "<td bgcolor=white><FONT face=Verdana size=1.5 >$body</font></td>"
$msgBody += "</tr>"
$msgBody += "</table>"

###################################################

#######file creation#######################
$File = "C:\sql\MSSQL_Deployment_Report.htm"
If ((Test-Path $File) -eq $true){ Remove-Item $File }
Add-Content -Path $File  -Value $msgBody
"Created file - $File"

###########################################

######send EMAIL######################

##### Change the value####
$smtp = "SMTP Server" 
$to = "ABC@AYZ.COM" 
$from = "ABC@AYZ.COM"
$cc = "ABC@AYZ.COM"
########################

$subject = "MSSQL Deployment Report"
#send-MailMessage -SmtpServer $smtp -To $to -Cc $cc -From $from -Subject $subject -Body $msgbody -BodyAsHtml
######send EMAIL#########################


