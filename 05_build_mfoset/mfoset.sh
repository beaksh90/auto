## Written by EXEM Co., Ltd. DEVQA BSH
## Last modified 2017.01.11
## Total Package Script 
## 통합패키지 총괄 스크립트

## Default source Directory
export NPSRC_DIR="C:/Multi-Runner/mfonp"
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
	export MFO_PACKAGE_VER=${TAG}
	echo "MFO RELEASE VERION = [ $TAG ] "
	
	
	## 자잘한 모든 형상항목의 버전을 다 보여준다.
	echo "
	SET PAGESIZE 0 FEEDBACK OFF VERIFY OFF HEADING OFF ECHO OFF;
	select MFONP_TAG,MFOWEB_TAG,MFOSQL_TAG,MFODG_TAG,MFOBUILD_TAG from mfo_tag t join runner_stat r
	on t.MFO_RELEASE_VER = r.TOTAL_VER
	where r.RUN_COMP='mfototal_win';" > checkout_tag.sql

	TAG=`echo exit | sqlplus -silent git/git@DEVQA23 @checkout_tag.sql`
	sleep 1
	rm checkout_tag.sql
	export MFONP_TAG_VALUE=`echo $TAG | awk '{print $1}'`
	export MFOWEB_TAG_VALUE=`echo $TAG | awk '{print $2}'`
	export MFOSQL_TAG_VALUE=`echo $TAG | awk '{print $3}'`
	export MFODG_TAG_VALUE=`echo $TAG | awk '{print $4}'`
	export MFOBUILD_TAG_VALUE=`echo $TAG | awk '{print $5}'`
##	MFORTS_TAG_VALUE=`echo $TAG | awk '{print $6}'`
	
	echo "MFONP_TAG VERION    = [ $MFONP_TAG_VALUE ] "
	echo "MFOWEB_TAG VERION   = [ $MFOWEB_TAG_VALUE ] "
	echo "MFOSQL_TAG VERION   = [ $MFOSQL_TAG_VALUE ] "
	echo "MFODG_TAG VERION    = [ $MFODG_TAG_VALUE ] "
	echo "MFOBUILD_TAG VERION = [ $MFOBUILD_TAG_VALUE ] "
##	echo "MFORTS_TAG VERION   = [ $MFORTS_TAG_VALUE ] "
}

TAG_VALUE_VAILD_CHECK ()
{
TAG_VAILD_ISSUE=0

for TAG_VER in $TAG
do
	CONF_ITEM=`echo $TAG_VER | awk -F "_" '{print $1}'`
	cd ${MAIN_DIR}/${CONF_ITEM}
	TAG_EXIST=`git tag -l | grep $TAG_VER | wc -l`
	
	if [ $TAG_EXIST = 0 ]; then
	git fetch git@${GIT_IPADDR}:mfo/${CONF_ITEM}.git --tag
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

REQUIRER_CHECK
GET_IPADDRESS_GIT_SERVER
FETCH_TOTAL_VER_INFO
TAG_VALUE_VAILD_CHECK
MFOBUILD_PART
sh $BUILD_DIR/05_build_mfoset/mfoset_dynamic_part.sh;
## AS of 170125 Dynamic Part was seperated in the 'mfoset_dynamic_part'
# BUILD_AS_REQ_ORDER
# CHECKOUT_MASTER_MFOBUILD
