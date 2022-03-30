<#
2a
Server: lbsvslapp022
Application: FME Desktop 2019.2
Process to run: C:\Apps\FMEDesktop2021.2.3\fme.exe "E:\FME workspaces\PROD_ConfirmGroupProcessing.fmw"
When: 06:00, daily (seven days) 

2b
Server: lbsvslapp022
Application: FME
Process to run: C:\Apps\FMEDesktop2021.2.3\fme.exe "E:\FME workspaces\PROD_LLPG_SSA_AddressSearchUpdate.fmw"
When: 06:15, daily (seven days)

2c
Server: lbsvslapp022
Application: FME
Process to run: C:\Apps\FMEDesktop2021.2.3\fme.exe "E:\FME workspaces\PROD_Exacom.fmw"
When: 06:30, daily (seven days) 

2d
Server: lbsvslapp022
Application: FME
Process to run: C:\Apps\FMEDesktop2021.2.3\fme.exe "E:\FME workspaces\PROD_UniformGroupProcessing.fmw" 
When: 06:45, daily (seven days)
#>

#region prepare log
$logfolder = "$psscriptroot\Logs" 
new-item $logfolder -ItemType Directory -ErrorAction SilentlyContinue
$logfile = Join-Path $logfolder -ChildPath ("$([io.path]::GetFileNameWithoutExtension($MyInvocation.MyCommand.Definition))_{0:yyyyMMdd_HHmm}.txt" -f (get-date))

# tidy log folder
Get-ChildItem $logfolder -File *.txt | Where-Object LastWriteTime -lt  (Get-Date).AddDays(-21)  | Remove-Item -Force -WhatIf

Start-Transcript -Path $logfile

#endregion

$Command = "C:\Apps\FMEDesktop2021.2.3\fme.exe"

# email alert   
function Set-EmailAlert {
    param (
        $logfile  
    )
    
    $lines = Select-String -Path $logfile  -Pattern '(Translation|^-|fme\.exe|run start|run completed)'

    if ($lines) { $lines }  else { "not found" } 
    
    $body = ''
    $lines | ForEach-Object {$body = $body +  $_.Line  + '<br>'}

    
    $MyParameters = @{
        to = 'neil.brereton@southwark.gov.uk'
        #Cc = @()
        #Bcc = 'nbrereton1@gmail.com'     
        subject = 'FME Desktop scheduled tasks'
        bodyashtml = $true
        body = "$body<br><br>"
        from = 'FMEpublish@lbsvslapp022'
        SmtpServer = 'smtp.southwark.gov.uk'
        #Attachments = $LogFile
    } 
    
    
    
    #send-mailmessage -to $alerts -subject $subject -bodyashtml -body $body -from  $from -SmtpServer “mail.lbs.ad.southwark.gov.uk"  
    
    send-mailmessage @MyParameters 
    
}

function Publish-FMEWorkspace 
{ 
    Param ($workspace)
    Write-Host "`r`n----------------------------------`r`n$Command" $workspace
   
    & "$Command" $workspace

    write-host ("Process completed at {0}" -f (get-date))
    Start-Sleep -Seconds 5

}
#--------------
# Main
#--------------


stop-transcript 

Set-EmailAlert -logfile 'E:\Scripts\FMEDesktop2021\Logs\FMEDesktop2021.2.3_20220324_0601.txt'
 


