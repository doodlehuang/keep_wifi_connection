$wifiAdapter = 'WLAN' # Put the name of your Wi-Fi adapter here (check by running Get-NetIPConfiguration in PowerShell)
if (-not $wifiAdapter) {
    exit
}
while ($true) {
    $gateway = (Get-NetIPConfiguration -InterfaceAlias $wifiAdapter).IPv4DefaultGateway.NextHop
    if ($gateway) {
        ($ping = Test-Connection -ComputerName $gateway -Count 3 -Quiet)
        if (-not $ping) {
            if (((Get-NetIPConfiguration -InterfaceAlias WLAN).NetAdapter.Status) -eq 'Up') {
                Restart-NetAdapter -Name $wifiAdapter
            }
        }
    }
}