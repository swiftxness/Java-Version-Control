@echo off
:: UTF-8 kódolás beállítása / Setting UTF-8 encoding
chcp 65001 >nul

:: Language setting initialization
if not defined script_language set "script_language=hu"

:language_menu
cls
if "%script_language%"=="hu" (
    echo Nyelv / Language:
    echo 1. Magyar (jelenlegi)
    echo 2. Angol
    echo 3. Folytatás a főmenübe
) else (
    echo Language / Nyelv:
    echo 1. Hungarian
    echo 2. English (current)
    echo 3. Continue to main menu
)

set /p lang_choice="> "
if "%lang_choice%"=="1" set "script_language=hu" & goto language_menu
if "%lang_choice%"=="2" set "script_language=en" & goto language_menu
if "%lang_choice%"=="3" goto main_menu
goto language_menu

:main_menu
cls
:: Ellenőrizzük, hogy a script rendszergazdaként fut-e
net session >nul 2>&1
if %errorLevel% neq 0 (
    if "%script_language%"=="hu" (
        echo Rendszergazdai jogok szuksegesek. Ujrainditas...
    ) else (
        echo Administrator privileges required. Restarting...
    )
    powershell -Command "Start-Process cmd -ArgumentList '/c "%~f0"' -Verb RunAs"
    exit /b
)

setlocal enabledelayedexpansion

:: Java telepítési könyvtárak keresése
set "java_dirs=C:\Program Files\Java"
set "count=0"

:: Verziók listázása
if exist "%java_dirs%" (
    if "%script_language%"=="hu" (
        echo Elérhető Java verziók:
    ) else (
        echo Available Java versions:
    )
    
    for /d %%D in ("%java_dirs%\*") do (
        set /a count+=1
        set "java_path[!count!]=%%D"
        echo !count!. %%D
    )
) else (
    if "%script_language%"=="hu" (
        echo Nem találtam Java telepítési mappát!
    ) else (
        echo No Java installation folder found!
    )
    pause
    goto language_menu
)

:: Verzió kiválasztása
if "%script_language%"=="hu" (
    set "prompt_text=Válassz egy Java verziót (1-!count!), 'l' a nyelvváltáshoz vagy 'q' a kilépéshez: "
) else (
    set "prompt_text=Choose a Java version (1-!count!), 'l' to change language or 'q' to quit: "
)

set /p choice=%prompt_text%
if "%choice%"=="q" exit /b
if "%choice%"=="l" goto language_menu

if not defined java_path[%choice%] (
    if "%script_language%"=="hu" (
        echo Érvénytelen választás!
    ) else (
        echo Invalid choice!
    )
    pause
    goto main_menu
)

:: JAVA_HOME beállítása
set "JAVA_HOME=!java_path[%choice%]!"
if "%script_language%"=="hu" (
    echo Új JAVA_HOME: %JAVA_HOME%
) else (
    echo New JAVA_HOME: %JAVA_HOME%
)

:: Rendszerváltozók frissítése (Admin jog szükséges!)
setx JAVA_HOME "%JAVA_HOME%" /M

:: PATH rendszerváltozó frissítése, pontosan %JAVA_HOME%\bin formátumban
setx PATH "%%JAVA_HOME%%\bin;%PATH%" /M
if "%script_language%"=="hu" (
    echo PATH változó frissítve: %%JAVA_HOME%%\bin hozzáadva
    echo Java verzió sikeresen beállítva!
) else (
    echo PATH variable updated: %%JAVA_HOME%%\bin added
    echo Java version successfully set!
)
pause

:: Visszatérés a menübe
goto main_menu
