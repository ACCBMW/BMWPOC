    new-psdrive -name SQLInstallDrive -psprovider FileSystem -root "C:\SQL_SERVER_SP";
    set-location SQLInstallDrive:;
    
    #The Like command contains keywords from the service pack exe. When ever a new SP exe is released you will need to
    #add a new if else block and put the keywords from the SP exe in the Like filter. It should be distinct from other   
    #Like filters.
    
    If (Get-ChildItem | Select-Object Name | Where-Object {$_.Name -Like '*2012SP3*.exe'})
    {
      #The file.txt is created in the local folder only after execution of the SP exe and contains the name of the SP   
      #Exe that was executed.

      "2012 SP3" | Out-File -filepath 'C:\SQL_SERVER_SP\file.txt';
      .\SQLServer2012SP3-KB3072779-x64-ENU.exe /action=patch /quiet /allinstances /IAcceptSQLServerLicenseTerms
    }

    ElseIf (Get-ChildItem | Select-Object Name | Where-Object {$_.Name -Like '*2012*.exe'})
    {
      "2012 CU" | Out-File -filepath 'C:\SQL_SERVER_SP\file.txt';
      .\SQLServer2012-KB3137746-x64.exe /action=patch /quiet /allinstances /IAcceptSQLServerLicenseTerms
    }

    ElseIf (Get-ChildItem | Select-Object Name | Where-Object {$_.Name -Like '*2008R2SP3*.exe'})
    {
      "2008R2 SP3" | Out-File -filepath 'C:\SQL_SERVER_SP\file.txt';
      .\SQLServer2008R2SP3-KB2979597-x64-ENU.exe /action=patch /quiet /allinstances /IAcceptSQLServerLicenseTerms
    }
    ElseIf (Get-ChildItem | Select-Object Name | Where-Object {$_.Name -Like '*2008R2SP2*.exe'})
    {
      "2008R2 SP2" | Out-File -filepath 'C:\SQL_SERVER_SP\file.txt';
      
    }
