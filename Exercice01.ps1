
<#

Exercise 1 : AD Management

A

#>


# Fonction pour generer des string
function string_gen {
<#
.SYNOPSIS

.DESCRIPTION

.PARAMETER ordinateurs

.EXAMPLE

.LINK
https://github.com/watashi-Amine
#>

        [CmdletBinding()]
        param(
        [Parameter(Mandatory=$true)]
        [Alias("size")]
        [Int] $N,
        [Parameter(Mandatory=$true)]
        [Alias("has_a_Number_on_It")]
        [bool]$hasNumber
        )

    
    if($hasNumber -eq $false)
     {
   $result = -join ((65..90) + (97..122) | Get-Random -Count $N | % {[char]$_})
       return $result
     }
     elseif ($hasNumber -eq $true)
     {
   $result =  -join ((48..90) + (97..122) | Get-Random -Count $N | % {[char]$_})
    return $result
     }

   
    



}




<#

MAIN

#>


# generer un nom de fichier csv pour enegistrer la liste des utilisateurs
$DATE = Get-Date -Format "dd-MM-yy-hh-mm-ss"
$FileName = "D:\listusers-" +$DATE + ".csv"

# creation du fichier csv et creation de l entete
New-Item $FileName -ItemType File
Set-Content $FileName -Value 'FirstName,LastName,Description,LogonName,DisplayName,Password,PNExpires,enabled'

# generer les 600 utilisateurs selon les condition de l'exercice

for ($i=0;$i -lt 600 ; $i ++)
{
#Write-Host $i

#generer des nombres aleatoire
$FN = Get-Random -Maximum 5 -Minimum 2
$LN = Get-Random -Maximum 5 -Minimum 2
$DES = Get-Random -Maximum 5 -Minimum 2

<#

respet des condition de l exercice

#>

#FirstName pas de condition
$FirstName =  string_gen -N $FN  -hasNumber 0
#LastName pas de condition
$LastName = string_gen  -N $LN -hasNumber 0 
#Description pas de condition
$Description = string_gen -N $DES -hasNumber 0
#LogonName premiere lettre du first name concat last name concat @amaris.net
$LogonName = $FirstName[0] +$LastName +  "@amatest.net"
#DisplayName last name en majiscule concat first name
$DisplayName = $LastName.ToUpper() + $FirstName.ToLower()
#Password valeur par defaut
$Password  = "Amatest2018!"
#PNExpires valeur par defaut
$PNExpires = $true
#enabled valeur par defaut
$enabled = $true

#prepation de la ligne du csv
$value = $FirstName  + "," + $LastName  + "," + $Description  + "," +  $LogonName + "," + $DisplayName  + "," +  $Password  + "," + $PNExpires  + "," +   $enabled

Add-Content $FileName -Value $value


#ajout de l utilisateur
New-ADUser -Name $DisplayName -GivenNam $FirstName -Surname $LastName -SamAccountName $LogonName -DisplayName $DisplayName -PasswordNeverExpires $PNExpires -Enabled $enabled -Description $Description  -Path "OU=PSTraining,OU=Amatest,OU=Holding,DC=amatest,DC=net" -AccountPassword  (ConvertTo-SecureString -AsPlainText $Password  -Force) -passThru



}


<#
Exercise 1 : AD Management

B

#>

#Creer le groupe

New-ADGroup -Name "SG_Training_Group001" -SamAccountName SG_Training_Group001 -GroupCategory  Security -GroupScope Global -DisplayName "SG_Training_Group001" -Path "OU=PSTraining,OU=Amatest,OU=Holding,dc=amatest,dc=net" -Description "Groupe de test pour le  training"


#ajouter les utilisteurs au groupe

$csv = Import-Csv -Path D:\listusers-07-05-19-12-02-25.csv | foreach {

if ($_.FirstName -Match "E" )
{

Add-ADGroupMember -identity "SG_Training_Group001" -Members $_.LogonName

}

}


#supprimer le groupe
Remove-ADGroup -Identity "SG_Training_Group001" -Confirm:$false



<#
Exercise 1 : AD Management

C

#>

Get-ADUser  -Filter * -Properties * -SearchBase "OU=PSTraining,OU=Amatest,OU=Holding,dc=amatest,dc=net" |
select SamAccountName,description,whencreated |
Export-Csv -Path "D:\C.csv"

<#
Exercise 1 : AD Management

D

#>

$Users = Get-ADUser  -Filter * -Properties * -SearchBase "OU=PSTraining,OU=Amatest,OU=Holding,dc=amatest,dc=net" 


$NBUser = Get-ADUser  -Filter * -Properties * -SearchBase "OU=PSTraining,OU=Amatest,OU=Holding,dc=amatest,dc=net"  | measure

Write-Host $NBUser.Count


foreach ($user in $Users)
{

Remove-ADUser -Identity  $user.SamAccountName -Confirm:$true

}


