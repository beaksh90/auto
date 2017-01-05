## Written by EXEM Co., Ltd. DEVQA BSH
## Last modified 2016.09.02
## Default source Directory

DG_TAR_FILE_DIR="C:/Multi-Runner/mfodg/deploy/MFO/tar"
PJS_FILE_DIR="C:/Multi-Runner/mfonp/deploy/MFO/PlatformJS"
WEBSRC_DIR="C:/Multi-Runner/mfoweb"
NPOUT_DIR="C:/Multi-Runner/mfonp/deploy/MFO"
PACK_DIR="C:/Multi-Runner/package"

REQEUIRER_CHECK()
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

GET_IPADDRESS_REPO_OR_TARGET ()
{
	##WHO, PART ���� �׳� ���� ��Ű�� ��... REQUIRER Table �ϳ� ����� ���ϴµ����� ������ ���� �� �Է� default�� QA, REPO )
	PART="REPO"
	WHO="QA"
	## Here are choices of PART. 
	## REPO, TARGET, GIT
	## Here are choices of WHO.
	## DEV, QA

	echo "SET PAGESIZE 0 FEEDBACK OFF VERIFY OFF HEADING OFF ECHO OFF;
	select ipaddr from ipaddress i join requirer r
	on i.PART = r.PART
	and i.WHO = r.WHO;" > checkout_tag.sql
	REPO_OR_TARGER_IPADDR=`echo exit | sqlplus -silent git/git@DEVQA23 @checkout_tag.sql`
	sleep 1
	rm checkout_tag.sql
	echo "REPO OR TARGET SERVER IPADDRESS = [ $REPO_OR_TARGER_IPADDR ] "
}

DG_FILE_SEND()
{
	cd $DG_TAR_FILE_DIR
	DG_TAR_FILE=`ls Maxgauge*.tar`
	for REPO_OR_TARGET_IP in $REPO_OR_TARGER_IPADDR
	do
		echo -e "git" | pscp $DG_TAR_FILE gitlab-runner@${REPO_OR_TARGET_IP}:/home/gitlab-runner/dg7000;
	done
}

PJS_FILE_SEND()
{
	cd $PJS_FILE_DIR
	PJS_FILE=`ls PlatformJS*.zip`
	for REPO_OR_TARGET_IP in $REPO_OR_TARGER_IPADDR
	do
		echo -e "git" | pscp $PJS_FILE gitlab-runner@${REPO_OR_TARGET_IP}:/home/gitlab-runner/pjs8080;
	done
}

MAKE_PJS_ZIP_FILE ()
{
	BUILD_NUMBER=`cat ${WEBSRC_DIR}/common/VersionControl.js | grep "var BuildNumber" | awk -F "'" '{print $2}'`
	cd $NPOUT_DIR/PlatformJS
	7z.exe a PlatformJS_${BUILD_NUMBER}.zip -x!*.zip
}
	
SENDING_VALUE ()
{
## VALUE=
## 1 require
## 2 Compile&Build
## 3 Send File to requirer
## 0 Waiting
 
echo "
update runner_stat set value='3' where run_comp='mfototal_win';" > checkout_tag.sql
echo exit | sqlplus -silent git/git@DEVQA23 @checkout_tag.sql
sleep 1
rm checkout_tag.sql
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
}

TAKE_LINUX_TOTAL_PACK()
{
	##WHO, PART ���� �׳� ���� ��Ű�� ��... REQUIRER Table �ϳ� ����� ���ϴµ����� ������ ���� �� �Է� default�� QA, REPO )

	echo "SET PAGESIZE 0 FEEDBACK OFF VERIFY OFF HEADING OFF ECHO OFF;
	select ipaddr from ipaddress i join requirer r
	on i.PART = 'BUILD'
	and i.WHO = r.WHO
	and i.REMARK='LINUX_PACKAGING';" > checkout_tag.sql
	REPO_OR_TARGET_IP=`echo exit | sqlplus -silent git/git@DEVQA23 @checkout_tag.sql`
	sleep 1
	rm checkout_tag.sql

	cd ${PACK_DIR}
	echo -e "git" | pscp gitlab-runner@${REPO_OR_TARGET_IP}:/home/gitlab-runner/*.tar ./;
	## ������ ��Ű���� ���⿡ ���Խ�Ŵ
	## Linux total package also included in this function.
	mv ./*.tar ${PACK_DIR}/${MFO_PACKAGE_VER}/
	
}

SEND_FILE_TO_REQUIRER()
{
case $REQ_TAG in
	totalwopjs|total)
## PlatformJS & DataGather ( total - CI PROCESS )
## total�� INNOSETUP��Ű��&������ �ڵ���ġ���� �����ϴ� �����̴�.
## totalwopjs �� INNOSETUP��Ű�� ���� 2���� PJS�� �ִ� ���� �����ϰ� �����.
	DG_FILE_SEND
	MAKE_PJS_ZIP_FILE
	PJS_FILE_SEND
	FETCH_TOTAL_VER_INFO
	TAKE_LINUX_TOTAL_PACK
	;;
	nwsd|nwd|nsd|nd|wsd|wd|sd)
## PlatformJS & DataGather
	DG_FILE_SEND
	MAKE_PJS_ZIP_FILE
	PJS_FILE_SEND
	;;
	nws|nw|ns|n|ws|w|s)
## Only PlatformJS
	MAKE_PJS_ZIP_FILE
	PJS_FILE_SEND
	;;
	d)
## Only DataGather
	DG_FILE_SEND;;
esac
}

REMOVE_RECORD_OF_REQUIRER_TABLE()
{
echo "truncate table requirer;" > insert_tag.sql
echo "update runner_stat set value='0' where run_comp='mfototal_win';" >> insert_tag.sql
REQUIRER_INFO=`echo exit | sqlplus -silent git/git@DEVQA23 @insert_tag.sql`
sleep 1
rm insert_tag.sql
}

REQEUIRER_CHECK
GET_IPADDRESS_REPO_OR_TARGET
SENDING_VALUE
SEND_FILE_TO_REQUIRER
REMOVE_RECORD_OF_REQUIRER_TABLE