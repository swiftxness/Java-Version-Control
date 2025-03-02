@echo off
:: UTF-8 kódolás beállítása
chcp 65001 >nul

:main_menu
cls
:: Ellenőrizzük, hogy a script rendszergazdaként fut-e
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo Rendszergazdai jogok szuksegesek. Ujrainditas...
    powershell -Command "Start-Process cmd -ArgumentList '/c "%~f0"' -Verb RunAs"
    exit /b
)

setlocal enabledelayedexpansion

:: Java telepítési könyvtárak keresése
set "java_dirs=C:\Program Files\Java"
set "count=0"

:: Verziók listázása
if exist "%java_dirs%" (
    for /d %%D in ("%java_dirs%\*") do (
        set /a count+=1
        set "java_path[!count!]=%%D"
        echo !count!. %%D
    )
) else (
    echo Nem találtam Java telepítési mappát!
    pause
    exit /b
)

:: Verzió kiválasztása
set /p choice=Válassz egy Java verziót (1-!count!) vagy írd be 'q' a kilépéshez: 
if "%choice%"=="q" exit /b

if not defined java_path[%choice%] (
    echo Érvénytelen választás!
    pause
    goto main_menu
)

:: JAVA_HOME beállítása
set "JAVA_HOME=!java_path[%choice%]!"
echo Új JAVA_HOME: %JAVA_HOME%

:: Rendszerváltozók frissítése (Admin jog szükséges!)
setx JAVA_HOME "%JAVA_HOME%" /M

:: PATH rendszerváltozó frissítése, pontosan %JAVA_HOME%\bin formátumban
setx PATH "%%JAVA_HOME%%\bin;%PATH%" /M
echo PATH változó frissítve: %%JAVA_HOME%%\bin hozzáadva

echo Java verzió sikeresen beállítva!
pause

:: Visszatérés a menübe
goto main_menu
