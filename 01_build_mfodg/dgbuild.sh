## Written by EXEM Co., Ltd. DEVQA BSH
## Last modified 2017.01.11
## Default source Directory
DGSRC_DIR="C:/Multi-Runner/mfodg"
DGSMS_DIR="C:/Multi-Runner/mfosms"
DGMAIL_DIR="C:/Multi-Runner/mfomail"
DGAPI_DIR="C:/Multi-Runner/mfoapi"
DGTCP_DIR="C:/Multi-Runner/mfotcp"
DGOUT_DIR="C:/Multi-Runner/mfodg/deploy/mfo"
DGETC_DIR="C:/Multi-Runner/mfobuild/01_build_mfodg"
ANT_BUILD_SCRIPT_DIR="C:/Multi-Runner/mfobuild/01_build_mfodg"

## I Think that there are so tiny Changes of component, so I do hard coding.
## 변화가 많치 않은 형상항목들이라 하드코딩 처리하였고, 필요시 매뉴얼하게 변경함.
DGSMS_TAG_VER="mfosms_170306.01"
DGMAIL_TAG_VER="mfomail_170516.01"
DGAPI_TAG_VER="mfoapi_170411.01"
DGTCP_TAG_VER="mfotcp_170808.01"

echo "================================================"
echo "Data Gather Compile & BUILD & Packaging Start..!"
echo "================================================"

GIT_CHECKOUT_SMS_MAIL_API_TCP()
{
cd $DGSMS_DIR
git checkout $DGSMS_TAG_VER
cd $DGMAIL_DIR
git checkout $DGMAIL_TAG_VER
cd $DGAPI_DIR
git checkout $DGAPI_TAG_VER
cd $DGTCP_DIR
git checkout $DGTCP_TAG_VER
}

CLEAN_DG_FILES ()
{
	rm -rf $DGOUT_DIR
}

EXECUTE_ANT_SCRIPT()
{
	cd $ANT_BUILD_SCRIPT_DIR
	ant -buildfile mfodg_ant.xml
	ant -buildfile mfosms_ant.xml
	ant -buildfile mfomail_ant.xml
	ant -buildfile mfoapi_ant.xml
	ant -buildfile mfotcp_ant.xml
}

VERSION_CHECK()
{
	DG_TITLE=`cat $DGSRC_DIR/src/jdg/server/XmConfig.java | grep DATAGATHER_TITLE | grep public | awk -F "=" '{print $2}'  | tr -d '' | tr -d ';' | tr -d '"'`
	DG_MAJOR=`cat $DGSRC_DIR/src/jdg/server/XmConfig.java | grep DATAGATHER_MAJOR | grep public | awk -F "=" '{print $2}'  | tr -d ' ' | tr -d ';'| tr -d '"'`
	DG_MINOR=`cat $DGSRC_DIR/src/jdg/server/XmConfig.java | grep DATAGATHER_MINOR | grep public | awk -F "=" '{print $2}'  | tr -d ' ' | tr -d ';' | tr -d '"'`
	SERV_DESC=$DG_TITLE$DG_MAJOR.$DG_MINOR
	
	cd $DGOUT_DIR
	DG_FILE=`find -type f -name DGServer.jar`
	SMS_FILE=`find -type f -name sample_sms.jar`
	MAIL_FILE=`find -type f -name sample_mail.jar`
	API_FILE=`find -type f -name sample_api.jar`
	TCP_FILE=`find -type f -name sample_tcp.jar`
	RUNABLE_DG_JAR_VER=`java -jar $DG_FILE -version`
	export RUNABLE_DG_JAR_VER;
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
	cp -a $DGETC_DIR/DGServer_M $DGOUT_DIR/DGServer_M
	cp -a $DGETC_DIR/DGServer_S1 $DGOUT_DIR/DGServer_S1
	cp -a $DGETC_DIR/XmPing $DGOUT_DIR/XmPing
	cp -a $DGETC_DIR/PG_Backup $DGOUT_DIR/PG_Backup
	cp -a $DGETC_DIR/PG_Age $DGOUT_DIR/PG_Age
	cp -a $DG_FILE $DGOUT_DIR/DGServer_M/bin
	cp -a $DG_FILE $DGOUT_DIR/DGServer_S1/bin
	cp -v $SMS_FILE $DGOUT_DIR/DGServer_S1/svc/sms.jar
	cp -v $MAIL_FILE $DGOUT_DIR/DGServer_S1/svc/mail.jar
	cp -v $API_FILE $DGOUT_DIR/DGServer_S1/svc/sample_api.jar
	cp -v $TCP_FILE $DGOUT_DIR/DGServer_S1/svc/sample_tcp.jar

	cp -v $DGSMS_DIR/sample_sms.unit $DGOUT_DIR/DGServer_S1/svc/sample_sms.unit
	cp -v $DGSMS_DIR/sample_sms.xml $DGOUT_DIR/DGServer_S1/svc/sms.xml
	cp -v $DGMAIL_DIR/sample_mail.unit $DGOUT_DIR/DGServer_S1/svc/sample_mail.unit
	cp -v $DGMAIL_DIR/sample_mail.xml $DGOUT_DIR/DGServer_S1/svc/mail.xml
	cp -v $DGAPI_DIR/sample_api.unit $DGOUT_DIR/DGServer_S1/svc/sample_api.unit
	cp -v $DGAPI_DIR/sample_api.xml $DGOUT_DIR/DGServer_S1/svc/sample_api.xml
	cp -v $DGTCP_DIR/sample_tcp.unit $DGOUT_DIR/DGServer_S1/svc/sample_tcp.unit
	cp -v $DGTCP_DIR/sample_tcp.xml $DGOUT_DIR/DGServer_S1/svc/sample_tcp.xml
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
			DG_DESC="Exem_$DG"
			echo "\"C:\Program Files (x86)\Jar2Exe Wizard\j2ewiz\" /jar C:\Multi-Runner\mfodg\deploy\mfo\DGServer_S1\bin\DGServer.jar $OUTPUT_DIR /m jdg.server.DGServer /type service /minjre 1.6 /maxjre 1.8 /platform windows /checksum $AMD_64  /service $DG /serviceshow $DG_DESC /servicedesc \"$SERV_DESC\" /pv 2,1,7,1099 /fv 2,1,7,1099 /ve \"ProductVersion=2, 1, 7, 1099\" /ve \"ProductName=Your product name\" /ve \"LegalCopyright=Copyright (c) 2007 - 2015\" /ve \"FileVersion=2, 1, 7, 1099\" /ve \"FileDescription=This file is the main program\" /ve \"LegalTrademarks=Trade marks\" /ve \"CompanyName=Your Company\"" >>  ./DGJAR2EXE.bat
			unset AMD_64
		done	
	done
	DGJAR2EXE.bat
	rm ./DGJAR2EXE.bat
}

INSERT_TAG_VALUE_TO_DGSCTL ()
{
	## Here are choices of COMP_TAGs. 
	## MFOSQL_TAG, MFOWEB_TAG, MFODG_TAG, MFONP_TAG
	## MFOPG_TAG, MFORTS_TAG, MFOBUILD_TAG 
	echo "
	SET PAGESIZE 0 FEEDBACK OFF VERIFY OFF HEADING OFF ECHO OFF;
	select MFODG_TAG from mfo_tag t join runner_stat r
	on t.MFO_RELEASE_VER = r.TOTAL_VER
	where r.RUN_COMP='mfototal_win';" > checkout_tag.sql

	MFODG_TAG_VALUE=`echo exit | sqlplus -silent git/git@DEVQA23 @checkout_tag.sql`
	sleep 1
	rm checkout_tag.sql
	
	
	## Data Gather Master
	DGSCTL_TEMPLETE=$DGOUT_DIR/DGServer_M/bin/dgsctl
	DGSCTL_TEMPLETE_SED=$DGOUT_DIR/DGServer_M/bin/dgsctl_sed
	sed -e 's/TAG\_VALUE\=\"will\_support\_as\_of\_2016\.11\"/TAG\_VALUE\=\"'$MFODG_TAG_VALUE'\"/g' $DGSCTL_TEMPLETE > ${DGSCTL_TEMPLETE_SED}
	mv ${DGSCTL_TEMPLETE_SED} $DGSCTL_TEMPLETE
	
	## Data Gather Slave
	DGSCTL_TEMPLETE=$DGOUT_DIR/DGServer_S1/bin/dgsctl
	DGSCTL_TEMPLETE_SED=$DGOUT_DIR/DGServer_S1/bin/dgsctl_sed
	sed -e 's/TAG\_VALUE\=\"will\_support\_as\_of\_2016\.11\"/TAG\_VALUE\=\"'$MFODG_TAG_VALUE'\"/g' $DGSCTL_TEMPLETE > ${DGSCTL_TEMPLETE_SED}
	mv ${DGSCTL_TEMPLETE_SED} $DGSCTL_TEMPLETE
}

MAKE_TAR()
{
	SERV_DESC=$DG_TITLE$DG_MAJOR.$DG_MINOR
	SERV_DESC=`echo $SERV_DESC | awk '{print $3}'`
	SERV_DESC=`echo "$SERV_DESC .package.tar" | tr -d ' '`
	TAR_NAME="$SERV_DESC"
	cd $DGOUT_DIR
	
	mkdir $DGOUT_DIR/tar
	mv $DGOUT_DIR/DGServer_M $DGOUT_DIR/tar/DGServer_M
	mv $DGOUT_DIR/DGServer_S1 $DGOUT_DIR/tar/DGServer_S1
	mv $DGOUT_DIR/XmPing $DGOUT_DIR/tar/XmPing
	mv $DGOUT_DIR/PG_Backup $DGOUT_DIR/tar/PG_Backup
	mv $DGOUT_DIR/PG_Age $DGOUT_DIR/tar/PG_Age
	cd $DGOUT_DIR/tar
	cp -v $DGOUT_DIR/tar/DGServer_S1/bin/mxg_obsd/win64/mxg_obsd_x64.exe  $DGOUT_DIR/tar/DGServer_S1/bin/mxg_obsd.exe
	cp -v $DGOUT_DIR/tar/DGServer_M/bin/mxg_obsd/win64/mxg_obsd_x64.exe  $DGOUT_DIR/tar/DGServer_M/bin/mxg_obsd.exe
	7z.exe a $TAR_NAME -x!*.tar
}

### Data Gather BUILD & Packaging Logic
	CLEAN_DG_FILES
	GIT_CHECKOUT_SMS_MAIL_API_TCP
	EXECUTE_ANT_SCRIPT
	VERSION_CHECK
if [ "$ERROR" != "1" ]; then
	CP_DG_JAR;
	JAR_TO_EXE;
	INSERT_TAG_VALUE_TO_DGSCTL;
	MAKE_TAR;
else
	echo RUNABLE_JAR_VER is	$RUNABLE_DG_JAR_VER;
	echo SOURCE_VERSION  is 	$SERV_DESC;
fi

echo "========================================================================="
echo "Data Gather BUILD & Packaging[ $RUNABLE_DG_JAR_VER ] END"
echo "========================================================================="