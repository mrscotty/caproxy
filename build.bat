REM @echo off
setlocal enabledelayedexpansion
REM setlocal

REM === Configuration ===
set DLL_NAME=CsrProxyPolicy.dll
set DLL_PATH=.\x64\Release\%DLL_NAME%
set "INSTALL_DIR=C:\Program Files\CsrProxyPolicy"
set "DEST_DLL=%INSTALL_DIR%\%DLL_NAME%"
set "SLN_PATH=CsrProxyPolicy\CsrProxyPolicy.sln"

echo "[INFO] Clean build tree..."
MSBuild "%SLN_PATH%" /t:Clean

echo "[INFO] Building CSR Proxy Policy Module (Release | x64)..."
MSBuild "%SLN_PATH%" /p:Configuration=Release /p:Platform=x64
if %errorlevel% neq 0 (
    echo "[ERROR] Build failed."
    exit /b %errorlevel%
)
echo "[INFO] Build completed successfully."

REM === Create target directory if needed ===
if not exist "%INSTALL_DIR%" (
    echo "[INFO] Creating target directory: %INSTALL_DIR%"
    mkdir "%INSTALL_DIR%"
)

REM === Gratuitous 'DIR' to see if this helps with the copy
dir x64

REM === Copy DLL ===
echo "[INFO] Copying %DLL_PATH% to %DEST_DLL%"
copy /Y "%DLL_PATH%" "%DEST_DLL%"
if %errorlevel% neq 0 (
    echo "[ERROR] Failed to copy DLL."
    exit /b %errorlevel%
)

REM === Register DLL ===
echo "[INFO] Registering DLL via regsvr32..."
regsvr32 /s "%DEST_DLL%"
if %errorlevel% neq 0 (
    echo "[ERROR] regsvr32 failed."
    exit /b %errorlevel%
)
echo "[INFO] DLL registered successfully."

REM === Restart Certificate Services ===
echo "[INFO] Restarting Certificate Services..."
net stop certsvc
net start certsvc
if %errorlevel% neq 0 (
    echo "[ERROR] Failed to restart certsvc."
    exit /b %errorlevel%
)
echo "[INFO] CA service restarted."

echo "[SUCCESS] All steps completed."
endlocal
REM pause
