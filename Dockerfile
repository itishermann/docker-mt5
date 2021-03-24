FROM solarkennedy/wine-x11-novnc-docker
ENV WINEPREFIX /root/prefix64
ENV WINEARCH win64
COPY ["MetaTrader 5", "/root/prefix64/drive_c/Program Files/MetaTrader 5"]
COPY ./supervisord.conf /etc/supervisor/conf.d/supervisord.conf
EXPOSE 8080