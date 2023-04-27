###############################################################################################################
#
# ABOUT THIS PROGRAM
#
#   SysMon64-Update-Splunk.ps1
#   https://github.com/Headbolt/SysMon64-Update-Splunk
#
#   This script was designed to Update the Version of Sysmon64.exe
#	Originally to deal with CVE-2022-44704
#
###############################################################################################################
#
# HISTORY
#
#   Version: 1.0 - 27/04/2023
#
#   27/04/2023 - V1.0 - Created by Headbolt
#							Cleaned up and better explained version of an old script
#
###############################################################################################################
#
#   CUSTOMISABLE VARIABLES
#
$FilePath='\\server\path\CVE-2022-44704' # Path to relevant files
$TargetVersion='14.13' # New Desired version
$BackupName="Sysmon64-Pre-$TargetVersion-Backup.exe" # name to give backup of current version
#
###############################################################################################################
#
#   BEGIN PROCESSING
#
###############################################################################################################
#
if ((Get-Item C:\Windows\Sysmon64.exe).VersionInfo.FileVersion -lt $TargetVersion) # Check if Version is lower than Target
{
	Start-Sleep -Seconds 30 # Designed to run at Startup, Pause to allow services to finish Starting
	Stop-Service -Name SplunkForwarder, Sysmon64 -force # Stop relevant Services
	Start-Sleep -Seconds 30 # Pause to ensure Services are cleanlly stopped
	Copy-Item -Path "C:\Windows\Sysmon64.exe" -Destination C:\Windows\$BackupName # Take a Backup of the current Version
	C:\Windows\Sysmon64.exe -u force # Uninstall Current Version
	Copy-Item $FilePath\Sysmon64.exe -Destination "C:\Windows\Temp" # Copy new Version to Temp Location
	Copy-Item $FilePath\Eula.txt -Destination "C:\Windows\Temp" # Copy Eula to Temp Location
	start-process -FilePath "C:\Windows\Temp\Sysmon64.exe" -ArgumentList '-i -accepteula' -Wait # Install New Version
	Start-Service -Name SplunkForwarder, Sysmon64 # Start Services
	Remove-Item "C:\Windows\Temp\Sysmon64.exe" # Delete Installer, now not needed
	Remove-Item "C:\Windows\Temp\Eula.txt" # Delete Eula, now not needed
}
