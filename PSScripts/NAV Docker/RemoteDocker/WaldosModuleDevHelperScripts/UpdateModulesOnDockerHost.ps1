﻿. (Join-Path $PSScriptRoot '.\_Settings.ps1')

$ModulePath = "C:\Users\waldo\dropbox\github\Cloud.Ready.Software.PowerShell\PSModules\CRS.NavContainerHelperExtension"

$cs = New-PSSession -ComputerName $DockerHost -UseSSL:$DockerHostUseSSL -Credential $DockerHostCredentials -SessionOption $DockerHostSessionOption

Get-ChildItem $ModulePath | %{
    Copy-Item `