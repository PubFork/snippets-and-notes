# set timezone to us est
Set-TimeZone -Name "Eastern Standard Time"

# create dirs
New-Item -ItemType directory -Path C:\App

# set app env
[Environment]::SetEnvironmentVariable("APP_HOST", "hostname.domain", "Machine")

# download and install notepad++
(New-Object System.Net.WebClient).DownloadFile("https://notepad-plus-plus.org/repository/7.x/7.6.3/npp.7.6.3.Installer.x64.exe", "C:\Windows\temp\npp.exe")
start-process -FilePath "C:\Windows\temp\npp.exe" -ArgumentList '/S' -Verb runas -Wait
