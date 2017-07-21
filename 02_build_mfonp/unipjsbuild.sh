## Written by EXEM Co., Ltd. DEVQA BSH
## Last modified 2017.01.11
## Default source Directory
PJSSRC_DIR="C:/Multi-Runner/unipjs"
PJSOUT_DIR="C:/Multi-Runner/unipjs/deploy/uni"
UNITPL_DIR="C:/Multi-Runner/unitpl"
SET_PJS_DIR="$PJSOUT_DIR/PlatformJS"

WEBSRC_DIR="C:/Multi-Runner/mfoweb"
WEBOUT_DIR="$SET_PJS_DIR/svc/www/MAXGAUGE"
SQLSRC_DIR="C:/Multi-Runner/mfosql"
SQLOUT_DIR="$SET_PJS_DIR/sql"

ANT_BUILD_SCRIPT_DIR="C:/Multi-Runner/unipjs/"
## I Think that there are so tiny Changes of component
## 변화가 많치 않은 형상항목이라 하드코딩 처리하였고, 필요시 매뉴얼하게 변경함.
UNITPL_TAG_VER="unitpl_170720.01"


echo "===================================================="
echo "JAVA PlatformJS Compile & BUILD & Packaging Start..!"
echo "===================================================="

CLEAN_NP_FILES ()
{
	rm -rf $PJSOUT_DIR
}

GIT_CHECKOUT_UNITPL()
{
cd $UNITPL_DIR

	TAG_EXIST=`git tag -l | grep $UNITPL_TAG_VER | wc -l`
	
	if [ $TAG_EXIST = 0 ]; then
		git fetch git@${GIT_IPADDR}:uni/${UNITPL_TAG_VER}.git --tag
		TAG_EXIST=`git tag -l | grep $UNITPL_TAG_VER | wc -l`
	
		if [ $TAG_EXIST = 0 ]; then
		TAG_VAILD_ISSUE=`expr $TAG_VAILD_ISSUE + 1`; 
		echo
		echo " $UNITPL_TAG_VER can not be checkouted"; 
		fi
	else
		echo " $UNITPL_TAG_VER is available"; 
	fi

git checkout $UNITPL_TAG_VER
}

EXECUTE_ANT_SCRIPT()
{
	cd $ANT_BUILD_SCRIPT_DIR
	ant -buildfile build_uni.xml
}

MV_NP_FILES()
{
	# jar 두개만 옮기는 식으로 변경함.
	cd $PJSOUT_DIR
	CONFIGURE_JAR=`find ./ -name platformjs_configuration.jar `
	PJS_JAR=`find ./ -name exem_platformjs.jar`
	cp -a ${UNITPL_DIR} ${SET_PJS_DIR}
	rm -rf ${SET_PJS_DIR}/.gitattributes
	rm -rf $SET_PJS_DIR/.git
	mv $CONFIGURE_JAR  $SET_PJS_DIR/app
	mv $PJS_JAR  $SET_PJS_DIR/svc/www/WEB-INF/lib


	CONFIGURE_SH=$SET_PJS_DIR/configuration.sh
	CONFIGURE_BAT=$SET_PJS_DIR/configuration.bat
	CONFIGURE_CHANGE=$SET_PJS_DIR/configuration.txt
	CONF_ITEM_GROUP="MFO"
	sed -e 's/MFJ/'${CONF_ITEM_GROUP}'/g' $CONFIGURE_SH > ${CONFIGURE_CHANGE}
	mv ${CONFIGURE_CHANGE} $CONFIGURE_SH
	sed -e 's/MFJ/'${CONF_ITEM_GROUP}'/g' $CONFIGURE_BAT > ${CONFIGURE_CHANGE}
	mv ${CONFIGURE_CHANGE} $CONFIGURE_BAT
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
	PJSCTL_TEMPLETE=$SET_PJS_DIR/config/template/pjsctl_linux
	PJSCTL_TEMPLETE_SED=$SET_PJS_DIR/config/template/pjsctl_linux_sed
	sed -e 's/MFONP\ will_support_as_of_2016.11/UNIPJS\ '$MFONP_TAG_VALUE'/g' $PJSCTL_TEMPLETE > ${PJSCTL_TEMPLETE_SED}
	mv ${PJSCTL_TEMPLETE_SED} $PJSCTL_TEMPLETE
	sed -e 's/__PRODUCT__WEB\ will_support_as_of_2016.11/__PRODUCT__WEB\ '$MFOWEB_TAG_VALUE'/g' $PJSCTL_TEMPLETE > ${PJSCTL_TEMPLETE_SED}
	mv ${PJSCTL_TEMPLETE_SED} $PJSCTL_TEMPLETE
	sed -e 's/__PRODUCT__SQL\ will_support_as_of_2016.11/__PRODUCT__SQL\ '$MFOSQL_TAG_VALUE'/g' $PJSCTL_TEMPLETE > ${PJSCTL_TEMPLETE_SED}
	mv ${PJSCTL_TEMPLETE_SED} $PJSCTL_TEMPLETE
}

EXECUTE_CONFIGURATION ()
{
	## 2017.02.10 configuration 실행하여 생성하는 것으로 로직을 변경함
	cd $SET_PJS_DIR
	echo -e  "1\n\n\n\n\n\n\n\n\n\n\n1\n\n0\n\n\n" | sh $SET_PJS_DIR/configuration.bat
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
	cd $PJSOUT_DIR/PlatformJS
	7z.exe a PlatformJS_${BUILD_NUMBER}.zip -x!*.zip
	PJS_FILE=`ls PlatformJS*.zip`
	mkdir -p $PJSOUT_DIR/zip
	mv $SET_PJS_DIR/$PJS_FILE $PJSOUT_DIR/zip/
}

## JAVA PlatformJS
	CLEAN_NP_FILES
	GIT_CHECKOUT_UNITPL
	EXECUTE_ANT_SCRIPT
	MV_NP_FILES
	INSERT_TAG_VALUE_TO_PJSCTL
	EXECUTE_CONFIGURATION
## SQL
	CP_SQL
## JAVA SCRIPT 
	CP_WEB
	## FOR DEMO IN ORDER TO REDUCE PROCESS TIME UNTIL 2017.05.22
	JAVASCRIPT_COMPRESS
## Packaging 
	MAKE_PJS_ZIP_FILE

echo "=================================================="
echo "JAVA PlatformJS Compile & BUILD & Packaging End..!"
echo "=================================================="