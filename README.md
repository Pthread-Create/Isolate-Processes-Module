# Isolate-Processes-Module
Isolate a processes from other processus on configurable core(s)
PowerShell module which require admin that can isolate a process or processes into a number of specific cpu cores and moves all other processes on other cpu cores

# Installation 
copy the psm1 file into %UserProfile%\Documents\WindowsPowerShell\Modules\IsolateProcesses

# Usage
isolateProcesses -core 1111000011110000 -name factorio.exe
Where
-code is a series of 0 and 1 which is each core of your cpu the left most are the highest numbered core
-name the process(es) that is isolated it can be a regex and match the start of the processes