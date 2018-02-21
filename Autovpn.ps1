function autovpn{

<#
.SYNOPSIS
Cette fonction se connecte automatiquement à un vpn.
This function automatically connects to a vpn.

.DESCRIPTION
Ce script PowerShell vous permet de vous connecter automatiquement à un vpn.
This PowerShell script allows you to automatically connect to a vpn.


.PARAMETER ordinateurs
Envirenement Windows server 2016 -Windows 10 - windows server 2012 R2
Powershell v 5.0


.EXAMPLE
./Autovpn.ps1
autovpn -NomConnexionVPN "vpn 1" -NomUtilisateurVPN "USER_NAME" -MotDePasseUtilisateurVPN "USER_PASSWORD"


.LINK
https://github.com/watashi-Amine
#>


            [CmdletBinding()]
            Param (
            [Parameter(Mandatory=$true)]
            [Alias("NomConnexionVPN")]
            [string]$vpnname,

            [Parameter(Mandatory=$true)]
            [Alias("NomUtilisateurVPN")]
            [string] $vpnusername,

            [Parameter(Mandatory=$true)]
            [Alias("MotDePasseUtilisateurVPN")]
            [string] $vpnpassword
            )


    while ($true)
        {

            $vpn = Get-VpnConnection -AllUserConnection | where {$_.Name -eq $vpnname}
            if ($vpn.ConnectionStatus -eq "Disconnected")
            {
                $cmd = $env:WINDIR + "\System32\rasdial.exe"
                $expression = "$cmd ""$vpnname"" $vpnusername $vpnpassword"
                Invoke-Expression -Command $expression 
            }
            start-sleep -seconds 30
        }

}
