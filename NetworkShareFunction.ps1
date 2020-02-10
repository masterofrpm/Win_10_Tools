Function MapNetworkDrive() {
    Param ( 
        [alias ("D")] [Parameter(Mandatory=$True,HelpMessage="`n`nUsage:`n[DriveLetter]:`n`nExample:`nG:`n`n`n")] [String] $DriveLetter,
        [alias ("P")] [Parameter(Mandatory=$True,HelpMessage="`n`nUsage:`n\\[ServerName]\[ShareDirectoryName]\[ShareFolder]``n`nExample:`n\\HomeNAS\Shares\Documents`n`n`n`n")] [String] $SharePath,
        [alias ("L")] [Parameter(Mandatory=$False)] [String] $LabelOfDrive,
		[alias ("U")] [Parameter(Mandatory=$False)] [String] $ShareUser,
		[alias ("Pass")] [Parameter(Mandatory=$False)] [String] $SharePass
    )
	$ShareReg =  $SharePath -replace '\\','#' 
	$Networkpath = "D\"
    $Networkpath = $Networkpath -replace "D",$DriveLetter
	If($ShareUser){If($SharePass){$ShareCred = ' /USER:"' + $ShareUser + '" "' + $SharePass + '"'}Else{$ShareCred = ' /User:"' + $ShareUser + '"'}}Else{$ShareCred = $Null}
    $RegPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\MountPoints2\"
	If (Net Use $DriveLetter 2> $null) {
		Write-Host "Drive $Networkpath`\ already exists. Failed to map $SharePath."
	} Else {
        Write-Host 
        Net Use $DriveLetter $SharePath /persistent:yes
		If (-not (Net Use $DriveLetter 2> $null)) {
			Write-Host "We tried to create a mapping to $SharePath but it still isn't there"
		}
	}
    If ($LabelOfDrive) {
        If ($CurrentVal = (Get-ItemProperty -Path "$RegPath$ShareReg" -Name _LabelFromReg 2> $null)) {
            If (-not ($CurrentVal._LabelFromReg -eq $LabelOfDrive)){
			    Write-Host "Updated the drive name for"$DriveLetter`\
                Set-ItemProperty -Path "$RegPath$ShareReg" -Name "_LabelFromReg" -Value "$LabelOfDrive" | Out-Null
            }
        } Else {
		    Write-Host "Created drive name for"$DriveLetter`\
            New-ItemProperty -Path "$RegPath$ShareReg" -Name "_LabelFromReg" -PropertyType String -Value "$LabelOfDrive" | Out-Null
        }
    }
}
# Be reminded that it is insecure to store passwords inside of scripts
# Examples
#MapNetworkDrive -D "G:" -P "\\ServerName\ShareFolder"
#MapNetworkDrive -D "G:" -P "\\ServerName\ShareFolder" -L "Label with Spaces"
#MapNetworkDrive -D "G:" -P "\\ServerName\ShareFolder" -L "Label with Spaces" -U "Username"
#MapNetworkDrive -D "G:" -P "\\ServerName\ShareFolder" -L "Label with Spaces" -U "Username" -Pass "Password"