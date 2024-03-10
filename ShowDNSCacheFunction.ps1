#ipconfig /displaydns | select-string 'Record Name' | foreach-object { $_.ToString().Split(' ')[-1]   } | Sort | Out-Gridview
#ipconfig /displaydns | select-string 'Record Name'  -Context 0,5 | foreach-object { 
    #$recordanswer = $_.ToString() | Select-String 'A (Host) Record' | foreach-object { $_.ToString().Split(' ')[-1] }
    #.Replace('  ','').Replace(' .','').Replace(':','').Split(' ') 
$tmparr = [ordered]@{}
$result = 0
$tmp1 = $null; $tmp2 = $null; $tmp3 = $null; $tmp4 = $null
function returndnscache{
    return ipconfig /displaydns
    }

returndnscache | ForEach-Object {
    If(-not $tmp1){
        $tmp = $_ | select-string 'Record N' | foreach-object { $_.ToString().Split(' ')[-1] } -ErrorAction SilentlyContinue -WarningAction SilentlyContinue -InformationAction SilentlyContinue; If($tmp){If([String] -eq $tmp.GetType()){ $tmp1 = $tmp }}
    } ElseIf(-not $tmp2) {
        $tmp = $_ | select-string 'Record T' | foreach-object { $_.ToString().Split(' ')[-1] }; If($tmp.GetType() -eq [String]){ $tmp2 = $tmp }
    } ElseIf(-not $tmp3) {
        $tmp = $_ | select-string 'Time T' | foreach-object { $_.ToString().Split(' ')[-1] }; If($tmp.GetType() -eq [String]){ $tmp3 = $tmp }
    } Else {
        $tmp = $_ | select-string ' Record \.' | foreach-object { $_.ToString().Split(' ')[-1] }; If($tmp){If($tmp.GetType() -eq [String]){ $tmp4 = $tmp }}
    }
    If($tmp1 -and $tmp4){
        $tmparr.$result = @($tmp1,$tmp2,$tmp3,$tmp4)
        $tmparr.$result
        $tmp1 = $null; $tmp2 = $null; $tmp3 = $null; $tmp4 = $null
        $result++
    }
}

$tmparr.GetEnumerator() | ForEach-Object{
    Write-Output "Value = $($_.value)"
}

function LiveDNSCache{
    $sites = [ordered]@{}
    $tmparr = [ordered]@{}
    $result = 0
    $tmp1 = $null; $tmp2 = $null; $tmp3 = $null; $tmp4 = $null

    returndnscache | ForEach-Object {
        If(-not $tmp1){
            $tmp = $_ | select-string 'Record N' | foreach-object { $_.ToString().Split(' ')[-1] } -ErrorAction SilentlyContinue -WarningAction SilentlyContinue -InformationAction SilentlyContinue; If($tmp){If([String] -eq $tmp.GetType()){ $tmp1 = $tmp }}
        } ElseIf(-not $tmp2) {
            $tmp = $_ | select-string 'Record T' | foreach-object { $_.ToString().Split(' ')[-1] } -ErrorAction SilentlyContinue -WarningAction SilentlyContinue -InformationAction SilentlyContinue; If($tmp.GetType() -eq [String]){ $tmp2 = $tmp }
        } ElseIf(-not $tmp3) {
            $tmp = $_ | select-string 'Time T' | foreach-object { $_.ToString().Split(' ')[-1] } -ErrorAction SilentlyContinue -WarningAction SilentlyContinue -InformationAction SilentlyContinue; If($tmp.GetType() -eq [String]){ $tmp3 = $tmp }
        } Else {
            $tmp = $_ | select-string ' Record \.' | foreach-object { $_.ToString().Split(' ')[-1] } -ErrorAction SilentlyContinue -WarningAction SilentlyContinue -InformationAction SilentlyContinue; If($tmp){If($tmp.GetType() -eq [String]){ $tmp4 = $tmp }}
        }
        If($tmp1 -and $tmp4){
            $tmparr.$result = @($tmp1,$tmp2,$tmp3,$tmp4)
            $tmparr.$result
            $tmp1 = $null; $tmp2 = $null; $tmp3 = $null; $tmp4 = $null
            $result++
        }
    }

    $tmparr.GetEnumerator() | ForEach-Object{
        Write-Output "Value = $($_.value)"
    }
}
$i = 0
do{
    Clear-Host
    LiveDNSCache
    $i++
    Start-Sleep -Seconds 1
}while($i -lt 15)