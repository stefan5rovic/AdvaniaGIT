﻿if ($BranchSettings.dockerContainerId -gt "") {
    $SetupParameters.navIdePath = Copy-DockerNAVClient -SetupParameters $SetupParameters -BranchSettings $BranchSettings
}


# Import Custom Test objects
if (Test-Path $SetupParameters.testObjectsPath) {
    Load-ModelTools -SetupParameters $SetupParameters
    foreach ($testObjectFile in (Get-ChildItem -Path (Join-Path $SetupParameters.testObjectsPath '*.txt'))) {
        Write-Host "Importing $($testObjectFile.Name)..."
        Update-NAVApplicationFromTxt -SetupParameters $SetupParameters -BranchSettings $BranchSettings -ObjectsPath $testObjectFile.FullName -SkipDeleteCheck
    }
    foreach ($testObjectFile in (Get-ChildItem -Path (Join-Path $SetupParameters.testObjectsPath '*.fob'))) {
        Write-Host "Importing $($testObjectFile.Name)..."
        Import-NAVApplicationGITObject -SetupParameters $SetupParameters -BranchSettings $BranchSettings -Path $testObjectFile.FullName -ImportAction Overwrite -SynchronizeSchemaChanges Force
    }
    Compile-UncompiledObjects -SetupParameters $SetupParameters -BranchSettings $BranchSettings
    if ((Get-UncompiledObjectsCount -BranchSettings $BranchSettings) -ne 0) {
        Throw
    }
    & (Join-Path $PSScriptRoot 'Start-ForceSync.ps1')
    UnLoad-ModelTools
}

        

