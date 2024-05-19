$wifiAdapter = 'WLAN' # Put the name of your Wi-Fi adapter here (check by running Get-NetIPConfiguration in PowerShell)
$sleepTime = 1
$restarted = $False
Out-File -FilePath C:\Users\Public\Documents\wifi_restart.log -InputObject "$(Get-Date) - Script started"
while ($true) {
    $gateway = (Get-NetIPConfiguration -InterfaceAlias $wifiAdapter).IPv4DefaultGateway.NextHop
    if ($gateway) {
        $sleepTime = 1
        $ping = Test-Connection -ComputerName $gateway -Count 3 -Quiet
        if (-not $ping) {
            if (((Get-NetIPConfiguration -InterfaceAlias WLAN).NetAdapter.Status) -eq 'Up') {
                Restart-NetAdapter -Name $wifiAdapter
                Out-File -FilePath C:\Users\Public\Documents\wifi_restart.log -Append -InputObject "$(Get-Date) - Restarted Wi-Fi adapter"
            }
        }
    } else {
        if ($restarted) {
            $restarted = $true
            Restart-NetAdapter -Name $wifiAdapter
            Out-File -FilePath C:\Users\Public\Documents\wifi_restart.log -Append -InputObject "$(Get-Date) - Restarted Wi-Fi adapter for once, will not restart again until gateway is found"
        }
        Start-Sleep -Seconds $sleepTime
        $sleepTime = [math]::Min($sleepTime * 2, 300)
        Out-File -FilePath C:\Users\Public\Documents\wifi_restart.log -Append -InputObject "$(Get-Date) - No gateway found, waiting for $sleepTime seconds"
    }
}