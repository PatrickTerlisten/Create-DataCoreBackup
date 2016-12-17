<#
    .SYNOPSIS
    No parameters needed. Just execute the script.

    .DESCRIPTION
    This script creates a backup of the DataCore SANsymphony-V configuration.
     
   .EXAMPLE
    Create-DataCoreBackup
    
   .NOTES
    Author: Patrick Terlisten, patrick@blazilla.de, Twitter @PTerlisten
    
    This script is provided “AS IS” with no warranty expressed or implied. Run at your own risk.

    This work is licensed under a Creative Commons Attribution NonCommercial ShareAlike 4.0
    International License (https://creativecommons.org/licenses/by-nc-sa/4.0/).
    
   .LINK
    http://www.vcloudnine.de
#>

# Register DataCore Cmdlets
Import-Module 'C:\Program Files\DataCore\SANsymphony\DataCore.Executive.Cmdlets.dll' -WarningAction silentlyContinue

# To create an encrypted password file, execute the following command
# Read-Host -AsSecureString | ConvertFrom-SecureString | Out-File securestring.txt
# Be sure to set $$ScriptFolder to the folder where the script is located.

# Variables
$BackupFolder = 'C:\SSVBACKUP'
$ScriptFolder = 'C:\Scripts'
$DcsLoginServer = HOSTNAME.EXE
$DcsUserName = 'Administrator'
$DcsPassword = Get-Content $ScriptFolder\securestring.txt | ConvertTo-SecureString
$DcsCredItem = New-Object -Typename System.Management.Automation.PSCredential -Argumentlist $DcsUserName, $DcsPassword
$Keep = 3

# Connect to Server Group using $server
Connect-DcsServer -Server $DcsLoginServer -Credential $DcsCredItem -Connection $DcsLoginServer

# Rotate backup files
ForEach ($Dcs in (Get-DcsServer)) {Invoke-Command -ComputerName $Dcs -ScriptBlock {

    # Keep last x files - see $Keep for number of files to keep
    # $Files is a variable which stores the filenames of all files that match *.cab
    $Files = Get-ChildItem -Path $using:BackupFolder -Recurse | Where-Object {-not $_.PsIsContainer} | where {$_.name -like '*.zip'}

    # Remove old files
    $Files | Sort-Object CreationTime | Select-Object -First ($Files.Count - $using:Keep)| Remove-Item
    }
}

# Set Backupfolder
ForEach ($Dcs in (Get-DcsServer)) {Set-DcsBackUpFolder -Server $Dcs -Folder $BackupFolder}

# Take Configbackup
Backup-DcsConfiguration

# Disconnect Server Group
Disconnect-DcsServer