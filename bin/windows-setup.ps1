# Run this before trying to run this script
# Only require scripts from online to be signed
# Set-ExecutionPolicy RemoteSigned

# Windows features
Enable-WindowsOptionalFeature -Online -FeatureName Containers-DisposableClientVM -All -NoRestart        # Sandbox
Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V -All -NoRestart                    # Docker desktop/Hyper V
Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux -All -NoRestart    # WSL
Enable-WindowsOptionalFeature -Online -FeatureName VirtualMachinePlatform -All -NoRestart               # WSL 2

# Registry
Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name "MenuShowDelay" -Value "100"
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer" -Name "ShowFrequent" -Value "0"
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "HideFileExt" -Value "0"
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "LaunchTo" -Value "1" # Open to This PC
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "SnapAssist" -Value "0"
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "ShowCortanaButton" -Value "0"
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "TaskbarSmallIcons" -Value "0"
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Search" -Name "BingSearchEnabled" -Value 0
Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Name "AppsUseLightTheme" -Value 0
Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Name "SystemUsesLightTheme" -Value 0
Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Name "EnableTransparency" -Value 0

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
npm install -g cmake-js cspell
