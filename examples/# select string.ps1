# select string

$ss = Select-String -Path E:\Scripts\FMEDesktop2021\Logs\example.log  -Pattern '(Translation|^-|fme\.exe|was)'

$ss[0]  |  Select-Object -Property * 