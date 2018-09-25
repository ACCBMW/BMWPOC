#################################################################################################################
# Name:              SQL Server(s) Discover database Report								#
# Created By:        Anurag Biala										#
# Team:              Cloud Automation 										#
# Version:           1.0											#
# Functionality:     This Script will be used to report database in detail of SQL servers			#
#		     												#  
#											 			#
# Environment:       SQL Server 2008 or above in windows server 2008 or above environment			#
# Email ID:          Point if Contact in case of any Issue 							#
#                    “Infra-ScriptFactory@accenture.com”								#
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

$body = "<table cellpadding=3 cellspacing=1  bgcolor=#FF8F2F style='font-family:verdana; font-size:7pt;'>"
$body += "<tr bgcolor=#DDDDDD>
	<TH>ServerName</TH>
	<TH>Instance Name</TH>
        <TH>Memory</TH>
	<TH>Login Details</TH>
        <TH>Clustered</TH>
        <TH>Product Info</TH>
        <TH>DB Version</TH>        
        <TH>Edition</TH>
        <TH>Product Level</TH>       
	<TH>SQL Server Agent</TH>
        <TH>SQL Jobs</TH>
	<TH>Uptime</TH>
        <TH>Database Detail</TH></tr>"

#######################Get Instance name########################
########
$s=$null
$server=$env:COMPUTERNAME
$TARGETDIR="C:\mdffiles.txt"
if(Test-Path -Path $TARGETDIR ){
Remove-Item -Path $TARGETDIR
New-Item -Path "c:\" -Name "mdffiles.txt" -ItemType "file"
}
else
{
New-Item -Path "c:\" -Name "mdffiles.txt" -ItemType "file"
}
#######
Try{
$errrun11=$null									
Get-WmiObject -computer $server win32_service -ErrorAction Stop >.\tmp.txt
$instances = Get-WmiObject -ComputerName $server win32_service | where {(($_.name -eq "MSSQLSERVER") -or ($_.name -like "MSSQL$*"))} | select-object name
}catch {  $ErrorMessage = $_.Exception.Message ; $errrun11=11

$body += "<tr bgcolor=white align=center><td><b>$server</b></td><TD colspan=12 align=left><font color=red>$ErrorMessage</font></TD></tr>"
}


If ($errrun11 -ne "11") {

##--------------------------Discovery Instance and Start one by one---------------------------------

foreach ($instance in $instances) {

$Instname="$($instance.name)"

if ($instance.name -like "MSSQLSERVER") { $instance1=$server} else {
$instance =  $($instance.name).Split("$")
$instance1="$server\$($instance[1])"
$Instname="$($instance[1])"
}
#######Instance name#########
$instance1
$name=$instance1


####end Instance name#########
try {
$runerr=$null
$srv = New-Object ('Microsoft.SqlServer.Management.Smo.Server') "$instance1"
$SJruns=$srv.JobServer.Jobs | Where-Object {$_.CurrentRunStatus -eq "running"} | Select Name,LastRunDate,nextrundate,CurrentRunStatus
$dbstest=$srv.Databases.name
$dbstest >tmp.txt
} catch {$ErrorMessage = $_.Exception.Message; $runerr=7
###Servername####

If ($s -eq $null) {$Srnm=$server} else {$Srnm=$null}
$Instnm=$instance1
#$i++
$s++
################
$body += "<tr bgcolor=white align=center><td><b>$Srnm</b></td><td><b>$instance1</b></td><TD colspan=10 align=left><font color=red>$ErrorMessage</font></TD></tr>"
}

If ($runerr -ne 7) {

################################################################

####
$i=$null
####
	$SQLServer=$null

 	$SQLServer = $srv

#############
	try{ Foreach($Database in $SQLServer.Databases){ break}} catch {$SQLServer=$null}

if (!$SQLServer) { #$body += "<tr bgcolor=#D3D3D3 align=center><TD colspan=10 align=center><font color=red><B>$instance</B></font></TD></tr>" 
} else {

	
#######Common Parameters##################
$Clusinfo= if ($sqlserver.isclustered -eq $true) {"Yes"} else {"No"}

#----Logins------------------------
$SQLLogins = $sqlserver.Logins

#############Logins##################################
$bodyM = "<table cellpadding=3 cellspacing=1  bgcolor=#FF8F2F style='font-family:verdana; font-size:7pt;'>"
$bodyM += "<tr bgcolor=#DDDDDD><TH>Login</TH><TH>Type</TH><TH>Member</TH></tr>"

$Slog="Login-Type-listMember <BR>"
foreach ($SQLLogin in $SQLLogins) {

$Lnm=$SQLLogin.name
$ltyp=$SQLLogin.logintype
#-----------------
$memb=$membr=$null
$membrs=$SQLLogin.ListMembers()
 foreach ($membr in $membrs) {
if ($memb){$memb += ","+$membr} else {$memb += $membr}
}#foreach ($membr in $membrs)

#----------------------
if (!$memb) {$memb="Public"}
$Slog+="$Lnm-$ltyp-$memb <BR>"
if($memb -notmatch "sysadmin") {
$bodyM += "<tr bgcolor=white align=left><TD>$Lnm</TD><TD>$ltyp</TD><TD>$memb</TD></tr>"
} else { $bodyM += "<tr bgcolor=white align=left><TD><font color=red >$Lnm</font></TD><TD>$ltyp</TD><TD>$memb</TD></tr>" }
}#foreach ($SQLLogin in $SQLLogins)
$bodyM += "</table>"

#------logins end----------------

#-------SQL Jobs-----------------
$flagjob=$null
$bodyJobM = "<table cellpadding=3 cellspacing=1  bgcolor=#FF8F2F style='font-family:verdana; font-size:7pt;'>"
$bodyJobM += "<tr bgcolor=#DDDDDD><TH>Name</TH><TH>LastRun</TH><TH>NextRun</TH><TH>Enabled</TH></tr>"
$Sjobsts=$null
$Sjobs=$SQLServer.JobServer.Jobs | Where-Object {($_.IsEnabled -eq $TRUE) -and ($_.name -notlike "*Machine*")} | Select Name,LastRunDate,nextrundate,IsEnabled

if ($Sjobs){

Foreach ($Sjob in $Sjobs) {

$bodyJobM += "<tr bgcolor=white align=left><TD>$($Sjob.name)</TD><TD>$($Sjob.LastRunDate)</TD><TD>$($Sjob.nextrundate)</TD><TD>$($Sjob.IsEnabled)</TD></tr>"

}#Foreach ($Sjob in $Sjobs)

} else { $flagjob= "Yes"}

$bodyJobM += "</table>"

If ($flagjob) {$bodyJobM = "No Job"}
#-------SQL Jobs end-------------

#######Common Parameters end##########################


###############Database Start Time###########
$UpTime=$null

if($SQLServer.Databases['tempdb']) {

        $udb = $SQLServer.Databases['tempdb']
        $CreateDate = $udb.CreateDate        
        $Time = (Get-Date) – $CreateDate
        
        $UpTime ="$($Time.DAYS) days $($Time.HOURS) hrs $($Time.MINUTES) mins $($Time.SECONDS) sec"

	}  

##################################SQL version detail##############
$databasename=$null
$Query = "
SELECT 
CASE 
WHEN   SERVERPROPERTY('PRODUCTVERSION') >= '13.0.1601.5' AND SERVERPROPERTY('PRODUCTVERSION') <'13.0.4001.0' 
 THEN 'SQL SERVER 2016' 
WHEN   SERVERPROPERTY('PRODUCTVERSION') >= '12.0.2000.8' AND SERVERPROPERTY('PRODUCTVERSION') <'12.0.4100.00' 
 THEN 'SQL SERVER 2014' 
WHEN SERVERPROPERTY('PRODUCTVERSION') >= '11.0.2100.60' AND SERVERPROPERTY('PRODUCTVERSION') <'12.0.2000.8' 
 THEN 'SQL SERVER 2012' 
 WHEN SERVERPROPERTY('PRODUCTVERSION')>='10.50.1600.1' AND SERVERPROPERTY('PRODUCTVERSION')<'11.0.2100.60' 
 THEN 'SQL SERVER 2008R2' 
 WHEN SERVERPROPERTY('PRODUCTVERSION')>='10.0.1600.22' AND SERVERPROPERTY('PRODUCTVERSION')<'10.50.1600.1' 
 THEN 'SQL SERVER 2008' 
 WHEN SERVERPROPERTY('PRODUCTVERSION')>='9.00.1399.06' AND SERVERPROPERTY('PRODUCTVERSION')<'10.0.1600.22' 
 THEN 'SQL SERVER 2005' 
 WHEN SERVERPROPERTY('PRODUCTVERSION')>='8.0.194' AND SERVERPROPERTY('PRODUCTVERSION')<'9.0.1399.06' 
 THEN 'SQL SERVER 2000' 
END AS SQLServer,
SERVERPROPERTY('PRODUCTVERSION ') AS DatabaseVersion,  
 SERVERPROPERTY('EDITION')AS Edition,
SERVERPROPERTY('PRODUCTLEVEL') AS productLevel
"
#Timeout parameters
$QueryTimeout = 120
$ConnectionTimeout = 30
$conn=New-Object System.Data.SqlClient.SQLConnection
$ConnectionString = "Server={0};Database={1};Integrated Security=True;Connect Timeout={2}" -f $instance1,$DatabaseName,$ConnectionTimeout
$conn.ConnectionString=$ConnectionString
$conn.Open()
$cmd=New-Object system.Data.SqlClient.SqlCommand($Query,$conn)
$cmd.CommandTimeout=$QueryTimeout
$ds=New-Object system.Data.DataSet
$da=New-Object system.Data.SqlClient.SqlDataAdapter($cmd)
try{
[void]$da.fill($ds)
} catch {}
$conn.Close()
$PrDetail=$ds.Tables
$PrDetail1=$PrDetail.SQLServer
$PrDetail2=$PrDetail.DatabaseVersion
$PrDetail3=$PrDetail.Edition
$PrDetail4=$PrDetail.productLevel

$PrDetail=$null

###################################################################


##################################Memory Detail##############
#--------------------
$bodyMem = "<table cellpadding=3 cellspacing=1  bgcolor=#FF8F2F style='font-family:verdana; font-size:7pt;'>"
$bodyMem += "<tr bgcolor=#DDDDDD><TH>Description</TH><TH>Value</TH></tr>"
#--------------------
$databasename=$null
$Query = "
SELECT CAST(description AS VARCHAR(50)) AS description, 
       CAST(value AS VARCHAR(50)) AS value
  FROM sys.configurations
 WHERE name IN ('awe enabled','max server memory (MB)','min server memory (MB)','priority boost')
 ORDER BY name
"
#Timeout parameters
$QueryTimeout = 120
$ConnectionTimeout = 30
$conn=New-Object System.Data.SqlClient.SQLConnection
$ConnectionString = "Server={0};Database={1};Integrated Security=True;Connect Timeout={2}" -f $instance1,$DatabaseName,$ConnectionTimeout
$conn.ConnectionString=$ConnectionString
$conn.Open()
$cmd=New-Object system.Data.SqlClient.SqlCommand($Query,$conn)
$cmd.CommandTimeout=$QueryTimeout
$ds=New-Object system.Data.DataSet
$da=New-Object system.Data.SqlClient.SqlDataAdapter($cmd)
try{
[void]$da.fill($ds)
} catch {}
$conn.Close()
Foreach ($mem in $ds.Tables[0]) {
$memd=$memV=$null
$memd=$mem.description
$memV=$mem.value

$bodyMem += "<tr bgcolor=white align=left><TD>$memd</TD><TD>$memv</TD></tr>"

} #Foreach ($mem in $ds.Tables)

$bodyMem += "</table>"

##################################Memory Detail end###############

####---------------------Database loop-----------------------------
################end database Start Time########
#--------------------------------Format------------------------------
$bodyDB = "<table cellpadding=3 cellspacing=1  bgcolor=#FF8F2F style='font-family:verdana; font-size:7pt;'>"
$bodyDB += "<tr bgcolor=#DDDDDD>
        <TH>Databases</TH>
        <TH>Roles</TH>
	<TH>Status</Th>
        <TH>Total-Size</Th>	
        <TH>MDB-file (Size -Used%)</TH>
        <TH>Log-file (Size -Used%)</TH>
	<TH>DataSpaceUsage(KB)</Th>
	<TH>SpaceAvailable(KB)</TH>
	<TH>RecoveryModel</TH>
	<TH>Full Backup</TH>
	<TH>Differential Backup</TH>
	<TH>Log Backup</TH></tr>"
#---------------------------------------------------------------------


	Foreach($Database in $SQLServer.Databases) {




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

###############DB Roles################################################
$db = $srv.Databases.Item($($Database.Name))
try { $db.users >tmp.txt
 
$bodyDBM = "<table cellpadding=3 cellspacing=1  bgcolor=#FF8F2F style='font-family:verdana; font-size:7pt;'>"
$bodyDBM += "<tr bgcolor=#DDDDDD><TH>User</TH><TH>Login</TH><TH>Type</TH><TH>Role</TH></tr>"


###################################


Foreach ($us in $db.Users) {

$uname= $us.Name
$utype= $us.usertype
$ulogin=$us.login

if ($ulogin) {$checklogin=$ulogin} else {$checklogin=$uname}

##################Role check#################
If ($checklogin) {

Foreach ($role in $db.roles){

$Rmember=$role.enummembers()
$rname=$role.name

If ($Rmember -contains $uname) {

$DBlog +="$uname,$checklogin,$utype,$rname<br>" 
$bodyDBM += "<tr bgcolor=white align=left><TD>$uname</TD><TD>$checklogin</TD><TD>$utype</TD><TD>$rname</TD></tr>"

}#If ($Rmember -contains $uname)
} #Foreach ($role in $db.roles
} #If ($ulogin)
} #Foreach ($us in $db.Users)
$bodyDBM += "</table>"

} catch { $bodyDBM=$null}


################Role Check end###############

###########Database file path check################
try { $db.FileGroups >tmp.txt
$MDBF=$LOGF=$null


###########Database file path check################
if ($db) {

#----------------------------------------------------------------
foreach ($fg in $db.FileGroups) { 
            foreach ($fl in $fg.Files) {  $dbsz=$dbsz1=$null
                        $fl1=$fl.FileName
                        echo "$fl1" >> "C:\mdffiles.txt"
      					 
					$dbsZ=[math]::Round(($fl.size)/1kb,2) 
                			$dbsz1=[math]::Round(($fl.size))
 
                                        $Mpercentused = [Math]::Round(($fl.UsedSpace/$fl.size) * 100, 1)
                                        
			if ($dbsz -match ".00") { $MDBF += $fl.FileName +" ("+"$dbsz1"+"MB -"+$Mpercentused+"%)" 
                                      
} else {$MDBF += $fl.FileName +" ("+"$dbsz"+"MB -"+$Mpercentused+"%)" 
                                      
}
					 
            }}
#----------------------------------------------------------------    
 #Process all log files used by the database 
   foreach ($dblogfile in $db.logfiles) { $lgsz=$lgsz1=$Lpercentused=$null
                                   $db1=$dblogfile.FileName
                                   echo "$db1" >> "C:\mdffiles.txt"
                                      
                                        $lgsz=[math]::Round(($dblogfile.size)/1kb,2) 
                			$lgsz1=[math]::Round(($dblogfile.size)) 
                                        $Lpercentused = [Math]::Round(( ($dblogfile.UsedSpace) /($dblogfile.size) ) * 100, 1)
                                         
          
			if ($lgsz -match ".00") { $LOGF += $dblogfile.FileName +" ("+"$lgsz1"+"MB -"+$Lpercentused +"%)" 
                                      
} else {$LOGF += $dblogfile.FileName +" ("+"$lgsz"+"MB -"+$Lpercentused +"%)" 
                                       
}            
            }}
#----------------------------------------------------------------
} catch {$LOGF=$null}

###########Database file path check#################

#################DB Roles end#########################################


 

################SQL Agent Check#################
$Sqlagt = Get-WmiObject -ComputerName $server win32_service | where {($_.displayname -like "SQL Server Agent*") -and ($_.displayname -like "*($instname)*")}
If ($($Sqlagt.state) -eq "Running") {$AGTsts="<font color=green>$($Sqlagt.state)</font>"} else { $AGTsts="<font color=red>$($Sqlagt.state)</font>"}

################end SQL Agent Check#################

################Database Status#######################

If ($($Database.Status) -like "*offline*") {$DB1sts="<font color=red>$($Database.Status)</font>"} 
#elseIf ($($Database.Status) -like "*restoring*") {$DB1sts="<font color=yellow>$($Database.Status)</font>"}
elseIf ($($Database.Status) -like "*normal*") {$DB1sts="<font color=green>Online</font>"} 
else { $DB1sts="$($Database.Status)"}

###Servername####

$Srnm=$server
#If ($i -eq $null) {$Instnm=$instance1; $Agtst=$Agtsts; $upt=$uptime} else {$Instnm=$Agtst=$upt=$PrDetail1=$PrDetail2=$PrDetail3=$PrDetail4=$Clusinfo=$slog=$bodyM=$null}

$i++
$s++
##################
################################Total Size ###################################
  		$Tdbsz=$TSZ=$Tdbsz1=$null
		$TdbsZ=[math]::Round($($Database.Size),2) 
                $Tdbsz1=[math]::Round($($Database.Size))  

		if ($Tdbsz -match ".00") { $TSZ= "$Tdbsz1"+"MB" } else {$TSZ= "$Tdbsz"+"MB" }
                 
################################Total Size End################################


	$bodyDB += "<tr bgcolor=white align=left>
	<TD><b>$($Database.Name)</b></TD>
        <TD>$bodyDBM</TD>
	<TD>$DB1sts</TD>
	<TD>$TSZ</TD>
        <TD>$mdbf</TD>
        <TD>$logf</TD>
	<TD>$($Database.DataSpaceUsage)</TD>
	<TD>$($Database.SpaceAvailable)</TD>
	<TD>$($Database.RecoveryModel)</TD>
	<TD>$LFBD</TD><TD>$LDBD</TD>
	<TD>$LLBD</TD></TR>"
	
$i++
$s++

####---------------------Database loop-----------------------------

	} #Foreach($Database in $SQLServer.Databases)

#-----------------------------------------
$bodyDB += "</Table>"
$body += "<tr bgcolor=white align=left>
	<TD><b>$srnm</b></TD>
	<TD><b>$instance1</b></TD>
        <TD>$bodyMem</TD>
        <TD>$bodyM</TD>
        <TD>$Clusinfo</TD>        
	<TD>$PrDetail1</TD>
	<TD>$PrDetail2</TD>
	<TD>$PrDetail3</TD>
	<TD>$PrDetail4</TD>
	<TD>$AGTsts</TD>
        <TD>$bodyJobM</TD>
	<TD>$uptime</TD>
        <TD>$bodyDB</TD></TR>"	

#------------------------------------------
$srnm=$instance1=$bodyM=$Clusinfo=$PrDetail1=$PrDetail2=$PrDetail3=$PrDetail4=$AGTsts=$bodyJobM=$uptime=$bodyDB=$null

} #if (!$SQLServer)



} else {$runerr=$ErrorMessage=$null}#If ($runerr -ne 7)


 
} #foreach ($instance in $instances)

} else {$errrun11=$null} #If ($errrun11 -ne "11")

#ForEach ($Server in $Servers)
##--------------------------Discovery Instance and Start one by one end---------------------------------

$body += "</Table>"


###########################################################################

$msgBody = "<table  cellpadding=3 cellspacing=1  bgcolor=#FF8F2F>"
$msgBody += "<tr align=center>"
$msgBody += "<td bgcolor=#DDDDDD><FONT face=Verdana size=1.5 ><b>SQL Server(s) Report</b></font></td>"
$msgBody += "</tr>"
$msgBody += "<tr>"
$msgBody += "<td bgcolor=white><FONT face=Verdana size=1.5 >$body</font></td>"
$msgBody += "</tr>"
$msgBody += "</table>"

###################################################

#######file creation#######################
#$File = "C:\Users\Administrator\Desktop\SQLServerReport.htm"
#If ((Test-Path $File) -eq $true){ Remove-Item $File }
#Add-Content -Path $File  -Value $msgBody
#"Created file - $File"

###########################################



