#This script will automatically call the function.  Remove or comment out line 104 to simply load the function without executing it.

Function Switch-AudioPlaybackDevice {
    <#
    .SYNOPSIS
        Cycles through the audio playback devices that are specified within the script
        and sets the initial volume of the device.
    .REMARKS
        Author:      Bryan Hall
        Date:        January 28, 2015
        Disclaimer:  The script is provided "as-is", with no warranty. The script was
                     developed and and tested on Windows 8.1 only.

        Requires NirCmd.exe from NirSoft.  The executable must be located in C:\Windows.

        To set the default playback device via NirCmd:
            NirCmd.exe setdefaultsounddevice ["DeviceName"] {Role:0=Console (Default), 1=Multimedia, 2=Communication}

        To set system volume via NirCmd:
            NirCmd.exe setsysvolumeume [volume=0-65535] {component=master,wavein,waveout,synth,cd,microphone,phone,aux,line,headphones} {device index}

        To run the script silently (no screen) from Windows:
            NirCmd.exe exec hide PowerShell.exe -WindowStyle Minimized -NoLogo -NonInteractive -File "Fnc_ToggleAudioPlaybackDevice.ps1"
    .LINK
        http://www.nirsoft.net/utils/nircmd.html
    #>

    [CmdletBinding()]

    Param(
        #No parameters, yet.
    )

    BEGIN {
        #Set the names of the playback devices here.  They must exactly match the actual names.
        $DevOut1 = "SaviReceive"
        $DevOut2 = "SpeakerHeadPhones"

        #Timeout (in milliseconds) for system tray balloon notification.  NirCmd.exe continues to run until this timeout expires.
        $BalloonTimeout = 2000

        #Specify the playback device flag file and NirCmd.exe paths
        $ToggleFlagFile = "$env:TEMP\PSAudioToggle.flg"
        $NirCmdPath     = "C:\Windows\Nircmd.exe" #This is the default location for Nircmd.exe

        #Verify that NirCmd.exe exists in C:\Windows
        If (-not (Test-Path -Path $NirCmdPath)) {
            Write-Warning "NirCmd.exe could not be found.  Download the file from NirSoft.net and save it as $NirCmdPath."
            Exit
        }

        #Check for or set the flag file to determine the last logged device change.
        If (Test-Path -Path $ToggleFlagFile) {
            $ToggleStatus = Get-Content $ToggleFlagFile
            Write-Verbose "Current default playback device is `"$ToggleStatus`"."
        } Else {
            Write-Verbose "$ToggleFlagFile not found.  Creating it."
            Set-Content -Value $DevOut3 -Path $ToggleFlagFile
        }
    } #End BEGIN Section

    PROCESS {
        #print $ToggleStatus
        #Switch to the next device in order, based on the device last stored in the flag file.
        Switch ($ToggleStatus) {
            $DevOut1 {
                Write-Verbose "Setting default playback device to `"$DevOut2`"."
                & $NirCmdPath setdefaultsounddevice $DevOut2 1
                & $NirCmdPath setsysvolume 30000
                $Icon = "C:\Windows\System32\mmres.dll,6"
                $CurrentDev = $DevOut2
                }
            $DevOut2 {
                Write-Verbose "Setting default playback device to `"$DevOut1`"."
                & $NirCmdPath setdefaultsounddevice $DevOut1 0
                & $NirCmdPath setsysvolume 30000
                $Icon = "C:\Windows\system32\ddores.dll,5"
                $CurrentDev = $DevOut1
                }
            #$DevOut3 {
            #    Write-Verbose "Setting default playback device to `"$DevOut1`"."
            #    & $NirCmdPath setdefaultsounddevice $DevOut1 0
            #    & $NirCmdPath setsysvolume 55000
            #    $Icon = "C:\Windows\system32\ddores.dll,12"
            #    $CurrentDev = $DevOut1
            #    }
            Default {
                Write-Verbose "Setting default playback device to `"$DevOut1`"."
                & $NirCmdPath setdefaultsounddevice $DevOut1 0
                & $NirCmdPath setsysvolume 55000
                $Icon = "C:\Windows\system32\ddores.dll,12"
                $CurrentDev = $DevOut1
                }
        } #End Switch
    } #End PROCESS Section

    END {
        & $NirCmdPath trayballoon "Default Playback Device" $CurrentDev $Icon $BalloonTimeout
        Set-Content -Value $CurrentDev -Path $ToggleFlagFile
    } #End END Section
} #End Function

#Call the function when the script is executed.
Switch-AudioPlaybackDevice