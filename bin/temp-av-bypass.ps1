# Getting terrible performance with Python in WSL?
#
# Putting a temporary exception in Windows Defender before running
# your load may speed things up
#
# I put this in a PS script so that I don't:
#    - forget to put the exception in every time
#    - forget to remove the exception when I'm finished
#    - resort to disabling "Real-time protection" for a bit cuz I'm lazy
#
# I don't consider this terribly risky, but you're still subverting your AV, so
# DO THIS AT YOUR OWN RISK

param (
    [string] $command = "python3",
    [switch] $help
)

$ErrorActionPreference = "Stop";

if (${help}) {
    echo "Add a Windows Defender exception for WSL's Python process, run a"
    echo "command in WSL, and remove the exception."
    echo ""
    echo "Usage: bypass.ps1 [-h] [-c command]"
    echo "    bypass.ps1 -h                             Display this message"
    echo "    bypass.ps1 -c 'python ./dostuff.py'       Add the exception and run"
    echo "    bypass.ps1 -command 'python ./dostuff.py' Add the exception and run"
    exit 0
}

# Grab the Python version from WSL
$python_version = bash.exe -c "python3 --version | sed -n 's/Python //p'" | %{ New-Object System.Version ($_) }
$process_name = "python" + ${python_version}.major + "." + ${python_version}.minor

echo "Adding exclusion for process ${process_name}"
Add-MpPreference -ExclusionProcess "${process_name}"
echo "Starting '${command}'..."
echo ""

try {
    bash.exe -c "${command}"
} catch [Exception] {
    echo "Error occurred:"
    echo "    $(${_}.Exception.GetType().FullName)"
    echo "    ${_}"
}

echo ""
Remove-MpPreference -ExclusionProcess "${process_name}"
echo "Removed exclusion for ${process_name}"