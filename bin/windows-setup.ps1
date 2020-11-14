# Run this before trying to run this script
# Only require scripts from online to be signed
# Set-ExecutionPolicy RemoteSigned

if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    echo "Please run as administrator"
    exit 1
}

# Directories
$user_name='jmcker'
New-Item -Path "D:\dev" -ItemType Directory
New-Item -Path "D:\${user_name}" -ItemType Directory
New-Item -Path "D:\${user_name}\Backup" -ItemType Directory
New-Item -Path "D:\${user_name}\Documents" -ItemType Directory
New-Item -Path "D:\${user_name}\Downloads" -ItemType Directory
New-Item -Path "D:\${user_name}\FX" -ItemType Directory
New-Item -Path "D:\${user_name}\Installations" -ItemType Directory
New-Item -Path "D:\${user_name}\Pictures" -ItemType Directory
New-Item -Path "D:\${user_name}\Stock Media" -ItemType Directory
New-Item -Path "D:\${user_name}\Videos" -ItemType Directory

# Time
Set-TimeZone -Name "Eastern Standard Time"
w32tm.exe /resync /force

# Windows features
Enable-WindowsOptionalFeature -Online -FeatureName Containers-DisposableClientVM -All -NoRestart        # Sandbox
Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V -All -NoRestart                    # Docker desktop/Hyper V
Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux -All -NoRestart    # WSL
Enable-WindowsOptionalFeature -Online -FeatureName VirtualMachinePlatform -All -NoRestart               # WSL 2

# Appearance
Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name "MenuShowDelay" -Value 100
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer" -Name "ShowFrequent" -Value 0
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "HideFileExt" -Value 0
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "LaunchTo" -Value 1 # Open to This PC
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "SnapAssist" -Value 0
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "ShowCortanaButton" -Value 0
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "TaskbarSmallIcons" -Value 0
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Search" -Name "BingSearchEnabled" -Value 0
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Name "AppsUseLightTheme" -Value 0
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Name "SystemUsesLightTheme" -Value 0
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Name "EnableTransparency" -Value 0

# Choco
Set-ExecutionPolicy Bypass -Scope Process -Force; Invoke-Expression ((New-Object System.Net.WebClient).DownloadString("https://chocolatey.org/install.ps1"))
$ENV:ChocolateyInstall = Convert-Path "$((Get-Command choco).Path)\..\.."
Import-Module "${ENV:ChocolateyInstall}\helpers\chocolateyProfile.psm1"

choco feature enable -n useRememberedArgumentsForUpgrades

# Productivity/utilities
choco install -y Firefox --params "/NoTaskbarShortcut /NoDesktopShortcut /RemoveDistributionDir"
choco install -y `
    googlechrome `
    nordvpn `
    openvpn `
    pdfsam `
    revo-uninstaller `
    signal `
    veracrypt `
    webex-meetings `
    WhatsApp `
    windirstat `
    7zip

choco pin add --name nordvpn
choco pin add --name openvpn
choco pin add --name veracrypt

# Dev
choco install -y cmake --installargs 'ADD_CMAKE_TO_PATH=System'
choco install -y git --params "/NoShellIntegration /NoGuiHereIntegration /NoShellHereIntegration"
choco install -y postgresql --installargs "--disable-components server,stackbuilder" --install-args-global
choco install -y python3 --installargs "PrependPath=1"
choco install -y sysinternals --params "/InstallDir:D:\${user_name}\Installations\SysInternals"
choco install -y `
    docker-desktop `
    doxygen `
    filezilla `
    gource `
    nmap `
    nodejs `
    notepadplusplus `
    microsoft-windows-terminal `
    postman `
    putty `
    reshack `
    vscode `
    vnc-viewer `
    visualstudio2017-workload-vctools `
    visualstudio2019community `
    visualstudio2019-workload-vctools `
    wireshark `
    wsl

# Media
choco install -y `
    audacity `
    audacity-ffmpeg `
    audacity-lame `
    ffmpeg `
    gimp `
    gstreamer `
    InkScape `
    musicbee `
    vlc
    # autodesk-fusion360 `
    # blender `

# Gaming
choco install -y `
    cpu-z `
    discord `
    epicgameslauncher `
    hwmonitor `
    obs-studio `
    samsung-magician `
    steam

Update-SessionEnvironment

# Python
pip install --user virtualenv youtube-dl

# Node
npm install -g cmake-js cspell nodemon


# Startup

# Enable/disable startup programs
# Enable: first byte == 0x2
# Disable: first byte == 0x3
function Set-RunAtStartup {
    param (
        [string]$Name,
        [switch]$Enabled = $false,
        [switch]$Disabled = $false
    )

    if (${Enabled} -eq ${Disabled}) {
        if (${Enabled}) {
            Write-Error "Cannot pass both -Enable and -Disable"
            exit 1
        }
        else {
            Write-Error "Must pass either -Enable or -Disable"
            exit 1
        }
    }

    # "HKLM:\Software\Microsoft\Windows\CurrentVersion\Run",
    $locations = @(
        "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\StartupApproved\Run"
    )

    foreach ($location in $locations) {
        echo "Checking for ${location}\${Name}..."

        try {
            $value = Get-ItemPropertyValue -Path "${location}" -Name "${Name}"
        } catch {
            continue
        }

        $first_byte = $value[0]
        $new_first_byte = ${first_byte}

        if (${first_byte} -eq 2) {
            if (${Enabled}) {
                echo "Already enabled"
                continue
            }

            echo "Disabling ${location}\${Name}"
            $new_first_byte = 3
        }
        elseif (${first_byte} -eq 3) {
            if (${Disabled}) {
                echo "Already disabled"
                continue
            }

            echo "Enabling ${location}\${Name}"
            $new_first_byte = 2
        }
        else {
            echo "Unknown value of '${first_byte}'. Skipping"
            continue
        }

        $value[0] = ${new_first_byte}

        Set-ItemProperty -Path "${location}" -Name "${Name}" -Value ${value}
    }
}

Set-RunAtStartup -Name "Discord" -Disable
Set-RunAtStartup -Name "NordVPN" -Disable
Set-RunAtStartup -Name "OneDrive" -Enable
Set-RunAtStartup -Name "OpenVPN" -Enable
Set-RunAtStartup -Name "OPENVPN-GUI" -Enable
Set-RunAtStartup -Name "Steam" -Disable

Set-RunAtStartup -Name "RtHDVBg_MAXX6" -Disable
Set-RunAtStartup -Name "RtHDVBg_PushButton" -Disable
Set-RunAtStartup -Name "RTHDVCPL" -Disable
Set-RunAtStartup -Name "WavesSvc" -Disable
