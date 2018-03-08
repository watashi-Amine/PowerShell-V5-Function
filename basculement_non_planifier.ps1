

Function Test-Site-Primaire {

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

             If ( $Test -match "La connexion au serveur réplica indiqué avec les paramètres spécifiés a réussi") {

                Return $True

            }
            Else {

                Return $False 
            }

}

function Afficher-Notification-Windows {            
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


function envoyer_mail {



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
<#
$email = "kintikan@gmail.com" 
 
$mdp = "Kintikan*" 
 
$ssmtp = "smtp.gmail.com" 

$Objet ="Alerte depuis Hyper V replica" 

$text = "<h2> Test mail from PS </h2> </br> Hi there "  
#>
 
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

function autovpn{
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
         <#   $vpnname = "YOURVPNCONNECTIONNAME"
            $vpnusername = "YOURUSERNAME"
            $vpnpassword = "YOURPASSWORD"
         #>
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


Function Basculement_Urgent {
        [CmdletBinding()]
             Param (
             [Parameter(Mandatory=$false)]
            [Alias("no")]
            [string]$not
            )                <#

                Changer les parameters

                 #>
                
                $SitePrimaire = @{
                Nom = "prinhyperv.site2.local"
                CertificateThumbprint = "289DC300146C3BCE71F65064124E8B9F2E0E752A"

                }
                <#

                Changer les parameters
                -----------------------
                Start-Service WinRM
                winrm set winrm/config/client '@{TrustedHosts="replica.siteA.local"}'
                Stop-Service WinRM
                -----------------------

                #>

                  $ListClient = (
                "client-site2.site2.local"
              <#   "289DC300146C3BCE71F65064124E8B9F2E0E752A",
                 "client2.site2.local"
              #>
                )

                


             Write-Verbose "Test de la connectivitÃ© avec $($SitePrimaire.Nom)  " 

               $PrimSiteActif = Test-Site-Primaire -PrimSite $SitePrimaire.Nom -ctp $SitePrimaire.CertificateThumbprint
             while ($PrimSiteActif)
        {
               write-host "en cours ... $(Get-Date)"
               sleep 2
             $PrimSiteActif = Test-Site-Primaire -PrimSite $SitePrimaire.Nom -ctp $SitePrimaire.CertificateThumbprint
        }

        write-host "fait ..."


If ($PrimSiteActif -eq $false) { 


          Write-Verbose "Debut des opérations ... " 

    Afficher-Notification-Windows -Titre "Connexion site primaire Perdu" -Message "Attention la connexion au site principale à été perdu lune opération de basculement doit étre configurer"
         
         sleep 2

   Afficher-Notification-Windows -Titre "Connexion site primaire Perdu" -Message "Un mail avec les étape a suivre est envoyé à l'administrateur"

          Write-Verbose "Notification activé ... " 

    try{
    envoyer_mail -adresse_email "kintikan@gmail.com" -mot_de_passe "Kintikan*"   -serveur_smtp "smtp.gmail.com"   -Objet_mail "Alert depuis HyperV Replica <b>Connexion site primaire Perdu</b> ! https://replica.sitea.local:8080"  -text_mail   "Attention la connexion au site principale Ã  Ã©tÃ© perdu l'opÃ©ration de basculement va se declencher automatiquement dans 60 seconde"
    }
    catch{
    Write-Verbose "Échec d'envoi du courrier"
    }
      Write-Verbose " courrier envoyer"

       Write-Verbose " sleeping 60 seconde "
    sleep 60


    Write-Verbose " Attente de l'intervension de l'administrateur "


            Write-Verbose " sleeping 60 seconde "
    sleep 60

          
           <#
              ForEach($c in $ListClient) {
                <#  Debut de connexion  

     Write-Verbose "DÃ©but  de connexion avec le clients critique  "  $c
      try{
          Enter-PSSession   $c
             
      }
      catch{
      
        Write-Verbose     "la connexion au client critique n'est pas Ã©tablie."  $c
            break
        }
        Write-Verbose  "la connexion au client critique est  Ã©tablie."  $c

        try{
        autovpn -NomConnexionVPN "vpn 1" -NomUtilisateurVPN "administrateur" -MotDePasseUtilisateurVPN "Root.2018"
        }
        catch{
        Write-Verbose  "liaison vpn echoué" 
        }
                <#  Fin de connexion  #>

            }  
            }
           
     
Function basculement_non_planifier {
        [CmdletBinding()]
             Param (
          
            [Parameter(Mandatory=$false)]
            [Alias("Nom_VM_Basculer")]
            [string]$vm
            )

            
            $vm="FS-Site2"
       Write-Verbose " Début des operation de basculement "

            Get-Vm | where {($_.ReplicationMode -eq "Replica") -and  ($_.Name -eq $vm)} | ForEach-Object {


            Start-VMFailover -VMName $_.Name -Confirm:$false
            Start-VM $_.Name

            }

       Write-Verbose " Fin des operation de basculement "

            }



