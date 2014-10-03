IF exist tools ( echo ... ) ELSE ( mkdir tools )
del tools\*.*  /F /Q
bin\curl -L -o tools\kpcli.exe http://downloads.sourceforge.net/project/kpcli/kpcli-2.7.exe
bin\curl -L -o tools\curl.zip http://curl.haxx.se/gknw.net/7.34.0/dist-w32/curl-7.34.0-rtmp-ssh2-ssl-sspi-zlib-idn-static-bin-w32.zip
bin\7za.exe e tools\curl.zip -otools\curl
del tools\curl.zip /F /Q