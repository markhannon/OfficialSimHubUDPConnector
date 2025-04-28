<#
Make script to easily manage development workflow.

Set configuration in make.ini and run with .\make.ps1.

Arguments:
-build      to build a zipfile suitable for use with CM
-install    to manually install from repo into game
-import     to manually copy back from game to repo
-verbose    to show extra script output
#>

param (
    [switch]$build = $false,
    [switch]$import = $false,
    [switch]$install = $false,
    [switch]$verbose = $false
 )

if ($verbose) {
    Set-PSDebug -Trace 1
} else {
    Set-PSDebug -Trace 0
}

# Get user make configuration
$make_ini = Get-Content -Path make.ini | ConvertFrom-StringData
$app_name = $make_ini.app_name
$apps_dir = $make_ini.apps_dir
$dist_dir = $make_ini.dist_dir
$game_dir = $make_ini.game_dir
$root_dir = $make_ini.root_dir

# Get apps version information
$manifest_ini = Get-Content -Path $apps_dir\$app_name\manifest.ini|`
Select-String -Pattern '^\[' -NotMatch | ConvertFrom-StringData
$version = $manifest_ini.VERSION

if ($build){

    $app_path = "${dist_dir}\${app_name}-${version}.zip"

    Write-Host -NoNewline Building $app_path ": "

    If (!(test-path $dist_dir))
    {
        New-Item -ItemType Directory -Path $dist_dir
    }
    
    If (!(test-path -Path $app_path)){
        $app = @{
            Path = $root_dir
            CompressionLevel = "Fastest"
            DestinationPath = $app_path
        }
        Compress-Archive @app
        Write-Host success 
    } else {
        Write-Host already exists
    }

    exit 0
}

if ($install -or $import){

    if ($install){
        $src = "$apps_dir\$app_name"
        $dst = "$game_dir\$app_name"
        Write-Host Installing from $src to $dst
    } else {
        $src = "$game_dir\$app_name"
        $dst = "$apps_dir\$app_name"
        Write-Host Importing from $src to $dst
    }

    robocopy `
    $src\$app `
    $dst\$app `
    /xd $src\$app\.git `
    /xd $src\$app\.gitignore `
    /mir

    exit 0
}
