param (
    [switch] $install,
    [switch] $start,
    [switch] $restart,
    [switch] $stop,
    [switch] $update,
    [switch] $rebuild,
    [switch] $updatedb,
    [switch] $updateself,
    [string] $output = ""
)

# Setup
$scriptPath = $MyInvocation.MyCommand.Path

$dir = Split-Path -Parent $MyInvocation.MyCommand.Path
if ($output -eq "") {
    $output = "${dir}\data"
}
else {
    New-Item -ItemType directory -Path $output -ErrorAction Ignore | Out-Null
    $output = Resolve-Path $output
}


$scriptsDir = "${output}\scripts"
$dockerRegistry = "evoflare" #"evoflare.docker:50000"
$githubBaseUrl = "https://raw.githubusercontent.com/evoflare/setup/master"
$coreVersion = "latest"
$webVersion = "latest"

# Functions

function Get-Self {
    Invoke-RestMethod -OutFile $scriptPath -Uri "${githubBaseUrl}/scripts/evoflare.ps1"
}

function Get-Run-File {
    if (!(Test-Path -Path $scriptsDir)) {
        New-Item -ItemType directory -Path $scriptsDir | Out-Null
    }
    # TODO download from git
    Invoke-RestMethod -OutFile $scriptsDir\run.ps1 -Uri "${githubBaseUrl}/scripts/run.ps1"
    # Copy-Item "${dir}\run.ps1" "${scriptsDir}\run.ps1"
}

function Assert-Output-Dir-Exists {
    if (!(Test-Path -Path $output)) {
        throw "Cannot find a Evoflare installation at $output."
    }
}

function Assert-Output-Dir-Not-Exists {
    if (Test-Path -Path "$output\docker") {
        ## throw "Looks like Evoflare is already installed at $output."
    }
}

function Write-Line($str) {
    if ($env:EVOFLARE_QUIET -ne "true") {
        Write-Host $str
    }
}

# Intro

$year = (Get-Date).year

Write-Line @'
                      __  _                   
                     / _|| |                  
   ___ __   __ ___  | |_ | |  __ _  _ __  ___ 
  / _ \\ \ / // _ \ |  _|| | / _` || '__|/ _ \
 |  __/ \ V /| (_) || |  | || (_| || |  |  __/
  \___|  \_/  \___/ |_|  |_| \__,_||_|   \___|
'@

Write-Line "
Copyright ${year}, Evoflare LLC
===================================================
"

Write-Line "Script path = ${scriptPath}" 
Write-Line "Output path = ${output}" 

Write-Line "Docker registry = ${dockerRegistry}" 
Write-Line "Core module version = ${coreVersion}" 
Write-Line "Web module version = ${webVersion}" 

if ($env:EVOFLARE_QUIET -ne "true") {
    # docker --version
    # docker-compose --version
}

Write-Line ""

# Commands

if ($install) {
    Assert-Output-Dir-Not-Exists
    New-Item -ItemType directory -Path $output -ErrorAction Ignore | Out-Null
    Get-Run-File
    Invoke-Expression "& `"$scriptsDir\run.ps1`" -install -outputDir `"$output`" -coreVersion $coreVersion -webVersion $webVersion -dockerRegistry $dockerRegistry"
}
elseif ($start -Or $restart) {
    Assert-Output-Dir-Exists
    Invoke-Expression "& `"$scriptsDir\run.ps1`" -restart -outputDir `"$output`" -coreVersion $coreVersion -webVersion $webVersion"
}
elseif ($update) {
    Assert-Output-Dir-Exists
    Get-Run-File
    Invoke-Expression "& `"$scriptsDir\run.ps1`" -update -outputDir `"$output`" -coreVersion $coreVersion -webVersion $webVersion"
}
elseif ($rebuild) {
    Assert-Output-Dir-Exists
    Invoke-Expression "& `"$scriptsDir\run.ps1`" -rebuild -outputDir `"$output`" -coreVersion $coreVersion -webVersion $webVersion"
}
elseif ($updatedb) {
    Assert-Output-Dir-Exists
    Invoke-Expression "& `"$scriptsDir\run.ps1`" -updatedb -outputDir `"$output`" -coreVersion $coreVersion -webVersion $webVersion"
}
elseif ($stop) {
    Assert-Output-Dir-Exists
    Invoke-Expression "& `"$scriptsDir\run.ps1`" -stop -outputDir `"$output`" -coreVersion $coreVersion -webVersion $webVersion"
}
elseif ($updateself) {
    Get-Self
    Write-Line "Updated self."
}
else {
    Write-Line "No command found."
}
