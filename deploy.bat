@echo off
echo [INFO] Install parent pom.xml to local repository.

cd %~dp0
call mvn clean deploy -Dmaven.test.skip=true
pause