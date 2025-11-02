@echo off
setlocal enabledelayedexpansion
set this_script_full_path=%~f0

rem Usage: build.bat [make target]

::===================================User Config1 Start===================================
rem BuildTools路径
set user_buildtools_path=BuildTools/
rem 构建工作路径(可选)
set user_build_path=build/
rem 源代码路径(多个路径无需加引号)
set user_src=demo_project/
rem 源代码排除路径(可选, 多个路径无需加引号)
set user_src_out=
rem 源代码添加路径(可选, 多个路径无需加引号, 将user_src_out排除的文件或路径再次添加)
set user_src_add=
rem 链接文件路径(可选, 若不提供自动查找*flash.ld)
set user_ld_file=
rem MCU类型
set user_mcu_type=mcu_template
rem 额外编译参数(可选, 多个参数无需加引号)
set user_extra_cc_args=
rem 额外汇编参数(可选, 多个参数无需加引号)
set user_extra_as_args=
rem 额外链接参数(可选, 多个参数无需加引号)
set user_extra_ld_args=
rem 目标文件名(后缀决定编译类型为lib或elf)
set user_target_name=demo.a
::====================================User Config1 End====================================

set buildtools_path=%~dp0%user_buildtools_path:/=\%

if "%1" NEQ "" (
	call %buildtools_path%\StartMake.bat %*
	if !errorlevel! NEQ 0 (
		exit /b 1
	) else (
		exit /b 0
	)
)

::===================================User Config2 Start===================================
rem 在此处按需组合make target
call %buildtools_path%\StartMake.bat clean
if %errorlevel% NEQ 0 (
	pause
	exit /b 1
)

call %buildtools_path%\StartMake.bat
if %errorlevel% NEQ 0 (
	pause
	exit /b 1
)
::====================================User Config2 End====================================

rem 正常退出
exit /b 0
