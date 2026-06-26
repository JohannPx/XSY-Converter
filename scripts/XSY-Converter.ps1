# PowerShell Script: XSY Converter
# Schneider Unity Pro XSY Variable Export Tool
# Version: 1.0.0 - WPF GUI
# Author: JPR
# Date: 2026-03-09

# =================== GENERAL SETTINGS ===================
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# Console UTF-8
try { chcp 65001 > $null } catch {}
try { [Console]::OutputEncoding = [System.Text.Encoding]::UTF8 } catch {}

# STA check (WPF requires STA thread)
if ([System.Threading.Thread]::CurrentThread.GetApartmentState() -ne 'STA') {
    Start-Process powershell.exe -ArgumentList "-Sta -WindowStyle Hidden -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -NoNewWindow -Wait
    exit
}

# Show startup message before hiding console
Write-Host ""
Write-Host "  XSY Converter" -ForegroundColor Cyan
Write-Host "  Chargement de l'interface..." -ForegroundColor Gray
Write-Host ""

# Brief pause so the user can read the startup message
Start-Sleep -Seconds 1

# Hide the console window (only the WPF GUI will be visible)
Add-Type -Name Win32 -Namespace Native -MemberDefinition @'
    [DllImport("kernel32.dll")] public static extern IntPtr GetConsoleWindow();
    [DllImport("user32.dll")] public static extern bool ShowWindow(IntPtr hWnd, int nCmdShow);
'@
$consoleHwnd = [Native.Win32]::GetConsoleWindow()
if ($consoleHwnd -ne [IntPtr]::Zero) {
    [Native.Win32]::ShowWindow($consoleHwnd, 0) | Out-Null  # 0 = SW_HIDE
}

# =================== MODULE LOADING + LAUNCH ===================
try {
    $ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
    $modulesDir = Join-Path $ScriptDir "modules"

    # Dans le build embarque (release), tous les modules sont deja concatenes ci-dessus et
    # $Script:EmbeddedBuild vaut $true. On ne doit PAS dot-sourcer un dossier "modules" externe
    # dans ce cas : il ecraserait les fonctions embarquees par des copies potentiellement obsoletes.
    # Seul le layout modulaire de dev charge les modules depuis le disque. (Get-Variable est utilise
    # car referencer un $Script:EmbeddedBuild non defini leverait une erreur sous Set-StrictMode.)
    $embeddedBuild = [bool](Get-Variable -Name EmbeddedBuild -Scope Script -ValueOnly -ErrorAction SilentlyContinue)

    if (-not $embeddedBuild -and (Test-Path $modulesDir)) {
        $moduleOrder = @(
            "AppState.ps1"
            "Localization.ps1"
            "XsyParser.ps1"
            "ExportCsv.ps1"
            "ExportEwon.ps1"
            "ExportPcVue.ps1"
            "UIHelpers.ps1"
            "UI.ps1"
        )
        foreach ($mod in $moduleOrder) {
            $modPath = Join-Path $modulesDir $mod
            if (Test-Path $modPath) {
                . $modPath
            }
        }
    }

    # =================== LAUNCH ===================
    $window = Initialize-MainWindow
    $window.ShowDialog() | Out-Null
} catch {
    $errMsg = $_.Exception.Message
    $inner = $_.Exception.InnerException
    while ($inner) {
        $errMsg += "`n-> $($inner.Message)"
        $inner = $inner.InnerException
    }
    # Log to file for debugging
    $logPath = Join-Path ([Environment]::GetFolderPath('Desktop')) "XSY_Converter_Error.log"
    "[$((Get-Date).ToString('yyyy-MM-dd HH:mm:ss'))] $errMsg`n$($_.ScriptStackTrace)" | Out-File $logPath -Encoding UTF8
    # Show console again for error display
    if ($consoleHwnd -ne [IntPtr]::Zero) {
        [Native.Win32]::ShowWindow($consoleHwnd, 5) | Out-Null  # SW_SHOW
    }
    try {
        Add-Type -AssemblyName PresentationFramework -ErrorAction SilentlyContinue
        [System.Windows.MessageBox]::Show(
            "Erreur: $errMsg`n`n$($_.ScriptStackTrace)",
            "Erreur", "OK", "Error")
    } catch {
        Write-Host "Erreur: $errMsg" -ForegroundColor Red
        Write-Host $_.ScriptStackTrace
        Read-Host "Appuyez sur Entree pour fermer"
    }
}
