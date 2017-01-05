## Written by EXEM Co., Ltd. DEVQA BSH
## Last modified 2016.08.25
## Total Package Script 
## 통합패키지 총괄 스크립트
echo "the first step is setting git_tag "
NPSRC_DIR="C:/Multi-Runner/mfonp"
WEBSRC_DIR="C:/Multi-Runner/mfoweb"
SQLSRC_DIR="C:/Multi-Runner/mfosql"
DGSRC_DIR="C:/Multi-Runner/mfodg"
PGSRC_DIR="C:/Database"
BUILD_DIR="C:/Multi-Runner/mfobuild"
KEEP_EMPTY_SCRIPT_DIR="C:/Multi-Runner/mfobuild/06_etc"
PACKAGE_DIR="C:/Multi-Runner/package"
PG_INSTALL_FILE="C:/Multi-Runner/mfobuild/07_build_mfopg"

RECOVER_KEEP()
{
sh $KEEP_EMPTY_SCRIPT_DIR/recoverkeep.sh
}

REMOVE_KEEP()
{
sh $KEEP_EMPTY_SCRIPT_DIR/removekeep.sh
}

REQUIRER_CHECK()
{
echo "SET PAGESIZE 0 FEEDBACK OFF VERIFY OFF HEADING OFF ECHO OFF;" > insert_tag.sql
echo "select WHO, PART, REQ_TAG from requirer;" >> insert_tag.sql
REQUIRER_INFO=`echo exit | sqlplus -silent git/git@DEVQA23 @insert_tag.sql`
sleep 1
rm insert_tag.sql

USING_USER=`echo $REQUIRER_INFO | awk '{print $1}'`
FOR_WHAT=`echo $REQUIRER_INFO | awk '{print $2}'`
REQ_TAG=`echo $REQUIRER_INFO | awk '{print $3}'`
}

GET_IPADDRESS_GIT_SERVER ()
{
	PART="GIT"
	WHO="QA"
	## Here are choices of PART. 
	## REPO, TARGET, GIT
	## Here are choices of WHO.
	## DEV, QA

	echo "SET PAGESIZE 0 FEEDBACK OFF VERIFY OFF HEADING OFF ECHO OFF;
	select ipaddr from ipaddress
	where PART='$PART'
	and WHO='$WHO';" > checkout_tag.sql
	GIT_IPADDR=`echo exit | sqlplus -silent git/git@DEVQA23 @checkout_tag.sql`
	sleep 1
	rm checkout_tag.sql
	echo "GIT SERVER IPADDRESS = [ $GIT_IPADDR ] "
}

FETCH_TOTAL_VER_INFO ()
{
	COMP_TAG="MFO_RELEASE_VER"
	## Here are choices of COMP_TAGs. 
	## MFOSQL_TAG, MFOWEB_TAG, MFODG_TAG, MFONP_TAG
	## MFOPG_TAG, MFORTS_TAG, MFOBUILD_TAG , MFO_RELEASE_VER
		
	echo "
	SET PAGESIZE 0 FEEDBACK OFF VERIFY OFF HEADING OFF ECHO OFF;
	select $COMP_TAG from mfo_tag t join runner_stat r
	on t.MFO_RELEASE_VER = r.TOTAL_VER
	where r.RUN_COMP='mfototal_win';" > checkout_tag.sql

	TAG=`echo exit | sqlplus -silent git/git@DEVQA23 @checkout_tag.sql`
	sleep 1
	rm checkout_tag.sql
	MFO_PACKAGE_VER=${TAG}
	echo "MFO RELEASE VERION = [ $TAG ] "
}

FETCH_TAG_VER_BUILD ()
{
	COMP_TAG="MFOBUILD_TAG"
	## Here are choices of COMP_TAGs. 
	## MFOSQL_TAG, MFOWEB_TAG, MFODG_TAG, MFONP_TAG
	## MFOPG_TAG, MFORTS_TAG, MFOBUILD_TAG 
		
	echo "
	SET PAGESIZE 0 FEEDBACK OFF VERIFY OFF HEADING OFF ECHO OFF;
	select $COMP_TAG from mfo_tag t join runner_stat r
	on t.MFO_RELEASE_VER = r.TOTAL_VER
	where r.RUN_COMP='mfototal_win';" > checkout_tag.sql

	TAG=`echo exit | sqlplus -silent git/git@DEVQA23 @checkout_tag.sql`
	sleep 1
	rm checkout_tag.sql
	cd $BUILD_DIR
	git checkout $TAG
}

FETCH_TAG_VER_PG ()
{
	## 2016년 11월 11일 부로 형상관리항목에서 제외시킨다.
	## Postgres DB 엔진설치, DB 설치, 유저생성, DGServer.jar install을 차례대로 실행하고 
	## 그렇게 만들어진 폴더를 패키징하는 것으로 로직을 변경하였다. 
	## As of 2016.11.11, We will Not manage pg version and change logic toward install pg_db every INNOSETUP PACKAGING
	COMP_TAG="MFOPG_TAG"
	## Here are choices of COMP_TAGs. 
	## MFOSQL_TAG, MFOWEB_TAG, MFODG_TAG, MFONP_TAG
	## MFOPG_TAG, MFORTS_TAG, MFOBUILD_TAG 
		
	echo "
	SET PAGESIZE 0 FEEDBACK OFF VERIFY OFF HEADING OFF ECHO OFF;
	select $COMP_TAG from mfo_tag t join runner_stat r
	on t.MFO_RELEASE_VER = r.TOTAL_VER
	where r.RUN_COMP='mfototal_win';" > checkout_tag.sql

	TAG=`echo exit | sqlplus -silent git/git@DEVQA23 @checkout_tag.sql`
	sleep 1
	rm checkout_tag.sql
	cd $PGSRC_DIR
	git checkout $TAG
}

FETCH_TAG_VER_DG ()
{
	COMP_TAG="MFODG_TAG"
	## Here are choices of COMP_TAGs. 
	## MFOSQL_TAG, MFOWEB_TAG, MFODG_TAG, MFONP_TAG
	## MFOPG_TAG, MFORTS_TAG, MFOBUILD_TAG 
	cd $DGSRC_DIR
	echo "
	SET PAGESIZE 0 FEEDBACK OFF VERIFY OFF HEADING OFF ECHO OFF;
	select $COMP_TAG from mfo_tag t join runner_stat r
	on t.MFO_RELEASE_VER = r.TOTAL_VER
	where r.RUN_COMP='mfototal_win';" > checkout_tag.sql
	TAG=`echo exit | sqlplus -silent git/git@DEVQA23 @checkout_tag.sql`
	sleep 1
	rm checkout_tag.sql
	git checkout $TAG
}

FETCH_TAG_VER_NP ()
{
	COMP_TAG="MFONP_TAG"
	## Here are choices of COMP_TAGs. 
	## MFOSQL_TAG, MFOWEB_TAG, MFODG_TAG, MFONP_TAG
	## MFOPG_TAG, MFORTS_TAG, MFOBUILD_TAG 
		
	echo "
	SET PAGESIZE 0 FEEDBACK OFF VERIFY OFF HEADING OFF ECHO OFF;
	select $COMP_TAG from mfo_tag t join runner_stat r
	on t.MFO_RELEASE_VER = r.TOTAL_VER
	where r.RUN_COMP='mfototal_win';" > checkout_tag.sql

	TAG=`echo exit | sqlplus -silent git/git@DEVQA23 @checkout_tag.sql`
	sleep 1
	rm checkout_tag.sql
	cd $NPSRC_DIR
	git checkout $TAG
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

	TAG=`echo exit | sqlplus -silent git/git@DEVQA23 @checkout_tag.sql`
	rm checkout_tag.sql
	sleep 1
	cd $WEBSRC_DIR
	git checkout $TAG
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
	where r.RUN_COMP='mfototal_win';" > checkout_tag.sql
	
	TAG=`echo exit | sqlplus -silent git/git@DEVQA23 @checkout_tag.sql`
	sleep 1
	rm checkout_tag.sql
	git checkout $TAG
}

MFOBUILD_PART()
{
cd $BUILD_DIR
RECOVER_KEEP
git fetch git@${GIT_IPADDR}:mfo/mfobuild.git --tag
FETCH_TAG_VER_BUILD
REMOVE_KEEP
}

NP_PART()
{
cd $SQLSRC_DIR
git fetch git@${GIT_IPADDR}:mfo/mfosql.git --tag
FETCH_TAG_VER_SQL

cd $WEBSRC_DIR
git fetch git@${GIT_IPADDR}:mfo/mfoweb.git --tag
FETCH_TAG_VER_WEB

cd $NPSRC_DIR
git fetch git@${GIT_IPADDR}:mfo/mfonp.git --tag
FETCH_TAG_VER_NP

### VALUE=1 require, 2 Compile&Build, 3 Send File to requirer, 4 Waiting
echo "
update runner_stat set value='2' where run_comp='mfototal_win';" > checkout_tag.sql
echo exit | sqlplus -silent git/git@DEVQA23 @checkout_tag.sql
sleep 1
rm checkout_tag.sql

sh $BUILD_DIR/02_build_mfonp/npbuild.sh;
}

DG_PART()
{
cd $DGSRC_DIR
git fetch git@${GIT_IPADDR}:mfo/mfodg.git --tag
FETCH_TAG_VER_DG

### VALUE=1 require, 2 Compile&Build, 3 Send File to requirer, 4 Waiting
echo "
update runner_stat set value='2' where run_comp='mfototal_win';" > checkout_tag.sql
echo exit | sqlplus -silent git/git@DEVQA23 @checkout_tag.sql
sleep 1
rm checkout_tag.sql

sh $BUILD_DIR/01_build_mfodg/dgbuild.sh;
}

INNOSETUP_PART()
{
## 2016.11.11부터 PG를 형상관리하지 않도록 로직을 변경하였다.
# cd $PGSRC_DIR
# RECOVER_KEEP
# git pull git@${GIT_IPADDR}:mfo/mfopg.git master --tag
# FETCH_TAG_VER_PG
# REMOVE_KEEP
## 2016.11.11부터 PG를 형상관리하지 않도록 로직을 변경하였다.
cd $PG_INSTALL_FILE
sh $PG_INSTALL_FILE/ready_pg.sh
sh $BUILD_DIR/05_build_mfoset/Innosetup.sh;
$PG_INSTALL_FILE/detach_pg.bat
}

RENAME_NP_FOR_DEPLOY ()
{
	## DIRECTORY '$PACKAGE_DIR/$MFO_PACKAGE_VER' WILL COLLECT EVERY FILES ABOUT DEPLOY.
	## 아래 생성되는 디렉토리에 이번에 만든 패키지 및 각종 설치파일을 모아둠
	mkdir $PACKAGE_DIR/$MFO_PACKAGE_VER
	
	PJS_BUILD_NUMBER=`cat $WEBSRC_DIR/common/VersionControl.js | grep "var BuildNumber" | awk -F "'" '{print $2}' | awk -F "." '{print $1"."$2"."$3}'`
	PJS_DATE=`cat cat $WEBSRC_DIR/common/VersionControl.js | grep "var BuildNumber" | awk -F "'" '{print $2}' | awk -F "." '{print $4}'`
	cd $NPSRC_DIR/deploy/MFO/PlatformJS
	PJS_FILE=`ls PlatformJS*.zip`
	cp -av $PJS_FILE $PACKAGE_DIR/$MFO_PACKAGE_VER/[MFO${PJS_BUILD_NUMBER}]_[PlatformJS]_[$PJS_DATE].zip
}

RENAME_DG_FOR_DEPLOY ()
{
	cd $DGSRC_DIR/deploy/MFO/tar
	DG_TAR_FILE=`ls Maxgauge*.tar`
	DGS_BUILD_NUMBER=`echo $DG_TAR_FILE | awk -F "MaxGauge" '{print $2}' | awk -F "_" '{print $1}'`
	DGS_DATE=`echo $DG_TAR_FILE | awk -F "." '{print $3}' | awk -F "_" '{print $2}'`
	cp -av $DG_TAR_FILE $PACKAGE_DIR/$MFO_PACKAGE_VER/[MFO${DGS_BUILD_NUMBER}]_[DataGather]_[$DGS_DATE].tar
}

RENAME_INNOSETUPFILES_FOR_DEPLOY ()
{
	cd $PACKAGE_DIR
	PJS_ONLY=`ls *ONLY_PJS*`
	mv $PJS_ONLY  $PACKAGE_DIR/$MFO_PACKAGE_VER/[MFO${PJS_BUILD_NUMBER}]_[PlatformJS]_[$PJS_DATE].exe
	TOTAL_PACKAGE=`ls *MaxGauge*`
	mv $TOTAL_PACKAGE $PACKAGE_DIR/$MFO_PACKAGE_VER/[MFO${PJS_BUILD_NUMBER}]_[Full_Setsup]_[$PJS_DATE].exe
}

WRITE_DOWN_TAG_INFO ()
{
	echo "
	SET PAGESIZE 0 FEEDBACK OFF VERIFY OFF HEADING OFF ECHO OFF;
	select  mfo_release_ver, mfonp_tag, mfoweb_tag, mfosql_tag, mfodg_tag, mforts_tag from mfo_tag t join runner_stat r
	on t.MFO_RELEASE_VER = r.TOTAL_VER
	where r.RUN_COMP='mfototal_win';" > checkout_tag.sql

	TAG=`echo exit | sqlplus -silent git/git@DEVQA23 @checkout_tag.sql`
	sleep 1
	rm checkout_tag.sql
	cd $PACKAGE_DIR/$MFO_PACKAGE_VER
	for i in $TAG
	do
	echo -e "$i\n" >> TAG_INFO.txt;
	done
}

SEND_DG_PJS_LINUX_BUILD_SRV ()
{
sh ${KEEP_EMPTY_SCRIPT_DIR}/sendfile_linux_packaging.sh;
}

BUILD_AS_REQ_ORDER()
{
	MFOBUILD_PART

case $REQ_TAG in
	totalwopjs|total)
## total은 INNOSETUP패키지&리눅스 자동설치까지 포함하는 개념이다.
	DG_PART
	NP_PART
	INNOSETUP_PART
	RENAME_NP_FOR_DEPLOY
	RENAME_DG_FOR_DEPLOY
	RENAME_INNOSETUPFILES_FOR_DEPLOY
	WRITE_DOWN_TAG_INFO
	SEND_DG_PJS_LINUX_BUILD_SRV
	;;
	nwsd|nwd|nsd|nd|wsd|wd|sd)
## PlatformJS & DataGahter ( total - CI PROCESS )
	DG_PART
	NP_PART
	;;
	nws|nw|ns|n|ws|w|s)
## Only PlatformJS
	NP_PART
	;;
	d)
## Only DataGather
	DG_PART
	;;
esac
}

REQUIRER_CHECK
GET_IPADDRESS_GIT_SERVER
FETCH_TOTAL_VER_INFO
BUILD_AS_REQ_ORDER
