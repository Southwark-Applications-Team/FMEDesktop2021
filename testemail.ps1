


gci E:\Scripts\FMEDesktop2021\Logs -Filter FMEDesktop2021*.txt  | sort LastWriteTime | select -last 1 | % {

    $log = $_.FullName 
    $mo = Select-String -Path $log  -Pattern '(Translation|^-|fme\.exe)'
    if ($mo) { $mo }  else { "not found" } 
    
}

$msg = ''
$mo | % {     
    $msg = $msg +  $_.Line  + '<br>'

}



$MyParameters = @{
    to = 'neil.brereton@southwark.gov.uk'
    #Cc = @()
    #Bcc = 'nbrereton1@gmail.com'     
    subject = 'test'
    bodyashtml = $true
    body = $msg
    from = 'gasdb@lbs-app-14'
    SmtpServer = 'smtp.southwark.gov.uk'
    #Attachments = $LogFile
} 

#host: smtp.southwark.gov.uk
#port: 25


#send-mailmessage -to $alerts -subject $subject -bodyashtml -body $body -from  $from -SmtpServer “mail.lbs.ad.southwark.gov.uk"  

send-mailmessage @MyParameters 