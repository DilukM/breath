#!/bin/bash

# 🌬️ Breathe App - Quick Setup Script

echo "🌬️  Setting up Breathe App..."
echo ""

# Check Flutter installation
echo "✅ Checking Flutter installation..."
if ! command -v flutter &> /dev/null
then
    echo "❌ Flutter not found. Please install Flutter first:"
    echo "   https://docs.flutter.dev/get-started/install"
    exit 1
fi

echo "✅ Flutter found!"
flutter --version
echo ""

# Get dependencies
echo "📦 Installing dependencies..."
flutter pub get
echo ""

# Check for issues
echo "🔍 Running Flutter doctor..."
flutter doctor
echo ""

# Optional: Generate Hive adapters
read -p "🔨 Generate Hive adapters? (y/n) " -n 1 -r
echo ""
if [[ $REPLY =~ ^[Yy]$ ]]
then
    echo "🔨 Generating Hive adapters..."
    flutter pub run build_runner build --delete-conflicting-outputs
    echo ""
fi

# List available devices
echo "📱 Available devices:"
flutter devices
echo ""

# Ask to run
read -p "🚀 Run the app now? (y/n) " -n 1 -r
echo ""
if [[ $REPLY =~ ^[Yy]$ ]]
then
    echo "🚀 Starting app..."
    flutter run
else
    echo ""
    echo "✅ Setup complete!"
    echo ""
    echo "To run the app later, use:"
    echo "  flutter run"
    echo ""
    echo "For more info, see:"
    echo "  README.md - Project overview"
    echo "  DEVELOPMENT.md - Development guide"
    echo ""
fi
