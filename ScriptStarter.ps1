<#
.NAME
    ScriptStarter
.SYNOPSIS
    Lists available scripts in current directory with ability to lunch them
#>

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

$Label1                          = New-Object system.Windows.Forms.Label
$Label1.text                     = "Script Starter Modded by Paul Meyers"
$Label1.AutoSize                 = $true
$Label1.width                    = 25
$Label1.height                   = 10
$Label1.location                 = New-Object System.Drawing.Point(18,15)
$Label1.Font                     = 'Microsoft Sans Serif,20,style=Bold'
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
$Label2.Font                     = 'Microsoft Sans Serif,10'

$Launch                           = New-Object system.Windows.Forms.Button
$Launch.BackColor                 = "#b8e986"
$Launch.text                      = "Launch Selected Script"
$Launch.width                     = 344
$Launch.height                    = 30
$Launch.Anchor                    = 'right,bottom,left'
$Launch.location                  = New-Object System.Drawing.Point(44,572)
$Launch.Font                      = 'Microsoft Sans Serif,10'

$Form.controls.AddRange(@($ScriptList,$Panel1,$Label2,$Launch))
$Panel1.controls.AddRange(@($Label1))

$Form.Add_Load({ Initialize })
$Launch.Add_Click({ LaunchScript })
#$ScriptList.Add_SelectedIndexChanged({ Selected-Script })



function Initialize { 
    
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


[void]$Form.ShowDialog()