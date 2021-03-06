while (!($verifiedCreds)) {
    $username = Read-Host "Enter the autologin username"
    $password = Read-Host "Enter the autologin password"
    $computer = $env:COMPUTERNAME
    Add-Type -AssemblyName System.DirectoryServices.AccountManagement
    $obj = New-Object System.DirectoryServices.AccountManagement.PrincipalContext ('machine', $computer)
    $goodCreds = $obj.ValidateCredentials($username, $password)
    if ($goodCreds) {
        $username = $username -split "\\"
        if ($username.Count -eq 2) {
            Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" -Name "DefaultDomainName" -Value $username[0]
            Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" -Name "DefaultUserName" -Value $username[1]
            Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" -Name "DefaultPassword" -Value $password
        }
        else {
            Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" -Name "DefaultUserName" -Value $username
            Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" -Name "DefaultPassword" -Value $password
        }
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" -Name "AutoAdminLogon" -Value 1
        $verifiedCreds = $true
        ""
        Write-Host "Credentials validated successfully" -ForegroundColor Green
        ""
    }
    else {
        ""
        Write-Warning "Credentials failed to validate"
        ""
    }
}
