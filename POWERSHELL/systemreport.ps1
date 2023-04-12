$adapters = Get-CimInstance Win32_NetworkAdapterConfiguration | Where-Object {$_.IPEnabled}

$report = foreach ($adapter in $adapters) {
    [PSCustomObject]@{
        Description  = $adapter.Description
        Index        = $adapter.Index
        IPAddress    = $adapter.IPAddress
        SubnetMask   = $adapter.IPSubnet
        DNSDomain    = $adapter.DNSDomain
        DNSServer    = $adapter.DNSServerSearchOrder
    }
}

$report | Format-Table -AutoSize
