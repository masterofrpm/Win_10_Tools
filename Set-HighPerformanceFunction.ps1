#Requires -RunAsAdministrator
function Set-HighPerformance
{
	  <#
		.Synopsis
			Set the power option of a host to High performance.
			 
		.Description 
			Set the power option of a host to High performance.             

		.Example
			PS C:\Windows\system32> Set-HighPerformance box1

			WARNING: *** Starting WinRM service on box1

			Existing Power Schemes (* Active)
			-----------------------------------
			Power Scheme GUID: 381b4222-f694-41f0-9685-ff5bb260df2e  (Balanced) *
			Power Scheme GUID: 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c  (High performance) 
			Power Scheme GUID: a1841308-3541-4fab-bc81-f71556f20b4a  (Power saver)
			Power Scheme GUID: db310065-829b-4671-9647-2261c00e86ef  (High Performance (ConfigMgr))
			Set High performance power option on box1

			Existing Power Schemes (* Active)
			-----------------------------------
			Power Scheme GUID: 381b4222-f694-41f0-9685-ff5bb260df2e  (Balanced)
			Power Scheme GUID: 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c  (High performance) *
			Power Scheme GUID: a1841308-3541-4fab-bc81-f71556f20b4a  (Power saver)
			Power Scheme GUID: db310065-829b-4671-9647-2261c00e86ef  (High Performance (ConfigMgr))
			WARNING: *** Stopping WinRM service on box1

		.Example 
			get-adcomputer -searchbase ‘OU=workstations,dc=contoso,dc=com’ -filter * -property * | select name  | Set-HighPerformance

			Set-HighPerformance for all the workstation in AD.

		.Notes
			  Author: Paolo Frigo - paolofrigo@gmail.com
	 #>
	 Param(
		[Parameter(Mandatory=$true,
		ValueFromPipeline=$true,
		ValueFromPipelineByPropertyName=$true,
		Position=0)]
		[Alias('name')]

		[string[]]$ComputerName
		)
	Process
	{
		$winRmNotRunning =(Get-Service -ComputerName $ComputerName winrm).Status -eq "Stopped"
		if ($winRmNotRunning -eq "True"){
			Get-Service -ComputerName $ComputerName winrm | Start-Service
			Write-Warning "*** Starting WinRM service on $ComputerName"
		}
		$RemoteSession = New-PSSession -ComputerName $ComputerName
		#$poweroption = invoke-command -ComputerName $ComputerName -ScriptBlock {powercfg -l}
		#$hp_guid  = $poweroption  | %{if($_.contains("High performance")) {$_.split()[3]}}
		invoke-command -Session $RemoteSession -ScriptBlock { powercfg /l }
		invoke-command -Session $RemoteSession -ScriptBlock {  powercfg /s "8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c"}
		Write-Output "Set High performance power option on $ComputerName"
		invoke-command  -Session $RemoteSession  -ScriptBlock { powercfg /l }

		if ($winRmNotRunning -eq "True"){
			Get-Service -ComputerName $ComputerName winrm | Stop-Service
			Write-Warning "*** Stopping WinRM service on $ComputerName"
		}
		Remove-PSSession -Session $RemoteSession
	}
}
