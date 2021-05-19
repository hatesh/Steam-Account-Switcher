
::==============================================================::
::              Haboosh's Steam Account Switcher                ::
::                                                              ::
::==============================================================::
@echo off        
setlocal EnableDelayedExpansion
TITLE Haboosh's Steam Account Switcher                          
::--------------------------------------------------------------::
::                 List your usernames here:                    ::
::--------------------------------------------------------------::
set steam_usernames=username1 username2 username3
::--------------------------------------------------------------::

::==============================================================::
::                                                              ::
::          \_   ___ \ \_____  \ \______ \ \_   _____/          ::
::          /    \  \/  /   |   \ |    |  \ |    __)_           ::
::          \     \____/    |    \|    `   \|        \          ::
::           \______  /\_______  /_______  /_______  /          ::
::                  \/         \/        \/        \/           ::
::                                                              ::
::==============================================================::
::                        (DO NOT EDIT)                         ::
::==============================================================::
::                DEFAULTS FOR ERROR HANDLING                   ::
::--------------------------------------------------------------::
set user=ERROR
set error=ERROR
::--------------------------------------------------------------::
::                   LIST USERNAMES TO USER                     ::
::--------------------------------------------------------------::
set /a account_counter = 1
echo Select an account:
for %%x in (%steam_usernames%) do (
    echo !account_counter!: %%x
    set /a "account_counter += 1"
)
::--------------------------------------------------------------::
::                          USER INPUT                          ::
::--------------------------------------------------------------::
set /p account="> "
::--------------------------------------------------------------::
::                         FIND CHOSEN                          ::
::--------------------------------------------------------------::
set /a select_counter = 1
for %%x in (%steam_usernames%) do (
    if !select_counter!==%account% set user=%%x
    if %account%==%%x (
        set user=%%x
        set /a account=!select_counter!
    )
    set /a "select_counter+=1"
)
::--------------------------------------------------------------::
::                          ACTIONS                             ::
::--------------------------------------------------------------::
if %user%==%error% (
    echo Invalid account selected. Edit the script if you want to add more.
) ELSE (
    echo Selected [%account%]: %user%
    echo Killing steam
    taskkill.exe /F /IM steam.exe
    echo Seetting as steam user
    reg add "HKCU\Software\Valve\Steam" /v AutoLoginUser /t REG_SZ /d %user% /f
    reg add "HKCU\Software\Valve\Steam" /v RememberPassword /t REG_DWORD /d 1 /f
    echo Opening steam
    start steam://open/main
    echo Make sure you select to remember password for auto-login.
)
::--------------------------------------------------------------::
::                        ACKNOWLEDGE                           ::
::--------------------------------------------------------------::
pause
::--------------------------------------------------------------::
::                            END                               ::
::--------------------------------------------------------------::
