<#
.NAME
    ScriptStarter
.SYNOPSIS
    Lists available scripts at https://github.com/masterofrpm/Win_10_Tools/
#>

$MySite = 'https://GitHub.com/masterofrpm/Win_10_Tools'
$URL_Base = $MySite.Replace('GitHub','raw.GitHub')+'/master/'
$Path_Base = $PSScriptRoot + '\'
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
$ScriptList.Font                 = 'Microsoft Sans Serif,12'

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

function Initialize {
    #Assign the list of scripts as the data source of listbox
    $ScriptList.DataSource = $scripts 
	}
function get-selectedScript {
    #Get The name of selected script
    $SelectedScript = $ScriptList.SelectedItem.ToString()
	Write-Host $SelectedScript
    #Get list of names of all ps1 scripts into a variable
	If(InternetCheck) {
		$CSV_Selected = Invoke-WebRequest $List_Url | ConvertFrom-Csv | where-object {$_.ScriptStarterLabel -eq $SelectedScript};
		} Else {
			Write-Host "Lost internet connectivity"
			Pause
			Exit
		}
	$ScriptToInit = $CSV_Selected.NameWithExtension
    $Script_Url = $URL_Base + $ScriptToInit
	$Script_Path = $Path_Base + $ScriptToInit
    return $Script_Url, $Script_Path, $CSV_Selected.LaunchType
}

function LaunchScript {
    $Script_Url, $Script_Path, $Launch_Type = get-selectedScript
	Write-Host $Script_Url, $Script_Path
	#Execute selected script
	(New-Object System.Net.WebClient).DownloadFile($Script_Url, $Script_Path)
	If($Launch_Type -eq "execute"){
		Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$Script_Path`" $UpArg" -Verb RunAs
	} ElseIf ($Launch_Type -eq "text"){
		Start-Process notepad.exe `"$Script_Path`"
	}
}

Function InternetCheck{ If($InternetCheck -eq 1 -or (Test-Connection www.GitHub.com -Count 1 -Quiet)){ Return $True } Return $False }
#Get list of names of all ps1 scripts into a variable
If(InternetCheck) { 
	Write-Host $List_Url; 
	$CSV_Ver = Invoke-WebRequest $List_Url | ConvertFrom-Csv; 
	$scripts = @(
		$CSV_Ver.ScriptStarterLabel
		) 
	} Else { 
		$scripts = @(
			'Internet Test Failed!',
			'Please check your internet connection.',
			'Be sure you can access github.com'
		) 
	}

[void]$Form.ShowDialog()