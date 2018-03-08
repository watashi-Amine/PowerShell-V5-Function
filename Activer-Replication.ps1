function Activer-Replication {
<#
.SYNOPSIS
Activer la réplication avec les configurations spécifier dans un fichier CSV.

.DESCRIPTION
Ce script PowerShell permet d'automatiser l'activation de la réplication dans un envirenement hyper-v replica pour plusieur instances.


.PARAMETER ordinateurs
Envirenement Windows server 2016 hyper-V
Powershell v 5.0
La réplication doit étre activer sur le site principal et le site de secours


.EXAMPLE
./Activer-Replication.ps1
Activer-Replication -CSV c:\\csv\vms.csv -Sleeptime 300

.LINK
https://github.com/watashi-Amine
#>

        [CmdletBinding()]
        param(
        [Parameter(Mandatory=$true)]
        [Alias("CSV")]
        [String] $CVS_FILE,
        [Parameter(Mandatory=$true)]
        [Alias("Sleeptime")]
        [Int] $SleepInSeconds
        )
    BEGIN {
    Write-Verbose "Bloc d'initialisation."

        #Configuration de temp d'arrét
 
       <#
        Configuration Certificate Thumbs Print
        On trouve le Thumbs avec la commende PowerShell 
        PS C:\> Get-ChildItem -path cert:\LocalMachine\My
        #>
 $ctp ="3894515B6CF914D8D1818EA0E57F93CF137FD196" # c'est propre à mon cas !!!!!
       
    Write-Verbose "importation du fichier CSV."
    try{
 $csv =  Import-csv $CVS_FILE
        }
    catch{
  $csv =$false
          if ($csv) {
            "Le fichier  {0} est pas valide." -F $CVS_FILE
        }
        else {
            "Le fichier {0} n'est pas valide vérifier l'arborescence." -F $CVS_FILE
            break
        }

    }

          }

    PROCESS {
     Write-Verbose "Bloc d'execution du script."
   Write-Verbose "Debut du parcour du fichier CSV."
          $csv | ForEach{
   
 

        #s'il n'y a pas de snapshot
            if ($_.History -eq 0)
             {
               Write-Verbose "Pas de snapshot."
            #Pas de snapshot
            Enable-VMReplication -VMName $_.VM -ReplicaServerName $_.ReplicaHost `
            -ReplicaServerPort $_.Port -AuthenticationType $_.Authentication -CertificateThumbprint $ctp
                }
                else
                {
                 #s'il n'y a pas de fréquence de capture de snapshot VSS
                if ($_.VSSFreq -eq 0)
                    {
                     #sans capture VSS
                     Enable-VMReplication -VMName $_.VM -ReplicaServerName $_.ReplicaHost `
                    -ReplicaServerPort $_.Port -AuthenticationType $_.Authentication `
                     -RecoveryHistory $_.History -CertificateThumbprint $ctp
                    }
                 else
                {
            #avec capture VSS
            Enable-VMReplication -VMName $_.VM -ReplicaServerName $_.ReplicaHost `
            -ReplicaServerPort $_.Port -AuthenticationType $_.Authentication `
            -RecoveryHistory $_.History -VSSSnapshotFrequency $_.VSSFreq -CertificateThumbprint $ctp




                 }
            }
        try{ 
         Start-VMInitialReplication -VMName $_.VM
         }
        catch{
        
        }
  
    Write-Verbose "$_.VM :: La réplication est bien configuré"
    Write-Verbose "attente de  $SleepInSeconds secondes"
    Start-Sleep -s $SleepInSeconds
}



            }

    END {
        Write-Verbose "Fin des opérations."
        }



}
