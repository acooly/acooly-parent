@echo off
title Deployment Project
echo [ACOOLY] Deploy module with pom.xml to local and remote repository.

set curdir=%~dp0
set partition=%curdir:~0,1%
%partition%:
cd %curdir%

rem if not exist pom.xml in current directory , then 'cd' parent directory
if not exist pom.xml cd..

set module_home=%cd%
echo [ACOOLY] The module location: %module_home%
echo.

call mvn -Pyiji-dev clean deploy -Dmaven.test.skip=true

echo.
echo [ACOOLY] deploy finished
pause