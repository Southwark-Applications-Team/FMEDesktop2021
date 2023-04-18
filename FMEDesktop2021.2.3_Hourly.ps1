<#

Server: lbsvslapp022
Application: FME Desktop 2021.2
Process to run: C:\Apps\FMEDesktop2021.2.3\fme.exe "E:\FME workspaces\PROD_BroadbandViaFTP.fmw"
When: 15 minutes past each hour (for 24 hours)
Days: Monday to Sunday

to do :   use same script has original run every day

#>

Param (
    [bool]$test=$true
)

#region prepare log
$basename = [io.path]::GetFileNameWithoutExtension($MyInvocation.MyCommand.Definition)
$logfolder = "$psscriptroot\Logs\$basename" 
new-item $logfolder -ItemType Directory -ErrorAction SilentlyContinue
$logfile = Join-Path $logfolder -ChildPath ("$($basename)_{0:yyyyMMdd_HHmm}.txt" -f (get-date))

# tidy log folder
Get-ChildItem $logfolder -File *.txt | Where-Object LastWriteTime -lt  (Get-Date).AddDays(-2)  | Remove-Item -Force -WhatIf

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
    if (!$test) {$alerts += 'Stuart.Carter@SOUTHWARK.GOV.UK' }
    $alerts += 'neil.brereton@southwark.gov.uk'

    $lines = Select-String -Path $logfile  -Pattern '(Translation|^-|fme\.exe|run start|run completed|process completed|error)'
    $SuccessLines = Select-String -Path $logfile  -Pattern '(SUCCESSFUL with)'
    $FailedLines = Select-String -Path $logfile  -Pattern '(FAILED with)'
 
    Write-Host ("Success {0}" -f $SuccessLines.Count) -ForegroundColor Green  
    Write-Host ("Failed {0}" -f $FailedLines.Count) -ForegroundColor red  


    if ($lines) { $lines }  else { "not found" } 
    
    $body = "Report from scheduled task $basename on LBSVSLAPP022<br>See attached for full log<br><br>"
    $lines | ForEach-Object {
        if ($_.line -match '(error|failed)') {
            $body +=  "<span style=""color: red"">{0}</span><br>" -f  $_.Line
        } elseif ($_.line -match '(successful$)') {
            $body +=  "<span style=""color: black"">{0}</span><br>" -f  $_.Line
        } else {
            $body +=  "{0}<br>" -f  $_.Line
        }
    }
    $subject = 'FME Desktop (Hourly)'
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
    
    if ($FailedLines.Count -eq 0 -and -$SuccessLines.Count -gt 0) { $MyParameters.to = 'neil.brereton@southwark.gov.uk'  }
        
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

Write-Host "Test = $test"

if (-not $test) {
    #Publish-FMEWorkspace "E:\FME workspaces\PROD_ConfirmGroupProcessing.fmw"

    #Publish-FMEWorkspace "E:\FME workspaces\PROD_LLPG_SSA_AddressSearchUpdate.fmw"

    #Publish-FMEWorkspace "E:\FME workspaces\PROD_Exacom.fmw"

    #Publish-FMEWorkspace "E:\FME workspaces\PROD_UniformGroupProcessing.fmw" 

    Publish-FMEWorkspace "E:\FME workspaces\PROD_BroadbandViaFTP.fmw"
}

Write-Host "$dash"
Set-RunMessage -msg "Run Completed"

stop-transcript 

if ($test) {  Set-EmailAlert -logfile 'E:\Scripts\FMEDesktop2021\Logs\example.log' } 
else { Set-EmailAlert -logfile $logfile }   


