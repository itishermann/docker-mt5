#!/bin/bash

# Copyright 2022, MetaQuotes Ltd.

# MetaTrader download url
URL="https://download.mql5.com/cdn/web/metaquotes.software.corp/mt5/mt5setup.exe"
# Wine version to install: stable or devel
WINE_VERSION="stable"

# Prepare: switch to 32 bit and add Wine key
sudo dpkg --add-architecture i386
wget -nc https://dl.winehq.org/wine-builds/winehq.key
sudo mv winehq.key /usr/share/keyrings/winehq-archive.key

# Get Ubuntu version and trim to major only
OS_VER=$(lsb_release -r |cut -f2 |cut -d "." -f1)
# Choose repository based on Ubuntu version
if (( $OS_VER >= 22)); then
  wget -nc https://dl.winehq.org/wine-builds/ubuntu/dists/jammy/winehq-jammy.sources
  sudo mv winehq-jammy.sources /etc/apt/sources.list.d/
elif (( $OS_VER < 22 )) && (( $OS_VER >= 21 )); then
  wget -nc https://dl.winehq.org/wine-builds/ubuntu/dists/impish/winehq-impish.sources
  sudo mv winehq-impish.sources /etc/apt/sources.list.d/
elif (( $OS_VER < 21 )) && (( $OS_VER >=20 )); then
  wget -nc https://dl.winehq.org/wine-builds/ubuntu/dists/focal/winehq-focal.sources
  sudo mv winehq-focal.sources /etc/apt/sources.list.d/
elif (( $OS_VER < 20 )); then
  wget -nc https://dl.winehq.org/wine-builds/ubuntu/dists/bionic/winehq-bionic.sources
  sudo mv winehq-bionic.sources /etc/apt/sources.list.d/
fi

# Update package and install Wine
sudo apt update
sudo apt upgrade
sudo apt install --install-recommends winehq-$WINE_VERSION

# Download MetaTrader
wget $URL

# Set environment to Windows 10
WINEPREFIX=~/.mt5 winecfg -v=win10
# Start MetaTrader installer
WINEPREFIX=~/.mt5 wine mt5setup.exe
