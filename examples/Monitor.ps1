

gci E:\Scripts\FMEDesktop2021\Logs -Filter FMEDesktop2021*.txt  | sort LastWriteTime | select -last 1 | % {

    $log = $_.FullName 
    $mo = Select-String -Path $log  -Pattern '(Translation|^-|fme\.exe)'
    if ($mo) { $mo }  else { "not found" } 

}

$mo | % { $_.Line }
