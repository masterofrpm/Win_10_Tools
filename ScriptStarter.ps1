<#
.NAME
    ScriptStarter
.SYNOPSIS
    Lists available scripts at https://github.com/masterofrpm/Win_10_Tools/
#>

$MySite = 'https://GitHub.com/masterofrpm/Win_10_Tools'
$URL_Base = $MySite.Replace('GitHub','raw.GitHub')+'/master/'
$Version_Url = $URL_Base + 'Version/Win10_GUI_Menu.csv'
$List_Url = $URL_Base + 'ScriptStarter_AvailableScripts.csv'

# Relaunch the script with administrator privileges
Function RequireAdmin {
	If (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]"Administrator")) {
		Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`" $PSCommandArgs" -Verb RunAs
		Exit
	}
}

RequireAdmin

Add-Type -AssemblyName System.Windows.Forms
[System.Windows.Forms.Application]::EnableVisualStyles()

$Form                            = New-Object system.Windows.Forms.Form
$Form.ClientSize                 = '416,638'
$Form.text                       = "Script Starter Modded by Paul Meyers"
$Form.TopMost                    = $false

$ScriptList                      = New-Object system.Windows.Forms.ListBox
$ScriptList.text                 = "listBox"
$ScriptList.width                = 342
$ScriptList.height               = 403
$ScriptList.Anchor               = 'top,right,bottom,left'
$ScriptList.location             = New-Object System.Drawing.Point(44,146)
$ScriptList.Font                 = 'Microsoft Sans Serif,14'

$Label1                          = New-Object system.Windows.Forms.Label
$Label1.text                     = "Script Starter Modded by Paul Meyers"
$Label1.AutoSize                 = $true
$Label1.width                    = 25
$Label1.height                   = 10
$Label1.location                 = New-Object System.Drawing.Point(18,15)
$Label1.Font                     = 'Microsoft Sans Serif,14,style=Bold'
$Label1.ForeColor                = "#ffffff"

$Panel1                          = New-Object system.Windows.Forms.Panel
$Panel1.height                   = 55
$Panel1.width                    = 700
$Panel1.BackColor                = "#4d8fde"
$Panel1.location                 = New-Object System.Drawing.Point(0,0)

$Label2                          = New-Object system.Windows.Forms.Label
$Label2.text                     = "List of scripts in current directory:"
$Label2.AutoSize                 = $true
$Label2.width                    = 25
$Label2.height                   = 10
$Label2.location                 = New-Object System.Drawing.Point(44,98)
$Label2.Font                     = 'Microsoft Sans Serif,14,style=Bold'

$Launch                           = New-Object system.Windows.Forms.Button
$Launch.BackColor                 = "#b8e986"
$Launch.text                      = "Launch Selected Script"
$Launch.width                     = 344
$Launch.height                    = 30
$Launch.Anchor                    = 'right,bottom,left'
$Launch.location                  = New-Object System.Drawing.Point(44,572)
$Launch.Font                      = 'Microsoft Sans Serif,14'

$Form.controls.AddRange(@($ScriptList,$Panel1,$Label2,$Launch))
$Panel1.controls.AddRange(@($Label1))

$Form.Add_Load({ Initialize })
$Launch.Add_Click({ LaunchScript })
#$ScriptList.Add_SelectedIndexChanged({ Selected-Script })



function Initialize { 
    UpdateCheck
    #Path of current folder, filtering all ps1 scripts
    $path = $PSScriptRoot + "\*.ps1"
    
    #Get list of names of all ps1 scripts into a variable
    $scripts = Get-ChildItem $path  | select -exp Name
    
    #Assign the list of scripts as the data source of listbox
    $ScriptList.DataSource = $scripts 

}

function get-selectedScript {
        #Get The name of selected script
    $scriptName = $ScriptList.SelectedItem.ToString()
    
    #path of selected script
    $path = $PSScriptRoot + "\" + $scriptName
    
    return $path
}

function LaunchScript {
    
    $path = get-selectedScript
  
    #Execute selected script
    Invoke-Expression -Command $path
}

Function UpdateCheck {
	#Write-Host "Checking for updates..."
	If(InternetCheck) {
		#Write-Host "Comparing Versions..."
		$CSV_Ver = Invoke-WebRequest $List_Url | ConvertFrom-Csv
		Write-Host $CSV_Ver
		Pause
		$CSVLine,$RT = If($Release_Type -eq 'Stable'){ 0,'' } Else{ 1,'Testing/' }
		$WebScriptVer = $CSV_Ver[$CSVLine].Version + "." + $CSV_Ver[$CSVLine].MinorVersion
		#Write-Host $CSV_Ver $CSVLine $RT $Release_Type $WebScriptVer $Script_Version
		If($WebScriptVer -gt $Script_Version){ ScriptUpdateFun $RT } Else { Write-Host "Running newest version" }
	} Else {
		
	}
	PAUSE
}

Function ScriptUpdateFun([String]$RT) {
	$Script_Url = $URL_Base + $RT + $($MyInvocation.MyCommand.Name)
	$ScrpFilePath = $FileBase + $($MyInvocation.MyCommand.Name)
	$FullVer = "$WebScriptVer.$WebScriptMinorVer"
	$UpArg = ''

	If($Accept_ToS -ne 1){ $UpArg += '-atos ' }
	If($InternetCheck -eq 1){ $UpArg += '-sic ' }
	If($CreateRestorePoint -eq 1){ $UpArg += '-crp ' }
	If($Restart -eq 0){ $UpArg += '-dnr' }
	$UpArg += If($RunScr){ "-run $TempSetting " } Else{ "-load $TempSetting " }

	Clear-Host
	MenuLine -L
	MenuBlankLine -L
	DisplayOutLML (''.PadRight(18)+'Update Found!') -C 13 -L
	MenuBlankLine -L
	DisplayOut '|',' Updating from version ',"$Script_Version".PadRight(30),'|' -C 14,15,11,14 -L
	MenuBlankLine -L
	DisplayOut '|',' Downloading version ',"$FullVer".PadRight(31),'|' -C 14,15,11,14 -L
	DisplayOutLML 'Will run after download is complete.' -C 15 -L
	MenuBlankLine -L
	MenuLine -L
	PAUSE
	(New-Object System.Net.WebClient).DownloadFile($Script_Url, $ScrpFilePath)
	Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$ScrpFilePath`" $UpArg" -Verb RunAs
	Exit
}

Function InternetCheck{ If($InternetCheck -eq 1 -or (Test-Connection www.GitHub.com -Count 1 -Quiet)){ Return $True } Return $False }

[void]$Form.ShowDialog()