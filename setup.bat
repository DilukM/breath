@echo off
REM 🌬️ Breathe App - Quick Setup Script for Windows

echo 🌬️  Setting up Breathe App...
echo.

REM Check Flutter installation
echo ✅ Checking Flutter installation...
where flutter >nul 2>nul
if %errorlevel% neq 0 (
    echo ❌ Flutter not found. Please install Flutter first:
    echo    https://docs.flutter.dev/get-started/install
    exit /b 1
)

echo ✅ Flutter found!
flutter --version
echo.

REM Get dependencies
echo 📦 Installing dependencies...
flutter pub get
echo.

REM Check for issues
echo 🔍 Running Flutter doctor...
flutter doctor
echo.

REM Ask to generate Hive adapters
set /p generate="🔨 Generate Hive adapters? (y/n): "
if /i "%generate%"=="y" (
    echo 🔨 Generating Hive adapters...
    flutter pub run build_runner build --delete-conflicting-outputs
    echo.
)

REM List available devices
echo 📱 Available devices:
flutter devices
echo.

REM Ask to run
set /p run="🚀 Run the app now? (y/n): "
if /i "%run%"=="y" (
    echo 🚀 Starting app...
    flutter run
) else (
    echo.
    echo ✅ Setup complete!
    echo.
    echo To run the app later, use:
    echo   flutter run
    echo.
    echo For more info, see:
    echo   README.md - Project overview
    echo   DEVELOPMENT.md - Development guide
    echo.
)
