IF exist tools ( echo ... ) ELSE ( mkdir tools )
del tools\*.*  /F /Q
bin\curl -L -o tools\kpcli.exe http://downloads.sourceforge.net/project/kpcli/kpcli-2.7.exe

rmdir /Q /S tools\curl
bin\curl -L -o tools\curl.zip http://curl.haxx.se/gknw.net/7.34.0/dist-w32/curl-7.34.0-rtmp-ssh2-ssl-sspi-zlib-idn-static-bin-w32.zip
bin\7za.exe e tools\curl.zip -otools\curl -aoa
del tools\curl.zip /F /Q

bin\curl -L -o tools\wget.exe http://users.ugent.be/~bpuype/cgi-bin/fetch.pl?dl=wget/wget.exe

bin\curl -L -J -o tools\fnr.exe http://download-codeplex.sec.s-msft.com/Download/Release?ProjectName=findandreplace&DownloadId=851369&FileTime=130458305187130000&Build=20941