## Written by EXEM Co., Ltd. DEVQA BSH
## Last modified 2016.09.02
## Default source Directory

DG_TAR_FILE_DIR="C:/Multi-Runner/mfodg/deploy/MFO/tar"
PJS_FILE_DIR="C:/Multi-Runner/mfonp/deploy/MFO/PlatformJS"

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
	##WHO, PART 쿼리 그냥 조인 시키면 됨... Wanter Table 하나 만들고 원하는데에서 쿼리로 변형 후 입력 default는 QA, REPO ㅇㅇ)
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

SEND_FILE_TO_REQUIRER()
{
case $REQ_TAG in
	total|nwsd|nwd|nsd|nd|wsd|wd|sd)
## PlatformJS & DataGahter ( total - CI PROCESS )
## total은 INNOSETUP패키지&리눅스 자동설치까지 포함하는 개념이다.
	DG_FILE_SEND
	PJS_FILE_SEND
	;;
	nws|nw|ns|n|ws|w|s)
## Only PlatformJS
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

