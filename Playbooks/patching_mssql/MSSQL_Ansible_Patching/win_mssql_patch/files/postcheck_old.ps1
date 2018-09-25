$a = gc c:\users\test\ver.txt
$body = "<html><title>Patching Post CHeck Report</title><center><BR><BR><font family:verdana; size:10pt;><b><u>POST PATCHING REPORT</b></u></font><table cellpadding=3 cellspacing=3  bgcolor=#FF8F2F  style='font-family:verdana; font-size:10pt;'><br><br>"
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

$body += "<tr bgcolor=#DDDDDD><TH>"+$env:COMPUTERNAME+"</TH><TH>"+$Pinfo+"</TH><TH>"+$SQLServer.Edition+"</TH><TH>Previous Version: "+$a+"<br>Current Version: "+$SQLServer.VersionString+"</TH><TH>"+$ser.Name+"</TH><TH><font color=green>"+$ser.Status+"</TH><TH>"+ $today +"</TH></tr>"
$body
}
else{
#write "failed - "$ser.Name
$body += "<tr bgcolor=#DDDDDD><TH>"+$env:COMPUTERNAME+"</TH><TH>-</TH><TH>-</TH><TH>-</TH><TH>"+$ser.Name+"</TH><TH><font color=red>"+$ser.Status+"</TH><TH>"+ $today +"</TH></tr>"
}
}
$body += "</table></html>"
$body |out-file -FilePath C:\pre_post\post_patch_report.html
