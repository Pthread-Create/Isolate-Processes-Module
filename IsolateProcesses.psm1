<#
.SYNOPSIS
This script changes the cores used by each process running to be different from the chosen process.

.DESCRIPTION
This script changes the cores used by each process running to be different from the chosen process.

.EXAMPLE
isolateProcesses -core 1111000011110000 -name factorio.exe

.PARAMETER core
binary number formatted, matching the cores that should be used by the process : 0000111100001111

.PARAMETER name
name = name of the processes to set affinity to, other process won't use the same cores
#>
function isolateProcesses {
	param(
		[Parameter(Mandatory)]
		[String]$core = '',
		[Parameter(Mandatory)]
		[String]$name = ''
	)

	# Check if ran as admin
	if (!(New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)){
		#elevate script and exit current non-elevated runtime
		Start-Process -FilePath 'powershell' -ArgumentList "-File $($MyInvocation.MyCommand.Source) -core $($core) -name $($name)" -Verb RunAs
		exit 0
	}else{
		if($name -match '^(.+)\.\w+$'){
			$name = $matches[1]
		}
		$processNum = (get-process | ? { $_.ProcessName -ilike "$name*" }).length
		if($processNum -eq 0){
			Write-Error "Process not found with $($name)"
		}
		$cpucore = (Get-CimInstance Win32_ComputerSystem).NumberOfLogicalProcessors
		$value = ""
		if($null -eq $($core)){
			for ($i=0; $i -le $cpucore/2-1; $i++){
				$value += "1"
			}
			for ($i=0; $i -le $cpucore/2-1; $i++){
				$value += "0"
			}
		}else{
			if($($core).Length -ne $cpucore){
				Write-Error "CPU Core value should be : $cpucore"
			}
			if($($core) -notmatch "^[01]+$"){
				Write-Error "CPU Core value should only be 0 and 1"
			}
		}
		$value = $($core)
		$pow = 1
		for ($i=0; $i -le $value.Length-2; $i++){
			$pow *= 2
		}
		$rpow = $pow
		$realvalue = 0
		foreach ($char in $value.ToCharArray()){
			if($char -eq "1"){
				$realvalue += $pow
			}
			$pow = $pow/2
		}
		Write-Host "Affinité de $($name) : $realvalue"

		$processes = get-process | ? { $_.ProcessName -ilike "$name*" } | % {
			try{
				$_.ProcessorAffinity = $realvalue 
			}catch{}
		}
		$realvalue2 = $rpow*2-$realvalue-1
		if($realvalue2 -eq 0){
			$realvalue2 = $realvalue
		}
		Write-Host "Affinité des processus : $realvalue2"
		$processes = get-process | ? { $_.ProcessName -inotlike "$name*" } | % {
			try{
				$_.ProcessorAffinity = $realvalue2 
			}catch{}
		}
		pause
	}
}
