
# Use .\AzStorageInfo.ps1 -ResourceGroup RG_NAME
# Leaves the output in out.csv in the current directory

param ($ResourceGroup)
$output = @()
$RG = $ResourceGroup

$VMs = @(Get-AzVM -ResourceGroupName $RG)


foreach ($VM in $VMs)
{

    Write-Verbose "$($VM.name) start" 
    $disk = Get-AzDisk -ResourceGroupName $RG -DiskName $VM.StorageProfile.OsDisk.Name
    $output += @{
                    "VMName"         = $VM.name
                    "OS"             = $VM.StorageProfile.OsDisk.OsType
                    "DiskType"       = "OS"
                    "DiskName"       = $disk.Name
                    "DiskSize"       = $disk.DiskSizeGB
                    "DiskSKU"        = $disk.Sku
                    "IOPSRead"       = $disk.DiskIOPSReadOnly
                    "IOPSReadWrite"  = $disk.DiskIOPSReadWrite
                    "MBPSRead"       = $disk.DiskMBpsReadOnly
                    "MBPSReadWrite"  = $disk.DiskMBpsReadWrite
                }

    foreach ($DataDisk in $VM.StorageProfile.DataDisks)
    { 
        $disk = Get-AzDisk -ResourceGroupName $RG -DiskName $DataDisk.Name
        $output += @{
                        "VMName"         = $VM.name
                        "OS"             = $VM.StorageProfile.OsDisk.OsType
                        "DiskType"       = "Data"
                        "DiskName"       = $disk.Name
                        "DiskSize"       = $disk.DiskSizeGB
                        "IOPSRead"       = $disk.DiskIOPSReadOnly
                        "IOPSReadWrite"  = $disk.DiskIOPSReadWrite
                        "MBPSRead"       = $disk.DiskMBpsReadOnly
                        "MBPSReadWrite"  = $disk.DiskMBpsReadWrite
                    }
    }

    Write-Verbose "$($VM.name) end"
}
"VM Name,OS,Disk type,Disk Name, Disk Size,IOPS,MBPS" | out-file -FilePath .\out.csv -Force
foreach ($item in $output)
{
    "$($item.VMName),$($item.OS),$($item.DiskType),$($item.DiskName),$($item.DiskSize),$($item.IOPSReadWrite),$($item.MBPSReadWrite)" | Out-File -FilePath .\out.csv -Append
}