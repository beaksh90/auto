## Written by EXEM Co., Ltd. DEVQA BSH
## Last modified 2016.08.25
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

CLEAN_NP_FILES ()
{
	rm -rf $NPOUT_DIR
}

ECLIPCE_AND_BUILD()
{
	cd $ANT_BUILD_SCRIPT_DIR
	ant -buildfile build_MFO.xml
}

GET_NP_FILES()
{
	#configuration.bat파일로 막 생성된 np경로 추적함.
	cd $NPOUT_DIR
	DIR=`find ./ -name configuration.bat`
	NP_FILES_DIR=`dirname $DIR`
	echo $NP_FILES_DIR
	mv $NP_FILES_DIR  $SET_NP_DIR
	cp $NP_SERVICE_DIR/* $SET_NP_DIR
	cp $NP_CONFIG_DIF/* $SET_NP_DIR/config/
}

CHECKOUT_MASTER_NP()
{
	cd $NPSRC_DIR
	git checkout master
}

CP_WEB()
{
mkdir -p $WEBOUT_DIR
cp -av $WEBSRC_DIR/* $WEBOUT_DIR
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
	DIR="$DIR $JAVASCRIPT_MAXGAUGE_DIR\\common"
	DIR="$DIR $JAVASCRIPT_MAXGAUGE_DIR\\config"
	DIR="$DIR $JAVASCRIPT_MAXGAUGE_DIR\\config\\view"
	DIR="$DIR $JAVASCRIPT_MAXGAUGE_DIR\\Exem "
	DIR="$DIR $JAVASCRIPT_MAXGAUGE_DIR\\Exem\\chart"
	DIR="$DIR $JAVASCRIPT_MAXGAUGE_DIR\\Exem\\config"
	DIR="$DIR $JAVASCRIPT_MAXGAUGE_DIR\\PA"
	DIR="$DIR $JAVASCRIPT_MAXGAUGE_DIR\\PA\\container"
	DIR="$DIR $JAVASCRIPT_MAXGAUGE_DIR\\PA\\view"
	DIR="$DIR $JAVASCRIPT_MAXGAUGE_DIR\\popup"
	DIR="$DIR $JAVASCRIPT_MAXGAUGE_DIR\\RTM"
	DIR="$DIR $JAVASCRIPT_MAXGAUGE_DIR\\RTM\\Frame"
	DIR="$DIR $JAVASCRIPT_MAXGAUGE_DIR\\RTM\\tools"
	DIR="$DIR $JAVASCRIPT_MAXGAUGE_DIR\\RTM\\view"

	#ls $JAVASCRIPT_MAXGAUGE_DIR\\lib\\IMXWS.js
	for DIR_PRE in ${DIR}
		do
		cd $DIR_PRE; 
			for APP in `ls | grep \.js | grep -v extjs`;
			do
				APP_DIR=$DIR_PRE\\${APP}
				echo $APP_DIR
				jso -s -c $APP_DIR;
				unset APP_DIR;
			done
	done

	jso -s -c $JAVASCRIPT_MAXGAUGE_DIR\\lib\\IMXWS.js
}

CHECKOUT_MASTER_WEB()
{
	cd $WEBSRC_DIR
	git checkout 5.3.2_July
}

CP_SQL()
{
mkdir -p $SQLOUT_DIR
cp -av $SQLSRC_DIR/MFO_Oracle $SQLOUT_DIR
cp -av $SQLSRC_DIR/MFO_PostgreSQL $SQLOUT_DIR
}

CHECKOUT_MASTER_SQL()
{
	cd $SQLSRC_DIR
	git checkout MFO5.3
}

MAKE_PJS_ZIP_FILE ()
{
	BUILD_NUMBER=`cat ${WEBSRC_DIR}/common/VersionControl.js | grep "var BuildNumber" | awk -F "'" '{print $2}'`
	cd $NPOUT_DIR/PlatformJS
	7z.exe a PlatformJS_${BUILD_NUMBER}.zip -x!*.zip
}
	
NEWPJS()
{
CLEAN_NP_FILES
ECLIPCE_AND_BUILD
GET_NP_FILES
#CHECKOUT_MASTER_NP
}

WEB()
{
CP_WEB
JAVASCRIPT_COMPRESS
#CHECKOUT_MASTER_WEB
}

SQL()
{
CP_SQL
#CHECKOUT_MASTER_SQL
}


NEWPJS
SQL
WEB
MAKE_PJS_ZIP_FILE



