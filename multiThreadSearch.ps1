$computerStart = "c:\temp\testComputer.txt"
$searchRegistryString = "Microsoft .NET Framework 4.5.2"

$computer = Get-Content $computerStart

$maxRunCount = 2
$question = "1"


$ScriptBlock = {

    param($computers, $regKeyToSearch, $question)

    function pingFunc ($comp) {

     Try {
        $testingConnection = Test-Connection -ComputerName $comp -Count 1 -Quiet
        $trueReturnPing = 'True'
        $falseReturnPing = 'False'

        if ($testingConnection -eq 'True') {
            return $trueReturnPing
        }
            else {return $falseReturnPing}
        } Catch {Write-Host "$comp failed with $_.ExceptionMessage" -ForegroundColor Yellow}
}

    $pingResult = pingFunc -comp $computers
    


    if ($pingResult -eq 'True'){
        Write-Host "$computers ping status is good" -ForegroundColor Green

        if ($question -eq "1") {
            Get-RegValue -ComputerName $computers -Key SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall -Recurse -Verbose | Where-Object {$_.Data -like "$regKeyToSearch"} | FT -AutoSize
        }
        if ($question -eq "2") {

        }
        if ($question -eq "3") {

        }
    }
    if ($pingResult -eq 'False'){
        Write-Host "$computers ping status is bad" -ForegroundColor Red
    }
    
}


ForEach ($computers in $computer) {

    start-job -ScriptBlock $scriptBlock -ArgumentList $computers, $searchRegistryString, $question

    While($(Get-Job -State Running).Count -ge $maxRunCount) {

        Get-Job | Wait-Job -Any | Out-Null

        }

        Get-Job -State Completed | % {
        Receive-Job $_ -AutoRemoveJob -Wait
        }
    }


While ($(Get-Job -State Running).Count -gt 0) {
   Get-Job | Wait-Job -Any | Out-Null
}
Get-Job -State Completed | % {
   Receive-Job $_ -AutoRemoveJob -Wait
}
Remove-Job *
