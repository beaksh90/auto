## Written by EXEM Co., Ltd. DEVQA BSH
## Last modified 2017.01.11
## Total Package Script 
## 통합패키지 총괄 스크립트

## Default source Directory
export NPSRC_DIR="C:/Multi-Runner/mfonp"
export UNIPJS_DIR="C:/Multi-Runner/unipjs"
export WEBSRC_DIR="C:/Multi-Runner/mfoweb"
export SQLSRC_DIR="C:/Multi-Runner/mfosql"
export DGSRC_DIR="C:/Multi-Runner/mfodg"
export BUILD_DIR="C:/Multi-Runner/mfobuild"
export KEEP_EMPTY_SCRIPT_DIR="C:/Multi-Runner/mfobuild/06_etc"
export PACKAGE_DIR="C:/Multi-Runner/package"
export PG_INSTALL_FILE="C:/Multi-Runner/mfobuild/07_build_mfopg"
export MAIN_DIR="C:/Multi-Runner"

echo "the first step is setting git_tag "

REQUIRER_CHECK()
{
echo "SET PAGESIZE 0 FEEDBACK OFF VERIFY OFF HEADING OFF ECHO OFF;" > insert_tag.sql
echo "select WHO, PART, REQ_TAG from requirer;" >> insert_tag.sql
REQUIRER_INFO=`echo exit | sqlplus -silent git/git@DEVQA23 @insert_tag.sql`
sleep 1
rm insert_tag.sql

export USING_USER=`echo $REQUIRER_INFO | awk '{print $1}'`
export FOR_WHAT=`echo $REQUIRER_INFO | awk '{print $2}'`
export REQ_TAG=`echo $REQUIRER_INFO | awk '{print $3}'`
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
	export GIT_IPADDR=`echo exit | sqlplus -silent git/git@DEVQA23 @checkout_tag.sql`
	sleep 1
	rm checkout_tag.sql
	echo "GIT SERVER IPADDRESS = [ $GIT_IPADDR ] "
}

FETCH_TOTAL_VER_INFO ()
{
	## 자잘한 모든 형상항목의 버전을 다 보여준다.
	echo "
	SET PAGESIZE 0 FEEDBACK OFF VERIFY OFF HEADING OFF ECHO OFF;
	select MFO_RELEASE_VER, MFONP_TAG, MFOWEB_TAG, MFOSQL_TAG, MFODG_TAG, MFOBUILD_TAG from mfo_tag t join runner_stat r
	on t.MFO_RELEASE_VER = r.TOTAL_VER
	where r.RUN_COMP='mfototal_win';" > checkout_tag.sql

	TAG=`echo exit | sqlplus -silent git/git@DEVQA23 @checkout_tag.sql`
	sleep 1
	rm checkout_tag.sql
	export MFO_PACKAGE_VER=`echo $TAG | awk '{print $1}'`
	export UNIPJS_TAG_VALUE=`echo $TAG | awk '{print $2}'`
	export MFOWEB_TAG_VALUE=`echo $TAG | awk '{print $3}'`
	export MFOSQL_TAG_VALUE=`echo $TAG | awk '{print $4}'`
	export MFODG_TAG_VALUE=`echo $TAG | awk '{print $5}'`
	export MFOBUILD_TAG_VALUE=`echo $TAG | awk '{print $6}'`
##	MFORTS_TAG_VALUE=`echo $TAG | awk '{print $6}'`

	echo "MFO RELEASE VERION  = [ $MFO_PACKAGE_VER ] "
	echo "UNIPJS_TAG VERION   = [ $UNIPJS_TAG_VALUE ] "
	echo "MFOWEB_TAG VERION   = [ $MFOWEB_TAG_VALUE ] "
	echo "MFOSQL_TAG VERION   = [ $MFOSQL_TAG_VALUE ] "
	echo "MFODG_TAG VERION    = [ $MFODG_TAG_VALUE ] "
	echo "MFOBUILD_TAG VERION = [ $MFOBUILD_TAG_VALUE ] "
##	echo "MFORTS_TAG VERION   = [ $MFORTS_TAG_VALUE ] "
}

TAG_VALUE_VAILD_CHECK ()
{
TAG_VAILD_ISSUE=0
## RELEASE VERSION 제외 
TAG=`echo $TAG | awk '{print $2" "$3" "$4" "$5" "$6}'`
for TAG_VER in $TAG
do
	CONF_ITEM=`echo $TAG_VER | awk -F "_" '{print $1}'`
	CONF_GROUP=`echo $CONF_ITEM | cut -c 1-3`
	cd ${MAIN_DIR}/${CONF_ITEM}
	TAG_EXIST=`git tag -l | grep $TAG_VER | wc -l`
	
	if [ $TAG_EXIST = 0 ]; then
	git fetch git@${GIT_IPADDR}:${CONF_GROUP}/${CONF_ITEM}.git --tag
	TAG_EXIST=`git tag -l | grep $TAG_VER | wc -l`
	
		if [ $TAG_EXIST = 0 ]; then
		TAG_VAILD_ISSUE=`expr $TAG_VAILD_ISSUE + 1`; 
		echo
		echo " $TAG_VER can not be checkouted"; 
		fi
	else
		echo " $TAG_VER is available"; 
	fi
	unset TAG_EXIST
done

echo
if [ $TAG_VAILD_ISSUE -gt 0 ]; then
	echo " Tag VER Valid check : [Fail]" 
	echo " 'TAG VAILD ISSUE' is should be fixed in advancd "
	echo " To prevent next problems, Build Processing is going to be closed."
	# MAKE it stop..!
	echo "abc > ./error.sh";
	sh error.sh ; rm ./error.sh;
else
	echo " Tag VER Valid check : [Pass]" 
fi
}

FETCH_TAG_VER_DG ()
{
	cd $DGSRC_DIR
	git checkout $MFODG_TAG_VALUE
}

FETCH_TAG_VER_NP ()
{
	cd $UNIPJS_DIR
	git checkout $UNIPJS_TAG_VALUE
}

FETCH_TAG_VER_WEB()
{
	cd $WEBSRC_DIR
	git checkout $MFOWEB_TAG_VALUE
}

FETCH_TAG_VER_SQL ()
{
	cd $SQLSRC_DIR
	git checkout $MFOSQL_TAG_VALUE
}

NP_PART()
{
cd $SQLSRC_DIR
git fetch git@${GIT_IPADDR}:mfo/mfosql.git --tag
FETCH_TAG_VER_SQL

cd $WEBSRC_DIR
git fetch git@${GIT_IPADDR}:mfo/mfoweb.git --tag
FETCH_TAG_VER_WEB

cd $UNIPJS_DIR
git fetch git@${GIT_IPADDR}:uni/unipjs.git --tag
FETCH_TAG_VER_NP

### VALUE=1 require, 2 Compile&Build, 3 Send File to requirer, 0 Stand by
echo "
update runner_stat set value='2' where run_comp='mfototal_win';" > checkout_tag.sql
echo exit | sqlplus -silent git/git@DEVQA23 @checkout_tag.sql
sleep 1
rm checkout_tag.sql

sh $BUILD_DIR/02_build_mfonp/unipjsbuild.sh;
}

DG_PART()
{
cd $MAIN_DIR/mfosms
git fetch git@${GIT_IPADDR}:mfo/mfosms.git --tag

cd $MAIN_DIR/mfomail
git fetch git@${GIT_IPADDR}:mfo/mfomail.git --tag

cd $MAIN_DIR/mfoapi
git fetch git@${GIT_IPADDR}:mfo/mfoapi.git --tag

cd $DGSRC_DIR
git fetch git@${GIT_IPADDR}:mfo/mfodg.git --tag
FETCH_TAG_VER_DG

### VALUE=1 require, 2 Compile&Build, 3 Send File to requirer, 0 Stand by
echo "
update runner_stat set value='2' where run_comp='mfototal_win';" > checkout_tag.sql
echo exit | sqlplus -silent git/git@DEVQA23 @checkout_tag.sql
sleep 1
rm checkout_tag.sql

sh $BUILD_DIR/01_build_mfodg/dgbuild.sh;
}

INNOSETUP_AND_PG_PART()
{
## 2016.11.11부터 PG를 형상관리하지 않도록 로직을 변경하였다.
## Postgres DB 엔진설치, DB 설치, 유저생성, DGServer.jar install을 차례대로 실행하고 
## 그렇게 만들어진 폴더를 패키징하는 것으로 로직을 변경하였다. 

cd $PG_INSTALL_FILE
sh $PG_INSTALL_FILE/ready_pg.sh
## FOR DEMO IN ORDER TO REDUCE PROCESS TIME UNTIL 2017.05.22
sh $BUILD_DIR/05_build_mfoset/Innosetup.sh;
$PG_INSTALL_FILE/detach_pg.bat
}

RENAME_NP_FOR_DEPLOY ()
{
	if [ -d "$PACKAGE_DIR/$MFO_PACKAGE_VER" ]; then
		echo " There is duplicate Dir"
		echo " Existing Dir is going to be removed"
		rm -r $PACKAGE_DIR/$MFO_PACKAGE_VER
	fi

	## DIRECTORY '$PACKAGE_DIR/$MFO_PACKAGE_VER' WILL COLLECT EVERY FILES ABOUT DEPLOY.
	## 아래 생성되는 디렉토리에 이번에 만든 패키지 및 각종 설치파일을 모아둠
	
	mkdir $PACKAGE_DIR/$MFO_PACKAGE_VER
	cd $UNIPJS_DIR/deploy/uni/zip
	PJS_FILE=`ls PlatformJS*.zip`
	PJS_BUILD_NUMBER=`cat $WEBSRC_DIR/common/VersionControl.js | grep "var BuildNumber" | awk -F "'" '{print $2}' | awk -F "." '{print $1"."$2"."$3}'`
	PJS_DATE=`cat $WEBSRC_DIR/common/VersionControl.js | grep "var BuildNumber" | awk -F "'" '{print $2}' | awk -F "." '{print $4}'`
	cp -v $PJS_FILE $PACKAGE_DIR/$MFO_PACKAGE_VER/[MFO${PJS_BUILD_NUMBER}]_[PlatformJS]_[$PJS_DATE].zip
}

RENAME_DG_FOR_DEPLOY ()
{
	cd $DGSRC_DIR/deploy/MFO/tar
	DG_TAR_FILE=`ls Maxgauge*.tar`
	DGS_BUILD_NUMBER=`echo $DG_TAR_FILE | awk -F "MaxGauge" '{print $2}' | awk -F "_" '{print $1}'`
	DGS_DATE=`echo $DG_TAR_FILE | awk -F "." '{print $3}' | awk -F "_" '{print $2}'`
	cp -v $DG_TAR_FILE $PACKAGE_DIR/$MFO_PACKAGE_VER/[MFO${DGS_BUILD_NUMBER}]_[DataGather]_[$DGS_DATE].tar
}

RENAME_INNOSETUPFILES_FOR_DEPLOY ()
{
cd $PACKAGE_DIR

case $REQ_TAG in
	total)
	## totalwopjs 는 INNOSETUP패키지 파일 2개중 PJS만 있는 것을 제외하고 만든다.
	## FOR DEMO IN ORDER TO REDUCE PROCESS TIME UNTIL 2017.05.22
	## mv -> cp  UNTIL 2017.05.22
		PJS_ONLY=`ls *ONLY_PJS*`
		mv $PJS_ONLY  $PACKAGE_DIR/$MFO_PACKAGE_VER/[MFO${PJS_BUILD_NUMBER}]_[PlatformJS]_[$PJS_DATE].exe
		TOTAL_PACKAGE=`ls *MaxGauge* | grep -v "ONLY_PJS"`
		mv $TOTAL_PACKAGE $PACKAGE_DIR/$MFO_PACKAGE_VER/[MFO${PJS_BUILD_NUMBER}]_[Full_Setup]_[$PJS_DATE].exe
	;;
	totalwopjs)
		TOTAL_PACKAGE=`ls *MaxGauge*`
		mv $TOTAL_PACKAGE $PACKAGE_DIR/$MFO_PACKAGE_VER/[MFO${PJS_BUILD_NUMBER}]_[Full_Setup]_[$PJS_DATE].exe
	;;
esac
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
case $REQ_TAG in
	totalwopjs|total)
## PlatformJS & DataGather ( total - CI PROCESS )
## total은 INNOSETUP패키지&리눅스 자동설치까지 포함하는 개념이다.
## totalwopjs 는 INNOSETUP패키지 파일 2개중 PJS만 있는 것을 제외하고 만든다.
	DG_PART
	NP_PART
	INNOSETUP_AND_PG_PART
	## PACKAGE DIR MADE BY FUNC 'RENAME_NP_FOR_DEPLOY'
	RENAME_NP_FOR_DEPLOY
	RENAME_DG_FOR_DEPLOY
	RENAME_INNOSETUPFILES_FOR_DEPLOY
	WRITE_DOWN_TAG_INFO
	SEND_DG_PJS_LINUX_BUILD_SRV
	;;
	nwsd|nwd|nsd|nd|wsd|wd|sd)
## PlatformJS & DataGahter
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
TAG_VALUE_VAILD_CHECK
## AS of 170125 Dynamic Part was seperated in the 'mfoset_dynamic_part'
## AS of 170719 Revert changes of 170125.
# sh $BUILD_DIR/05_build_mfoset/mfoset_dynamic_part.sh;
BUILD_AS_REQ_ORDER
# CHECKOUT_MASTER_MFOBUILD
