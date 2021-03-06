@echo off
rem ----------------------------------------------------------------------------
rem
rem     VOD SaveLogs Utility
rem         Copyright(C) 2001-2004 by SeaChange Interational, Inc.
rem
rem     Author: Christiaan Lutzer
rem     Modified by: Mark Smith for SPOT and Transcoder/AdRouter usage
rem
rem ----------------------------------------------------------------------------
goto start
:help
echo.
echo %0 [-c computer] [-l log-directory] [-s system-root] [-t system type]
echo    Copyright(C) 2001-2002, SeaChange International, Inc.
echo.
echo This script creates a timestamped archive of the logs in C:\itv\log,
echo the NT application and system event logs, and of any Dr. Watson logs found.
echo It will operate on the current computer, or a computer specified on the
echo command line.
echo.
echo The archive created by this script will be created in the current working
echo directory, and will be named in the following format:
echo.
echo    log-%%COMPUTERNAME%%-YYYY.MM.DD-HH.MM.SS.zip
echo.
echo where YYYY=year, MM=month, DD=day, HH=hour, MM=minute, SS=second.
echo.
echo The default computer name is '%computername%', and the default log dir is
echo C:\itv\log (i.e. %computername%\\C$\itv\log, and the default system type
echo is ITV.
echo.
echo Command line parameters:
echo.
echo    -c      Specify the computer whose logs should be saved.
echo    -l      Specify the directory where the ITV log files are kept.
echo    -s      Specify the Window NT root directory (i.e. where Dr. Watson log
echo            file will be saved.)  This is typically known as the
echo            %%systemroot%% environment variable.
echo    -t      Specify system type this log collection utility is to be run 
echo            against.  Not providing this option defaults to running on a SeaChange
echo            ITV system.  (SPOT, DigitalX)
echo.
goto end

:start
set DEBUG=0
rem Initialize local variables to 'nil'.
set LOGDIR=
set LOGDIR2=
set DEFAULT=
set SYSDIR=
set COMPUTER=
set WATSONLOG=
set WATSONDMP=
set APPEVTLOG=
set SYSEVTLOG=
set SECEVTLOG=
set BADACTION=
set CMMSMELOG=
set MSMELOG=
set SYSTYPE=

rem ----------------------------------------------------------------------------
rem
rem     Parse the command line options.
rem
rem ----------------------------------------------------------------------------
:loopstart
if ({%DEBUG%}=={1}) (echo Argument: 1=%1, 2=%2)
if {%1}=={} goto loopend
    if {%1}=={-l} if {%2}=={} goto badargument
    if {%1}=={-l} (
        set LOGDIR=%2
        shift
    )
    if {%1}=={-c} if {%2}=={} goto badargument
    if {%1}=={-c} (
        set COMPUTER=%2
        shift
    )
    if {%1}=={-s} if {%2}=={} goto badargument
    if {%1}=={-s} (
        set SYSDIR=%2
        shift
    )
    if {%1}=={-t} if {%2}=={} goto badargument
    if {%1}=={-t} (
	set SYSTYPE=%2
	shift

	
    )
    if {%1}=={-d} (
        set DEBUG=1
    )
    if {%1}=={/?} (goto help)
    if {%1}=={-?} goto help
    if {%1}=={/h} goto help
    if {%1}=={-h} goto help
    if {%1}=={/help} goto help
    if {%1}=={--help} goto help
shift
goto loopstart
:badargument
echo Error: you must specify an argument with %1!
goto end
:loopend

rem ----------------------------------------------------------------------------
rem
rem     The assumptions of savelogs are this: if we are operating on the local
rem     computer, then we use %ITVROOT% and %systemroot%.  However, if we are
rem     running against a remote computer, we assume the standard ITV defaults.
rem
rem     Note: setting SYSDIR and LOGDIR on the command line take precedence.
rem	Note: setting the System Type parameter to anything other than the default
rem	      will execute that particular log collection routine
rem
rem ----------------------------------------------------------------------------
if {%COMPUTER%}=={} (set COMPUTER=%computername%)

if {%SYSTYPE%}=={SPOT} goto SPOT
if {%SYSTYPE%}=={DigitalX} goto IAR

if {%SYSDIR%}=={} (
    expandenv.exe SYSTEMROOT -p "SET SYSDIR=" -c %COMPUTER% > }{.bat
    call }{.bat
)
if {%SYSDIR%}=={} (
    set SYSDIR=%SYSTEMROOT%
)

if {%LOGDIR%}=={} (
    expandenv.exe ITVROOT -p "SET LOGDIR=" -s "\log" -c %COMPUTER% > }{.bat
    call }{.bat
    set LOGDIR2=C:\seachange\log
    set DEFAULT=1
)
if {%LOGDIR%}=={} (
    set LOGDIR=C:\itv\log
)
if {%SYSTYPE%}=={} (
    set SYSTYPE=ITV
)

if {%SYSTYPE%}=={SPOT} goto SPOT
if {%SYSTYPE%}=={DigitalX} goto IAR

if {%COMPUTER%}=={%computername%} (
    echo Operating on Local System [%COMPUTER%]...
    set WATSONLOG=%SYSDIR%\drwtsn32.log
    set WATSONDMP=%SYSDIR%\user.dmp
    set APPEVTLOG=C:\Application.evt
    set SYSEVTLOG=C:\System.evt
    set SECEVTLOG=C:\Security.evt
    set BADACTION=C:\badaction.dat
    set CMMSMELOG=%SYSDIR%\system32\CMWatch*.dmp
    set MSMELOG=%SYSDIR%\system32\*MSME*.dmp
) else (
    echo Operating on Remote System [%COMPUTER%]...
    set APPEVTLOG=\\%COMPUTER%\C$\Application.evt
    set SYSEVTLOG=\\%COMPUTER%\C$\System.evt
    set SECEVTLOG=\\%COMPUTER%\C$\Security.evt
    set BADACTION=\\%COMPUTER%\C$\badaction.dat
    rem ------------------------------------------------------------------------
    rem
    rem     Convert the colons in the UNC pathname to dollar signs.
    rem
    rem ------------------------------------------------------------------------
    for /f "tokens=1,2 delims=:" %%I in ("\\%COMPUTER%\%LOGDIR%") do set LOGDIR=%%I$%%J
    for /f "tokens=1,2 delims=:" %%I in ("\\%COMPUTER%\%SYSDIR%\drwtsn32.log") do set WATSONLOG=%%I$%%J
    for /f "tokens=1,2 delims=:" %%I in ("\\%COMPUTER%\%SYSDIR%\user.dmp") do set WATSONDMP=%%I$%%J
    for /f "tokens=1,2 delims=:" %%I in ("\\%COMPUTER%\%SYSDIR%\system32\CMWatch*.dmp") do set CMMSMELOG=%%I$%%J
    for /f "tokens=1,2 delims=:" %%I in ("\\%COMPUTER%\%SYSDIR%\system32\*MSME*.dmp") do set MSMELOG=%%I$%%J
)

rem set LOGDIR=%TMPLOGDIR%

if {%DEBUG%}=={1} (
    echo [DEBUG] SYSDIR=%SYSDIR%
    echo [DEBUG] LOGDIR=%LOGDIR%
    echo [DEBUG] WATSONLOG=%WATSONLOG%
    echo [DEBUG] WATSONDMP=%WATSONDMP%
    echo [DEBUG] APPEVTLOG=%APPEVTLOG%
    echo [DEBUG] SYSEVTLOG=%SYSEVTLOG%
    echo [DEBUG] SECEVTLOG=%SECEVTLOG%
    echo [DEBUG] BADACTION=%BADACTION%
    echo [DEBUG] CMMSMELOG=%CMMSMELOG%
    echo [DEBUG] MSMELOG=%MSMELOG%
    pause
)

rem ----------------------------------------------------------------------------
rem
rem     Create a new unique file name for the archive.
rem
rem ----------------------------------------------------------------------------
timestamp.exe "set TIMESTAMP=" > }{.bat
call }{.bat
set archive=log-%COMPUTER%-%TIMESTAMP%
echo Creating log archive: %archive%
echo Creating log archive: %archive% > savelogs.log
mkdir %archive%

rem ----------------------------------------------------------------------------
rem
rem     Copy the appropriate files into the archive directory.
rem
rem ----------------------------------------------------------------------------
echo Copying log files...
echo Copying log files (%LOGDIR%\*.log)... >> savelogs.log
copy %LOGDIR%\*.log "%archive%" >> savelogs.log
if {%DEFAULT%}=={1} (
    copy %LOGDIR2%\*.log "%archive%" >> savelogs.log
)
set MVCMD=move
if {%MOVEWATSON%}=={0} (set MVCMD=copy)
if exist %WATSONLOG% (
    echo Copying Dr. Watson log...
    echo Copying Dr. Watson log... >> savelogs.log
    %MVCMD% %WATSONLOG% "%archive%" >> savelogs.log
)
if exist %WATSONDMP% (
    echo Copying Dr. Watson log...
    echo Copying Dr. Watson log... >> savelogs.log
    %MVCMD% %WATSONDMP% "%archive%" >> savelogs.log
)
if exist %BADACTION% (
    echo Copying MSME Bad Action log...
    echo Copying MSME Bad Action log... >> savelogs.log
    %MVCMD% %BADACTION% "%archive%" >> savelogs.log
)
if exist %CMMSMELOG% (
    echo Copying CM MSME Trace log...
    echo Copying CM MSME Trace log... >> savelogs.log
    %MVCMD% %CMMSMELOG% "%archive%" >> savelogs.log
)
if exist %MSMELOG% (
    echo Copying MSME Trace log...
    echo Copying MSME Trace log... >> savelogs.log
    %MVCMD% %MSMELOG% "%archive%" >> savelogs.log
)
rem ----------------------------------------------------------------------------
rem
rem     Dump the NT event logs.
rem
rem ----------------------------------------------------------------------------
if exist %APPEVTLOG% (del %APPEVTLOG%)
if exist %SYSEVTLOG% (del %SYSEVTLOG%)
if exist %SECEVTLOG% (del %SECEVTLOG%)
echo Dumping Application event log...
echo Dumping Application event log... >> savelogs.log
eventlog.exe Application "C:\Application.evt" %COMPUTER%
echo Dumping System event log...
echo Dumping System event log... >> savelogs.log
eventlog.exe System "C:\System.evt" %COMPUTER%
echo Dumping Security event log...
echo Dumping Security event log... >> savelogs.log
eventlog.exe Security "C:\Security.evt" %COMPUTER%
move %APPEVTLOG% %archive%
move %SYSEVTLOG% %archive%
move %SECEVTLOG% %archive%

rem ----------------------------------------------------------------------------
rem
rem     Creating file for seaver and moving it into archive directory.
rem 
rem ----------------------------------------------------------------------------
seaver \\%COMPUTER%\C_drive\cdci\exe\*.* >> Seaver-%COMPUTER%-%TIMESTAMP%.txt
move Seaver-%COMPUTER%-%TIMESTAMP%.txt %archive%

rem ----------------------------------------------------------------------------
rem
rem     Creating file for Pslist and moving it into archive directory.
rem
rem ----------------------------------------------------------------------------
pslist \\%COMPUTER% >> Pslist-%COMPUTER%-%TIMESTAMP%.txt
move Pslist-%COMPUTER%-%TIMESTAMP%.txt %archive%

rem ----------------------------------------------------------------------------
rem
rem     Creating file for Systeminfo and moving it into archive directory.
rem
rem ----------------------------------------------------------------------------
systeminfo /s \\%COMPUTER% >> Systeminfo-%COMPUTER%-%TIMESTAMP%.txt
move Systeminfo-%COMPUTER%-%TIMESTAMP%.txt %archive%

rem ----------------------------------------------------------------------------
rem
rem     Creating file for diskspace and moving it into archive directory.
rem
rem ----------------------------------------------------------------------------
fsutil volume diskfree \\%COMPUTER%\C_drive  >> FreeSpaceofdrive-%COMPUTER%-%TIMESTAMP%.txt
echo ---------------------------------------------------------------------------- >> FreeSpaceofdrive-%COMPUTER%-%TIMESTAMP%.txt
dvlutil dirinfo %COMPUTER% >> FreeSpaceofdrive-%COMPUTER%-%TIMESTAMP%.txt
move FreeSpaceofdrive-%COMPUTER%-%TIMESTAMP%.txt %archive%

rem ----------------------------------------------------------------------------
rem
rem     Creating file for regdump and moving it into archive directory.
rem
rem ----------------------------------------------------------------------------
RegDump /o Regdump-%COMPUTER%-%TIMESTAMP%.txt /r \\%COMPUTER%\HKEY_LOCAL_MACHINE\SOFTWARE\SEACHANGE  /acls/detail
move Regdump-%COMPUTER%-%TIMESTAMP%.txt %archive%

rem ----------------------------------------------------------------------------
rem
rem     Creating databases back-up.
rem
rem ----------------------------------------------------------------------------
sqlcmd -S %COMPUTER% -Q "BACKUP DATABASE [mpeg] TO DISK='%COMPUTER%\backupOf-mpeg-%COMPUTER%-%TIMESTAMP%.bak'"
sqlcmd -S %COMPUTER% -Q "BACKUP DATABASE [distribution] TO DISK='%COMPUTER%\backupOf-distribution-%COMPUTER%-%TIMESTAMP%.bak'"
zip.exe database-backup.zip %COMPUTER%\*.bak
move database-backup.zip %archive%
del %COMPUTER%\*.bak

rem ----------------------------------------------------------------------------
rem
rem     Creating Netset command file which has protocol statistics and current TCP/IP network connections.
rem
rem ----------------------------------------------------------------------------
netset -a >> Netset-%COMPUTER%-%TIMESTAMP%.txt
move Netset-%COMPUTER%-%TIMESTAMP%.txt %archive%

rem ----------------------------------------------------------------------------
rem
rem     Printing routing tables for network.
rem
rem ----------------------------------------------------------------------------
route print >> RoutePrint-%COMPUTER%-%TIMESTAMP%.txt
move RoutePrint-%COMPUTER%-%TIMESTAMP%.txt %archive%

rem ----------------------------------------------------------------------------
rem
rem     Zip up the archive directory.
rem
rem ----------------------------------------------------------------------------
echo Archiving files...
echo Archiving files... >> savelogs.log
zip.exe %archive%.zip %archive%\*.* >> savelogs.log

rem ----------------------------------------------------------------------------
rem
rem     Get rid of temporary stuff.
rem
rem ----------------------------------------------------------------------------
echo Removing temporary files...
echo Removing temporary files... >> savelogs.log
del /Q %archive%
rmdir %archive%
del }{.bat

echo Done.
goto end

:SPOT
set LOGDIR=c:\cdci\log
set LOGDIR2=\\%COMPUTER%\E$\cdci\log
if {%COMPUTER%}=={%computername%} (
    echo Operating on Local System [%COMPUTER%]...
    set WATSONLOG=%SYSDIR%\drwtsn32.log
    set WATSONDMP=%SYSDIR%\user.dmp
    set APPEVTLOG=C:\Application.evt
    set SYSEVTLOG=C:\System.evt
    set SECEVTLOG=C:\Security.evt
    set BADACTION=C:\badaction.dat
    set CMMSMELOG=%SYSDIR%\system32\CMWatch*.dmp
    set MSMELOG=%SYSDIR%\system32\*MSME*.dmp
) else (
    echo Operating on Remote System [%COMPUTER%]...
    set APPEVTLOG=\\%COMPUTER%\C$\Application.evt
    set SYSEVTLOG=\\%COMPUTER%\C$\System.evt
    set SECEVTLOG=\\%COMPUTER%\C$\Security.evt
    set BADACTION=\\%COMPUTER%\C$\badaction.dat
    rem ------------------------------------------------------------------------
    rem
    rem     Convert the colons in the UNC pathname to dollar signs.
    rem
    rem ------------------------------------------------------------------------
    for /f "tokens=1,2 delims=:" %%I in ("\\%COMPUTER%\%LOGDIR%") do set LOGDIR=%%I$%%J
    for /f "tokens=1,2 delims=:" %%I in ("\\%COMPUTER%\%SYSDIR%\drwtsn32.log") do set WATSONLOG=%%I$%%J
    for /f "tokens=1,2 delims=:" %%I in ("\\%COMPUTER%\%SYSDIR%\user.dmp") do set WATSONDMP=%%I$%%J
    for /f "tokens=1,2 delims=:" %%I in ("\\%COMPUTER%\%SYSDIR%\system32\CMWatch*.dmp") do set CMMSMELOG=%%I$%%J
    for /f "tokens=1,2 delims=:" %%I in ("\\%COMPUTER%\%SYSDIR%\system32\*MSME*.dmp") do set MSMELOG=%%I$%%J
)

rem set LOGDIR=%TMPLOGDIR%

if {%DEBUG%}=={1} (
    echo [DEBUG] SYSDIR=%SYSDIR%
    echo [DEBUG] LOGDIR=%LOGDIR%
    echo [DEBUG] LOGDIR2=%LOGDIR2%
    echo [DEBUG] WATSONLOG=%WATSONLOG%
    echo [DEBUG] WATSONDMP=%WATSONDMP%
    echo [DEBUG] APPEVTLOG=%APPEVTLOG%
    echo [DEBUG] SYSEVTLOG=%SYSEVTLOG%
    echo [DEBUG] SECEVTLOG=%SECEVTLOG%
    echo [DEBUG] BADACTION=%BADACTION%
    echo [DEBUG] CMMSMELOG=%CMMSMELOG%
    echo [DEBUG] MSMELOG=%MSMELOG%
    pause
)

rem ----------------------------------------------------------------------------
rem
rem     Create a new unique file name for the archive.
rem
rem ----------------------------------------------------------------------------
timestamp.exe "set TIMESTAMP=" > }{.bat
call }{.bat
set archive=log-%COMPUTER%-%TIMESTAMP%
echo Creating log archive: %archive%
echo Creating log archive: %archive% > savelogs.log
mkdir %archive%

rem ----------------------------------------------------------------------------
rem
rem     Copy the appropriate files into the archive directory.
rem
rem ----------------------------------------------------------------------------
echo Copying log files...
echo Copying log files located in c:\cdci\log (%LOGDIR%\*.log)... >> savelogs.log
echo Copying log files located in e:\cdci\log (%LOGDIR2%\*.log)... >> savelogs.log
echo Ignore "system cannot find the drive specified.." error if this is not being run on a SPOT inserter...
copy %LOGDIR%\*.log "%archive%" >> savelogs.log
copy %LOGDIR2%\*.log "%archive%" >> savelogs.log

set MVCMD=move
if {%MOVEWATSON%}=={0} (set MVCMD=copy)
if exist %WATSONLOG% (
    echo Copying Dr. Watson log...
    echo Copying Dr. Watson log... >> savelogs.log
    %MVCMD% %WATSONLOG% "%archive%" >> savelogs.log
)
if exist %WATSONDMP% (
    echo Copying Dr. Watson log...
    echo Copying Dr. Watson log... >> savelogs.log
    %MVCMD% %WATSONDMP% "%archive%" >> savelogs.log
)
if exist %BADACTION% (
    echo Copying MSME Bad Action log...
    echo Copying MSME Bad Action log... >> savelogs.log
    %MVCMD% %BADACTION% "%archive%" >> savelogs.log
)
if exist %CMMSMELOG% (
    echo Copying CM MSME Trace log...
    echo Copying CM MSME Trace log... >> savelogs.log
    %MVCMD% %CMMSMELOG% "%archive%" >> savelogs.log
)
if exist %MSMELOG% (
    echo Copying MSME Trace log...
    echo Copying MSME Trace log... >> savelogs.log
    %MVCMD% %MSMELOG% "%archive%" >> savelogs.log
)
rem ----------------------------------------------------------------------------
rem
rem     Dump the NT event logs.
rem
rem ----------------------------------------------------------------------------
if exist %APPEVTLOG% (del %APPEVTLOG%)
if exist %SYSEVTLOG% (del %SYSEVTLOG%)
if exist %SECEVTLOG% (del %SECEVTLOG%)
echo Dumping Application event log...
echo Dumping Application event log... >> savelogs.log
eventlog.exe Application "C:\Application.evt" %COMPUTER%
echo Dumping System event log...
echo Dumping System event log... >> savelogs.log
eventlog.exe System "C:\System.evt" %COMPUTER%
echo Dumping Security event log...
echo Dumping Security event log... >> savelogs.log
eventlog.exe Security "C:\Security.evt" %COMPUTER%
move %APPEVTLOG% %archive%
move %SYSEVTLOG% %archive%
move %SECEVTLOG% %archive%

rem ----------------------------------------------------------------------------
rem
rem     Creating file for seaver and moving it into archive directory.
rem 
rem ----------------------------------------------------------------------------
seaver \\%COMPUTER%\C_drive\cdci\exe\*.* >> Seaver-%COMPUTER%-%TIMESTAMP%.txt
move Seaver-%COMPUTER%-%TIMESTAMP%.txt %archive%

rem ----------------------------------------------------------------------------
rem
rem     Creating file for Pslist and moving it into archive directory.
rem
rem ----------------------------------------------------------------------------
pslist \\%COMPUTER% >> Pslist-%COMPUTER%-%TIMESTAMP%.txt
move Pslist-%COMPUTER%-%TIMESTAMP%.txt %archive%

rem ----------------------------------------------------------------------------
rem
rem     Creating file for Systeminfo and moving it into archive directory.
rem
rem ----------------------------------------------------------------------------
systeminfo /s \\%COMPUTER% >> Systeminfo-%COMPUTER%-%TIMESTAMP%.txt
move Systeminfo-%COMPUTER%-%TIMESTAMP%.txt %archive%

rem ----------------------------------------------------------------------------
rem
rem     Creating file for diskspace and moving it into archive directory.
rem
rem ----------------------------------------------------------------------------
fsutil volume diskfree \\%COMPUTER%\C_drive  >> FreeSpaceofdrive-%COMPUTER%-%TIMESTAMP%.txt
echo ---------------------------------------------------------------------------- >> FreeSpaceofdrive-%COMPUTER%-%TIMESTAMP%.txt
dvlutil dirinfo %COMPUTER% >> FreeSpaceofdrive-%COMPUTER%-%TIMESTAMP%.txt
move FreeSpaceofdrive-%COMPUTER%-%TIMESTAMP%.txt %archive%

rem ----------------------------------------------------------------------------
rem
rem     Creating file for regdump and moving it into archive directory.
rem
rem ----------------------------------------------------------------------------
RegDump /o Regdump-%COMPUTER%-%TIMESTAMP%.txt /r \\%COMPUTER%\HKEY_LOCAL_MACHINE\SOFTWARE\SEACHANGE  /acls/detail
move Regdump-%COMPUTER%-%TIMESTAMP%.txt %archive%

rem ----------------------------------------------------------------------------
rem
rem     Creating databases back-up.
rem
rem ----------------------------------------------------------------------------
sqlcmd -S %COMPUTER% -Q "BACKUP DATABASE [mpeg] TO DISK='%COMPUTER%\backupOf-mpeg-%COMPUTER%-%TIMESTAMP%.bak'"
sqlcmd -S %COMPUTER% -Q "BACKUP DATABASE [distribution] TO DISK='%COMPUTER%\backupOf-distribution-%COMPUTER%-%TIMESTAMP%.bak'"
zip.exe database-backup.zip %COMPUTER%\*.bak
move database-backup.zip %archive%
del %COMPUTER%\*.bak

rem ----------------------------------------------------------------------------
rem
rem     Creating Netset command file which has protocol statistics and current TCP/IP network connections.
rem
rem ----------------------------------------------------------------------------
netset -a >> Netset-%COMPUTER%-%TIMESTAMP%.txt
move Netset-%COMPUTER%-%TIMESTAMP%.txt %archive%

rem ----------------------------------------------------------------------------
rem
rem     Printing routing tables for network.
rem
rem ----------------------------------------------------------------------------
route print >> RoutePrint-%COMPUTER%-%TIMESTAMP%.txt
move RoutePrint-%COMPUTER%-%TIMESTAMP%.txt %archive%

rem ----------------------------------------------------------------------------
rem
rem     Zip up the archive directory.
rem
rem ----------------------------------------------------------------------------
echo Archiving files...
echo Archiving files... >> savelogs.log
zip.exe %archive%.zip %archive%\*.* >> savelogs.log

rem ----------------------------------------------------------------------------
rem
rem     Get rid of temporary stuff.
rem
rem ----------------------------------------------------------------------------
echo Removing temporary files...
echo Removing temporary files... >> savelogs.log
del /Q %archive%
rmdir %archive%
del }{.bat

echo Done.
goto end

:IAR
set LOGDIR=c:\ADROUTER\log
if {%COMPUTER%}=={%computername%} (
    echo Operating on Local System [%COMPUTER%]...
    set WATSONLOG=%SYSDIR%\drwtsn32.log
    set WATSONDMP=%SYSDIR%\user.dmp
    set APPEVTLOG=C:\Application.evt
    set SYSEVTLOG=C:\System.evt
    set SECEVTLOG=C:\Security.evt
    set BADACTION=C:\badaction.dat
    set CMMSMELOG=%SYSDIR%\system32\CMWatch*.dmp
    set MSMELOG=%SYSDIR%\system32\*MSME*.dmp
) else (
    echo Operating on Remote System [%COMPUTER%]...
    set APPEVTLOG=\\%COMPUTER%\C$\Application.evt
    set SYSEVTLOG=\\%COMPUTER%\C$\System.evt
    set SECEVTLOG=\\%COMPUTER%\C$\Security.evt
    set BADACTION=\\%COMPUTER%\C$\badaction.dat
    rem ------------------------------------------------------------------------
    rem
    rem     Convert the colons in the UNC pathname to dollar signs.
    rem
    rem ------------------------------------------------------------------------
    for /f "tokens=1,2 delims=:" %%I in ("\\%COMPUTER%\%LOGDIR%") do set LOGDIR=%%I$%%J
    for /f "tokens=1,2 delims=:" %%I in ("\\%COMPUTER%\%SYSDIR%\drwtsn32.log") do set WATSONLOG=%%I$%%J
    for /f "tokens=1,2 delims=:" %%I in ("\\%COMPUTER%\%SYSDIR%\user.dmp") do set WATSONDMP=%%I$%%J
    for /f "tokens=1,2 delims=:" %%I in ("\\%COMPUTER%\%SYSDIR%\system32\CMWatch*.dmp") do set CMMSMELOG=%%I$%%J
    for /f "tokens=1,2 delims=:" %%I in ("\\%COMPUTER%\%SYSDIR%\system32\*MSME*.dmp") do set MSMELOG=%%I$%%J
)

rem set LOGDIR=%TMPLOGDIR%

if {%DEBUG%}=={1} (
    echo [DEBUG] SYSDIR=%SYSDIR%
    echo [DEBUG] LOGDIR=%LOGDIR%
    echo [DEBUG] WATSONLOG=%WATSONLOG%
    echo [DEBUG] WATSONDMP=%WATSONDMP%
    echo [DEBUG] APPEVTLOG=%APPEVTLOG%
    echo [DEBUG] SYSEVTLOG=%SYSEVTLOG%
    echo [DEBUG] SECEVTLOG=%SECEVTLOG%
    echo [DEBUG] BADACTION=%BADACTION%
    echo [DEBUG] CMMSMELOG=%CMMSMELOG%
    echo [DEBUG] MSMELOG=%MSMELOG%
    pause
)

rem ----------------------------------------------------------------------------
rem
rem     Create a new unique file name for the archive.
rem
rem ----------------------------------------------------------------------------
timestamp.exe "set TIMESTAMP=" > }{.bat
call }{.bat
set archive=log-%COMPUTER%-%TIMESTAMP%
echo Creating log archive: %archive%
echo Creating log archive: %archive% > savelogs.log
mkdir %archive%

rem ----------------------------------------------------------------------------
rem
rem     Copy the appropriate files into the archive directory.
rem
rem ----------------------------------------------------------------------------
echo Copying log files...
echo Copying log files (%LOGDIR%\*.log)... >> savelogs.log
copy %LOGDIR%\*.log "%archive%" >> savelogs.log

set MVCMD=move
if {%MOVEWATSON%}=={0} (set MVCMD=copy)
if exist %WATSONLOG% (
    echo Copying Dr. Watson log...
    echo Copying Dr. Watson log... >> savelogs.log
    %MVCMD% %WATSONLOG% "%archive%" >> savelogs.log
)
if exist %WATSONDMP% (
    echo Copying Dr. Watson log...
    echo Copying Dr. Watson log... >> savelogs.log
    %MVCMD% %WATSONDMP% "%archive%" >> savelogs.log
)
if exist %BADACTION% (
    echo Copying MSME Bad Action log...
    echo Copying MSME Bad Action log... >> savelogs.log
    %MVCMD% %BADACTION% "%archive%" >> savelogs.log
)
if exist %CMMSMELOG% (
    echo Copying CM MSME Trace log...
    echo Copying CM MSME Trace log... >> savelogs.log
    %MVCMD% %CMMSMELOG% "%archive%" >> savelogs.log
)
if exist %MSMELOG% (
    echo Copying MSME Trace log...
    echo Copying MSME Trace log... >> savelogs.log
    %MVCMD% %MSMELOG% "%archive%" >> savelogs.log
)
rem ----------------------------------------------------------------------------
rem
rem     Dump the NT event logs.
rem
rem ----------------------------------------------------------------------------
if exist %APPEVTLOG% (del %APPEVTLOG%)
if exist %SYSEVTLOG% (del %SYSEVTLOG%)
if exist %SECEVTLOG% (del %SECEVTLOG%)
echo Dumping Application event log...
echo Dumping Application event log... >> savelogs.log
eventlog.exe Application "C:\Application.evt" %COMPUTER%
echo Dumping System event log...
echo Dumping System event log... >> savelogs.log
eventlog.exe System "C:\System.evt" %COMPUTER%
echo Dumping Security event log...
echo Dumping Security event log... >> savelogs.log
eventlog.exe Security "C:\Security.evt" %COMPUTER%
move %APPEVTLOG% %archive%
move %SYSEVTLOG% %archive%
move %SECEVTLOG% %archive%

rem ----------------------------------------------------------------------------
rem
rem     Creating file for seaver and moving it into archive directory.
rem 
rem ----------------------------------------------------------------------------
seaver \\%COMPUTER%\C_drive\cdci\exe\*.* >> Seaver-%COMPUTER%-%TIMESTAMP%.txt
move Seaver-%COMPUTER%-%TIMESTAMP%.txt %archive%

rem ----------------------------------------------------------------------------
rem
rem     Creating file for Pslist and moving it into archive directory.
rem
rem ----------------------------------------------------------------------------
pslist \\%COMPUTER% >> Pslist-%COMPUTER%-%TIMESTAMP%.txt
move Pslist-%COMPUTER%-%TIMESTAMP%.txt %archive%

rem ----------------------------------------------------------------------------
rem
rem     Creating file for Systeminfo and moving it into archive directory.
rem
rem ----------------------------------------------------------------------------
systeminfo /s \\%COMPUTER% >> Systeminfo-%COMPUTER%-%TIMESTAMP%.txt
move Systeminfo-%COMPUTER%-%TIMESTAMP%.txt %archive%

rem ----------------------------------------------------------------------------
rem
rem     Creating file for diskspace and moving it into archive directory.
rem
rem ----------------------------------------------------------------------------
fsutil volume diskfree \\%COMPUTER%\C_drive  >> FreeSpaceofdrive-%COMPUTER%-%TIMESTAMP%.txt
echo ---------------------------------------------------------------------------- >> FreeSpaceofdrive-%COMPUTER%-%TIMESTAMP%.txt
dvlutil dirinfo %COMPUTER% >> FreeSpaceofdrive-%COMPUTER%-%TIMESTAMP%.txt
move FreeSpaceofdrive-%COMPUTER%-%TIMESTAMP%.txt %archive%

rem ----------------------------------------------------------------------------
rem
rem     Creating file for regdump and moving it into archive directory.
rem
rem ----------------------------------------------------------------------------
RegDump /o Regdump-%COMPUTER%-%TIMESTAMP%.txt /r \\%COMPUTER%\HKEY_LOCAL_MACHINE\SOFTWARE\SEACHANGE  /acls/detail
move Regdump-%COMPUTER%-%TIMESTAMP%.txt %archive%


rem ----------------------------------------------------------------------------
rem
rem     Creating databases back-up.
rem
rem ----------------------------------------------------------------------------
sqlcmd -S %COMPUTER% -Q "BACKUP DATABASE [mpeg] TO DISK='%COMPUTER%\backupOf-mpeg-%COMPUTER%-%TIMESTAMP%.bak'"
sqlcmd -S %COMPUTER% -Q "BACKUP DATABASE [distribution] TO DISK='%COMPUTER%\backupOf-distribution-%COMPUTER%-%TIMESTAMP%.bak'"
zip.exe database-backup.zip %COMPUTER%\*.bak
move database-backup.zip %archive%
del %COMPUTER%\*.bak

rem ----------------------------------------------------------------------------
rem
rem     Creating Netset command file which has protocol statistics and current TCP/IP network connections.
rem
rem ----------------------------------------------------------------------------
netset -a >> Netset-%COMPUTER%-%TIMESTAMP%.txt
move Netset-%COMPUTER%-%TIMESTAMP%.txt %archive%

rem ----------------------------------------------------------------------------
rem
rem     Printing routing tables for network.
rem
rem ----------------------------------------------------------------------------
route print >> RoutePrint-%COMPUTER%-%TIMESTAMP%.txt
move RoutePrint-%COMPUTER%-%TIMESTAMP%.txt %archive%

rem ----------------------------------------------------------------------------
rem
rem     Zip up the archive directory.
rem
rem ----------------------------------------------------------------------------
echo Archiving files...
echo Archiving files... >> savelogs.log
zip.exe %archive%.zip %archive%\*.* >> savelogs.log

rem ----------------------------------------------------------------------------
rem
rem     Get rid of temporary stuff.
rem
rem ----------------------------------------------------------------------------
echo Removing temporary files...
echo Removing temporary files... >> savelogs.log
del /Q %archive%
rmdir %archive%
del }{.bat

echo Done.


:end
