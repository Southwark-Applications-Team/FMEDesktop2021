PackageManagement update failed. 
Please run the following command in a new Windows PowerShell session and then restart the PowerShell extension: 


[system.net.webrequest]::defaultwebproxy = new-object system.net.webproxy('http://LBSSquidProxy.lbs.ad.southwark.gov.uk:8080')

[system.net.webrequest]::defaultwebproxy.credentials = [System.Net.CredentialCache]::DefaultNetworkCredentials

[system.net.webrequest]::defaultwebproxy.BypassProxyOnLocal = $true

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

Install-Module PackageManagement -Force -AllowClobber -MinimumVersion 1.4.6


Install-Module –Name PowerShellGet –Force -AllowClobber




Get-PSRepository


#  this worked  !! 
[Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12
Register-PSRepository -Default -Verbose
Set-PSRepository -Name "PSGallery" -InstallationPolicy Trusted 