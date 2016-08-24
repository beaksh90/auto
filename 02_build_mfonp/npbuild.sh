#Defaul DG source Directory
NPSRC_DIR="C:\Multi-Runner\mfonp"
NPOUT_DIR="C:\Multi-Runner\mfonp\deploy\MFO"
NP_SERVICE_DIR="C:\Multi-Runner\mfobuild\02_build_mfonp\np_service"
NP_CONFIG_DIF="C:\Multi-Runner\mfobuild\02_build_mfonp\config"
SET_NP_DIR="$NPOUT_DIR\PlatformJS"

WEBSRC_DIR="C:\Multi-Runner\mfoweb"
WEBOUT_DIR="$SET_NP_DIR\svc\www\MAXGAUGE"
SQLSRC_DIR="C:\Multi-Runner\mfosql"
SQLOUT_DIR="$SET_NP_DIR\sql"

ANT_BUILD_SCRIPT_DIR="C:\Multi-Runner\mfonp\platformjs"

CLEAN_NP_FILES ()
{
	rm -rf $NPOUT_DIR
}

FETCH_TAG_VER_NP ()
{
	COMP_TAG="MFONP_TAG"
	## Here are choices of COMP_TAGs. 
	## MFOSQL_TAG, MFOWEB_TAG, MFODG_TAG, MFONP_TAG
	## MFOPG_TAG, MFORTS_TAG, MFOBUILD_TAG 
	
	echo "
	SET PAGESIZE 0 FEEDBACK OFF VERIzFY OFF HEADING OFF ECHO OFF;
	select $COMP_TAG from mfo_tag t join runner_stat r
	on t.MFO_RELEASE_VER = r.TOTAL_VER
	where r.RUN_COMP='mfototal_win';" > ./checkout_tag.sql

	TAG=`echo exit | sqlplus -slient git/git@DEVQA23 @./checkout_tag.sql`
	sleep 1
	rm ./checkout_tag.sql
	cd $NPSRC_DIR
	git checkout $TAG
}

ECLIPCE_AND_BUILD()
{
	cd $ANT_BUILD_SCRIPT_DIR
	ant -buildfile build_MFO.xml
}

GET_NP_FILES()
{
	#configuration.bat���Ϸ� �� ������ np��� ������.
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

FETCH_TAG_VER_WEB()
{
	COMP_TAG="MFOWEB_TAG"
	## Here are choices of COMP_TAGs. 
	## MFOSQL_TAG, MFOWEB_TAG, MFODG_TAG, MFONP_TAG
	## MFOPG_TAG, MFORTS_TAG, MFOBUILD_TAG 
	
	echo "
	SET PAGESIZE 0 FEEDBACK OFF VERIFY OFF HEADING OFF ECHO OFF;
	select $COMP_TAG from mfo_tag t join runner_stat r
	on t.MFO_RELEASE_VER = r.TOTAL_VER
	where r.RUN_COMP='mfototal_win';" > checkout_tag.sql

	TAG=`echo exit | sqlplus -slient git/git@DEVQA23 @checkout_tag.sql`
	rm checkout_tag.sql
	sleep 1
	cd $WEBSRC_DIR
	git checkout $TAG
}

CP_WEB()
{
mkdir -p $WEBOUT_DIR
cp -av $WEBSRC_DIR/* $WEBOUT_DIR
}

JAVASCRIPT_COMMPRESS()
{
	JAVASCRIPT_MAXGAUGE_DIR="$WEBOUT_DIR"

	#common   ������ locale ������ ������ ��� JS
	#config      ������ style ������ ������ ��� JS
	#EventDescription  ���� X
	#Exem       ��� �ҽ�. ���� ���� ��� JS
	#Extjs       ���� X
	#Images    ���� X
	#Lib        ���� ���� IMXWS.js
	#PA        style ������ ���� �� ��� JS
	#Popup     ���� ���� app.js
	#Report_download ? �ش� ����.
	#RTM      style ������ ���� �� ��� JS

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

FETCH_TAG_VER_SQL ()
{
	COMP_TAG="MFOSQL_TAG"
	## Here are choices of COMP_TAGs. 
	## MFOSQL_TAG, MFOWEB_TAG, MFODG_TAG, MFONP_TAG
	## MFOPG_TAG, MFORTS_TAG, MFOBUILD_TAG 
	cd $SQLSRC_DIR
	echo "
	SET PAGESIZE 0 FEEDBACK OFF VERIFY OFF HEADING OFF ECHO OFF;
	select $COMP_TAG from mfo_tag t join runner_stat r
	on t.MFO_RELEASE_VER = r.TOTAL_VER
	where r.RUN_COMP='mfototal_win';" > ./checkout_tag.sql
	
	TAG=`echo exit | sqlplus -slient git/git@DEVQA23 @./checkout_tag.sql`
	sleep 1
	rm ./checkout_tag.sql
	git checkout $TAG
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

NEWPJS()
{
CLEAN_NP_FILES
# FETCH_TAG_VER_NP
ECLIPCE_AND_BUILD
GET_NP_FILES
#CHECKOUT_MASTER_NP
}

WEB()
{
FETCH_TAG_VER_WEB
CP_WEB
JAVASCRIPT_COMMPRESS
CHECKOUT_MASTER_WEB
}

SQL()
{
FETCH_TAG_VER_SQL
CP_SQL
CHECKOUT_MASTER_SQL
}


NEWPJS
SQL
WEB




