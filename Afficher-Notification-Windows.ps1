function Afficher-Notification-Windows {     
<#
.SYNOPSIS
Tout est dans le nom :: cette fonction affiche une notilication windows (tester sous windows 10-server 2016 -server 2012 R2).
Everything is in the name :: this function displays a windows notification (test under windows 10-server 2016 -server 2012 R2).

.DESCRIPTION
Ce script PowerShell l'affichage d'une notification windows.
This PowerShell script will display a windows notification.


.PARAMETER ordinateurs
Envirenement Windows server 2016 -Windows 10 - windows server 2012 R2
Powershell v 5.0



.EXAMPLE
./Afficher-Notification-Windows.ps1
Afficher-Notification-Windows -Titre "une notification" -Message "une notification"

.LINK
https://github.com/watashi-Amine
#>
        [cmdletbinding()]            
        param(            
             [parameter(Mandatory=$true)]            
             [string]$Titre, 

             [ValidateSet("Info","Warning","Error")]             
             [string]$TypeMessage = "Warning",            
             [parameter(Mandatory=$true)]            
             [string]$Message,  

             [string]$Duration=10000            
        ) 
        [system.Reflection.Assembly]::LoadWithPartialName('System.Windows.Forms') | Out-Null            
        $balloon = New-Object System.Windows.Forms.NotifyIcon            
        $path = Get-Process -id $pid | Select-Object -ExpandProperty Path            
        $icon = [System.Drawing.Icon]::ExtractAssociatedIcon($path)            
        $balloon.Icon = $icon            
        $balloon.BalloonTipIcon = $TypeMessage            
        $balloon.BalloonTipText = $Message            
        $balloon.BalloonTipTitle = $Titre            
        $balloon.Visible = $true            
        $balloon.ShowBalloonTip($Duration)            

}   
