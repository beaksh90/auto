## Written by EXEM Co., Ltd. DEVQA BSH
## Last modified 2017.01.25
## mfoset 스크립트중 가끔 수정되는 (동적인) 부분이 checkout중 문제가 되어 분리하게 되었음
## dynamic part of mfoset script sometimes make problems, so make it two parts.

FETCH_TAG_VER_DG ()
{
	cd $DGSRC_DIR
	git checkout $MFODG_TAG_VALUE
}

FETCH_TAG_VER_NP ()
{
	cd $NPSRC_DIR
	git checkout $MFONP_TAG_VALUE
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

cd $NPSRC_DIR
git fetch git@${GIT_IPADDR}:mfo/mfonp.git --tag
FETCH_TAG_VER_NP

### VALUE=1 require, 2 Compile&Build, 3 Send File to requirer, 0 Stand by
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
# sh $BUILD_DIR/05_build_mfoset/Innosetup.sh;
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
	cd $NPSRC_DIR/deploy/MFO/zip
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
		cp $PJS_ONLY  $PACKAGE_DIR/$MFO_PACKAGE_VER/[MFO${PJS_BUILD_NUMBER}]_[PlatformJS]_[$PJS_DATE].exe
		TOTAL_PACKAGE=`ls *MaxGauge* | grep -v "ONLY_PJS"`
		cp $TOTAL_PACKAGE $PACKAGE_DIR/$MFO_PACKAGE_VER/[MFO${PJS_BUILD_NUMBER}]_[Full_Setup]_[$PJS_DATE].exe
	;;
	totalwopjs)
		TOTAL_PACKAGE=`ls *MaxGauge*`
		cp $TOTAL_PACKAGE $PACKAGE_DIR/$MFO_PACKAGE_VER/[MFO${PJS_BUILD_NUMBER}]_[Full_Setup]_[$PJS_DATE].exe
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

CHECKOUT_MASTER_MFOBUILD()
{
	cd $BUILD_DIR
	sh $KEEP_EMPTY_SCRIPT_DIR/recoverkeep.sh
	git checkout master
}

BUILD_AS_REQ_ORDER
CHECKOUT_MASTER_MFOBUILD
