﻿#. (Join-Path $PSScriptRoot "GetDependencies_TestApps.ps1")

$Path = "C:\ProgramData\NavContainerHelper\DependencyApps"
$AllAppFiles = Get-ChildItem -Path $Path -Filter "*.app"

$AllApps = @()
foreach ($AppFile in $AllAppFiles) {
    $App = Get-NAVAppInfo -Path $AppFile.FullName
    $AllApps += [PSCustomObject]@{
        AppId        = $App.AppId
        Version      = $App.Version
        Name         = $App.Name
        Publisher    = $App.Publisher
        ProcessOrder = 0                            
        Dependencies = $App.Dependencies
        Path         = $AppFile.FullName
    }
}

function AddToDependencyTree() {
    param(
        [PSObject] $App,
        [PSObject[]] $DependencyArray,
        [PSObject[]] $AppCollection,
        [Int] $Order = 1
    )   

    foreach ($Dependency in $App.Dependencies) {
        $DependencyArray = AddToDependencyTree `
            -App ($AppCollection | where AppId -eq $Dependency.AppId) `
            -DependencyArray $DependencyArray `
            -AppCollection $AppCollection `
            -Order ($Order - 1)
    }

    if (-not($DependencyArray | where AppId -eq $App.AppId)) {
        $DependencyArray += $App
        ($DependencyArray | where AppId -eq $App.AppId).ProcessOrder = $Order
    }
    else {
        if (($DependencyArray | where AppId -eq $App.AppId).ProcessOrder -gt $Order) {
            ($DependencyArray | where AppId -eq $App.AppId).ProcessOrder = $Order
        } 
    }

    $DependencyArray
}

#Script execution
$FinalResult = @()

$AllApps | foreach {    
    $FinalResult = AddToDependencyTree -App $_ -DependencyArray $FinalResult -AppCollection $AllApps -Order $AllApps.Count
}

$FinalResult | sort ProcessOrder | ft