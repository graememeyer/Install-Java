# Install-Java
# Elevate to administrator if necessary
If (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator))
{
  # Relaunch as an elevated process:
  Start-Process powershell.exe "-File",('"{0}"' -f $MyInvocation.MyCommand.Path) -Verb RunAs
  exit
}

$DownloadUrl = "https://javadl.oracle.com/webapps/download/AutoDL?BundleId=242060_3d5a2bb8f8d4428bbe94aed7ec7ae784"

$Site = Invoke-WebRequest -UseBasicParsing "https://www.java.com/en/download/manual.jsp"
foreach($Link in $Site.links)
{
    if($Link.title -match "Download Java software for Windows \(64-bit\)")
    {
        $FileName = $Link.innerHTML
        Write-Output "Correct: $($Link.href)"
        $DownloadUrl = $Link.href
        break
    }
}
$FileName = "jre.exe"
$OutPath = "$($env:USERPROFILE)\Desktop\$($FileName)"

Write-Host "Downloading from: $($DownloadUrl)"
$ProgressPreference = 'SilentlyContinue'
Invoke-WebRequest $DownloadUrl -UseBasicParsing -OutFile $OutPath
Write-Host "Wrote file to $($OutPath)"

Write-Host "Installing the Java Runtime Environment. This can take a few minutes. Please stand by..."
Start-Process $OutPath '/s REBOOT=0 SPONSORS=0 AUTO_UPDATE=0' -wait
Write-Output $?
Read-Host "Installation complete. Enter any key to exit"