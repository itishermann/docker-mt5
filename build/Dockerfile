FROM solarkennedy/wine-x11-novnc-docker
ENV WINEPREFIX /home/ubuntu/prefix64
ENV WINEARCH win64

# # MetaTrader download url
# ENV URL="https://download.mql5.com/cdn/web/metaquotes.software.corp/mt5/mt5setup.exe"
# # Wine version to install: stable or devel
# ENV WINE_VERSION="stable"

# # Prepare: switch to 32 bit and add Wine key
# RUN dpkg --add-architecture i386 \
#     && apt-get update \
#     && apt-get install -y wget gnupg2 software-properties-common \
#     && wget -nc https://dl.winehq.org/wine-builds/winehq.key \
#     && apt-key add winehq.key \
#     && rm winehq.key

# # Get Ubuntu version and trim to major only
# RUN OS_VER=$(lsb_release -r | cut -f2 | cut -d "." -f1) \
#     && if (( $OS_VER >= 22)); then \
#          wget -nc https://dl.winehq.org/wine-builds/ubuntu/dists/jammy/winehq-jammy.sources \
#          && mv winehq-jammy.sources /etc/apt/sources.list.d/; \
#        elif (( $OS_VER < 22 )) && (( $OS_VER >= 21 )); then \
#          wget -nc https://dl.winehq.org/wine-builds/ubuntu/dists/impish/winehq-impish.sources \
#          && mv winehq-impish.sources /etc/apt/sources.list.d/; \
#        elif (( $OS_VER < 21 )) && (( $OS_VER >=20 )); then \
#          wget -nc https://dl.winehq.org/wine-builds/ubuntu/dists/focal/winehq-focal.sources \
#          && mv winehq-focal.sources /etc/apt/sources.list.d/; \
#        elif (( $OS_VER < 20 )); then \
#          wget -nc https://dl.winehq.org/wine-builds/ubuntu/dists/bionic/winehq-bionic.sources \
#          && mv winehq-bionic.sources /etc/apt/sources.list.d/; \
#        fi

# # Update package and install Wine
# RUN apt-get update \
#     && apt-get upgrade -y \
#     && apt-get install -y --install-recommends winehq-$WINE_VERSION

# # Download MetaTrader
# RUN wget $URL

# # Set environment to Windows 10
# RUN WINEPREFIX=~/.mt5 winecfg -v=win10

# # Start MetaTrader installer
# CMD ["WINEPREFIX=~/.mt5", "wine", "mt5setup.exe"]

EXPOSE 8080