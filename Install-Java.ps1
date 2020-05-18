# Installs the Java Runtime Environment (JRE) for Windows 64 Bit

# Elevate to administrator if necessary
If (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator))
{
  # Relaunch as an elevated process:
  Start-Process powershell.exe "-File",('"{0}"' -f $MyInvocation.MyCommand.Path) -Verb RunAs
  exit
}

# Default download URL - correct as of 2020-05-18
$DownloadUrl = "https://javadl.oracle.com/webapps/download/AutoDL?BundleId=242060_3d5a2bb8f8d4428bbe94aed7ec7ae784"

# Attempts to grab the latest download URL from the manual downloads page
$Site = Invoke-WebRequest -UseBasicParsing "https://www.java.com/en/download/manual.jsp"
foreach($Link in $Site.links)
{
    if($Link.title -match "Download Java software for Windows \(64-bit\)")
    {
        $FileName = $Link.innerHTML
        Write-Output "Found an up-to-date download link: $($Link.href)"
        $DownloadUrl = $Link.href
        break
    }
}


$FileName = "jre.exe"
$OutPath = "$($env:USERPROFILE)\Desktop\$($FileName)"

Write-Output "Downloading from: $($DownloadUrl)"
$ProgressPreference = 'SilentlyContinue'
Invoke-WebRequest $DownloadUrl -UseBasicParsing -OutFile $OutPath
Write-Host "Wrote file to $($OutPath)"

Write-Output "Installing the Java Runtime Environment. This can take a few minutes. Please stand by..."
Start-Process $OutPath '/s REBOOT=0 SPONSORS=0 AUTO_UPDATE=0' -wait

# Writes the output of the last command (E.g. an error message/status) to the output (stdout/console)
Write-Output $?

Write-Host "Installation complete."
Write-Output "Removing the downloaded file."
Remove-Item $OutPath

Write-Output "Configuring the JAVA_HOME and system Path variables..."
# The default Java installation path
$Java_Default_Installation_Dir = "$($env:SystemDrive)\Program Files\Java\"

# Gets the JRE version from the registry
$JRE_Reg_Version = Get-ChildItem "HKLM:\SOFTWARE\JavaSoft\Java Runtime Environment" | Select-Object -ExpandProperty pschildname -Last 1

# Checks for the install directory of that JRE version
$JRE_Dir = Join-Path -Path $Java_Default_Installation_Dir -ChildPath "jre$($JRE_Reg_Version)"

# If JRE path computed from the registry isn't valid, try to grab one that is there.
if (-not (Test-Path $JRE_Dir)){
    # Looks for the JRE version directory within the default installation path
    $JRE_Dir = Get-ChildItem -Path $Java_Default_Installation_Dir -Directory -Filter 'jre*' | Select-Object -ExpandProperty FullName
}

# If the JRE path is now valid, create the JAVA_HOME system variable add it to the system PATH
if (Test-Path $JRE_Dir){
  try {
    [Environment]::SetEnvironmentVariable("JAVA_HOME", $JRE_Dir, [System.EnvironmentVariableTarget]::Machine)               
    [Environment]::SetEnvironmentVariable("Path", [Environment]::GetEnvironmentVariable('Path', [EnvironmentVariableTarget]::Machine) + "%JAVA_HOME%\bin", [EnvironmentVariableTarget]::Machine)
  }
  catch {
    Write-Host "Error with the path variables"
  }
}

Read-Host "Installation complete. Enter any key to exit"
