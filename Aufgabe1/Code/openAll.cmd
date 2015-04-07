@ECHO off
ECHO Start HBQ...
start werl -name hbq -setcookie zumm
ping 1.1.1.1 -n 1 -w 1000 > nul
ECHO Start Server...
start werl -name server -setcookie zumm
ping 1.1.1.1 -n 1 -w 1000 > nul
ECHO Start Client...
start werl -name client -setcookie zumm


