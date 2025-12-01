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
- CPU model, number of cores, threads, max clock speed  
- Total RAM with per-DIMM details (size, speed, vendor)  
- GPU model, VRAM, and driver version  

### 📈 Live System Metrics
- CPU usage (averaged over multiple samples)  
- Memory usage in GB and percentage  
- Disk usage for each fixed drive  
- Temperature in °C and °F from ACPI thermal zones  
- Top **N** processes sorted by CPU time  

### 🩺 Health Status Tags  
All major metrics include health indicators:

| Metric       | WARN Threshold | CRITICAL Threshold |
|--------------|----------------|--------------------|
| CPU Usage    | ≥ 70%          | ≥ 90%              |
| Memory Usage | ≥ 75%          | ≥ 90%              |
| Disk Usage   | ≥ 80%          | ≥ 90%              |
| Temperature  | ≥ 75°C         | ≥ 85°C             |

Status tags mimic the behavior of real monitoring systems (Zabbix, Datadog, Nagios, SCOM).

---

## 🧠 Why I Built This (Internship-Optimized Explanation)

This project was designed to demonstrate practical skills relevant to:

- Systems engineering  
- Infrastructure monitoring  
- Windows internals  
- Performance analysis  
- PowerShell automation  

It simulates a lightweight diagnostic tool similar to what support engineers, IT admins, or systems engineers build in real environments.

For an internship or early-career role, this project shows:

- Ability to query system APIs (CIM/WMI)  
- Comfort with scripting and tooling  
- Understanding of system health indicators  
- Ability to document and structure technical tools  
- Professional engineering practices such as modular code and thresholds  

---

## ▶️ Usage

### 1. Open PowerShell  
Start → type **PowerShell** → Run as Administrator (recommended)

### 2. Allow script execution (if needed)
Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned
### 3. Run the script
.\system_health.ps1

🔍 Implementation Details
System Inspection via CIM/WMI
  Win32_Processor — CPU model, cores, threads, clock
  Win32_ComputerSystem — total memory
  Win32_PhysicalMemory — DIMM slots
  Win32_VideoController — GPU information
  Win32_LogicalDisk — disk usage

Runtime Metrics
  Get-Counter for CPU performance counter
  Get-Process for top CPU-consuming processes

Temperature Monitoring
  ACPI WMI Class: MSAcpi_ThermalZoneTemperature
  Conversion:
    Raw tenths of Kelvin → °C
    °C → °F

Status Tagging Logic
  Get-StatusFromValue -Value $metric -Warn $warnThreshold -Crit $critThreshold

🛠 Skills Demonstrated

This project showcases:
  PowerShell scripting & automation
  Hardware inspection via CIM/WMI
  System monitoring and health evaluation
  Performance counter usage
  Process inspection & diagnostics
  Temperature measurement & sensor interpretation
  Threshold-based alerting logic
  Clean scripting practices (modular functions, error handling)
  Clear documentation / README writing

