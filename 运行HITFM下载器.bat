@echo off
chcp 65001 >nul
cd /d "%~dp0"

:: ============= 第一步：用户输入日期/目录（优先执行）=============
echo.
echo  HITFM 节目下载器配置
echo.

set /p START_DATE=起始日期 (格式 YYYY-MM-DD，默认 2025-11-01): 
if "%START_DATE%"=="" set START_DATE=2025-11-01

set /p END_DATE=结束日期 (格式 YYYY-MM-DD，默认 2025-11-30): 
if "%END_DATE%"=="" set END_DATE=2025-11-30

set /p SAVE_DIR=保存目录 (默认 HITFM): 
if "%SAVE_DIR%"=="" set SAVE_DIR=HITFM

:: 自动转为 ./HITFM_xxx 格式
set SAVE_BASE_DIR=./%SAVE_DIR%

:: ============= 第二步：生成config.py（输入完成后立刻生成）=============
echo.
echo ?? 正在生成配置文件 config.py...
(
echo START_DATE = "%START_DATE%"
echo END_DATE = "%END_DATE%"
echo CHANNEL_NAME = "662"
echo SAVE_BASE_DIR = "%SAVE_BASE_DIR%"
) > config.py
if exist config.py (
    echo ? config.py 生成成功！
) else (
    echo ? config.py 生成失败，请检查目录写入权限！
    pause
    exit /b 1
)

:: ============= 第三步：检查Python环境和依赖 =============
echo.
echo ?? 检查Python环境...
:: 检测Python是否安装
python --version >nul 2>&1
if %errorlevel% NEQ 0 (
    echo ? 未找到Python环境，请先安装Python并勾选「Add Python to PATH」！
    pause
    exit /b 1
)

:: 检测核心依赖（requests）
echo ?? 检查Python依赖...
python -c "import requests" >nul 2>&1
if %errorlevel% NEQ 0 (
    echo ??  缺少requests依赖，正在自动安装...
    pip install requests
    if %errorlevel% NEQ 0 (
        echo ? 依赖安装失败，请手动运行：pip install requests
        pause
        exit /b 1
    )
    echo ? 依赖安装成功！
)

:: ============= 第四步：运行主脚本（依赖就绪后执行）=============
echo.
echo ? 依赖已就绪，开始下载节目...
echo.

:RUN
python hitfm_downloader.py
:: 检测脚本运行结果
if %errorlevel% EQU 0 (
    echo ?? 节目下载完成！
) else (
    echo ? 脚本运行出错，请查看上方错误信息后重试！
    pause
    exit /b 1
)

:: ============= 结束流程 =============
echo.
echo ?? 整个流程执行完毕！
echo 按任意键退出...
pause >nul