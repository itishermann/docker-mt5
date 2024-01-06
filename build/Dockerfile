FROM solarkennedy/wine-x11-novnc-docker
ENV WINEPREFIX /home/ubuntu/prefix64
ENV WINEARCH win64

RUN apt update 
RUN apt full-upgrade -y
RUN apt install nano vim curl unzip -y
RUN apt clean
COPY ./metatrader5.zip /root/
RUN unzip -q /root/metatrader5.zip -d /root/
RUN rm /root/metatrader5.zip

RUN apt autoremove -y

EXPOSE 8080