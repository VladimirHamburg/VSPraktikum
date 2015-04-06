@ECHO OFF
set "All="
ECHO Initiate compile for...
FOR %%i IN (*.erl) do call set "All=%%All%% %%i"
ECHO %All:~1%
ECHO.
ECHO Result:
set "errorlevel="
erl -compile %All:~1%
IF errorlevel 1 (
	ECHO FAILED! COMPILED WITH ERRORS! Code: %errorlevel%	
) else (
	ECHO SUCCESS! COMPILED WITH NO ERRORS!
)
ECHO.
PAUSE

