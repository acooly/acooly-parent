@echo off
echo [INFO] Install parent pom.xml to maven repository.

cd %~dp0
set profile=
set /P profile=maven profile(def: acooly[yiji_dev,yiji_online]): %=%
if defined profile (set profile=%profile%) else set profile=acooly
echo [INFO] Chose maven profile: %profile%
call mvn clean deploy -Dmaven.test.skip=true -P%profile%
pause