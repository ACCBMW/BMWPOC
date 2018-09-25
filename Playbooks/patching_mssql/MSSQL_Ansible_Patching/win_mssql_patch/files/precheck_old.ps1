$body = "<html><title>Pre Patching Report</title><center><BR><BR><font family:verdana; size:10pt;><b><u>PATCHING PRECHECK REPORT</b></u></font><table cellpadding=3 cellspacing=3  bgcolor=#FF8F2F  style='font-family:verdana; font-size:10pt;'><br><br>"
$body += "<tr bgcolor=#DDDDDD><TH>ServerName</TH><TH>Product Name</TH><TH>Edition</TH><TH>Version</TH><TH>Instance Name</TH><TH>Status</TH><TH>Date</TH></tr>"
$ser_stat = Get-Service |  where{ $_.name -like "MSSQL$*"} |select-object name, Status
forEach($ser in $ser_stat){
if($ser_stat.Status -eq "Running"){
$Server = $env:COMPUTERNAME
$SQLServer=$null
$SQLServer = New-Object ('Microsoft.SqlServer.Management.Smo.Server') $Server 
$databasename=$null
$Query = "select @@version"
#Timeout parameters
$QueryTimeout = 120
$ConnectionTimeout = 30
$conn=New-Object System.Data.SqlClient.SQLConnection
$ConnectionString = "Server={0};Database={1};Integrated Security=True;Connect Timeout={2}" -f $server,$DatabaseName,$ConnectionTimeout
$conn.ConnectionString=$ConnectionString
$conn.Open()
$cmd=New-Object system.Data.SqlClient.SqlCommand($Query,$conn)
$cmd.CommandTimeout=$QueryTimeout
$ds=New-Object system.Data.DataSet
$da=New-Object system.Data.SqlClient.SqlDataAdapter($cmd)
[void]$da.fill($ds)
$conn.Close()
$data1= $ds.Tables[0]
$productinfos=($data1.column1).Split('-')
$Pinfo=$productinfos[0]
$today = date
$body += "<tr bgcolor=#DDDDDD><TH>"+$env:COMPUTERNAME+"</TH><TH>"+$Pinfo+"</TH><TH>"+$SQLServer.Edition+"</TH><TH>"+$SQLServer.VersionString+"</TH><TH>"+$ser.Name+"</TH><TH><font color=green>"+$ser.Status+"</TH><TH>"+ $today +"</TH></tr>"
}
else{
#write "failed - "$ser.Name
$body += "<tr bgcolor=#DDDDDD><TH>"+$env:COMPUTERNAME+"</TH><TH>-</TH><TH>-</TH><TH>-</TH><TH>"+$ser.Name+"</TH><TH><font color=red>"+$ser.Status+"</TH><TH>"+ $today +"</TH></tr>"
}
}
$body += "</table></html>"
$type = [Microsoft.Win32.RegistryHive]::LocalMachine;
$regconnection = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey($type, $env:COMPUTERNAME) ;
$instancekey = "SOFTWARE\Microsoft\Microsoft SQL Server\Instance Names\SQL";
$openinstancekey = $regconnection.opensubkey($instancekey);
$instances = $openinstancekey.getvaluenames();
foreach ($instance in $instances) {
 
                # Define SQL setup registry keys
                $instancename = $openinstancekey.getvalue($instance);
                $instancesetupkey = "SOFTWARE\Microsoft\Microsoft SQL Server\" + $instancename + "\Setup"; 
 
                # Open SQL setup registry key
                $openinstancesetupkey = $regconnection.opensubkey($instancesetupkey);
 
                $edition = $openinstancesetupkey.getvalue("Edition")
 
                # Get version and convert to readable text
                $version = $openinstancesetupkey.getvalue("Version");
 }
$version > c:\pre_post\ver.txt
$body|out-file -FilePath C:\pre_post\pre_patch_report.html

