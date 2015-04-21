@ECHO OFF
echo Create server.cfg with using address %COMPUTERNAME%.localhost ...
echo Delete old server.cfg
del /s /q server.cfg>nul
echo Write new server.cfg...
start /B substitude.cmd YOUR_PC_NAME_HERE "%COMPUTERNAME%" serverExample.txt>server.cfg
echo ...done
echo Create client.cfg with using address %COMPUTERNAME%.localhost ...
echo Delete old client.cfg
del /s /q client.cfg>nul
echo Write new client.cfg
start /B substitude.cmd YOUR_PC_NAME_HERE "%COMPUTERNAME%" clientExample.txt>client.cfg
echo ...done
ping 1.1.1.1 -n 1 -w 1000 > nul


