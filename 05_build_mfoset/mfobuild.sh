## Written by EXEM Co., Ltd. DEVQA BSH
## Last modified 2017.07.19
##
## QA가 빌드할 때, 먼저 스크립트(mfoset.sh)가 실행된다. 
## 스크립트 끝에는 mfobuild 항목을 특정시점으로 Checkout하는데 
## 현 실행중인 스크립트(mfoset.sh)가 변경사항이 있는 경우 
## Git에서 변경을 시도 VS OS에서 locking, 즉, Conflict가 발생한다. 
##
## 이를 커버하기 위해 checkout 명령을 수행하는 파일은 변경사항이 영원히 없도록 한다.

## Default source Directory
export BUILD_DIR="C:/Multi-Runner/mfobuild"
export KEEP_EMPTY_SCRIPT_DIR="C:/Multi-Runner/mfobuild/06_etc"
export MAIN_DIR="C:/Multi-Runner"

echo "the first step is setting git_tag "

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

MFOBUILD_PART()
{
cd $BUILD_DIR
sh $KEEP_EMPTY_SCRIPT_DIR/recoverkeep.sh
git fetch git@${GIT_IPADDR}:mfo/mfobuild.git --tag
FETCH_TAG_VER_BUILD
sh $KEEP_EMPTY_SCRIPT_DIR/removekeep.sh
}

CHECKOUT_MASTER_MFOBUILD()
{
	cd $BUILD_DIR
	sh $KEEP_EMPTY_SCRIPT_DIR/recoverkeep.sh
	git checkout master -f
}

RECOVER_CONFLICT_FILE()
{
	git checkout ${BUILD_DIR}/05_build_mfoset/mfoset_dynamic_part.sh
	git checkout ${BUILD_DIR}/05_build_mfoset/mfoset.set
}

GET_IPADDRESS_GIT_SERVER
MFOBUILD_PART
sh $BUILD_DIR/05_build_mfoset/mfoset.sh;
## AS of 170719 , 'mfoset.sh , mfoset_dynamic_part.sh => mfoset.sh'
CHECKOUT_MASTER_MFOBUILD