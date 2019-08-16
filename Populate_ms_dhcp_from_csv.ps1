 <#
.SYNOPSIS
This script has the role of populating the reservation of a dhcp server

.DESCRIPTION
This script retrieves two csvs the routes to retrieve the IP addresses having a MAC dependency. and active on the networks

.PARAMETERS
Envirenement Windows server 2016
Powershell v 5.0
Py_ASA_MAC.csv
Py_SCAN.csv

.EXAMPLE
.
./dhcp.ps1

.LINK
https://github.com/watashi-Amine
#>


$Py_asa_mac = Import-Csv -Path "C:\dhcp_conf\csv\Py_asa_mac.csv" 
$Py_scan = Import-Csv -Path "C:\dhcp_conf\csv\Py_scan.csv" 
Start-Transcript  -path "C:\dhcp_conf\logs\dhcp_logs.log"
Write-host "DHCP START"

foreach ($Py_a in $Py_asa_mac) {

    foreach ($Py_s in $Py_scan) {
        if ($Py_s.IP -eq $Py_a.IP) {

            if ($Py_s.status -eq "UP") {
                $MAC = $Py_a.MAC.Replace(".", "")

                $Zone = switch ($Py_s.INTERFACE ) {
                    TESTINSIDE { "■■■■■■IP■■■" }
                    TESTSECURED	{ "■■■■■IP■■■■" }
                    TESTMIDDLE	{ "■■■■■■IP■■■" }

                }
                try {
                  $HName = [System.Net.Dns]::GetHostEntry($Py_s.IP).HostName
                  Write-host("HOSTNAME",$HName)
                  Write-host "netsh Dhcp Server ■■■■srv■ip■■■■ Scope "$Zone "Add reservedip "$Py_s.IP " " $MAC $HName " " $Py_s.IP 
                   $Aresult = netsh Dhcp Server "■■■■srv■ip■■■■■" Scope $Zone Add reservedip $Py_s.IP $MAC $HName $HName 
                   Write-host $result
                   if($Aresult -like "*is being used by another client*")
                   {
                    Write-host "FROM TRY"
                       netsh Dhcp server scope $Zone delete reservedip $Py_s.IP $MAC

                       netsh Dhcp Server "10.50.1.4" Scope $Zone Add reservedip $Py_s.IP $MAC $HName $HName
                   }
                }
                catch {

                    $Aresul =netsh Dhcp Server "10.50.1.4" Scope $Zone Add reservedip $Py_s.IP $MAC $Py_s.IP 
                     if($Aresult -like "*is being used by another client*")
                   {
                    Write-host "FROM CATCH"
                       netsh Dhcp server scope $Zone delete reservedip $Py_s.IP $MAC 

                       netsh Dhcp Server "10.50.1.4" Scope $Zone Add reservedip $Py_s.IP $MAC $Py_s.IP $Py_s.IP 
                   }

                   Write-host ("the IP"+$Py_s.IP ) -ForegroundColor Cyan 
                    Write-host (Get-Date -Format "yyyy-MM-dd HH:mm:ss") -ForegroundColor Cyan 
                    Write-host("Line : " + $error[0].InvocationInfo.ScriptLineNumber) -Fore Cyan 
                    Write-host ("Command : " + $error[0].InvocationInfo.MyCommand) -Fore Cyan
                    Write-host -ForegroundColor Cyan "ERROR : [$($_.GetType())] $_"
                }
            }
     
        }
    }




}
Stop-Transcript
