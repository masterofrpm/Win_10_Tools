Set-ExecutionPolicy Bypass -Scope Process -Force; `
  iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))

$MySite = 'https://GitHub.com/masterofrpm/Win_10_Tools'
$URL_Base = $MySite.Replace('GitHub','raw.GitHub')+'/master/'
$List_Url = $URL_Base + 'choco_shortlist.csv'

$installlist = Invoke-WebRequest $List_Url | ConvertFrom-Csv
Write-Host $installlist
Pause
foreach ($Pkg in $installlist) {
	choco install $Pkg.AppName --limit-output -y  --no-reduce-package-size
	}