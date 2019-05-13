
 
$APP = Get-WebApplication  | select Path,applicationPool,PhysicalPath | Out-String

$APP = Get-WebApplication  | select Path,applicationPool,PhysicalPath | Out-

Send-MailMessage -to "mbaccouche@amaris.com" -Body $APP -SmtpServer "smtp.amatest.net" -Subject "O2FITERP01_PS Web Application" -From "poshtraining@o2f-it.com" -
