# select string fail 
  $log='E:\Scripts\FMEDesktop2021\Logs\FMEDesktop2021.2.3_Hourly\20220414_1615.txt' 
  $lines = Select-String -Path $log -Pattern '(Translation|^-|fme\.exe|run start|run completed|process completed|error)'
  $SuccessLines = Select-String -Path $log  -Pattern '(SUCCESSFUL with)'
  $FailedLines = Select-String -Path $log -Pattern '(FAILED with)'

  Write-Host ("Success {0}" -f $SuccessLines.Count) -ForegroundColor Green  
  Write-Host ("Failed {0}" -f $FailedLines.Count) -ForegroundColor red  

