WIN_PACK_DIR="C:\cygwin64\home\Administrator"
UNINSTALL_DIR="C:\EXEM"

STOP_AND_REMOVE_MFO_REMAIN ()
{
	## STOP
	echo "REMOVE MFO"	
	sc stop DGServer_OBS_S1
	sc stop DGServer_OBS_M
	sc stop DGServer_M
	sc stop DGServer_S1
	sc stop PostgreSQL
	sc delete DGServer_OBS_S1
	sc delete DGServer_OBS_M
	sc delete DGServer_M
	sc delete DGServer_S1
	sc delete PostgreSQL
	${UNINSTALL_DIR}/unins000.exe /sp- /silent
}

INSTALL_MFO ()
{
	cd $WIN_PACK_DIR
	echo "INSTALL MFO"
	MAXGAUGE_FILE=`ls | grep .exe`
	echo $MAXGAUGE_FILE
	chmod.bat
	$MAXGAUGE_FILE /sp- /silent 
}

STOP_AND_REMOVE_MFO_REMAIN
sleep 7
INSTALL_MFO