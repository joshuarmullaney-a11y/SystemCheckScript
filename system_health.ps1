<#
    system_health.ps1
    Complete Windows System Health Monitor

    Adds:
    - Hardware specs
    - Temperature checks
    - Threshold-based OK/WARN/CRITICAL status tags (NEW)
#>


param(
    [int]$TopProcesses = 5
)

# ---------------------------------------------------------
# STATUS LOGIC — Thresholds
# ---------------------------------------------------------
$CpuWarnPct     = 70
$CpuCritPct     = 90
$MemWarnPct     = 75
$MemCritPct     = 90
$DiskWarnPct    = 80
$DiskCritPct    = 90
$TempWarnC      = 75
$TempCritC      = 85

function Get-StatusFromValue {
    param(
        [double]$Value,
        [double]$Warn,
        [double]$Crit
    )

    if ($Value -ge $Crit) { return "CRITICAL" }
    elseif ($Value -ge $Warn) { return "WARN" }
    else { return "OK" }
}

# ---------------------------------------------------------
# HEADER
# ---------------------------------------------------------
Write-Host "================= System Health Report ================="

$now = Get-Date
$computerName = $env:COMPUTERNAME

Write-Host ("Timestamp         : {0}" -f $now.ToString("yyyy-MM-dd HH:mm:ss"))
Write-Host ("Computer Name     : {0}" -f $computerName)
Write-Host ""

# ---------------------------------------------------------
# HARDWARE SPECS
# ---------------------------------------------------------
Write-Host ("Hardware Specs     :")
Write-Host ("-" * 56)

# CPU Info
try {
    $cpus = Get-CimInstance Win32_Processor
    $cpuIndex = 1
    foreach ($cpu in $cpus) {
        $name    = $cpu.Name.Trim()
        $cores   = $cpu.NumberOfCores
        $threads = $cpu.NumberOfLogicalProcessors
        $maxClockGHz = [Math]::Round($cpu.MaxClockSpeed / 1000, 2)

        Write-Host ("CPU {0}            : {1}" -f $cpuIndex, $name)
        Write-Host ("  Cores/Threads    : {0} cores / {1} threads" -f $cores, $threads)
        Write-Host ("  Max Clock        : {0} GHz" -f $maxClockGHz)
        $cpuIndex++
    }
}
catch {
    Write-Host "CPU Info           : Unable to retrieve CPU info." -ForegroundColor Yellow
}

# RAM Info
try {
    $cs = Get-CimInstance Win32_ComputerSystem
    $totalRamGB = [Math]::Round($cs.TotalPhysicalMemory / 1GB, 2)

    Write-Host ("Total RAM          : {0} GB" -f $totalRamGB)

    $dimms = Get-CimInstance Win32_PhysicalMemory
    $dimmIndex = 1
    foreach ($dimm in $dimms) {
        $sizeGB = [Math]::Round($dimm.Capacity / 1GB, 2)
        $speed  = $dimm.Speed
        $vendor = $dimm.Manufacturer
        $part   = $dimm.PartNumber.Trim()

        Write-Host ("  DIMM {0}         : {1} GB @ {2} MHz" -f $dimmIndex, $sizeGB, $speed)
        Write-Host ("    Vendor/Part    : {0} / {1}" -f $vendor, $part)
        $dimmIndex++
    }
}
catch {
    Write-Host "RAM Info           : Unable to retrieve RAM info." -ForegroundColor Yellow
}

# GPU Info
try {
    $gpus = Get-CimInstance Win32_VideoController
    $gpuIndex = 1
    foreach ($gpu in $gpus) {
        $name   = $gpu.Name
        $vramMB = if ($gpu.AdapterRAM) { [Math]::Round($gpu.AdapterRAM / 1MB, 0) } else { 0 }
        $driver = $gpu.DriverVersion

        Write-Host ("GPU {0}            : {1}" -f $gpuIndex, $name)
        if ($vramMB -gt 0) {
            Write-Host ("  VRAM             : {0} MB" -f $vramMB)
        }
        Write-Host ("  Driver Version   : {0}" -f $driver)
        $gpuIndex++
    }
}
catch {
    Write-Host "GPU Info           : Unable to retrieve GPU info." -ForegroundColor Yellow
}

Write-Host ("-" * 56)

# ---------------------------------------------------------
# CPU USAGE + STATUS
# ---------------------------------------------------------
try {
    $cpuSamples = Get-Counter '\Processor(_Total)\% Processor Time' -SampleInterval 1 -MaxSamples 3
    $cpuAvg = ($cpuSamples.CounterSamples.CookedValue | Measure-Object -Average).Average
    $cpuAvg = [Math]::Round($cpuAvg, 2)

    # STATUS TAG
    $cpuStatus = Get-StatusFromValue -Value $cpuAvg -Warn $CpuWarnPct -Crit $CpuCritPct

    Write-Host ("CPU Usage (avg)   : {0} %  [{1}]" -f $cpuAvg, $cpuStatus)
}
catch {
    Write-Host "CPU Usage (avg)   : Unable to read CPU counters." -ForegroundColor Yellow
}

Write-Host ("-" * 56)

# ---------------------------------------------------------
# MEMORY USAGE + STATUS
# ---------------------------------------------------------
$os = Get-CimInstance Win32_OperatingSystem

$totalMemKB = [float]$os.TotalVisibleMemorySize
$freeMemKB  = [float]$os.FreePhysicalMemory
$usedMemKB  = $totalMemKB - $freeMemKB

$totalMemGB = [Math]::Round($totalMemKB / 1MB, 2)
$usedMemGB  = [Math]::Round($usedMemKB / 1MB, 2)
$freeMemGB  = [Math]::Round($freeMemKB / 1MB, 2)

$usedMemPct = [Math]::Round(($usedMemKB / $totalMemKB) * 100, 2)
$freeMemPct = [Math]::Round(($freeMemKB / $totalMemKB) * 100, 2)

# STATUS TAG
$memStatus = Get-StatusFromValue -Value $usedMemPct -Warn $MemWarnPct -Crit $MemCritPct

Write-Host ("Memory (GB)       : Total={0} | Used={1} | Free={2}" -f $totalMemGB, $usedMemGB, $freeMemGB)
Write-Host ("Memory (%)        : Used={0} % | Free={1} %  [{2}]" -f $usedMemPct, $freeMemPct, $memStatus)

Write-Host ("-" * 56)

# ---------------------------------------------------------
# DISK USAGE + STATUS
# ---------------------------------------------------------
Write-Host "Disk Usage:"

$drives = Get-CimInstance Win32_LogicalDisk -Filter "DriveType=3"

foreach ($d in $drives) {
    $sizeGB = if ($d.Size)      { [Math]::Round($d.Size / 1GB, 2) } else { 0 }
    $freeGB = if ($d.FreeSpace) { [Math]::Round($d.FreeSpace / 1GB, 2) } else { 0 }
    $usedGB = $sizeGB - $freeGB

    $usedPct = if ($d.Size -ne 0) {
        [Math]::Round(($usedGB / $sizeGB) * 100, 0)
    } else {
        0
    }

    # STATUS TAG
    $diskStatus = Get-StatusFromValue -Value $usedPct -Warn $DiskWarnPct -Crit $DiskCritPct

    Write-Host ("  {0}  Total={1} GB | Used={2} GB | Free={3} GB ({4} % used) [{5}]" -f `
        $d.DeviceID, $sizeGB, $usedGB, $freeGB, $usedPct, $diskStatus)
}

Write-Host ("-" * 56)

# ---------------------------------------------------------
# TEMPERATURE + STATUS
# ---------------------------------------------------------
try {
    $thermalZones = Get-CimInstance -Namespace "root/wmi" -ClassName "MSAcpi_ThermalZoneTemperature" -ErrorAction Stop

    if ($null -eq $thermalZones -or $thermalZones.Count -eq 0) {
        Write-Host "Temperature Info   : No thermal zones reported by WMI."
    }
    else {
        foreach ($zone in $thermalZones) {
            $currentTempKelvin     = $zone.CurrentTemperature / 10
            $currentTempCelsius    = $currentTempKelvin - 273.15
            $currentTempFahrenheit = ($currentTempCelsius * 9/5) + 32

            $tempC = $currentTempCelsius.ToString("F2")
            $tempF = $currentTempFahrenheit.ToString("F2")

            # STATUS TAG
            $tempStatus = Get-StatusFromValue -Value $currentTempCelsius -Warn $TempWarnC -Crit $TempCritC

            Write-Host ("Temperature ({0}) : {1} $([char]176)C / {2} $([char]176)F  [{3}]" -f `
                $zone.InstanceName, $tempC, $tempF, $tempStatus)
        }
    }
}
catch {
    Write-Host "Temperature Info   : Could not retrieve temperature via WMI/CIM." -ForegroundColor Yellow
}

Write-Host ("-" * 56)

# ---------------------------------------------------------
# TOP PROCESSES
# ---------------------------------------------------------
Write-Host ("Top {0} Processes by CPU Time:" -f $TopProcesses)

try {
    $procs = Get-Process | Sort-Object CPU -Descending | Select-Object -First $TopProcesses

    $i = 1
    foreach ($p in $procs) {
        $cpuTimeSec = [Math]::Round($p.CPU, 2)
        $wsMB       = [Math]::Round($p.WorkingSet64 / 1MB, 2)
        Write-Host ("  {0}. {1,-15} CPU(s)={2,7}  WS(MB)={3,7}" -f $i, $p.ProcessName, $cpuTimeSec, $wsMB)
        $i++
    }
}
catch {
    Write-Host "Process Info       : Unable to retrieve process list." -ForegroundColor Yellow
}

Write-Host ("=" * 56)
