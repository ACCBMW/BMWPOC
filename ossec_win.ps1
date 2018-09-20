$agent_key = "asdasd"
$path = 'C:\Users\ossec-agent-win32-2.9.3-2912.exe'
$config = "C:\Program Files (x86)\ossec-agent\ossec.conf"
Start-Process -Wait -FilePath  -ArgumentList '/S' -PassThru
Add-Content $config "`n<ossec_config>   <client>      <server-ip>0.0.0.0</server-ip>   </client> </ossec_config>"
echo "y" | & "C:\Program Files (x86)\ossec-agent\manage_agents.exe" "-i $($agent_key)" "y`r`n"