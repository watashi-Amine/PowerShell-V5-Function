function MoveEnabledUserXOuToYOu {
<#
.SYNOPSIS
cette fonction permet de deplacer tout les utilisateur actif sous une OU vers une autre OU.

.DESCRIPTION
Ce script PowerShell permet cette fonction permet de deplacer tout les utilisateur actif sous une OU vers une autre OU.


.PARAMETER ordinateurs
Microsoft Active Directory
Powershell v 5.0



.EXAMPLE
./DeplacerTousUserDeXversY.ps1
DeplacerUserXversY -src “OU=NomsousOU,OU=NomOU,DC=domain,DC=local” -dst "OU=NomsousOU2,OU=NomOU2,DC=domain,DC=local"


.LINK
https://github.com/watashi-Amine
#>

        [CmdletBinding()]
        param(
        [Parameter(Mandatory=$true)]
        [Alias("Source")]
        [String] $src,
        [Parameter(Mandatory=$true)]
        [Alias("Destination")]
        [String] $dst
        )


Get-ADUser –SearchBase $src -Filter {Enabled -eq $true } |
 ForEach-Object {
Move-ADObject -Identity  $_.distinguishedName -TargetPath $dst
}
}
