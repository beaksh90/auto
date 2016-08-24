#Defaul DG source Directory
DGSRC_DIR="C:\Multi-Runner\mfodg"
DGOUT_DIR="C:\Multi-Runner\mfodg\deploy\mfo"
DGETC_DIR="C:\Multi-Runner\mfobuild\01_build_mfodg"
ANT_BUILD_SCRIPT_DIR="C:\Multi-Runner\mfobuild\01_build_mfodg"

FETCH_TAG_VER ()
{
	COMP_TAG="MFODG_TAG"
	## Here are choices of COMP_TAGs. 
	## MFOSQL_TAG, MFOWEB_TAG, MFODG_TAG, MFONP_TAG
	## MFOPG_TAG, MFORTS_TAG, MFOBUILD_TAG 
	
	echo "
	SET PAGESIZE 0 FEEDBACK OFF VERIFY OFF HEADING OFF ECHO OFF;
	select $COMP_TAG from mfo_tag t join runner_stat r
	on t.MFO_RELEASE_VER = r.TOTAL_VER
	where r.RUN_COMP='mfototal_win';" > ./checkout_tag.sql

	TAG=`echo exit | sqlplus -slient git/git@DEVQA23 @./checkout_tag.sql`
	sleep 1
	rm ./checkout_tag.sql
	cd $DGSRC_DIR
	git checkout $TAG
}

CHECKOUT_MASTER()
{
	cd $DGSRC_DIR
	git checkout master
}

CLEAN_DG_FILES ()
{
	rm -rf $DGOUT_DIR
}

ECLIPCE_AND_BUILD()
{
	cd $ANT_BUILD_SCRIPT_DIR
	ant -buildfile mfodg_ant.xml
}

VERSION_CHECK()
{
	DG_TITLE=`cat $DGSRC_DIR/src/jdg/server/XmConfig.java | grep DATAGATHER_TITLE | grep public | awk -F "=" '{print $2}'  | tr -d '' | tr -d ';' | tr -d '"'`
	DG_MAJOR=`cat $DGSRC_DIR/src/jdg/server/XmConfig.java | grep DATAGATHER_MAJOR | grep public | awk -F "=" '{print $2}'  | tr -d ' ' | tr -d ';'`
	DG_MINOR=`cat $DGSRC_DIR/src/jdg/server/XmConfig.java | grep DATAGATHER_MINOR | grep public | awk -F "=" '{print $2}'  | tr -d ' ' | tr -d ';' | tr -d '"'`
	SERV_DESC=$DG_TITLE$DG_MAJOR.$DG_MINOR
	
	cd $DGOUT_DIR
	DG_FILE=`find -type f`
	RUNABLE_DG_JAR_VER=`java -jar $DG_FILE -version`
	# Don't know why Do not like below 2 cmd, a not matched error occur.
	SERV_DESC=`echo $SERV_DESC | awk '{print $1 $2 $3 $4}' `
	RUNABLE_DG_JAR_VER=`echo $RUNABLE_DG_JAR_VER | awk '{print $1 $2 $3 $4}'`
	if [ "$RUNABLE_DG_JAR_VER" != "$SERV_DESC" ]; then 
		echo "abc > ./error.sh";
		echo " there is a problem, not macthed version between .jar and src"; ERROR="1"; echo here..!; echo $ERROR;  sh error.sh ; rm ./error.sh; 
	else
		echo -e " DG VERSION CHECK OK..!\n" ;
	fi
}

CP_DG_JAR()
{
	cp -av $DGETC_DIR/DGServer_M $DGOUT_DIR/DGServer_M
	cp -av $DGETC_DIR/DGServer_S1 $DGOUT_DIR/DGServer_S1
	cp -av $DGETC_DIR/XmPing $DGOUT_DIR/XmPing
	cp -av $DG_FILE $DGOUT_DIR/DGServer_M/bin
	cp -av $DG_FILE $DGOUT_DIR/DGServer_S1/bin
}

JAR_TO_EXE()
{
	DGM_S="DGServer_S1 DGServer_M"
	BITS="_x86.exe _x86_64.exe"
	## 추후 서비스 표시명 변경 예정 "
	## 추후 batch 파일 <-> 쉘스크립트 상호 사용간 문제 해결할 예정 지금은 batch 파일 만들어서 사용 
	DISPLAY_SRC="Exem_DGServer_S1 Exem_DGServer_M"
	for DG in $DGM_S
	do
		OUTPUT_DIR="/o C:\Multi-Runner\mfodg\deploy\mfo\\"
		OUTPUT_DIR_1="$OUTPUT_DIR$DG\bin\\$DG"
		for OS_BIT in $BITS
		do
			if [ "$OS_BIT" = "_x86_64.exe" ]; then
				AMD_64=/amd64
				OUTPUT_DIR="$OUTPUT_DIR_1$OS_BIT"
			else
				OUTPUT_DIR="$OUTPUT_DIR_1$OS_BIT"
			fi;
			
			echo "\"C:\Program Files (x86)\Jar2Exe Wizard\j2ewiz\" /jar C:\Multi-Runner\mfodg\deploy\mfo\DGServer_S1\bin\DGServer.jar $OUTPUT_DIR /m jdg.server.DGServer /type service /minjre 1.6 /maxjre 1.8 /platform windows /checksum $AMD_64  /service $DG /serviceshow $DG /servicedesc \"$SERV_DESC\" /pv 2,1,7,1099 /fv 2,1,7,1099 /ve \"ProductVersion=2, 1, 7, 1099\" /ve \"ProductName=Your product name\" /ve \"LegalCopyright=Copyright (c) 2007 - 2015\" /ve \"FileVersion=2, 1, 7, 1099\" /ve \"FileDescription=This file is the main program\" /ve \"LegalTrademarks=Trade marks\" /ve \"CompanyName=Your Company\"" >>  ./DGJAR2EXE.bat
			unset AMD_64
		done	
	done
	DGJAR2EXE.bat
	rm ./DGJAR2EXE.bat
}

MAKE_TAR()
{
	SERV_DESC=$DG_TITLE$DG_MAJOR.$DG_MINOR
	SERV_DESC=`echo $SERV_DESC | awk '{print $4}'`
	SERV_DESC=`echo "$SERV_DESC package.tar" | tr -d ' '`
	TAR_NAME="MaxGauge$SERV_DESC"
	cd $DGOUT_DIR
	
	mkdir $DGOUT_DIR/tar
	mv $DGOUT_DIR/DGServer_M $DGOUT_DIR/tar/DGServer_M
	mv $DGOUT_DIR/DGServer_S1 $DGOUT_DIR/tar/DGServer_S1
	mv $DGOUT_DIR/XmPing $DGOUT_DIR/tar/XmPing
	cd $DGOUT_DIR/tar
	7z.exe a $TAR_NAME -x!*.tar
	cp -v $DGOUT_DIR/tar/DGServer_S1/bin/mxg_obsd/win64/mxg_obsd_x64.exe  $DGOUT_DIR/tar/DGServer_S1/bin/mxg_obsd.exe
	cp -v $DGOUT_DIR/tar/DGServer_M/bin/mxg_obsd/win64/mxg_obsd_x64.exe  $DGOUT_DIR/tar/DGServer_M/bin/mxg_obsd.exe
}

## 과거 구식의 산물임
INIT_SRC_RM_AND_COPY()
{
	rm -rf C:/Multi-Runner/workspace/MFO_DataGather/src
	cp -av C:/Multi-Runner/mfodg/src C:\Multi-Runner/workspace/MFO_DataGather/src
}
#	INIT_SRC_RM_AND_COPY

	FETCH_TAG_VER
	CLEAN_DG_FILES
	ECLIPCE_AND_BUILD
	VERSION_CHECK
if [ "$ERROR" != "1" ]; then
	CP_DG_JAR;
	JAR_TO_EXE;
	MAKE_TAR;
else
	echo RUNABLE_JAR_VER is	$RUNABLE_DG_JAR_VER;
	echo SOURCE_VERSION  is 	$SERV_DESC;
fi
	CHECKOUT_MASTER