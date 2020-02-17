#ipconfig /displaydns | select-string 'Record Name' | foreach-object { $_.ToString().Split(' ')[-1]   } | Sort | Out-Gridview
#ipconfig /displaydns | select-string 'Record Name'  -Context 0,5 | foreach-object { 
    #$recordanswer = $_.ToString() | Select-String 'A (Host) Record' | foreach-object { $_.ToString().Split(' ')[-1] }
    #.Replace('  ','').Replace(' .','').Replace(':','').Split(' ')  
[ArrayList]$sites = @()
$tmparr = "" | Select RecordName, RecordType, TTL, DataLength, Section, Answer
#$tmparr = "" | Select RecordName, Answer
$tmp1 = $null; $tmp2 = $null; $tmp3 = $null; $tmp4 = $null; $tmp5 = $null; $tmp6 = $null
function returndnscache{
    return ipconfig /displaydns
    }

returndnscache | ForEach-Object {
    If(-not $tmp1){
        $tmp = $_ | select-string 'Record N' | foreach-object { $_.ToString().Split(' ')[-1] }; If($tmp.GetType() -eq [String]){ $tmp1 = $tmp }
    } ElseIf(-not $tmp2) {
        $tmp = $_ | select-string 'Record T' | foreach-object { $_.ToString().Split(' ')[-1] }; If($tmp.GetType() -eq [String]){ $tmp2 = $tmp }
    } ElseIf(-not $tmp3) {
        $tmp = $_ | select-string 'Time T' | foreach-object { $_.ToString().Split(' ')[-1] }; If($tmp.GetType() -eq [String]){ $tmp3 = $tmp }
    } ElseIf(-not $tmp4) {
        $tmp = $_ | select-string 'Data L' | foreach-object { $_.ToString().Split(' ')[-1] }; If($tmp.GetType() -eq [String]){ $tmp4 = $tmp }
    } ElseIf(-not $tmp5) {
        $tmp = $_ | select-string 'Section ' | foreach-object { $_.ToString().Split(' ')[-1] }; If($tmp.GetType() -eq [String]){ $tmp5 = $tmp }
    } Else {
        $tmp = $_ | select-string '\) Record' | foreach-object { $_.ToString().Split(' ')[-1] }; If($tmp.GetType() -eq [String]){ $tmp6 = $tmp }
    }
    If($tmp1 -and $tmp6){
        $tmparr.RecordName = $tmp1; $tmparr.RecordType = $tmp2; $tmparr.TTL = $tmp3; $tmparr.DataLength = $tmp4
        $tmparr.Section = $tmp5; $tmparr.Answer = $tmp6
        $tmparr
        $sites += $tmparr
        $tmp1 = $null; $tmp2 = $null; $tmp3 = $null; $tmp4 = $null; $tmp5 = $null; $tmp6 = $null
    }
}
Write-Host 'Sites'
$sites