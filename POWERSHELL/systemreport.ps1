[CmdletBinding()]
param(
    [switch]$System,
    [switch]$Disks,
    [switch]$Network
)

# Define functions to get system information
function Get-ComputerSystem {
    Get-CimInstance -Class Win32_ComputerSystem
}

function Get-OperatingSystem {
    Get-CimInstance -Class Win32_OperatingSystem
}

function Get-Processor {
    Get-CimInstance -Class Win32_Processor
}

function Get-PhysicalMemory {
    Get-CimInstance -Class Win32_PhysicalMemory
}

function Get-DiskDrive {
    Get-CimInstance -Class Win32_DiskDrive
}

function Get-DiskPartition {
    Get-CimInstance -Class Win32_DiskPartition
}

function Get-LogicalDisk {
    Get-CimInstance -Class Win32_LogicalDisk
}

function Get-NetworkAdapterConfiguration {
    Get-CimInstance -Class Win32_NetworkAdapterConfiguration | Where-Object {$_.IPEnabled -eq 'True'}
}

function Get-VideoController {
    Get-CimInstance -Class Win32_VideoController
}

# Define function to format memory information as a table
function Format-Memory {
    $memories = Get-PhysicalMemory
    $table = @()
    $total = 0
    foreach ($memory in $memories) {
        $size = [math]::Round($memory.Capacity / 1GB, 2)
        $row = [pscustomobject]@{
            Vendor = $memory.Manufacturer
            Description = $memory.Caption
            Size = $size
            Bank = $memory.BankLabel
            Slot = $memory.DeviceLocator
        }
        $total += $size
        $table += $row
    }
    Write-Host "Installed RAM: $($total) GB`n"
    $table | Format-Table -AutoSize
}

# Define function to format disk information as a table
function Format-Disk {
    $drives = Get-DiskDrive
    $table = @()
    foreach ($drive in $drives) {
        $partitions = Get-DiskPartition -DiskDrive $drive
        foreach ($partition in $partitions) {
            $logicaldisks = Get-LogicalDisk -Partition $partition
            foreach ($logicaldisk in $logicaldisks) {
                $size = [math]::Round($logicaldisk.Size / 1GB, 2)
                $free = [math]::Round($logicaldisk.FreeSpace / 1GB, 2)
                $percentage = [math]::Round(($free / $size) * 100, 2)
                $row = [pscustomobject]@{
                    Vendor = $drive.Manufacturer
                    Model = $drive.Model
                    Size = $size
                    FreeSpace = $free
                    '% Free' = $percentage
                    Drive = $logicaldisk.DeviceID
                }
                $table += $row
            }
        }
    }
    $table | Format-Table -AutoSize
}

# Display system information based on parameters
if ($System) {
    Write-Host "System Hardware Description"
    Get-ComputerSystem

    Write-Host "`nOperating System Information"
    Get-OperatingSystem

    Write-Host "`nProcessor Information"
    Get-Processor

    Write-Host "`nMemory Information"
    Format-Memory

    Write-Host "`nVideo Controller Information"
    Get-VideoController
}

# Display disk information based on parameters
if ($Disks) {
    Write-Host "`nDisk Information"
    Format-Disk
}

#
