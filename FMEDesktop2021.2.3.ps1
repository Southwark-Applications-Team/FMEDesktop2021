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

Param (
    [bool]$test=$true
)

#region prepare log
$logfolder = "$psscriptroot\Logs" 
new-item $logfolder -ItemType Directory -ErrorAction SilentlyContinue
$logfile = Join-Path $logfolder -ChildPath ("$([io.path]::GetFileNameWithoutExtension($MyInvocation.MyCommand.Definition))_{0:yyyyMMdd_HHmm}.txt" -f (get-date))

# tidy log folder
Get-ChildItem $logfolder -File *.txt | Where-Object LastWriteTime -lt  (Get-Date).AddDays(-21)  | Remove-Item -Force -WhatIf

Start-Transcript -Path $logfile

#endregion

$Command = "C:\Apps\FMEDesktop2021.2.3\fme.exe"

$dash = '-'*50
#--------------
# Functions
#--------------

# email alert   
function Set-EmailAlert {
    param (
        $logfile  
    )
    $alerts = @()
    if ($test) {$alerts += 'Stuart.Carter@SOUTHWARK.GOV.UK' }
    $alerts += 'neil.brereton@southwark.gov.uk'

    $lines = Select-String -Path $logfile  -Pattern '(Translation|^-|fme\.exe|run start|run completed|process completed|error)'
    $SuccessLines = Select-String -Path $logfile  -Pattern '(SUCCESSFUL with)'
    $FailedLines = Select-String -Path $logfile  -Pattern '(FAILED with)'

    Write-Host ("Success {0}" -f $SuccessLines.Count) -ForegroundColor Green  
    Write-Host ("Failed {0}" -f $FailedLines.Count) -ForegroundColor red  


    if ($lines) { $lines }  else { "not found" } 
    
    $body = 'Report from scheduled task FMEDesktop2021 on LBSVSLAPP022<br>See attached for full log<br><br>'
    $lines | ForEach-Object {
        if ($_.line -match '(error|failed)') {
            $body +=  "<span style=""color: red"">{0}</span><br>" -f  $_.Line
        } elseif ($_.line -match '(successful$)') {
            $body +=  "<span style=""color: black"">{0}</span><br>" -f  $_.Line
        } else {
            $body +=  "{0}<br>" -f  $_.Line
        }
    }
    $subject = 'FME Desktop'
    if ($test) { $subject += ' TEST'}
    #$subject += " Success={0} Fail={1}" -f $SuccessLines.Count, $FailedLines.Count
    if ($SuccessLines.Count -gt 0) {$subject += " Success={0}" -f $SuccessLines.Count}
    if ($FailedLines.Count -gt 0) {$subject += " Fail={0}" -f $FailedLines.Count}
    
    $MyParameters = @{
        to = $alerts
        #Cc = @()
        #Bcc = 'nbrereton1@gmail.com'     
        subject = $subject
        bodyashtml = $true
        body = "$body<br><br>"
        from = 'FMEpublish@lbsvslapp022'
        SmtpServer = 'smtp.southwark.gov.uk'
        Attachments = $LogFile
    } 
    
    
    
    #send-mailmessage -to $alerts -subject $subject -bodyashtml -body $body -from  $from -SmtpServer “mail.lbs.ad.southwark.gov.uk"  
    
    send-mailmessage @MyParameters 
    
}

# run the FME program 
function Publish-FMEWorkspace 
{ 
    Param ($workspace)
    Write-Host "$dash"
    Write-Host $Command $workspace
   
    & "$Command" $workspace

    write-host ("Process completed at {0}" -f (get-date))
    Start-Sleep -Seconds 5

}

# run started or completed message
function Set-RunMessage ($msg) { write-host ("{0} {1:dd/MM/yyyy HH:mm:ss}" -f $msg, (get-date))}

#--------------
# Main
#--------------

Set-RunMessage -msg "Run Started"

if (-not $test) {
    Publish-FMEWorkspace "E:\FME workspaces\PROD_ConfirmGroupProcessing.fmw"

    Publish-FMEWorkspace "E:\FME workspaces\PROD_LLPG_SSA_AddressSearchUpdate.fmw"

    Publish-FMEWorkspace "E:\FME workspaces\PROD_Exacom.fmw"

    Publish-FMEWorkspace "E:\FME workspaces\PROD_UniformGroupProcessing.fmw" 
}

Write-Host "$dash"
Set-RunMessage -msg "Run Completed"

stop-transcript 

if ($test) {  Set-EmailAlert -logfile 'E:\Scripts\FMEDesktop2021\Logs\example.log' } 
else { Set-EmailAlert -logfile $logfile }   


