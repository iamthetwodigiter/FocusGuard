#!/bin/bash

# FocusGuard Installer Script for Linux/macOS
# Manages ADB setup, APK selection from GitHub, and installation.

set -e

echo "------------------------------------------------"
echo "   FocusGuard APK Installer (Linux/macOS)"
echo "------------------------------------------------"

# 1. Check for ADB
ADB_BIN="adb"
if ! command -v adb &> /dev/null; then
    if [ -f "./platform-tools/adb" ]; then
        ADB_BIN="./platform-tools/adb"
    else
        echo "ADB not found in PATH or ./platform-tools/."
        echo "Attempting to download platform-tools..."
        
        PLATFORM="linux"
        if [[ "$OSTYPE" == "darwin"* ]]; then
            PLATFORM="darwin"
        fi
        
        URL="https://dl.google.com/android/repository/platform-tools-latest-${PLATFORM}.zip"
        
        if command -v curl &> /dev/null; then
            curl -L -o platform-tools.zip "$URL"
        elif command -v wget &> /dev/null; then
            wget -O platform-tools.zip "$URL"
        else
            echo "Error: Neither curl nor wget found. Please install platform-tools manually."
            exit 1
        fi
        
        unzip -q platform-tools.zip
        rm platform-tools.zip
        ADB_BIN="./platform-tools/adb"
        chmod +x "$ADB_BIN"
    fi
fi

# 2. Fetch Latest Release from GitHub
REPO="iamthetwodigiter/FocusGuard"
echo "Fetching latest releases from GitHub..."

RELEASE_DATA=$(curl -s "https://api.github.com/repos/$REPO/releases/latest")

if echo "$RELEASE_DATA" | jq -e '.message' &>/dev/null; then
    MSG=$(echo "$RELEASE_DATA" | jq -r '.message')
    echo "GitHub API Note: $MSG (Might be no releases yet)"
    echo "Checking for local APKs..."
    APK_PATH=$(ls *.apk 2>/dev/null | head -n 1 || true)
    if [ -n "$APK_PATH" ]; then
        echo "Found local APK: $APK_PATH"
    else
        echo "No APK found. Please build the project or create a release on GitHub."
        exit 1
    fi
else
    # Parse assets into a list of name|url
    ASSETS=$(echo "$RELEASE_DATA" | jq -r '.assets[] | select(.name | endswith(".apk")) | "\(.name)|\(.browser_download_url)"')

    if [ -z "$ASSETS" ]; then
        echo "No APK assets found in the latest GitHub release."
        APK_PATH=$(ls *.apk 2>/dev/null | head -n 1 || true)
        if [ -n "$APK_PATH" ]; then
            echo "Found local APK: $APK_PATH"
        else
            echo "No APK found."
            exit 1
        fi
    else
        # Split into arrays manually for better compatibility
        i=0
        while IFS='|' read -r name url; do
            NAMES[i]=$name
            URLS[i]=$url
            i=$((i+1))
        done <<< "$ASSETS"

        echo "Latest Release Assets:"
        for j in "${!NAMES[@]}"; do
            echo "$((j+1))) ${NAMES[$j]}"
        done

        if [ ${#NAMES[@]} -eq 1 ]; then
            CHOICE=1
        else
            printf "Select an APK to install (1-%d): " "${#NAMES[@]}"
            read -r CHOICE
        fi

        IDX=$((CHOICE-1))
        APK_NAME="${NAMES[$IDX]}"
        APK_URL="${URLS[$IDX]}"
        APK_PATH="./$APK_NAME"

        if [ -f "$APK_PATH" ]; then
            printf "APK '%s' already exists. Re-download? (y/N): " "$APK_NAME"
            read -r REDOWNLOAD
            if [ "$REDOWNLOAD" = "y" ] || [ "$REDOWNLOAD" = "Y" ]; then
                echo "Downloading $APK_NAME..."
                curl -L -o "$APK_PATH" "$APK_URL"
            fi
        else
            echo "Downloading $APK_NAME..."
            curl -L -o "$APK_PATH" "$APK_URL"
        fi
    fi
fi

# 3. Check for Devices
echo "Checking for connected devices..."
DEVICE_COUNT=$($ADB_BIN devices | grep -v "List" | grep "device$" | wc -l)

if [ "$DEVICE_COUNT" -eq 0 ]; then
    echo "------------------------------------------------"
    echo "❌ No Android devices found."
    echo "Please:"
    echo "  1. Connect your phone via USB"
    echo "  2. Enable 'USB Debugging' in Developer Options"
    echo "  3. Accept the debugging prompt on your phone"
    echo "------------------------------------------------"
    exit 1
fi

# 4. Install
echo "Installing '$APK_PATH'..."
$ADB_BIN install -r "$APK_PATH"

if [ $? -eq 0 ]; then
    echo "------------------------------------------------"
    echo "✅ Success! FocusGuard installed successfully."
    echo "------------------------------------------------"
else
    echo "------------------------------------------------"
    echo "❌ Error: Failed to install APK."
    echo "------------------------------------------------"
    exit 1
fi

exit 0