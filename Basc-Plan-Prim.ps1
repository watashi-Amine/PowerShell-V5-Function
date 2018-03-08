function Basc-Plan-Prim{
  <#
.SYNOPSIS
Réaliser un basculement planifier pour toutes les vms ou la réplication est déja activée.

.DESCRIPTION
Ce script PowerShell permet d'automatiser le basculement plannifier des vms ou la réplication est déja activée.


.PARAMETER ordinateurs
Envirenement Windows server 2016 hyper-V
Powershell v 5.0
La réplication doit étre activer sur le site principal et le site de secours


.EXAMPLE
./Basc-Plan-Prim-all.ps1
Basc-Plan-Prim-all -Verbose (Verbose pour suivre l'évolution du basculement)

.LINK
https://github.com/watashi-Amine
#>
        [CmdletBinding()]
        param(
        [Parameter(Mandatory=$true)]
        [Alias("replicaSite")]
        [String] $replica,

        [Parameter(Mandatory=$true)]
        [Alias("Nom_Vm")]
        [String] $VMName
        )


           BEGIN {
		   	  <# 
	  
								********************************************
								--------------------------------------------
								Début des opérations dans le site primaire
								--------------------------------------------
								********************************************
	  
	  #>
		                  Write-Verbose "Début des opérations de la fonction Basc-Plan-Prim"   
		   }
           Process{
	  <# 
	  
								********************************************
								--------------------------------------------
											Début Basc-Plan-Prim
								--------------------------------------------
								********************************************
	  
	  #>

      Write-Verbose "Début des opérations dans le site primaire"     
      Get-VM | Where {($_.ReplicationMode -eq "Primary") -and ($_.Name -eq $VMName)}| ForEach-Object {
      Stop-VM $_.Name -Force
      Write-Verbose "en cours ..."   
      sleep 2
      Start-VMFailover -VMName $_.Name -Prepare -Confirm:$false
      sleep 2
      Write-Verbose "en cours ..." 
                 }
      Write-Verbose "Fin des opérations dans le site primaire"  

	  <# 
	  
								********************************************
								--------------------------------------------
								Début des opérations dans le site secondaire
								--------------------------------------------
								********************************************
	  
	  #>
	  
	  
      Write-Verbose "Début des opérations dans le site secondaire"   
	  
            $sec = ConvertTo-SecureString "Root.2018" -AsPlainText -Force
            $cre = New-Object pscredential("Administrateur",$sec)

                Invoke-Command -ComputerName "replica.sitea.local" -ScriptBlock {   param($Vname)
				$a =Get-ChildItem -Path Cert:\LocalMachine\My\ | where {$_.subject -eq "CN=replica.siteA.local"} |select Thumbprint
         
                Get-VM | Where {($_.ReplicationMode -eq "Replica")  -and ($_.Name -eq $Vname)} | ForEach-Object {
				    Write-Verbose "en cours ..."   
					sleep 2
                Start-VMFailover -VMName $_.Name -Confirm:$false
				    Write-Verbose "en cours ..." 
					sleep 2
				Set-VMReplication -reverse -VMName $_.Name -CertificateThumbprint $a.Thumbprint
				    Write-Verbose "en cours ..." 
					sleep 2
  

                Start-VM $_.Name
            }





} -Credential $cre -ArgumentList $VMName



           Write-Verbose "Fin des opérations dans le site secondaire"       
           }


           End{
           
                 Write-Verbose "Fin des opérations de la fonction Basc-Plan-Prim" 
           
           }




	  <# 
	  
								********************************************
								--------------------------------------------
											Fin Basc-Plan-Prim
								--------------------------------------------
								********************************************
	  
	  #>









}

