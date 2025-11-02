@echo off
setlocal enabledelayedexpansion

rem 若提供 this_script_full_path 提取 path & name (兼容老版 build.bat 仅提供 this_script_path)
if "%this_script_full_path%" NEQ "" (
	for %%i in ("%this_script_full_path%") do (
		set this_script_path=%%~dpi
		set this_script_name=%%~nxi
	)
) else (
	set this_script_name=build.bat
)

rem push当前路径, 并切换工作路径至本批处理文件路径
pushd %this_script_path%
rem format user_buildtools_path
set user_buildtools_path=%user_buildtools_path:/=\%
if "%user_buildtools_path:~-1%"=="\" set user_buildtools_path=%user_buildtools_path:~0,-1%
rem add shell-env\usr\bin to PATH
set PATH=%this_script_path%%user_buildtools_path%\binutils\shell-env\usr\bin;%PATH%

rem 遍历所有参数, 提取 --remote --remote-build, 生成新的参数列表
set remote_mode=0
for %%i in (%*) do (
	if "%%i" == "--remote" (
		set remote_mode=1
	) else if "%%i" == "--remote-build" (
		set remote_mode=2
	) else (
		if defined new_args (
			set "new_args=!new_args! %%i"
		) else (
			set "new_args=%%i"
		)
	)
)

if "%new_args%" NEQ "" (
	call :custom-make %new_args%
) else (
	call :custom-make all
)

if not "%remote_mode%" == "2" (
	echo.
	if "%errorlevel%" == "0" (
		echo *********************[ Make Succeeded ]*********************
	) else (
		echo **********************[ Make Failed ]***********************
	)
)

exit /b


:custom-make
call :evn_info _fd1 _fd2 ncores
if not defined fd1 set "fd1=%_fd1%"
if not defined fd2 set "fd2=%_fd2%"

set build_cmd=make -R -j%ncores% -f %user_buildtools_path%\automake\makefile ^
REMOTE_MODE="%remote_mode%" FD1="%fd1%" FD2="%fd2%" SCRIPT_NAME="%this_script_name%" PWD_PATH="%CD%" ^
BUILD_PATH="%user_build_path%" SRC="%user_src%" SRC_OUT="%user_src_out%" SRC_ADD="%user_src_add%" ^
LD_FILE="%user_ld_file%" DST_PATH=%user_dst_dir% DST_JSON=%user_dst_json% MCU=%user_mcu_type% ^
EXTRA_CC_ARGS="%user_extra_cc_args%" EXTRA_AS_ARGS="%user_extra_as_args%" EXTRA_LD_ARGS="%user_extra_ld_args%" ^
TARGET=%user_target_name% %*

if not "%remote_mode%" == "2" echo %build_cmd%
%build_cmd%
goto :EOF

:evn_info
yenvprobe.exe
set exitcode=%ERRORLEVEL%
rem fd1 (bit7)
set /a "%1=(exitcode>>7) & 1"
rem fd2 (bit6)
set /a "%2=(exitcode>>6) & 1"
rem ncores (bit 5-0 + 1)
set /a "%3=(exitcode & 63) + 1"
goto :EOF
