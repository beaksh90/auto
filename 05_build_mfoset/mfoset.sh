## Written by EXEM Co., Ltd. DEVQA BSH
## Last modified 2016.08.25
## Total Package Script 
## 통합패키지 총괄 스크립트
echo "the first step is setting git_tag "
NPSRC_DIR="C:/Multi-Runner/mfonp"
WEBSRC_DIR="C:/Multi-Runner/mfoweb"
SQLSRC_DIR="C:/Multi-Runner/mfosql"
DGSRC_DIR="C:/Multi-Runner/mfodg"
PGSRC_DIR="C:/Multi-Runner/mfopg/Database"
BUILD_DIR="C:/Multi-Runner/mfobuild"
KEEP_EMPTY_SCRIPT_DIR="C:/Multi-Runner/mfobuild/06_etc"

RECOVER_KEEP()
{
sh $KEEP_EMPTY_SCRIPT_DIR/recoverkeep.sh
}

REMOVE_KEEP()
{
sh $KEEP_EMPTY_SCRIPT_DIR/removekeep.sh
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

	TAG=`echo exit | sqlplus -slient git/git@DEVQA23 @checkout_tag.sql`
	sleep 1
	rm checkout_tag.sql
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

	TAG=`echo exit | sqlplus -slient git/git@DEVQA23 @checkout_tag.sql`
	sleep 1
	rm checkout_tag.sql
	cd $BUILD_DIR
	git checkout $TAG
}

FETCH_TAG_VER_PG ()
{
	COMP_TAG="MFOPG_TAG"
	## Here are choices of COMP_TAGs. 
	## MFOSQL_TAG, MFOWEB_TAG, MFODG_TAG, MFONP_TAG
	## MFOPG_TAG, MFORTS_TAG, MFOBUILD_TAG 
		
	echo "
	SET PAGESIZE 0 FEEDBACK OFF VERIFY OFF HEADING OFF ECHO OFF;
	select $COMP_TAG from mfo_tag t join runner_stat r
	on t.MFO_RELEASE_VER = r.TOTAL_VER
	where r.RUN_COMP='mfototal_win';" > checkout_tag.sql

	TAG=`echo exit | sqlplus -slient git/git@DEVQA23 @checkout_tag.sql`
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
	TAG=`echo exit | sqlplus -slient git/git@DEVQA23 @checkout_tag.sql`
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

	TAG=`echo exit | sqlplus -slient git/git@DEVQA23 @checkout_tag.sql`
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

	TAG=`echo exit | sqlplus -slient git/git@DEVQA23 @checkout_tag.sql`
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
	
	TAG=`echo exit | sqlplus -slient git/git@DEVQA23 @checkout_tag.sql`
	sleep 1
	rm checkout_tag.sql
	git checkout $TAG
}

FETCH_TOTAL_VER_INFO

cd $BUILD_DIR
RECOVER_KEEP
git pull git@10.10.202.196:mfo/mfobuild.git master --tag
FETCH_TAG_VER_BUILD
REMOVE_KEEP

cd $PGSRC_DIR
RECOVER_KEEP
git pull git@10.10.202.196:mfo/mfopg.git master --tag
FETCH_TAG_VER_PG
REMOVE_KEEP


cd $SQLSRC_DIR
git pull git@10.10.202.196:mfo/mfosql.git MFO5.3 --tag
FETCH_TAG_VER_SQL

cd $WEBSRC_DIR
git pull git@10.10.202.196:mfo/mfoweb.git 5.3.2_July --tag
FETCH_TAG_VER_WEB

cd $NPSRC_DIR
git pull git@10.10.202.196:mfo/mfonp.git master --tag
FETCH_TAG_VER_NP

cd $DGSRC_DIR
git pull git@10.10.202.196:mfo/mfodg.git master --tag
FETCH_TAG_VER_DG

sh $BUILD_DIR/01_build_mfodg/dgbuild.sh;
sh $BUILD_DIR/02_build_mfonp/npbuild.sh;
sh $BUILD_DIR/05_build_mfoset/Innosetup.sh;