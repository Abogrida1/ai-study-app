@echo off
setlocal
cd /d "%~dp0"

if not defined FLUTTER_ROOT set "FLUTTER_ROOT=C:\Users\hacker\Desktop\mobile apps\flutter"
set "FLUTTER=%FLUTTER_ROOT%\bin\flutter.bat"

if not exist "%FLUTTER%" (
  echo [خطأ] لم يُعثر على Flutter هنا:
  echo   %FLUTTER%
  echo عدّل FLUTTER_ROOT داخل هذا الملف أو عرّفه في البيئة.
  pause
  exit /b 1
)

echo تشغيل: pub get ...
call "%FLUTTER%" pub get
if errorlevel 1 (
  if not defined NO_PAUSE pause
  exit /b 1
)

echo تشغيل التطبيق على Chrome ...
call "%FLUTTER%" run -d chrome
if errorlevel 1 (
  if not defined NO_PAUSE pause
  exit /b 1
)
if not defined NO_PAUSE pause
