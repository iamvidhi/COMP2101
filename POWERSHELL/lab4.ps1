# Define functions to gather system information

function Get-SystemHardware {
    Get-CimInstance Win32_ComputerSystem | Select-Object Manufacturer, Model, TotalPhysicalMemory
}

function Get-OperatingSystem {
    Get-CimInstance Win32_OperatingSystem | Select-Object Caption, Version
}

function Get-Processor {
    Get-CimInstance Win32_Processor | Select-Object Name, NumberOfCores, MaxClockSpeed, 
    @{Name='L1 Cache Size'; Expression={$_.L1CacheSize}}, 
    @{Name='L2 Cache Size'; Expression={$_.L2CacheSize}}, 
    @{Name='L3 Cache Size'; Expression={$_.L3CacheSize}}
}

function Get-Memory {
    $memory = Get-CimInstance Win32_PhysicalMemory | Select-Object BankLabel, DeviceLocator, Manufacturer, PartNumber, SerialNumber, @{Name='Size (GB)'; Expression={$_.Capacity / 1GB -as [int]}}
    $totalMemory = ($memory | Measure-Object -Property 'Size (GB)' -Sum).Sum
    $memory | Format-Table BankLabel, DeviceLocator, Manufacturer, PartNumber, SerialNumber, 'Size (GB)'
    Write-Host "Total Memory: $totalMemory GB"
}

function Get-Disks {
    $diskdrives = Get-CimInstance Win32_DiskDrive
    $diskInfo = foreach ($disk in $diskdrives) {
        $partitions = $disk | Get-CimAssociatedInstance -ResultClassName Win32_DiskPartition
        foreach ($partition in $partitions) {
            $logicaldisks = $partition | Get-CimAssociatedInstance -ResultClassName Win32_LogicalDisk
            foreach ($logicaldisk in $logicaldisks) {
                [PSCustomObject]@{
                    'Manufacturer' = $disk.Manufacturer
                    'Model' = $disk.Model
                    'Size (GB)' = [math]::Round($disk.Size / 1GB, 2)
                    'Location' = $partition.DeviceID
                    'Drive Letter' = $logicaldisk.DeviceID
                    'Free Space (GB)' = [math]::Round($logicaldisk.FreeSpace / 1GB, 2)
                    '% Free' = [math]::Round(($logicaldisk.FreeSpace / $logicaldisk.Size) * 100, 2)
                }
            }
        }
    }
    $diskInfo | Format-Table Manufacturer, Model, 'Size (GB)', Location, 'Drive Letter', 'Free Space (GB)', '% Free'
}

function Get-Network {
    Get-NetAdapter | Select-Object Name, InterfaceDescription, Status, MacAddress, LinkSpeed
}

function Get-VideoController {
    Get-CimInstance Win32_VideoController | Select-Object AdapterCompatibility, Description, 
    @{Name='Resolution'; Expression={$_.VideoModeDescription -replace '^.*(\d{3,4}x\d{3,4}).*$', '$1'}}
}

# Output system information

Write-Host "System Hardware"
Get-SystemHardware

Write-Host "`nOperating System"
Get-OperatingSystem

Write-Host "`nProcessor"
Get-Processor

Write-

