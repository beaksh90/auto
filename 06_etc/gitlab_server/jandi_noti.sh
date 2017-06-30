#!/bin/bash
## Written by EXEM Co., Ltd. DEVQA BSH
## Last modified 2017.05.25
## Default source Directory
JANDI_DIR="/home/gitlab-runner/.jandi"

CHECK_IF_REQUIRER_EXIST ()
{
    echo "
    SET PAGESIZE 0 FEEDBACK OFF VERIFY OFF HEADING OFF ECHO OFF;
    select substr(mfo_release_ver,1,3) from requirer;" > requirer.sql

    export REQURIER_GROUP=`echo exit | sqlplus -silent git/git@DEVQA23 @requirer.sql`
    rm requirer.sql
    if [ -z $REQURIER_GROUP ]; then
        echo -e "\033[33m NO ONE REQUEST THIS PIPELINE..!\n FOR THIS REASON, STOPPED JANDI ALARM\033[m "
        kill $$
    fi
}

SET_VALUES_BY_CASE_OF_GROUP ()
{

case $REQURIER_GROUP in
    mfo)
        export PROJECT_ID=49
        ## REAL MFO KEY     : https://wh.jandi.com/connect-api/webhook/11671944/2f7c4e5a519db8021cdbda11d6f12c16
        export JANDI_API_KEY="https://wh.jandi.com/connect-api/webhook/11671944/2f7c4e5a519db8021cdbda11d6f12c16"
        export CONF_ITEM_LIST="mfodg mfonp mfoweb mfosql mfobuild"
        ## TEST ENV PART
        export TEST_ENV_PART="{\"title\":\"[ TEST Environment ]\",\"description\":\"[DEVQA21 : ORACLE & LINUX (패치)](http://10.10.32.21:8080/MAXGAUGE/)\n[DEVQA24 : ORACLE & LINUX (신규)](http://10.10.32.24:8080/MAXGAUGE/)\n[DEVQA22 : PG & LINUX (패치)](http://10.10.32.22:8080/MAXGAUGE/)\n[DEVQA20 : PG & WIN (신규)](http://10.10.32.20:8080/MAXGAUGE/)\"}"
    ;;
    mfd)
        export PROJECT_ID=73
        export JANDI_API_KEY="https://wh.jandi.com/connect-api/webhook/11671944/09554b141d82e7a1b92fd0a3ff260973"
        export CONF_ITEM_LIST="mfddg unipjs mfdweb mfdsql mfdbuild"
        ## TEST ENV PART
        export TEST_ENV_PART="{\"title\":\"[ TEST Environment ]\",\"description\":\"[DEVQA81 : PG & LINUX (패치)](http://10.10.32.81:8080/MAXGAUGE/)\"}"
    ;;
esac
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
    PIPELINE_STATUS=`curl --silent --header "PRIVATE-TOKEN: sG2UzXShy7HyuXN8GSR5" "http://10.10.32.101/api/v3/projects/${PROJECT_ID}/pipelines" | jq .[0].status | tr -d '"'`
    if [ "${PIPELINE_STATUS}" = "success" ]; then
        NOTI_END
        break;
    elif [ "${PIPELINE_STATUS}" = "failed" ]||[ "${PIPELINE_STATUS}" = "canceled" ]; then
        PIPELINE_NUM=`curl --silent --header "PRIVATE-TOKEN: sG2UzXShy7HyuXN8GSR5" "http://10.10.32.101/api/v3/projects/${PROJECT_ID}/pipelines" | jq .[0].id | tr -d '"'`
        export PIPELINE_NUM PIPELINE_STATUS
        NOTI_CANCEL_OR_FAILED ${PIPELINE_NUM} ${PIPELINE_STATUS}
        TRUNCATE_REQUIRER_TAB
        break;
    fi
    sleep 1
done
## DON'T CARE TIME OVER
}

CHECK_IF_REQUIRER_EXIST
SET_VALUES_BY_CASE_OF_GROUP
NOTI_START
FOLLOW_PIPELINE_STATUS

