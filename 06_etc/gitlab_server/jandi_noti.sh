#!/bin/bash
## Written by EXEM Co., Ltd. DEVQA BSH
## Last modified 2017.05.25
## Default source Directory
JANDI_DIR="/home/gitlab-runner/.jandi"

CHECK_IF_REQUIRER_EXIST ()
{
        echo "
        SET PAGESIZE 0 FEEDBACK OFF VERIFY OFF HEADING OFF ECHO OFF;
        select count(*) from requirer;" > requirer.sql

        REQURIER_CNT=`echo exit | sqlplus -silent git/git@DEVQA23 @requirer.sql`
        rm requirer.sql
	if [ `echo $REQURIER_CNT` = "0" ]; then
		echo -e "\033[33m NO ONE REQUEST THIS PIPELINE..!\n FOR THIS REASON, STOPPED JANDI ALARM\033[m "
		kill $$
	fi

}

NOTI_START ()
{
sh $JANDI_DIR/jandi_noti_start.sh
}

NOTI_END ()
{

sh $JANDI_DIR/jandi_noti_end.sh
}

NOTI_CANCEL_OR_FAILED ()
{
sh $JANDI_DIR/jandi_noti_cancel_or_failed.sh
}

TRUNCATE_REQUIRER_TAB ()
{
        echo "
        SET PAGESIZE 0 FEEDBACK OFF VERIFY OFF HEADING OFF ECHO OFF;
        truncate table requirer;" > requirer.sql

        echo exit | sqlplus -silent git/git@DEVQA23 @requirer.sql
        rm requirer.sql
	echo " TRUNCATED REQUIRER TABLE "
}

FOLLOW_PIPELINE_STATUS ()
{
for i in `seq 1 1800`
do 
	PIPELINE_STATUS=`curl --silent --header "PRIVATE-TOKEN: sG2UzXShy7HyuXN8GSR5" "http://10.10.32.101/api/v3/projects/49/pipelines" | jq .[0].status | tr -d '"'`
	if [ "${PIPELINE_STATUS}" = "success" ]; then
		NOTI_END
		break;
	elif [ "${PIPELINE_STATUS}" = "failed" ]||[ "${PIPELINE_STATUS}" = "canceled" ]; then
		PIPELINE_NUM=`curl --silent --header "PRIVATE-TOKEN: sG2UzXShy7HyuXN8GSR5" "http://10.10.32.101/api/v3/projects/49/pipelines" | jq .[0].id | tr -d '"'`
		export PIPELINE_NUM PIPELINE_STATUS
		NOTI_CANCEL_OR_FAILED ${PIPELINE_NUM} ${PIPELINE_STATUS}
		TRUNCATE_REQUIRER_TAB
		break;
	fi
	sleep 1
done
#	NOTI_CANCEL_OR_FAILED ${PIPELINE_NUM} ${PIPELINE_STATUS}
#	TRUNCATE_REQUIRER_TAB
}

CHECK_IF_REQUIRER_EXIST
NOTI_START
FOLLOW_PIPELINE_STATUS

