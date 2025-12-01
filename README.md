# Windows System Health Monitor (PowerShell)

A comprehensive PowerShell script that performs a detailed system health check on Windows, including:

- Hardware specifications (CPU, RAM, GPU)
- CPU, memory, disk usage
- Temperature monitoring via ACPI (if supported)
- Top processes by CPU usage
- **Status tagging system: OK / WARN / CRITICAL**
- Clean, human-readable output suitable for diagnostics and troubleshooting

This project demonstrates scripting, monitoring, and system-level engineering practices aligned with modern Windows infrastructure tools.

---

## 🚀 Features

### 🔧 Hardware Specs
- CPU model, cores, threads, max clock speed  
- Total RAM + per-DIMM details (size, speed, vendor)  
- GPU name, VRAM, and driver version  

### 📈 Live System Metrics
- CPU usage (averaged over multiple samples)  
- Memory usage (GB + percentage)  
- Disk usage for all fixed drives  
- Temperature (°C/°F) from ACPI thermal zones  
- Top **N** processes by CPU time  

### 🩺 Health Status Tags
Each metric includes a clear health classification:

| Metric       | WARN Threshold | CRITICAL Threshold |
|--------------|----------------|--------------------|
| CPU Usage    | ≥ 70%          | ≥ 90%              |
| Memory Usage | ≥ 75%          | ≥ 90%              |
| Disk Usage   | ≥ 80%          | ≥ 90%              |
| Temperature  | ≥ 75°C         | ≥ 85°C             |

These thresholds mimic real monitoring tools (Nagios, Zabbix, Datadog, SCOM).

---

## 📋 Example Output (Truncated)


================= System Health Report =================
Timestamp         : 2025-02-02 14:12:55
Computer Name     : DESKTOP-12345

Hardware Specs     :
--------------------------------------------------------
CPU 1            : Intel(R) Core(TM) i7-9750H CPU @ 2.60GHz
  Cores/Threads    : 6 cores / 12 threads
  Max Clock        : 2.60 GHz

Total RAM          : 15.89 GB
  DIMM 1           : 8 GB @ 2667 MHz
  DIMM 2           : 8 GB @ 2667 MHz

GPU 1              : NVIDIA GeForce GTX 1660 Ti
  VRAM             : 6144 MB
  Driver Version   : 31.0.15.xxx

--------------------------------------------------------
CPU Usage (avg)   : 12.34 %  [OK]
--------------------------------------------------------
Memory (GB)       : Total=15.89 | Used=4.22 | Free=11.67
Memory (%)        : Used=26.5 % | Free=73.5 %  [OK]
--------------------------------------------------------
Disk Usage:
  C:  Total=476.94 GB | Used=350.00 GB | Free=126.94 GB (73 % used) [WARN]
--------------------------------------------------------
Temperature (ACPI\ThermalZone\TZ00_0) : 47.20 °C / 116.96 °F  [OK]
--------------------------------------------------------
Top 5 Processes by CPU Time:
  1. chrome           CPU(s)=1234.56  WS(MB)=512.34
  2. code             CPU(s)= 987.65  WS(MB)=750.21
========================================================
▶️ Usage
1. Open PowerShell
Start → type PowerShell → Run as Administrator (recommended)

2. Allow script execution (if needed)
powershell
Copy code
Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned
3. Run the script
powershell
Copy code
.\system_health.ps1
Show more processes:

powershell
Copy code
.\system_health.ps1 -TopProcesses 10
🔍 Implementation Details
System Inspection (CIM/WMI)
Win32_Processor

Win32_ComputerSystem

Win32_PhysicalMemory

Win32_VideoController

Win32_LogicalDisk

Runtime Metrics
Performance counters via Get-Counter

Process statistics via Get-Process

Temperature via ACPI
WMI class: MSAcpi_ThermalZoneTemperature

Temperature conversion:

Raw = tenths of Kelvin

°C = (Raw / 10) - 273.15

°F = (°C × 9/5) + 32

Health Status Tagging Logic
powershell
Copy code
Get-StatusFromValue -Value $metric -Warn $warnThreshold -Crit $critThreshold
🛠 Skills Demonstrated
PowerShell scripting & automation

CIM/WMI queries for hardware inspection

OS-level monitoring & diagnostics

Temperature and performance counter interpretation

Threshold-based health reporting (OK/WARN/CRITICAL)

Clean, modular scripting design

Error handling & system introspection

📌 Possible Enhancements
Export output to JSON, CSV, or a log file

Add network connectivity & latency test

Color-coded statuses in terminal

Add -OutputPath parameter for logging

Email or Slack alert integration

Schedule reports using Task Scheduler
