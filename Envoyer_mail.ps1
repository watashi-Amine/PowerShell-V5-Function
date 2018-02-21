function envoyer_mail {
<#
.SYNOPSIS
envoyer un mail depuis un script PowerShell (tester sous windows 10-server 2016 -server 2012 R2).
send an email from a PowerShell script (test under windows 10-server 2016 -server 2012 R2).

.DESCRIPTION
Ce script PowerShell permet d'envoyer un email.
This PowerShell script is used to send an email.


.PARAMETER ordinateurs
Envirenement Windows server 2016 hyper-V
Powershell v 5.0
La réplication doit étre activer sur le site principal et le site de secours


.EXAMPLE
./Envoyer_mail.ps1
envoyer_mail -adresse_email YOUR_EMAIL@gmail.com  -mot_de_passe YOUR_PASSWORD -serveur_smtp smtp.gmail.com -Objet_mail TEST -text_mail YOUR_TEXT

.LINK
https://github.com/watashi-Amine

#>



[CmdletBinding()]
        Param (
            [Parameter(Mandatory=$true)]
            [Alias("adresse_email")]
            [string]$email,

            [Parameter(Mandatory=$true)]
            [Alias("mot_de_passe")]
            [string] $mdp,

            [Parameter(Mandatory=$true)]
            [Alias("serveur_smtp")]
            [string] $ssmtp,

            [Parameter(Mandatory=$true)]
            [Alias("Objet_mail")]
            [string] $Objet,

            [Parameter(Mandatory=$true)]
            [Alias("text_mail")]
            [string] $text
            )
 
$msg = new-object Net.Mail.MailMessage 
$smtp = new-object Net.Mail.SmtpClient($ssmtp) 
$smtp.EnableSsl = $true 
$msg.From = "$email"  
$msg.To.Add("$email") 
$msg.BodyEncoding = [system.Text.Encoding]::Unicode 
$msg.SubjectEncoding = [system.Text.Encoding]::Unicode 
$msg.IsBodyHTML = $true  
$msg.Subject = $Objet
$msg.Body = $text

$SMTP.Credentials = New-Object System.Net.NetworkCredential("$email", "$mdp"); 
$smtp.Send($msg)



}
