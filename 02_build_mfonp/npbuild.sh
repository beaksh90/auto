## Written by EXEM Co., Ltd. DEVQA BSH
## Last modified 2017.01.11
## Default source Directory
NPSRC_DIR="C:/Multi-Runner/mfonp"
NPOUT_DIR="C:/Multi-Runner/mfonp/deploy/MFO"
PJS_FILE_DIR="C:/Multi-Runner/mfonp/deploy/MFO/PlatformJS"
NP_SERVICE_DIR="C:/Multi-Runner/mfobuild/02_build_mfonp/np_service"
NP_CONFIG_DIF="C:/Multi-Runner/mfobuild/02_build_mfonp/config"
SET_NP_DIR="$NPOUT_DIR/PlatformJS"

WEBSRC_DIR="C:/Multi-Runner/mfoweb"
WEBOUT_DIR="$SET_NP_DIR/svc/www/MAXGAUGE"
SQLSRC_DIR="C:/Multi-Runner/mfosql"
SQLOUT_DIR="$SET_NP_DIR/sql"

ANT_BUILD_SCRIPT_DIR="C:\Multi-Runner\mfonp\platformjs"

echo "===================================================="
echo "JAVA PlatformJS Compile & BUILD & Packaging Start..!"
echo "===================================================="

CLEAN_NP_FILES ()
{
	rm -rf $NPOUT_DIR
}

EXECUTE_ANT_SCRIPT()
{
	cd $ANT_BUILD_SCRIPT_DIR
	ant -buildfile build_MFO.xml
}

MV_NP_FILES()
{
	#configuration.bat파일로 막 생성된 np경로 추적함.
	cd $NPOUT_DIR
	DIR=`find ./ -name configuration.bat`
	NP_FILES_DIR=`dirname $DIR`
	mv $NP_FILES_DIR  $SET_NP_DIR
}

INSERT_TAG_VALUE_TO_PJSCTL ()
{
	## Here are choices of COMP_TAGs. 
	## MFOSQL_TAG, MFOWEB_TAG, MFODG_TAG, MFONP_TAG
	## MFOPG_TAG, MFORTS_TAG, MFOBUILD_TAG 
	echo "
	SET PAGESIZE 0 FEEDBACK OFF VERIFY OFF HEADING OFF ECHO OFF;
	select MFONP_TAG,MFOWEB_TAG,MFOSQL_TAG  from mfo_tag t join runner_stat r
	on t.MFO_RELEASE_VER = r.TOTAL_VER
	where r.RUN_COMP='mfototal_win';" > checkout_tag.sql

	TAG=`echo exit | sqlplus -silent git/git@DEVQA23 @checkout_tag.sql`
	sleep 1
	rm checkout_tag.sql
	MFONP_TAG_VALUE=`echo $TAG | awk '{print $1}'`
	MFOWEB_TAG_VALUE=`echo $TAG | awk '{print $2}'`
	MFOSQL_TAG_VALUE=`echo $TAG | awk '{print $3}'`
	PJSCTL_TEMPLETE=$SET_NP_DIR/config/template/pjsctl_linux
	PJSCTL_TEMPLETE_SED=$SET_NP_DIR/config/template/pjsctl_linux_sed
	sed -e 's/MFONP\ will_support_as_of_2016.11/MFONP\ '$MFONP_TAG_VALUE'/g' $PJSCTL_TEMPLETE > ${PJSCTL_TEMPLETE_SED}
	mv ${PJSCTL_TEMPLETE_SED} $PJSCTL_TEMPLETE
	sed -e 's/MFOWEB\ will_support_as_of_2016.11/MFOWEB\ '$MFOWEB_TAG_VALUE'/g' $PJSCTL_TEMPLETE > ${PJSCTL_TEMPLETE_SED}
	mv ${PJSCTL_TEMPLETE_SED} $PJSCTL_TEMPLETE
	sed -e 's/MFOSQL\ will_support_as_of_2016.11/MFOSQL\ '$MFOSQL_TAG_VALUE'/g' $PJSCTL_TEMPLETE > ${PJSCTL_TEMPLETE_SED}
	mv ${PJSCTL_TEMPLETE_SED} $PJSCTL_TEMPLETE
	

}

EXECUTE_CONFIGURATION ()
{
	## 2017.02.10 configuration 실행하여 생성하는 것으로 로직을 변경함
	cd $SET_NP_DIR
	echo -e  "1\n\n\n\n\n\n\n\n\n\n\n1\n\n0\n\n\n" | sh $SET_NP_DIR/configuration.bat
}

CP_SQL()
{
	mkdir -p $SQLOUT_DIR
	echo " START TO COPY SQL STATEMENT"
	cp -a $SQLSRC_DIR/MFO_Oracle $SQLOUT_DIR
	cp -a $SQLSRC_DIR/MFO_PostgreSQL $SQLOUT_DIR
	echo " END TO COPY SQL STATEMENT"
}

CP_WEB()
{
	mkdir -p $WEBOUT_DIR
	echo " START TO COPY JAVA SCRIPTS"
	cp -a $WEBSRC_DIR/* $WEBOUT_DIR
	echo " END TO COPY JAVA SCRIPTS"
}

JAVASCRIPT_COMPRESS()
{
	JAVASCRIPT_MAXGAUGE_DIR="$WEBOUT_DIR"

	#common   내부의 locale 폴더를 제외한 모든 JS
	#config      내부의 style 폴더를 제외한 모든 JS
	#EventDescription  압축 X
	#Exem       모든 소스. 각각 폴더 모든 JS
	#Extjs       압축 X
	#Images    압축 X
	#Lib        폴더 안의 IMXWS.js
	#PA        style 폴더를 제외 한 모든 JS
	#Popup     폴더 안의 app.js
	#Report_download ? 해당 없음.
	#RTM      style 폴더를 제외 한 모든 JS

	# Cannot use array, cause too low bash version.

	DIR="$JAVASCRIPT_MAXGAUGE_DIR"
	DIR="$DIR $JAVASCRIPT_MAXGAUGE_DIR/common"
	DIR="$DIR $JAVASCRIPT_MAXGAUGE_DIR/config"
	DIR="$DIR $JAVASCRIPT_MAXGAUGE_DIR/config/view"
	DIR="$DIR $JAVASCRIPT_MAXGAUGE_DIR/Exem "
	DIR="$DIR $JAVASCRIPT_MAXGAUGE_DIR/Exem/chart"
	DIR="$DIR $JAVASCRIPT_MAXGAUGE_DIR/Exem/config"
	DIR="$DIR $JAVASCRIPT_MAXGAUGE_DIR/PA"
	DIR="$DIR $JAVASCRIPT_MAXGAUGE_DIR/PA/container"
	DIR="$DIR $JAVASCRIPT_MAXGAUGE_DIR/PA/view"
	DIR="$DIR $JAVASCRIPT_MAXGAUGE_DIR/popup"
	DIR="$DIR $JAVASCRIPT_MAXGAUGE_DIR/RTM"
	DIR="$DIR $JAVASCRIPT_MAXGAUGE_DIR/RTM/Frame"
	DIR="$DIR $JAVASCRIPT_MAXGAUGE_DIR/RTM/tools"
	DIR="$DIR $JAVASCRIPT_MAXGAUGE_DIR/RTM/view"

	#ls $JAVASCRIPT_MAXGAUGE_DIR/lib/IMXWS.js
	for DIR_PRE in ${DIR}
		do
		cd $DIR_PRE; 
			for APP in `ls | grep \.js | grep -v extjs`;
			do
				APP_DIR=$DIR_PRE/${APP}
				echo $APP_DIR
				jso -s -c $APP_DIR;
				unset APP_DIR;
			done
	done

	jso -s -c $JAVASCRIPT_MAXGAUGE_DIR/lib/IMXWS.js
}

MAKE_PJS_ZIP_FILE ()
{
	BUILD_NUMBER=`cat ${WEBSRC_DIR}/common/VersionControl.js | grep "var BuildNumber" | awk -F "'" '{print $2}'`
	cd $NPOUT_DIR/PlatformJS
	7z.exe a PlatformJS_${BUILD_NUMBER}.zip -x!*.zip
	PJS_FILE=`ls PlatformJS*.zip`
	mkdir -p $NPOUT_DIR/zip
	mv $SET_NP_DIR/$PJS_FILE $NPOUT_DIR/zip/
}

## JAVA PlatformJS
	CLEAN_NP_FILES
	EXECUTE_ANT_SCRIPT
	MV_NP_FILES
	INSERT_TAG_VALUE_TO_PJSCTL
	EXECUTE_CONFIGURATION
## SQL
	CP_SQL
## JAVA SCRIPT 
	CP_WEB
	## FOR DEMO IN ORDER TO REDUCE PROCESS TIME UNTIL 2017.05.22
	#JAVASCRIPT_COMPRESS
## Packaging 
	MAKE_PJS_ZIP_FILE

echo "=================================================="
echo "JAVA PlatformJS Compile & BUILD & Packaging End..!"
echo "=================================================="