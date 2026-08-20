# 🚀 Project Kizen Optimizer

![Version](https://img.shields.io/badge/version-1.3.1-brightgreen.svg)
![Platform](https://img.shields.io/badge/platform-Windows%2010%20%7C%2011-blue.svg)
![License](https://img.shields.io/badge/license-MIT-orange.svg)

**Project Kizen Optimizer** is an intelligent, hardware-aware batch tool designed to automate Windows deep maintenance, system repair, junk cleanup, and network optimization through a simple Command Line Interface (CLI).

---

## ✨ Features

* 🧠 **Smart Storage Optimization:** Automatically identifies C: drive type (SSD vs. HDD) via PowerShell. Applies safe TRIM (`defrag C: /L /H`) for SSDs to preserve write endurance, while performing traditional defragmentation (`defrag C: /O /H`) on HDDs.
* 🌐 **Web Browser Cache Cleanup:** Purges temporary cache files for Google Chrome, Microsoft Edge, and Brave browsers without affecting passwords or browsing history.
* 💥 **Crash & Error Log Clearing:** Removes Windows Error Reporting (WER) logs, Minidump crash files (`C:\Windows\Minidump`), and system event logs.
* 📦 **Delivery Optimization & Update Repair:** Resets Windows Update services (`wuauserv`, `bits`, `cryptsvc`), purges `SoftwareDistribution` caches, and clears Delivery Optimization (`dosvc`) data.
* 🖼️ **Icon Cache Rebuild:** Rebuilds corrupted Windows `IconCache.db` database files.
* ⏱️ **Dynamic Runtime Logging:** Logs execution durations to `.txt` files to provide real-time estimated runtimes for future maintenance cycles.
* 🛡️ **System Integrity Scans:** Automates DISM (`/RestoreHealth`, `/StartComponentCleanup`) and SFC (`/scannow`) repairs.
* 🔒 **Automated Restore Point:** Creates a `Kizen_Maintenance_RestorePoint` System Restore Point before executing any repair routines.

---

## 🛠️ Usage Instructions

1. Download `kizen-optimizer-v1.3.1.bat` from the **Releases** tab.
2. **Right-click** the file and select **"Run as administrator"** (Administrator privileges are required for system repair commands).
3. Select an operation mode from the interactive menu (1-4):
   - **[1] Quick Cleanup:** Temp files, Browser Cache, GPU/DirectX Cache, Event Logs, Telemetry, Network Reset.
   - **[2] Deep Repair:** Restore Point, WER/Dumps, Delivery Optimization, Update Reset, DISM, SFC, Storage Optimization.
   - **[3] Full Maintenance:** Complete execution of Quick Cleanup & Deep Repair + Icon Cache Rebuild.
   - **[4] Exit**

---

## 🗺️ Project Roadmap

### 🟢 Released Features
- [x] **v1.0.0 - v1.2.0:** Core maintenance routines, dynamic time logging, automated SSD/HDD detection, system restore point creation.
- [x] **v1.3.0:** Full English localization, browser cache cleanup, WER/Minidump clearing, Delivery Optimization reset, Icon Cache rebuilding.
- [x] **v1.3.1:** Stability improvements – fixed menu input reset, improved Windows Update reset (`net stop` instead of `taskkill`), PowerShell pipe escaping for reliable disk detection.

### 🟡 Planned Features (v1.4.0)
- [ ] **Gaming & Latency Booster:** Standby List RAM flushing, Ultimate Performance power plan, TCP latency optimizations.
- [ ] **Detailed Logging System:** Time-stamped `.log` / `.json` export support.
- [ ] **Custom Exclusions:** Option to skip specific modules (e.g., preserving browser caches).

### 🔵 Future Vision (v2.0.0)
- [ ] **PowerShell Engine Migration:** Rewriting backend to modular `.ps1` for advanced error handling.
- [ ] **GitHub Auto-Update Checker:** Automatic notifications for new repository releases.
- [ ] **Modern GUI:** WPF/WinForms desktop user interface.

---

## ⚠️ Disclaimer & License

This project is licensed under the **MIT License**. Use this script at your own discretion. It is recommended to keep System Protection enabled so the automatic Restore Point module can operate properly.
