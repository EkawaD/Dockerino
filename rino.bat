@echo Off
setlocal EnableDelayedExpansion

set install_dir=%USERPROFILE%/.rino
set list=(xampp symfony python django flask react vue)
set lib=%install_dir%/lib.bat
set current=%cd%

set param1=%1
set param2=%2

if !param1!==start (
    call :start
) else if !param1!==run (
    call :start > nul
    call :get_params
    call :is_container_started
    if !process!==python (
        docker exec -ti !container! python !param2!
    ) else (
        echo ERROR: This project is not a python project !
    )
) else if  !param1!==update (
    call %lib% update
    goto :eof
) else if  !param1!==help (
    call %lib% help 
) else (
    set app=%param1%
    set project_name=%param2%
    call :get_app !app!
)

goto :eof


:start
call %lib% start_docker
docker-compose up -d
goto :eof

:get_params
for %%* in (.) do set project=%%~nx*
for /f "tokens=*" %%i in ('type .env') do (
    set line=%%i
    for /F "tokens=2 delims==" %%a in ("!line!") do ( 
        set process=%%a
        set container=!project!_!process!
    )
    goto :eof
)
goto :eof
    
:is_container_started
for /F "tokens=*" %%i in ('docker ps --format {{.Names}}') do (
    if %%i==!container! (
        echo Rino found %%i container
    ) else (
        echo No container for this project is currently running, you should use [rino start] to be sure
        goto :eof
    )
)
goto :eof

:get_app
for %%G in %list% do ( 
    if /I "%~1"=="%%~G" (
        goto :match %%~G
    ) 
)
goto :eof

:match
echo %app%
echo %project_name%
if %~1==xampp (
    call %lib% xampp %app% %project_name%
) else if %~1==symfony (
    call %lib% symfony %app% %project_name%
) else if %~1==python (
    call %lib% python %app% %project_name%
) else (
    echo Erreur !
)
goto :eof