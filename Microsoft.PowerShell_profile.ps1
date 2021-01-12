# UNIX Command aliases
Set-Alias which Get-Command
Set-Alias grep Select-String
Set-Alias ll Get-ChildItem
Set-Alias alias Set-Alias

Set-Variable -Name "EDITOR" -Value "code"

# Convenience stuff
# This way you only have to type '..' instead of 'cd ..' to go up
Function GoUp {
    cd ..
}
Set-Alias .. GoUp

# Oh-My-Posh stuff
$ohMyPoshPath = "C:\Users\bonda\scoop\apps\oh-my-posh\current\oh-my-posh.exe"
$ohMyPoshTheme = "zash"

[ScriptBlock]$Prompt = {
    $lastCommandSuccess = $?
    $realLASTEXITCODE = $global:LASTEXITCODE
    $errorCode = 0
    if ($lastCommandSuccess -eq $false) {
        #native app exit code
        if ($realLASTEXITCODE -ne 0) {
            $errorCode = $realLASTEXITCODE
        }
        else {
            $errorCode = 1
        }
    }
    $startInfo = New-Object System.Diagnostics.ProcessStartInfo
    $startInfo.FileName = $ohMyPoshPath
    $cleanPWD = $PWD.ProviderPath.TrimEnd("\")
    $startInfo.Arguments = "-config=""C:\Users\bonda\scoop\apps\oh-my-posh\current\themes\$ohMyPoshTheme.json"" -error=$errorCode -pwd=""$cleanPWD"""
    $startInfo.Environment["TERM"] = "xterm-256color"
    $startInfo.CreateNoWindow = $true
    $startInfo.StandardOutputEncoding = [System.Text.Encoding]::UTF8
    $startInfo.RedirectStandardOutput = $true
    $startInfo.UseShellExecute = $false
    if ($PWD.Provider.Name -eq 'FileSystem') {
      $startInfo.WorkingDirectory = $PWD.ProviderPath
    }
    $process = New-Object System.Diagnostics.Process
    $process.StartInfo = $startInfo
    $process.Start() | Out-Null
    $standardOut = $process.StandardOutput.ReadToEnd()
    $process.WaitForExit()
    $standardOut
    $global:LASTEXITCODE = $realLASTEXITCODE
    #remove temp variables
    Remove-Variable realLASTEXITCODE -Confirm:$false
    Remove-Variable lastCommandSuccess -Confirm:$false
}
Set-Item -Path Function:prompt -Value $Prompt -Force

# AWS Profile
Set-Variable -Name "AWS_ECR_ACCESSID" -Value "543843577229"
Set-Variable -Name "AWS_COMPUTE_REGION" -Value "ap-southeast-1"
$authenticateEcrOnStartup = $false

Function DockerAuthAWS{
    Write-Output "Authenticating AWS ECR at $AWS_COMPUTE_REGION with Access ID $AWS_ECR_ACCESSID, please wait..."
    aws ecr get-login-password --region ap-southeast-1 | docker login --username AWS --password-stdin "$AWS_ECR_ACCESSID.dkr.ecr.$AWS_COMPUTE_REGION.amazonaws.com"    
}
# Set-Alias -Name docker-aws-auth -Value DockerAuthAWS
Set-Alias -Name Ecr-Auth -Value DockerAuthAWS

if($authenticateEcrOnStartup -eq $true) {
    DockerAuthAWS
}
