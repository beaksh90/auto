## Written by EXEM Co., Ltd. DEVQA BSH
## Last modified 2017.01.03
## Default source Directory

DG_TAR_FILE_DIR="C:/Multi-Runner/mfodg/deploy/MFO/tar"
PJS_FILE_DIR="C:/Multi-Runner/mfonp/deploy/MFO/PlatformJS"
WEBSRC_DIR="C:/Multi-Runner/mfoweb"
NPOUT_DIR="C:/Multi-Runner/mfonp/deploy/MFO"

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
	##WHO, PART 쿼리 그냥 조인 시키면 됨... REQUIRER Table 하나 만들고 원하는데에서 쿼리로 변형 후 입력 default는 QA, REPO )
	PART="REPO"
	WHO="QA"
	REMARK="LINUX_PACKAGING"
	## Here are choices of PART. 
	## REPO, TARGET, GIT
	## Here are choices of WHO.
	## DEV, QA

	echo "SET PAGESIZE 0 FEEDBACK OFF VERIFY OFF HEADING OFF ECHO OFF;
	select ipaddr from ipaddress i join requirer r
	on i.PART = 'BUILD'
	and i.WHO = r.WHO
	and i.REMARK='LINUX_PACKAGING';" > checkout_tag.sql
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
	## 리눅스 패키징을 위해 만든 압축파일이라 지운다, 추후 send file 섹터에서 다시 압축함.
	rm $PJS_FILE
}

MAKE_PJS_ZIP_FILE ()
{
	BUILD_NUMBER=`cat ${WEBSRC_DIR}/common/VersionControl.js | grep "var BuildNumber" | awk -F "'" '{print $2}'`
	cd $NPOUT_DIR/PlatformJS
	7z.exe a PlatformJS_${BUILD_NUMBER}.zip -x!*.zip
}

SEND_FILE_TO_REQUIRER()
{
case $REQ_TAG in
	totalwopjs|total)
## PlatformJS & DataGather ( total - CI PROCESS )
## total은 INNOSETUP패키지&리눅스 자동설치까지 포함하는 개념이다.
## totalwopjs는 INNOSETUP패키지 파일 2개중 PJS만 있는 것을 제외하고 만든다.
	DG_FILE_SEND
	MAKE_PJS_ZIP_FILE
	PJS_FILE_SEND
	;;
esac
}

REQEUIRER_CHECK
GET_IPADDRESS_REPO_OR_TARGET
SEND_FILE_TO_REQUIRER

