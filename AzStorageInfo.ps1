
# Use .\AzStorageInfo.ps1 -ResourceGroup RG_NAME

param ($ResourceGroup)
$output = @()
$RG = $ResourceGroup

$VMs = @(Get-AzVM -ResourceGroupName $RG)
#$i = 0

#foreach ($VM in $VMs)
for ($i = 0; $i -lt $VMs.Length; $i++)
{

    "$i $($VMs[$i].name) start" | Out-Default
    $disk = @(Get-AzDisk -ResourceGroupName $RG -DiskName $VMs[$i].StorageProfile.OsDisk.Name)
    $output += @{"VMName" = $VMs[$i].name}
    $output[-1].add("OS", $VMs[$i].StorageProfile.OsDisk.OsType)
    $output[-1].add("DiskType", "OS")
    $output[-1].add("DiskName", $disk.Name)
    $output[-1].add("DiskSize", $disk.DiskSizeGB)
    $output[-1].add("DiskSKU", $disk.Sku)
    $output[-1].add("IOPSRead", $disk.DiskIOPSReadOnly)
    $output[-1].add("IOPSReadWrite", $disk.DiskIOPSReadWrite)
    $output[-1].add("MBPSRead", $disk.DiskMBpsReadOnly)
    $output[-1].add("MBPSReadWrite", $disk.DiskMBpsReadWrite)

    for ($j = 0; $j -lt $VMs[$i].StorageProfile.DataDisks.Count; $j++)
    { 
        $disk = Get-AzDisk -ResourceGroupName $RG -DiskName $VMs[$i].StorageProfile.DataDisks[$j].Name
        $output += @{"VMName" = $VMs[$i].name}
        $output[-1].add("OS", $VMs[$i].StorageProfile.OsDisk.OsType)
        $output[-1].add("DiskType", "Data")
        $output[-1].add("DiskName", $disk.Name)
        $output[-1].add("DiskSize", $disk.DiskSizeGB)
        $output[-1].add("IOPSRead", $disk.DiskIOPSReadOnly)
        $output[-1].add("IOPSReadWrite", $disk.DiskIOPSReadWrite)
        $output[-1].add("MBPSRead", $disk.DiskMBpsReadOnly)
        $output[-1].add("MBPSReadWrite", $disk.DiskMBpsReadWrite)
    }

    "$i $($VMs[$i].name) end" | Out-Default
    #$i++
}
"VM Name,OS,Disk type,Disk Name, Disk Size,IOPS,MBPS" | out-file -FilePath .\out.csv -Force
foreach ($item in $output)
{
    "$($item.VMName),$($item.OS),$($item.DiskType),$($item.DiskName),$($item.DiskSize),$($item.IOPSReadWrite),$($item.MBPSReadWrite)" | Out-File -FilePath .\out.csv -Append
}