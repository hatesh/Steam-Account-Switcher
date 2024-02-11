$USERNAME_FILE = "C:\Users\${env:USERNAME}\steam_usernames.txt"
$global:EVENT_LOOP = $true

function OpenUsernameFile {
    Invoke-Item "${USERNAME_FILE}"
}

function InitialiseUsernameFile {
    # Check if the file exists
    if (-not (Test-Path $USERNAME_FILE)) {
        # Create a new file
        New-Item -Path $USERNAME_FILE -ItemType File | Out-Null
        Write-Host "Created new usernames file: $USERNAME_FILE"
        $global:usernames = @()
    }
}

function ReadUsernames {
    InitialiseUsernameFile
    # $global:usernames = Get-Content -Path $USERNAME_FILE
    # Count the number of lines in the file
    $lineCount = Get-Content -Path $USERNAME_FILE | Measure-Object -Line | Select-Object -ExpandProperty Lines
    $fileContent = Get-Content -Path $USERNAME_FILE -Raw -ErrorAction SilentlyContinue
    if ([string]::IsNullOrWhiteSpace($fileContent)) {
        # Empty file: Initialize an empty array
        $global:usernames = @()
    } elseif ($lineCount -lt 2) {
        # Single line: Store it as the first index in a new array
        $global:usernames = @($fileContent)
    } else {
        # More than one line: Load content into an array
        $global:usernames = $fileContent -split [Environment]::NewLine
    }
}

function WriteUsernames {
    Write-Output "Saving usernames to ${USERNAME_FILE}"
    if ($global:usernames.Length -eq 0) {
        New-Item -Path $USERNAME_FILE -ItemType File -Force
    } elseif ($global:usernames.Length -eq 1) {
        $global:usernames | Set-Content -NoNewline -Path $USERNAME_FILE
    } elseif ($global:usernames.Length -gt 1) {
        $head = $global:usernames[0..($global:usernames.Length - 2)]
        $head | Set-Content -Path $USERNAME_FILE
        $global:usernames[-1] | Add-Content -NoNewline  -Path $USERNAME_FILE
    } else {
        $global:usernames | Set-Content -Path $USERNAME_FILE
    }
}

function NewUsername {
    Redraw
    Section -InputString " NEW USERNAME "
    # Load current usernames
    ReadUsernames
    # Prompt user for a new username
    $newUsername = Read-Host "Enter a new username"
    # Add the new username to the list
    $global:usernames += $newUsername
    # Write the usernames to the file
    WriteUsernames
}

function DeleteUsername {
    Redraw
    Section -InputString " ACCOUNT DELETE "
    Show-Accounts
    $delete_selection = Read-Host -Prompt "delete"
    if ($delete_selection -ge 1 -and $delete_selection -le $usernames.Length) {
        $user = $usernames[$account - 1]
        $pre_delete_num_accounts = $global:usernames.Length
        $global:usernames = $global:usernames | Where-Object { $_ -ne $user }
        # Prevent an 
        if ($pre_delete_num_accounts -eq 2) {
            $global:usernames = @($global:usernames)
        }
        WriteUsernames
    } else {
        Write-Host "No account with that number"
        pause
    }
}

function Set-SteamUser {
    param (
        [string]$selectedUser
    )
    Redraw
    Section -InputString " STEAM SWITCH "
    Write-Host "Selected account: $selectedUser"
    Write-Host "Killing Steam"
    taskkill.exe /F /IM steam.exe
    Write-Host "Setting as Steam user"
    reg add "HKCU\Software\Valve\Steam" /v AutoLoginUser /t REG_SZ /d $selectedUser /f
    reg add "HKCU\Software\Valve\Steam" /v RememberPassword /t REG_DWORD /d 1 /f
    Write-Host "Opening Steam"
    Start-Process "steam://open/main"
    Write-Host "Make sure you select to remember the password for auto-login."
    pause
}

# Function to display account options
function Show-Accounts {
    ReadUsernames
    SubSection -InputString " ACCOUNTS "
    for ($i = 0; $i -lt $global:usernames.Length; $i++) {
        Write-Host "$($i + 1): $($global:usernames[$i])"
    }
}
function Show-MenuOptions {
    SubSection -InputString " CONFIG "
    Write-Host "a: Add a new steam username"
    Write-Host "d: Delete a username"
    Write-Host "o: Open the usernames file"
    Write-Host "e: Exit the application"
}


function MenuInput {
    $menu_input = Read-Host -Prompt "selection"
    if (-not ($menu_input -match '^\d+$')) {
        switch ($menu_input.ToLower()) {
            'a' { NewUsername }
            'e' { ExitSwitcher }
            'd' { DeleteUsername }
            'o' { OpenUsernameFile }
            Default {
                Write-Host "Invalid Input"
            }
        }
    }
    elseif ($menu_input -ge 1 -and $menu_input -le $global:usernames.Length) {
        $user = $global:usernames[$menu_input - 1]
        Set-SteamUser -selectedUser $user
    }
    else {
        Write-Host "No account with that number"
    }
}

function Menu {
    Redraw
    Section -InputString " MAIN MENU "
    Show-Accounts
    Show-MenuOptions
    MenuInput
}

function ExitSwitcher {
    Write-Host "Exiting"
    $global:EVENT_LOOP = $false
}

function Splash {
    Redraw
    pause
}

function Title {
    Write-Host "     ___  ___  ________  ________  ________  ________  ________  ___  ___                "
    Write-Host "    |\  \|\  \|\   __  \|\   __  \|\   __  \|\   __  \|\   ____\|\  \|\  \               "
    Write-Host "    \ \  \\\  \ \  \|\  \ \  \|\ /\ \  \|\  \ \  \|\  \ \  \___|\ \  \\\  \              "
    Write-Host "     \ \   __  \ \   __  \ \   __  \ \  \\\  \ \  \\\  \ \_____  \ \   __  \             "
    Write-Host "      \ \  \ \  \ \  \ \  \ \  \|\  \ \  \\\  \ \  \\\  \|____|\  \ \  \ \  \            "
    Write-Host "       \ \__\ \__\ \__\ \__\ \_______\ \_______\ \_______\____\_\  \ \__\ \__\           "
    Write-Host "        \|__|\|__|\|__|\|__|\|_______|\|_______|\|_______|\_________\|__|\|__|           "
    Write-Host "                                                         \|_________|                    "
    Write-Host "     ________  ___       __   ___  _________  ________  ___  ___  _______   ________     "
    Write-Host "    |\   ____\|\  \     |\  \|\  \|\___   ___\\   ____\|\  \|\  \|\  ___ \ |\   __  \    "
    Write-Host "    \ \  \___|\ \  \    \ \  \ \  \|___ \  \_\ \  \___|\ \  \\\  \ \   __/|\ \  \|\  \   "
    Write-Host "     \ \_____  \ \  \  __\ \  \ \  \   \ \  \ \ \  \    \ \   __  \ \  \_|/_\ \   _  _\  "
    Write-Host "      \|____|\  \ \  \|\__\_\  \ \  \   \ \  \ \ \  \____\ \  \ \  \ \  \_|\ \ \  \\  \| "
    Write-Host "        ____\_\  \ \____________\ \__\   \ \__\ \ \_______\ \__\ \__\ \_______\ \__\\ _\ "
    Write-Host "       |\_________\|____________|\|__|    \|__|  \|_______|\|__|\|__|\|_______|\|__|\|__|"
    Write-Host "       \|_________|                                                                      "
    Write-Host "                                                                                         "
    Write-Host "                                                                                         "                                                                                   
}

function CenterString {
    param (
        [string]$InputString,
        [string]$PaddingChar = " ",
        [int]$TotalLength = 89
    )
    # Calculate the padding required
    $paddingLength = $TotalLength - $InputString.Length
    $leftPadding = [Math]::Floor($paddingLength / 2)
    $rightPadding = [Math]::Ceiling($paddingLength / 2)
    # Create the centered string
    $centeredString = "{0}{1}{2}" -f $($PaddingChar * $leftPadding), $InputString, $($PaddingChar * $rightPadding)
    # Return
    return $centeredString
}

function Section {
    param (
        [string]$InputString,
        [int]$TotalLength = 89
    )
    Write-Host $("=" * $TotalLength)
    Write-Host $(CenterString -InputString $InputString -PaddingChar '-' -TotalLength $TotalLength)
    Write-Host $("=" * $TotalLength)
}

function SubSection {
    param (
        [string]$InputString,
        [int]$TotalLength = 89
    )
    Write-Host $("-" * $TotalLength)
    Write-Host $(CenterString -InputString $InputString -PaddingChar ' ' -TotalLength $TotalLength)
    Write-Host $("-" * $TotalLength)
}
function Redraw {
    Clear-Host
    Title
}

# ACTUAL CODE LOOP
Splash
while ($global:EVENT_LOOP) {
    Menu
}
Redraw
Write-Host "Goodbye!"
Start-Sleep 0.5
exit
