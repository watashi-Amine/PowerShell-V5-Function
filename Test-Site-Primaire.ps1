Function Test-Site-Primaire {

<#
.SYNOPSIS
---FR
Dans le cadre d'une replication avec hyper-v replica.Cette fonction peux étre trés utile.
---ANG
As part of a replication with hyper-v replica.This function can be very useful.

.DESCRIPTION
---FR
Ce script PowerShell teste la connectivité à un site de de replica ou principale et retourne la valeur Vrai ou Faux.
Ce script est codé pour une replication hyper-v replica avec certification. Vous pouvez le modifier pour une replication avec Kerberos.
Attention la fonction if est francophone changer si vous travaillez vous un env anglo-saxon !!!!!
---ANG
This PowerShell script tests connectivity to a replica or primary site and returns True or False.
This script is coded for hyper-v replica replication with certification. You can edit it for replication with Kerberos.
Beware the if function is French-speaking change if you work you an Anglo-Saxon env !!!!!!!!

.PARAMETER ordinateurs
Envirenement Windows server 2016 -Windows 10 - windows server 2012 R2
Powershell v 5.0


.EXAMPLE
./Test-Site-Primaire.ps1
Test-Site-Primaire -HyperVHost "SITE_PRINCIPAL@YOURDOMAIN.COM" -CertificateThumbprint "YOUR_CERT_THUMB_PRINT[//cmd_powershell//>Get-ChildItem -Path Cert:\LocalMachine\My\]"


.LINK
https://github.com/watashi-Amine
#>


        [CmdletBinding()]
        Param (
            [Parameter(Mandatory=$true)]
            [Alias("HyperVHost")]
            [string]$PrimSite,

            [Parameter(Mandatory=$true)]
            [Alias("CertificateThumbprint")]
            [string] $ctp
            )

        $Test = Test-VMReplicationConnection -AuthenticationType Certificate -CertificateThumbprint $ctp -ReplicaServerName $PrimSite -ReplicaServerPort 443 -ErrorAction SilentlyContinue

            If ( $Test -match "a réussi") {

                Return $True

            }
            Else {

                Return $False 
            }

}
