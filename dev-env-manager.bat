@echo off
title Dev Env Manager v1.0
color 0A

:main_menu
cls
echo ^+============================================+
echo ^|          Dev Env Manager v1.0              ^|
echo ^+============================================+
echo ^|  Select Programming Language:              ^|
echo ^|                                            ^|
echo ^|    [1] Python                              ^|
echo ^|    [2] Node.js                             ^|
echo ^|    [3] Java (Maven)                        ^|
echo ^|    [4] Go                                  ^|
echo ^|    [5] PHP (Composer)                      ^|
echo ^|    [6] Rust                                ^|
echo ^|    [0] Exit                                ^|
echo ^+============================================+
echo.
choice /c 0123456 /n /m "Enter option [0-6]: "
if %errorlevel%==1 exit /b 0
if %errorlevel%==2 goto python_menu
if %errorlevel%==3 goto nodejs_menu
if %errorlevel%==4 goto java_menu
if %errorlevel%==5 goto go_menu
if %errorlevel%==6 goto php_menu
if %errorlevel%==7 goto rust_menu
goto main_menu

:: ============================================================
:: Python Menu
:: ============================================================
:python_menu
cls
echo ^+--------------------------------------------+
echo ^|           Python Environment               ^|
echo ^+--------------------------------------------+
echo.
echo   [1] Change Mirror Source (pip)
echo   [2] Environment Check and Fix
echo   [3] Back to Main Menu
echo.
choice /c 123 /n /m "Enter option [1-3]: "
if %errorlevel%==1 goto python_source
if %errorlevel%==2 goto python_check
if %errorlevel%==3 goto main_menu
goto python_menu

:python_source
cls
echo ^+--------------------------------------------+
echo ^|         Python Mirror Source               ^|
echo ^+--------------------------------------------+
echo.
echo   [1] Tsinghua (Recommended)   pypi.tuna.tsinghua.edu.cn
echo   [2] Aliyun                  mirrors.aliyun.com/pypi/
echo   [3] USTC                    pypi.mirrors.ustc.edu.cn/
echo   [4] Douban                  pypi.douban.com/simple/
echo   [5] Huawei Cloud            repo.huaweicloud.com/repository/pypi
echo   [6] Official (Default)      pypi.org/simple
echo   [7] Back
echo.
choice /c 1234567 /n /m "Select mirror [1-7]: "
if %errorlevel%==7 goto python_menu
if %errorlevel%==1 set "PIP_SRC=https://pypi.tuna.tsinghua.edu.cn/simple" && set "SRC_NAME=Tsinghua"
if %errorlevel%==2 set "PIP_SRC=https://mirrors.aliyun.com/pypi/simple/" && set "SRC_NAME=Aliyun"
if %errorlevel%==3 set "PIP_SRC=https://pypi.mirrors.ustc.edu.cn/simple/" && set "SRC_NAME=USTC"
if %errorlevel%==4 set "PIP_SRC=https://pypi.douban.com/simple/" && set "SRC_NAME=Douban"
if %errorlevel%==5 set "PIP_SRC=https://repo.huaweicloud.com/repository/pypi/simple" && set "SRC_NAME=Huawei Cloud"
if %errorlevel%==6 set "PIP_SRC=https://pypi.org/simple" && set "SRC_NAME=Official(Default)"

echo.
echo Switching to %SRC_NAME% ...
echo.

pip config set global.index-url %PIP_SRC% 2>nul
if %errorlevel% neq 0 (
    echo [Backup method] Creating pip config file...
    if not exist "%USERPROFILE%\pip\" mkdir "%USERPROFILE%\pip\"
    echo [global] > "%USERPROFILE%\pip\pip.ini"
    echo index-url = %PIP_SRC% >> "%USERPROFILE%\pip\pip.ini"
    echo trusted-host = pypi.tuna.tsinghua.edu.cn mirrors.aliyun.com pypi.mirrors.ustc.edu.cn pypi.douban.com repo.huaweicloud.org >> "%USERPROFILE%\pip\pip.ini"
)

echo.
echo [OK] Successfully switched to %SRC_NAME%
echo     Current URL: %PIP_SRC%
echo.
pause
goto python_menu

:python_check
cls
echo ^+--------------------------------------------+
echo ^|       Python Environment Check             ^|
echo ^+--------------------------------------------+
echo.
set ERROR_COUNT=0
set FIX_COUNT=0

echo [Check 1/8] Python installation ...
python --version >nul 2>&1
if %errorlevel% neq 0 (
    echo   [FAIL] Python not installed!
    set /a ERROR_COUNT+=1
    echo   -> Download from https://www.python.org/downloads/
    echo   -> Check "Add Python to PATH" during install
) else (
    for /f "tokens=2 delims= " %%v in ('python --version 2^>^&1') do (
        echo   [OK] Python version: %%v
    )
)

echo.
echo [Check 2/8] pip package manager ...
pip --version >nul 2>&1
if %errorlevel% neq 0 (
    echo   [FAIL] pip not available!
    set /a ERROR_COUNT+=1
    echo   -> Try fix: python -m ensurepip --upgrade
    call python -m ensurepip --upgrade 2>nul
    if !errorlevel! equ 0 (
        echo   [OK] pip fixed!
        set /a FIX_COUNT+=1
    ) else (
        echo   [FAIL] Auto fix failed, please install manually
    )
) else (
    for /f "tokens=2 delims= " %%v in ('pip --version 2^>^&1') do (
        echo   [OK] pip version: %%v
    )
)

echo.
echo [Check 3/8] Current mirror source ...
for /f "tokens=3" %%s in ('pip config get global.index-url 2^>nul') do (
    echo   [OK] Current mirror: %%s
) 2>nul || (
    echo   [WARN] No custom mirror, using official (may be slow)
)

echo.
echo [Check 4/8] Python PATH ...
where python >nul 2>&1
if %errorlevel% equ 0 (
    echo   [OK] Python in PATH
) else (
    echo   [FAIL] Python not found in PATH
    set /a ERROR_COUNT+=1
    echo   -> Reinstall Python and check "Add to PATH"
)

echo.
echo [Check 5/8] Virtual env support (venv) ...
python -c "import venv" >nul 2>&1
if %errorlevel% equ 0 (
    echo   [OK] venv module available
) else (
    echo   [WARN] venv module unavailable
)

echo.
echo [Check 6/8] Build tools (setuptools, wheel) ...
python -c "import setuptools; import wheel" >nul 2>&1
if %errorlevel% equ 0 (
    echo   [OK] setuptools and wheel installed
) else (
    echo   [WARN] Missing setuptools or wheel
    echo   -> Installing: pip install setuptools wheel
    call pip install setuptools wheel -q 2>nul
    if !errorlevel! equ 0 (
        echo   [OK] Installed successfully
        set /a FIX_COUNT+=1
    ) else (
        echo   [FAIL] Install failed
    )
)

echo.
echo [Check 7/8] SSL/TLS support ...
python -c "import ssl; print('SSL:', ssl.OPENSSL_VERSION)" >nul 2>&1
if %errorlevel% equ 0 (
    for /f "tokens=2 delims=: " %%v in ('python -c "import ssl; print('SSL:', ssl.OPENSSL_VERSION)" 2^>^&1') do (
        echo   [OK] %%v
    )
) else (
    echo   [FAIL] SSL module error
    set /a ERROR_COUNT+=1
)

echo.
echo [Check 8/8] Disk space ...
for /f "tokens=3" %%s in ('wmic logicaldisk where "DeviceID='C:'" get FreeSpace /value ^| findstr "="') do (
    set FREE_SPACE=%%s
)
set /a FREE_GB=%FREE_SPACE:~0,-9%
if %FREE_GB% gtr 5 (
    echo   [OK] C: drive free space OK (~%FREE_GB% GB)
) else (
    echo   [WARN] C: drive low space (~%FREE_GB% GB)
    set /a ERROR_COUNT+=1
)

echo.
echo ^+--------------------------------------------+
echo ^| Done! Found %ERROR_COUNT% issues, fixed %FIX_COUNT% ^|
echo ^+--------------------------------------------+
echo.
pause
goto python_menu


:: ============================================================
:: Node.js Menu
:: ============================================================
:nodejs_menu
cls
echo ^+--------------------------------------------+
echo ^|          Node.js Environment               ^|
echo ^+--------------------------------------------+
echo.
echo   [1] Change Mirror Source (npm/yarn/pnpm)
echo   [2] Environment Check and Fix
echo   [3] Back to Main Menu
echo.
choice /c 123 /n /m "Enter option [1-3]: "
if %errorlevel%==1 goto nodejs_source
if %errorlevel%==2 goto nodejs_check
if %errorlevel%==3 goto main_menu
goto nodejs_menu

:nodejs_source
cls
echo ^+--------------------------------------------+
echo ^|       Node.js Mirror Source                ^|
echo ^+--------------------------------------------+
echo.
echo   [1] Taobao/NPMMirror (Recommended)  registry.npmmirror.com
echo   [2] Tencent Cloud                 mirrors.cloud.tencent.com/npm/
echo   [3] Huawei Cloud                   repo.huaweicloud.com/repository/npm/
echo   [4] Official (Default)             registry.npmjs.org
echo   [5] Back
echo.
choice /c 12345 /n /m "Select mirror [1-5]: "
if %errorlevel%==5 goto nodejs_menu
if %errorlevel%==1 set "NPM_SRC=https://registry.npmmirror.com" && set "NSRC_NAME=Taobao(NPMMirror)"
if %errorlevel%==2 set "NPM_SRC=https://mirrors.cloud.tencent.com/npm/" && set "NSRC_NAME=Tencent Cloud"
if %errorlevel%==3 set "NPM_SRC=https://repo.huaweicloud.com/repository/npm/" && set "NSRC_NAME=Huawei Cloud"
if %errorlevel%==4 set "NPM_SRC=https://registry.npmjs.org" && set "NSRC_NAME=Official(Default)"

echo.
echo Switching to %NSRC_NAME% ...

npm config set registry %NPM_SRC%
yarn config set registry %NPM_SRC% >nul 2>&1
pnpm config set registry %NPM_SRC% >nul 2>&1

echo.
echo [OK] npm switched to %NSRC_NAME%
call npm config get registry
echo.
where yarn >nul 2>&1 && echo [OK] Yarn also switched
where pnpm >nul 2>&1 && echo [OK] pnpm also switched
echo.
pause
goto nodejs_menu

:nodejs_check
cls
echo ^+--------------------------------------------+
echo ^|     Node.js Environment Check              ^|
echo ^+--------------------------------------------+
echo.
set ERROR_COUNT=0
set FIX_COUNT=0

echo [Check 1/8] Node.js installation ...
node --version >nul 2>&1
if %errorlevel% neq 0 (
    echo   [FAIL] Node.js not installed!
    set /a ERROR_COUNT+=1
    echo   -> Download LTS from https://nodejs.org
) else (
    for /f "tokens=*" %%v in ('node --version') do (
        echo   [OK] Node.js version: %%v
    )
)

echo.
echo [Check 2/8] npm package manager ...
npm --version >nul 2>&1
if %errorlevel% neq 0 (
    echo   [FAIL] npm not available!
    set /a ERROR_COUNT+=1
) else (
    for /f "tokens=*" %%v in ('npm --version') do (
        echo   [OK] npm version: %%v
    )
)

echo.
echo [Check 3/8] Current npm registry ...
for /f "tokens=*" %%r in ('npm config get registry 2^>^&1') do (
    echo   [OK] Current registry: %%r
    if "%%r"=="https://registry.npmjs.org/" (
        echo         (Official, may be slow in China)
    ) else (
        echo         (Using China mirror)
    )
)

echo.
echo [Check 4/8] npm global prefix ...
for /f "tokens=*" %%p in ('npm config get prefix 2^>^&1') do (
    echo   [OK] Global path: %%p
)

echo.
echo [Check 5/8] npm cache status ...
npm cache verify >nul 2>&1
if %errorlevel% equ 0 (
    echo   [OK] Cache OK
) else (
    echo   [WARN] Cache error, cleaning...
    npm cache clean --force >nul 2>&1
    echo   [OK] Cache cleaned
    set /a FIX_COUNT+=1
)

echo.
echo [Check 6/8] Common dev tools ...
where yarn >nul 2>&1 && echo   [OK] Yarn installed || echo   [WARN] Yarn not installed (optional)
where pnpm >nul 2>&1 && echo   [OK] pnpm installed || echo   [WARN] pnpm not installed (optional)
where npx >nul 2>&1 && echo   [OK] npx available || (echo   [FAIL] npx missing && set /a ERROR_COUNT+=1)

echo.
echo [Check 7/8] Global directory permission ...
for /f "tokens=*" %%p in ('npm config get prefix 2^>^&1') do (
    if exist "%%p" (
        echo test > "%%p\_perm_test_$$$.tmp" 2>nul && (
            del "%%p\_perm_test_$$$.tmp" >nul 2>&1
            echo   [OK] Global dir writable
        ) || (
            echo   [FAIL] Global dir not writable!
            set /a ERROR_COUNT+=1
            echo   -> Fix: npm config set prefix "%%APPDATA%%\npm"
        )
    )
)

echo.
echo [Check 8/8] Core module integrity ...
node -e "try{require('http');process.exit(0)}catch(e){process.exit(1)}" >nul 2>&1
if %errorlevel% equ 0 (
    echo   [OK] Core modules OK
) else (
    echo   [FAIL] Node.js may be corrupted
    set /a ERROR_COUNT+=1
)

echo.
echo ^+--------------------------------------------+
echo ^| Done! Found %ERROR_COUNT% issues, fixed %FIX_COUNT% ^|
echo ^+--------------------------------------------+
echo.
pause
goto nodejs_menu


:: ============================================================
:: Java (Maven) Menu
:: ============================================================
:java_menu
cls
echo ^+--------------------------------------------+
echo ^|       Java (Maven) Environment             ^|
echo ^+--------------------------------------------+
echo.
echo   [1] Change Mirror Source (Maven Repository)
echo   [2] Environment Check and Fix
echo   [3] Back to Main Menu
echo.
choice /c 123 /n /m "Enter option [1-3]: "
if %errorlevel%==1 goto java_source
if %errorlevel%==2 goto java_check
if %errorlevel%==3 goto main_menu
goto java_menu

:java_source
cls
echo ^+--------------------------------------------+
echo ^|        Maven Mirror Source                 ^|
echo ^+--------------------------------------------+
echo.
echo   [1] Aliyun (Recommended)      maven.aliyun.com
echo   [2] Huawei Cloud              repo.huaweicloud.com
echo   [3] Tencent Cloud             mirrors.cloud.tencent.com
echo   [4] Huawei Cloud (Gradle)     repo.huaweicloud.com
echo   [5] Back
echo.
choice /c 12345 /n /m "Select mirror [1-5]: "
if %errorlevel%==5 goto java_menu
if %errorlevel%==1 (
    set "MAVEN_MIRROR_ID=aliyunmaven"
    set "MAVEN_MIRROR_URL=https://maven.aliyun.com/repository/public"
    set "MSRC_NAME=Aliyun Public Repo"
)
if %errorlevel%==2 (
    set "MAVEN_MIRROR_ID=huawei-cloud"
    set "MAVEN_MIRROR_URL=https://repo.huaweicloud.com/repository/maven/"
    set "MSRC_NAME=Huawei Cloud Repo"
)
if %errorlevel%==3 (
    set "MAVEN_MIRROR_ID=tencent"
    set "MAVEN_MIRROR_URL=https://mirrors.cloud.tencent.com/nexus/repository/maven-public/"
    set "MSRC_NAME=Tencent Cloud Repo"
)
if %errorlevel%==4 (
    set "MAVEN_MIRROR_ID=huawei-gradle"
    set "MAVEN_MIRROR_URL=https://repo.huaweicloud.com/repository/gradle-plugin/"
    set "MSRC_NAME=Huawei Gradle Plugin Repo"
)

echo.
echo Configuring %MSRC_NAME% ...

set "MAVEN_SETTINGS="
if exist "%USERPROFILE%\.m2\settings.xml" set "MAVEN_SETTINGS=%USERPROFILE%\.m2\settings.xml"
if exist "%MAVEN_HOME%\conf\settings.xml" set "MAVEN_SETTINGS=%MAVEN_HOME%\conf\settings.xml"
if exist "%M2_HOME%\conf\settings.xml" set "MAVEN_SETTINGS=%M2_HOME%\conf\settings.xml"

if not defined MAVEN_SETTINGS (
    echo Maven settings.xml not found, creating new one...
    if not exist "%USERPROFILE%\.m2\" mkdir "%USERPROFILE%\.m2\"
    set "MAVEN_SETTINGS=%USERPROFILE%\.m2\settings.xml"
    (
        echo ^<?xml version="1.0" encoding="UTF-8"?^>
        echo ^<settings xmlns="http://maven.apache.org/SETTINGS/1.2.0"
        echo           xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
        echo           xsi:schemaLocation="http://maven.apache.org/SETTINGS/1.2.0"
        echo           https://maven.apache.org/xsd/settings-1.2.0.xsd"^>
        echo   ^<mirrors^>
        echo     ^<mirror^>
        echo       ^<id^>%MAVEN_MIRROR_ID%^</id^>
        echo       ^<mirrorOf^>central^</mirrorOf^>
        echo       ^<name^>%MSRC_NAME%^</name^>
        echo       ^<url^>%MAVEN_MIRROR_URL%^</url^>
        echo     ^</mirror^>
        echo   ^</mirrors^>
        echo ^</settings^>
    ) > "%MAVEN_SETTINGS%"
) else (
    echo Found settings.xml at: %MAVEN_SETTINGS%
    echo.
    echo Please manually edit settings.xml and add inside ^<mirrors^> tag:
    echo.
    echo   ^<mirror^>
    echo     ^<id^>%MAVEN_MIRROR_ID%^</id^>
    echo     ^<mirrorOf^>central^</mirrorOf^>
    echo     ^<name^>%MSRC_NAME%^</name^>
    echo     ^<url^>%MAVEN_MIRROR_URL%^</url^>
    echo   ^</mirror^>
    echo.
    echo File location: %MAVEN_SETTINGS%
)

echo.
echo [OK] %MSRC_NAME% config ready
echo     Mirror URL: %MAVEN_MIRROR_URL%
echo.
pause
goto java_menu

:java_check
cls
echo ^+--------------------------------------------+
echo ^|     Java (Maven) Environment Check         ^|
echo ^+--------------------------------------------+
echo.
set ERROR_COUNT=0
set FIX_COUNT=0

echo [Check 1/7] JAVA_HOME environment variable ...
if defined JAVA_HOME (
    echo   [OK] JAVA_HOME: %JAVA_HOME%
    if exist "%JAVA_HOME%\bin\java.exe" (
        echo   [OK] java.exe exists
    ) else (
        echo   [FAIL] JAVA_HOME points to invalid path
        set /a ERROR_COUNT+=1
    )
) else (
    echo   [FAIL] JAVA_HOME not set!
    set /a ERROR_COUNT+=1
    echo   -> Fix: setx JAVA_HOME "your-jdk-path"
)

echo.
echo [Check 2/7] Java version ...
java -version >nul 2>&1
if %errorlevel% equ 0 (
    for /f "tokens=3" %%v in ('java -version 2^>^&1 ^| findstr "version"') do (
        echo   [OK] Java version: %%~v
    )
) else (
    echo   [FAIL] Java not in PATH or not installed
    set /a ERROR_COUNT+=1
)

echo.
echo [Check 3/7] JDK compiler (javac) ...
javac -version >nul 2>&1
if %errorlevel% equ 0 (
    for /f "tokens=*" %%v in ('javac -version 2^>^&1') do (
        echo   [OK] javac version: %%v
    )
) else (
    echo   [WARN] javac not available (JRE instead of JDK?)
    echo   -> Development requires full JDK
)

echo.
echo [Check 4/7] Maven build tool ...
mvn --version >nul 2>&1
if %errorlevel% equ 0 (
    for /f "tokens=3" %%v in ('mvn --version 2^>^&1 ^| findstr "Apache Maven"') do (
        echo   [OK] Maven version: %%v
    )
) else (
    echo   [FAIL] Maven not installed or not in PATH
    set /a ERROR_COUNT+=1
    echo   -> Download: https://maven.apache.org/download.cgi
)

echo.
echo [Check 5/7] M2_HOME/MAVEN_HOME ...
if defined M2_HOME (
    echo   [OK] M2_HOME: %M2_HOME%
) else if defined MAVEN_HOME (
    echo   [OK] MAVEN_HOME: %MAVEN_HOME%
) else (
    echo   [WARN] M2_HOME/MAVEN_HOME not set (optional but recommended)
)

echo.
echo [Check 6/7] Maven local repository ...
if exist "%USERPROFILE%\.m2\repository" (
    echo   [OK] Local repo exists: %USERPROFILE%\.m2\repository
) else (
    echo   [WARN] Local repo not created yet (auto-created on first mvn run)
)

echo.
echo [Check 7/7] JVM memory ...
for /f "tokens=2 delims==" %%m in ('wmic OS get TotalVisibleMemorySize /value 2^>nul ^| find "="') do (
    set /a RAM_MB=%%m/1024
)
if %RAM_MB% gtr 8000 (
    echo   [OK] System RAM: ~%RAM_MB% MB (enough)
) else (
    echo   [WARN] Low RAM: ~%RAM_MB% MB
    echo   -> Set MAVEN_OPTS: -Xmx512m
)

echo.
echo ^+--------------------------------------------+
echo ^| Done! Found %ERROR_COUNT% issues, fixed %FIX_COUNT% ^|
echo ^+--------------------------------------------+
echo.
pause
goto java_menu


:: ============================================================
:: Go Menu
:: ============================================================
:go_menu
cls
echo ^+--------------------------------------------+
echo ^|           Go Environment                   ^|
echo ^+--------------------------------------------+
echo.
echo   [1] Change Mirror Source (Go Module Proxy)
echo   [2] Environment Check and Fix
echo   [3] Back to Main Menu
echo.
choice /c 123 /n /m "Enter option [1-3]: "
if %errorlevel%==1 goto go_source
if %errorlevel%==2 goto go_check
if %errorlevel%==3 goto main_menu
goto go_menu

:go_source
cls
echo ^+--------------------------------------------+
echo ^|        Go Module Proxy Selection           ^|
echo ^+--------------------------------------------+
echo.
echo   [1] Qiniu (Recommended)     goproxy.cn
echo   [2] Aliyun                  mirrors.aliyun.com/goproxy/
echo   [3] Official Proxy (Global) proxy.golang.org
echo   [4] Direct (No Proxy)       off
echo   [5] Back
echo.
choice /c 12345 /n /m "Select proxy [1-5]: "
if %errorlevel%==5 goto go_menu
if %errorlevel%==1 set "GO_PROXY=https://goproxy.cn,direct" && set "GSRC_NAME=Qiniu(goproxy.cn)"
if %errorlevel%==2 set "GO_PROXY=https://mirrors.aliyun.com/goproxy/,direct" && set "GSRC_NAME=Aliyun"
if %errorlevel%==3 set "GO_PROXY=https://proxy.golang.org,direct" && set "GSRC_NAME=Official Proxy"
if %errorlevel%==4 set "GO_PROXY=off" && set "GSRC_NAME=Direct Connection(Proxy Off)"

echo.
echo Switching to %GSRC_NAME% ...
go env -w GOPROXY=%GO_PROXY%
go env -w GO111MODULE=on

echo.
echo [OK] Switched to %GSRC_NAME%
echo     Current GOPROXY: %GO_PROXY%
echo.
pause
goto go_menu

:go_check
cls
echo ^+--------------------------------------------+
echo ^|         Go Environment Check               ^|
echo ^+--------------------------------------------+
echo.
set ERROR_COUNT=0
set FIX_COUNT=0

echo [Check 1/7] Go installation ...
go version >nul 2>&1
if %errorlevel% neq 0 (
    echo   [FAIL] Go not installed or not in PATH!
    set /a ERROR_COUNT+=1
    echo   -> Download: https://go.dev/dl/
) else (
    for /f "tokens=3" %%v in ('go version') do (
        echo   [OK] Go version: %%v
    )
)

echo.
echo [Check 2/7] GOPATH ...
for /f "tokens=*" %%p in ('go env GOPATH 2^>^&1') do (
    echo   [OK] GOPATH: %%p
    if exist "%%p" (
        echo   [OK] GOPATH dir exists
    ) else (
        echo   [WARN] GOPATH dir missing, will auto-create
        mkdir "%%p" 2>nul && echo   [OK] Created
    )
)

echo.
echo [Check 3/7] GOROOT ...
for /f "tokens=*" %%r in ('go env GOROOT 2^>^&1') do (
    echo   [OK] GOROOT: %%r
)

echo.
echo [Check 4/7] GOPROXY setting ...
for /f "tokens=*" %%p in ('go env GOPROXY 2^>^&1') do (
    echo   [OK] GOPROXY: %%p
)

echo.
echo [Check 5/7] GO111MODULE mode ...
for /f "tokens=*" %%m in ('go env GO111MODULE 2^>^&1') do (
    echo   [OK] GO111MODULE: %%m
    if not "%%m"=="on" (
        echo   -> Enable module mode: go env -w GO111MODULE=on
    )
)

echo.
echo [Check 6/7] Go toolchain integrity ...
go fmt -h >nul 2>&1 && echo   [OK] go fmt works || (echo   [FAIL] go fmt broken && set /a ERROR_COUNT+=1)
go vet -h >nul 2>&1 && echo   [OK] go vet works || (echo   [FAIL] go vet broken && set /a ERROR_COUNT+=1)
go build -h >nul 2>&1 && echo   [OK] go build works || (echo   [FAIL] go build broken && set /a ERROR_COUNT+=1)

echo.
echo [Check 7/7] Proxy connectivity ...
ping -n 1 goproxy.cn >nul 2>&1
if %errorlevel% equ 0 (
    echo   [OK] goproxy.cn reachable
) else (
    echo   [WARN] goproxy.cn unreachable, check network or change proxy
)

echo.
echo ^+--------------------------------------------+
echo ^| Done! Found %ERROR_COUNT% issues, fixed %FIX_COUNT% ^|
echo ^+--------------------------------------------+
echo.
pause
goto go_menu


:: ============================================================
:: PHP (Composer) Menu
:: ============================================================
:php_menu
cls
echo ^+--------------------------------------------+
echo ^|        PHP (Composer) Environment          ^|
echo ^+--------------------------------------------+
echo.
echo   [1] Change Mirror Source (Composer)
echo   [2] Environment Check and Fix
echo   [3] Back to Main Menu
echo.
choice /c 123 /n /m "Enter option [1-3]: "
if %errorlevel%==1 goto php_source
if %errorlevel%==2 goto php_check
if %errorlevel%==3 goto main_menu
goto php_menu

:php_source
cls
echo ^+--------------------------------------------+
echo ^|        Composer Mirror Source             ^|
echo ^+--------------------------------------------+
echo.
echo   [1] Aliyun (Recommended)     mirrors.aliyun.com/composer/
echo   [2] Tencent Cloud            mirrors.cloud.tencent.com/composer/
echo   [3] Huawei Cloud             repo.huaweicloud.com/repository/php
echo   [4] Official (Default)       packagist.org
echo   [5] Back
echo.
choice /c 12345 /n /m "Select mirror [1-5]: "
if %errorlevel%==5 goto php_menu
if %errorlevel%==1 set "COMP_SRC=https://mirrors.aliyun.com/composer/" && set "CSRC_NAME=Aliyun"
if %errorlevel%==2 set "COMP_SRC=https://mirrors.cloud.tencent.com/composer/" && set "CSRC_NAME=Tencent Cloud"
if %errorlevel%==3 set "COMP_SRC=https://repo.huaweicloud.com/repository/php" && set "CSRC_NAME=Huawei Cloud"
if %errorlevel%==4 set "COMP_SRC=https://packagist.org" && set "CSRC_NAME=Official(Packagist)"

echo.
echo Switching to %CSRC_NAME% ...
composer config -g repo.packagist composer %COMP_SRC%

echo.
echo [OK] Composer switched to %CSRC_NAME%
composer config -g repositories.packagist composer %COMP_SRC%
echo.
pause
goto php_menu

:php_check
cls
echo ^+--------------------------------------------+
echo ^|     PHP (Composer) Environment Check       ^|
echo ^+--------------------------------------------+
echo.
set ERROR_COUNT=0
set FIX_COUNT=0

echo [Check 1/6] PHP installation ...
php --version >nul 2>&1
if %errorlevel% neq 0 (
    echo   [FAIL] PHP not installed or not in PATH!
    set /a ERROR_COUNT+=1
) else (
    for /f "tokens=2 delims= " %%v in ('php -v 2^>^&1 ^| findstr /i "PHP"') do (
        echo   [OK] PHP version: %%v
    )
)

echo.
echo [Check 2/6] Composer package manager ...
composer --version >nul 2>&1
if %errorlevel% neq 0 (
    echo   [FAIL] Composer not installed!
    set /a ERROR_COUNT+=1
    echo   -> Install: php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
    echo               php composer-setup.php
) else (
    for /f "tokens=1-3 delims= " %%a in ('composer --version 2^>^&1') do (
        echo   [OK] Composer %%a %%b %%c
    )
)

echo.
echo [Check 3/6] Current Composer mirror ...
for /f "tokens=*" %%s in ('composer config -g repositories.packagist.org composer 2^>nul') do (
    echo   [OK] Current mirror: %%s
) 2>nul || (
    echo   [WARN] Using default official (packagist.org)
)

echo.
echo [Check 4/6] Key PHP extensions ...
php -m 2>nul | findstr /i "openssl" >nul && echo   [OK] openssl extension || (echo   [FAIL] Missing openssl && set /a ERROR_COUNT+=1)
php -m 2>nul | findstr /i "mbstring" >nul && echo   [OK] mbstring extension || echo   [WARN] Missing mbstring
php -m 2>nul | findstr /i "fileinfo" >nul && echo   [OK] fileinfo extension || echo   [WARN] Missing fileinfo
php -m 2>nul | findstr /i "curl" >nul && echo   [OK] curl extension || echo   [WARN] Missing curl

echo.
echo [Check 5/6] PHP memory limit ...
for /f "tokens=2 delims== " %%m in ('php -i 2^>nul ^| findstr /i "memory_limit"') do (
    echo   [OK] memory_limit: %%m
)

echo.
echo [Check 6/6] PHP timezone ...
php -r "echo date_default_timezone_get();" 2>nul
if %errorlevel% equ 0 (
    for /f %%z in ('php -r "echo date_default_timezone_get();" 2^>nul') do (
        if "%%z"=="UTC" (
            echo   [WARN] Timezone is UTC, recommend Asia/Shanghai
        ) else (
            echo   [OK] Timezone: %%z
        )
    )
)

echo.
echo ^+--------------------------------------------+
echo ^| Done! Found %ERROR_COUNT% issues, fixed %FIX_COUNT% ^|
echo ^+--------------------------------------------+
echo.
pause
goto php_menu


:: ============================================================
:: Rust Menu
:: ============================================================
:rust_menu
cls
echo ^+--------------------------------------------+
echo ^|           Rust Environment                 ^|
echo ^+--------------------------------------------+
echo.
echo   [1] Change Mirror Source (crates.io)
echo   [2] Environment Check and Fix
echo   [3] Back to Main Menu
echo.
choice /c 123 /n /m "Enter option [1-3]: "
if %errorlevel%==1 goto rust_source
if %errorlevel%==2 goto rust_check
if %errorlevel%==3 goto main_menu
goto rust_menu

:rust_source
cls
echo ^+--------------------------------------------+
echo ^|       Rust/Cargo Mirror Source             ^|
echo ^+--------------------------------------------+
echo.
echo   [1] Tsinghua (Recommended)   mirrors.tuna.tsinghua.edu.cn
echo   [2] USTC                    mirrors.ustc.edu.cn
echo   [3] ByteDance (rsproxy)     rsproxy.cn
echo   [4] Official (Default)      crates.io
echo   [5] Back
echo.
choice /c 12345 /n /m "Select mirror [1-5]: "
if %errorlevel%==5 goto rust_menu
if %errorlevel%==1 set "RSRC_NAME=Tsinghua"
if %errorlevel%==2 set "RSRC_NAME=USTC"
if %errorlevel%==3 set "RSRC_NAME=ByteDance(rsproxy)"
if %errorlevel%==4 set "RSRC_NAME=Official(Default)"

if not exist "%USERPROFILE%\.cargo\" mkdir "%USERPROFILE%\.cargo\"

if %errorlevel%==1 (
    (
        echo [source.crates-io]
        echo replace-with = 'tsinghua'
        echo.
        echo [source.tsinghua]
        echo registry = "sparse+https://mirrors.tuna.tsinghua.edu.cn/crates.io-index/"
    ) > "%USERPROFILE%\.cargo\config.toml"
)
if %errorlevel%==2 (
    (
        echo [source.crates-io]
        echo replace-with = 'ustc'
        echo.
        echo [source.ustc]
        echo registry = "sparse+https://mirrors.ustc.edu.cn/crates.io-index/"
    ) > "%USERPROFILE%\.cargo\config.toml"
)
if %errorlevel%==3 (
    (
        echo [source.crates-io]
        echo replace-with = 'rsproxy'
        echo.
        echo [source.rsproxy]
        echo registry = "https://rsproxy.cn/crates.io-index"
        echo.
        echo [registries.rsproxy]
        echo index = "https://rsproxy.cn/crates.io-index"
        echo.
        echo [net]
        echo git-fetch-with-cli = true
    ) > "%USERPROFILE%\.cargo\config.toml"
)
if %errorlevel%==4 (
    if exist "%USERPROFILE%\.cargo\config.toml" (
        del "%USERPROFILE%\.cargo\config.toml"
        echo [OK] Removed mirror config, using official source
    ) else (
        echo [OK] Already using default
    )
    pause
    goto rust_menu
)

echo.
echo [OK] Switched to %RSRC_NAME%
echo     Config file: %USERPROFILE%\.cargo\config.toml
echo.
pause
goto rust_menu

:rust_check
cls
echo ^+--------------------------------------------+
echo ^|         Rust Environment Check             ^|
echo ^+--------------------------------------------+
echo.
set ERROR_COUNT=0
set FIX_COUNT=0

echo [Check 1/6] Rust installation ...
rustc --version >nul 2>&1
if %errorlevel% neq 0 (
    echo   [FAIL] Rust not installed!
    set /a ERROR_COUNT+=1
    echo   -> Install: rustup-init.exe (https://rustup.rs/)
) else (
    for /f "tokens=*" %%v in ('rustc --version') do (
        echo   [OK] Rust version: %%v
    )
)

echo.
echo [Check 2/6] Cargo package manager ...
cargo --version >nul 2>&1
if %errorlevel% neq 0 (
    echo   [FAIL] Cargo not available!
    set /a ERROR_COUNT+=1
) else (
    for /f "tokens=*" %%v in ('cargo --version') do (
        echo   [OK] %%v
    )
)

echo.
echo [Check 3/6] Rust toolchain manager (rustup) ...
rustup --version >nul 2>&1
if %errorlevel% equ 0 (
    for /f "tokens=*" %%v in ('rustup --version') do (
        echo   [OK] %%v
    )
    echo.
    echo   Installed toolchains:
    rustup show 2>nul | findstr /i "toolchain"
) else (
    echo   [FAIL] rustup not installed
    set /a ERROR_COUNT+=1
)

echo.
echo [Check 4/6] Cargo mirror config ...
if exist "%USERPROFILE%\.cargo\config.toml" (
    echo   [OK] Custom config detected
    type "%USERPROFILE%\.cargo\config.toml" | findstr /i "replace-with" >nul && (
        echo   [OK] Using China mirror
    ) || (
        echo   [INFO] Config exists but no mirror replacement
    )
) else (
    echo   [INFO] Using official crates.io (may be slow)
)

echo.
echo [Check 5/6] Default build target ...
rustup show active-toolchain >nul 2>&1
if %errorlevel% equ 0 (
    for /f "tokens=*" %%t in ('rustup show active-toolchain 2^>^&1') do (
        echo   [OK] Active toolchain: %%t
    )
)

echo.
echo [Check 6/6] Rust component completeness ...
rustup component list --installed 2>nul | find /c "." >nul
echo   Installed components:
rustup component list --installed 2>nul
echo.
rustup component list 2>nul | findstr /i "rls rust-analyzer rustfmt clippy" | findstr "(installed)" >nul || (
    echo   -> Recommended: rustup component add rls rust-analysis rustfmt clippy
)

echo.
echo ^+--------------------------------------------+
echo ^| Done! Found %ERROR_COUNT% issues, fixed %FIX_COUNT% ^|
echo ^+--------------------------------------------+
echo.
pause
goto rust_menu