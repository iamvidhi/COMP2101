function display_cpu_os_ram_video {
    Write-Host "=== CPU ==="
    Get-CimInstance -ClassName Win32_Processor | Select-Object Name,NumberOfCores,NumberOfLogicalProcessors
    Write-Host ""

    Write-Host "=== OS ==="
    Get-CimInstance -ClassName Win32_OperatingSystem | Select-Object Caption,Version,OSArchitecture
    Write-Host ""

    Write-Host "=== RAM ==="
    Get-CimInstance -ClassName Win32_PhysicalMemory | Measure-Object -Property Capacity -Sum | Select-Object @{Name='TotalMemory';Expression={$_.Sum / 1GB}}
    Write-Host ""

    Write-Host "=== Video ==="
    Get-CimInstance -ClassName Win32_VideoController | Select-Object Name,AdapterCompatibility
    Write-Host ""
}

function display_disks {
    Write-Host "=== Disks ==="
    Get-CimInstance -ClassName Win32_LogicalDisk | Select-Object DeviceID,VolumeName,Size,FreeSpace
    Write-Host ""
}

function display_network {
    Write-Host "=== Network ==="
    Get-NetAdapter | Select-Object Name,InterfaceDescription,MacAddress,Status,LinkSpeed
    Write-Host ""
}

if ($args.Count -eq 0) {
    display_cpu_os_ram_video
    display_disks
    display_network
} else {
    foreach ($arg in $args) {
        switch ($arg) {
            "-System" {
                display_cpu_os_ram_video
            }
            "-Disks" {
                display_disks
            }
            "-Network" {
                display_network
            }
            default {
                Write-Host "Invalid option: $arg"
                Write-Host "Usage: systemreport.ps1 [-System] [-Disks] [-Network]"
                exit 1
            }
        }
    }
}

