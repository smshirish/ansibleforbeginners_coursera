@echo off
setlocal enabledelayedexpansion

rem start_ansible_target.bat
rem Launches the Ansible target container using Podman on Windows.
rem Usage: start_ansible_target.bat [image-name]

set "LOGFILE=%~dp0start_ansible_target.log"
echo [%date% %time%] Starting Ansible target container... > "%LOGFILE%"

rem Validate Podman is installed and available in PATH.
where podman >nul 2>&1
if errorlevel 1 (
    echo [%date% %time%] ERROR: podman executable not found. >> "%LOGFILE%"
    echo ERROR: podman executable not found. Please install Podman or add it to PATH.
    exit /b 1
)

rem Default values.
set "IMAGE_NAME=my-ansible-host2"
if not "%~1"=="" set "IMAGE_NAME=%~1"
set "HOST_PORT=2222"
set "MOUNT_SOURCE=C:\data\workspace\devops_infra\share_mounts\dev_container_copied_data"
set "MOUNT_TARGET=/shared/dev_container_copied_data"

rem Validate mount source path.
if not exist "%MOUNT_SOURCE%" (
    echo [%date% %time%] ERROR: Mount source path does not exist: %MOUNT_SOURCE% >> "%LOGFILE%"
    echo ERROR: Mount source path does not exist: %MOUNT_SOURCE%
    exit /b 2
)

echo [%date% %time%] Using image: %IMAGE_NAME% >> "%LOGFILE%"
echo [%date% %time%] Mount source: %MOUNT_SOURCE% >> "%LOGFILE%"
echo [%date% %time%] Host port: %HOST_PORT% >> "%LOGFILE%"

echo Running Podman container...
echo podman run -v "%MOUNT_SOURCE%:%MOUNT_TARGET%" -p 0.0.0.0:%HOST_PORT%:22 -it "%IMAGE_NAME%" >> "%LOGFILE%"

podman run -v "%MOUNT_SOURCE%:%MOUNT_TARGET%" -p 0.0.0.0:%HOST_PORT%:22 -it "%IMAGE_NAME%"
if errorlevel 1 (
    set "RC=%ERRORLEVEL%"
    echo [%date% %time%] ERROR: podman run failed with code %RC%. >> "%LOGFILE%"
    echo ERROR: podman run failed with code %RC%. Check the log file at "%LOGFILE%" for details.
    exit /b %RC%
)

echo [%date% %time%] Container launched successfully. >> "%LOGFILE%"
echo Container launched successfully.
exit /b 0
