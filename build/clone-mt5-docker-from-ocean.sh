rm -Rf /home/sander/projects/docker-mt5/testdata
mkdir -p /home/sander/projects/docker-mt5/testdata/dark-venus
mkdir -p /home/sander/projects/docker-mt5/testdata/ticker-beats
cp -R /home/sander/projects/MT5-on-Docker/Metatrader/* /home/sander/projects/docker-mt5/testdata/dark-venus/
cp -R /home/sander/projects/MT5-on-Docker/Metatrader/* /home/sander/projects/docker-mt5/testdata/ticker-beats/
rm -R /home/sander/projects/docker-mt5/testdata/dark-venus/MQL5
rm -R /home/sander/projects/docker-mt5/testdata/ticker-beats/MQL5