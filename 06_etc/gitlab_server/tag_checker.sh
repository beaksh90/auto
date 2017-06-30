#!/bin/bash
## Written by EXEM Co., Ltd. DEVQA BSH
## Last modified 2017.03.31
## Default source Directory
## tag count list file  '. ./.mxctl/tag_checker.conf'

MAIN_DIR="/var/opt/gitlab/git-data/repositories"
WORKING_DIR=`pwd`
sh /root/.bash_profile
CONF_ITEM_LIST="mfobuild mfonp mfoweb mfosql mfodg mforts mfaweb mfasql mftweb mftsql mfddg mfdbuild unipjs mfdweb mfdsql"

PREVENT_FROM_DUPLE_EXEC ()
{
TAG_CHECKER_PID=`ps -ef | grep -v grep | grep -v $$ | grep "/var/opt/gitlab/tag_checker.sh" | awk '{print $2}' | wc -l `
SONAR_SCANNER_PID=`ps -ef | grep -v "grep" | grep "/app/sonarqube/sonar-scanner" | awk '{print $2}'`

    if [ "$TAG_CHECKER_PID" -gt 1 ]||[ "$SONAR_SCANNER_PID" != "" ];
    then
        echo "Due to existing Process tag_checker process number : $TAG_CHECKER_PID , sonar_scanner : $SONAR_SCANNER_PID, Exit. "
        exit
    else 
        echo -e "\nNothing previous Process..!\n"
    fi;
}

CHECK_IF_PUSHED_TAG_ARRIVE ()
{
UPDATER=0
for CONF_ITEM in $CONF_ITEM_LIST
do
    CONF_ITEM_GROUP=`expr substr $CONF_ITEM 1 3` 
    cd ${MAIN_DIR}/${CONF_ITEM_GROUP}/${CONF_ITEM}.git
    TAG_COUNT2=`git tag -l "${CONF_ITEM}\_[0-9]*[.][0-9][0-9]" | wc -l`
    TAG_COUNT1=`cat /var/opt/gitlab/.mxctl/tag_checker.conf | grep ${CONF_ITEM} | awk -F "=" '{print $2}'`
    if [ "${CONF_ITEM}" = "mfobuild" ]; then MFO_BUILD_TAG_NEWEST=`git tag -l | tail -n 1`; fi
        
    if [ ${TAG_COUNT2} != ${TAG_COUNT1} ]; then
        STEP=0
        DIFF_COUNT=`expr ${TAG_COUNT2} - ${TAG_COUNT1}`
        PASS_COUNT=`expr ${TAG_COUNT2} - ${DIFF_COUNT}`
        echo "Here is '${CONF_ITEM}' Part "

        for TAG in `git tag -l "${CONF_ITEM}\_[0-9]*[.][0-9][0-9]"`
        do
            STEP=`expr $STEP + 1`
            if [ ${PASS_COUNT} -lt ${STEP} ]; then
        echo "set define off;" >> insert_tag.sql
                EXTRACT_DEV_MENTION $PREVIOUS_TAG $TAG 
                echo "insert into mfo_tag_part values('${TAG}','${MFO_BUILD_TAG_NEWEST}');" >> insert_tag.sql
                UPDATER=`expr $UPDATER + 1`
                STATIC_ANALYSIS_SONARQUBE $CONF_ITEM $TAG $CONF_ITEM_GROUP $MAIN_DIR
                JANDI_API_CALL
            fi
                PREVIOUS_TAG=$TAG
        done
        
        echo exit | sqlplus -silent git/git@DEVQA23 @insert_tag.sql
        sleep 1
        rm -rf insert_tag.sql
    fi
    ATTACHMENT="TAG_COUNT1[$CONF_ITEM]=${TAG_COUNT2}\n$ATTACHMENT";
done
}

EXTRACT_DEV_MENTION ()
{
unset DEV_MENTION
unset BRANCH_INFO
IFS="
"
for STATEMENT in `git log ${PREVIOUS_TAG}..${TAG}`;
do
    case `echo $STATEMENT | awk '{print $1}'` in
        commit)
            if [ `echo $STATEMENT | grep -E "commit .{40}"` ]; 
            then
                NEXT_HASH_CODE=`echo $STATEMENT | awk '{print $2}'`;
                if [ "${CONF_ITEM}" = "mfoweb" ]; 
                then 
                    BRANCH_INFO=`git branch --contains $NEXT_HASH_CODE`; 
                    BRANCH_INFO=" ,{\"title\":\"Branch  : ${BRANCH_INFO} \"} "
                fi
            else
                COLLECT_STATEMENT
            fi
        ;;
        Author:|Date:|Merge|Merge:)
        ;;
        *)
            COLLECT_STATEMENT
        ;;
    esac
done

COMMIT_MENT_INSERT_QUERY

unset IFS
unset HASH_CODE
}

COLLECT_STATEMENT ()
{
    DEV_MENTION="$DEV_MENTION $STATEMENT\n"
    TREAT_JANDI_STATEMENT
    TREAT_QUERY_STATEMENT
    HASH_CODE=$NEXT_HASH_CODE
}

TREAT_JANDI_STATEMENT ()
{
    if [ ${STATEMENT} != "    " ];
    then
            PRE_JANDI_STATEMENT=`echo $STATEMENT           | sed -re 's:\x27:\x27\x5C\x5C\x27\x27:g'`     # ESCAPE   '  -> '//''
            PRE_JANDI_STATEMENT=`echo $PRE_JANDI_STATEMENT | sed -re 's:\x5C\x28:\x27\x5C\x5C\x28\x27:g'` # ESCAPE   )  -> '//)'
            PRE_JANDI_STATEMENT=`echo $PRE_JANDI_STATEMENT | sed -re 's:\x5C\x29:\x27\x5C\x5C\x29\x27:g'` # ESCAPE   (  -> '//('
            PRE_JANDI_STATEMENT=`echo $PRE_JANDI_STATEMENT | sed -re 's:\x5C\x09:\x20:g'`                 # REMOVE   \t -> (space)
            PRE_JANDI_STATEMENT=`echo $PRE_JANDI_STATEMENT | sed -re 's:\x5C\x22::g'`                     # REMOVE   "

            if [ "${NEXT_HASH_CODE}" != "${HASH_CODE}" ]&&[ ${HASH_CODE} ];
            then
                JANDI_DEV_MENTION="$JANDI_DEV_MENTION\n     ※\n"
            fi
            JANDI_DEV_MENTION="$JANDI_DEV_MENTION $PRE_JANDI_STATEMENT \n"
    fi
}

# origin : https://wh.jandi.com/connect-api/webhook/11671944/f8ae192012daed50247b8c2a221f62f3
JANDI_API_CALL ()
{

case ${CONF_ITEM_GROUP} in
    mfo|uni)
        API_KEY="https://wh.jandi.com/connect-api/webhook/11671944/f8ae192012daed50247b8c2a221f62f3"
    ;;
    mfd)
        API_KEY="https://wh.jandi.com/connect-api/webhook/11671944/4b3d86ca7e973f3c143fa4dc1977d7ad"
    ;;
esac

echo "
curl \
-X POST ${API_KEY} \
-H \"Accept: application/vnd.tosslab.jandi-v2+json\" \
-H \"Content-Type: application/json\" \
--data-binary '{\"body\":\"TAG [${TAG}](http://10.10.32.101/${CONF_ITEM_GROUP}/${CONF_ITEM}/tags/${TAG}) is just pushed.\n:)\",\"connectColor\":\"#99CCFF\",\"connectInfo\":[
{\"title\":\"${TAG}  vs  ${PREVIOUS_TAG}\n[[ Check difference from previous one ]](http://10.10.32.101/${CONF_ITEM_GROUP}/${CONF_ITEM}/compare/${PREVIOUS_TAG}...${TAG}?view=parallel)\"},
{\"title\":\"Comment of the developer : \",\"description\":\"${JANDI_DEV_MENTION}\"}
${SONAR_URL} ${BRANCH_INFO}]}'" > jandi_api.sh

sh jandi_api.sh
rm jandi_api.sh
unset JANDI_DEV_MENTION
unset SONAR_URL
}


TREAT_QUERY_STATEMENT ()
{
    STATEMENT=`echo $STATEMENT | sed -re 's:\x27:\x27\x27:g'`
    if [ "${NEXT_HASH_CODE}" != "${HASH_CODE}" ]&&[ $HASH_CODE ];
    then
        COMMIT_MENT_INSERT_QUERY
    fi
    QUERY_DEV_MENTION="$QUERY_DEV_MENTION $STATEMENT'||CHR(10)||'"
}

COMMIT_MENT_INSERT_QUERY ()
{
    echo "insert into mfo_git_comment values('${TAG}','${HASH_CODE}','${QUERY_DEV_MENTION}');"
    echo "insert into mfo_git_comment values('${TAG}','${HASH_CODE}','${QUERY_DEV_MENTION}');"  >> insert_tag.sql
    unset QUERY_DEV_MENTION
}

STATIC_ANALYSIS_SONARQUBE ()
{

case ${CONF_ITEM} in
    mfonp|mfoweb|mfodg|unipjs|mfddg|mfdweb)

    cd /app/sonarqube/static_analysis_items/${CONF_ITEM}
    git fetch git@10.10.32.101:mfo/${CONF_ITEM}.git --tag
    git checkout $TAG
    sed -i s/sonar.projectVersion=.*/sonar.projectVersion=$TAG/g ./sonar-project.properties
    sonar-scanner
    cd ${MAIN_DIR}/${CONF_ITEM_GROUP}/${CONF_ITEM}.git

    ATTACH_SONAR_URL
    ;;
esac

}

ATTACH_SONAR_URL ()
{
. /app/sonarqube/static_analysis_items/${CONF_ITEM}/.scannerwork/report-task.txt
for WATING in `seq 1  600`
do
        SONAR_STATUS=`curl --silent -u admin:admin ${ceTaskUrl} | jq .task.status | tr -d '"'`
        sleep 1
        echo  $SONAR_STATUS : $WAITING
        if [ "${SONAR_STATUS}" = "SUCCESS" ]; then
                break;
        fi
done

SONAR_METRIC=`curl --request POST --silent -u admin:admin http://10.10.32.101:9000/api/qualitygates/project_status?projectKey=${CONF_ITEM_GROUP}:${CONF_ITEM}`
SONAR_METRIC=`echo $SONAR_METRIC | jq .projectStatus.conditions | jq '.[].status, .[].metricKey, .[].actualValue' | tr -d '"'`

echo $SONAR_METRIC
BUGS=`echo $SONAR_METRIC | awk '{print $8}'`
VUL=`echo $SONAR_METRIC | awk '{print $7}'`
DEPT=`echo $SONAR_METRIC | awk '{print $9}' | cut -c 1-3`

SONAR_LINK="(http://10.10.32.101:9000/dashboard/index/${CONF_ITEM_GROUP}:${CONF_ITEM})"

SONAR_URL=" ,{\"title\":\"Sonar Qube ( metrics on new code ) :\",\"description\":\"     New Bugs :\t\t\t\t[${BUGS}]${SONAR_LINK}\n
     New Vulnerabilities :\t\t[${VUL}]${SONAR_LINK}\n     Technical Dept Ratio :\t[${DEPT}]${SONAR_LINK} % \"} "
}

UPDATE_THIS_FILE ()
{
if [ $UPDATER != 0 ]; then
    echo -e "$ATTACHMENT"
    echo -e "$ATTACHMENT" > /var/opt/gitlab/.mxctl/tag_checker.conf 
fi
}

ORACLE_ENV_VAR()
{
export ORACLE_HOSTNAME=DEVQA101
export ORACLE_UNQNAME=DEVQA101
export ORACLE_BASE=/app/oracle
export ORACLE_HOME=$ORACLE_BASE/product/11.2.0.1/db_1
export ORACLE_SID=DEVQA101
export PATH=$ORACLE_HOME/bin:/usr/sbin:$PATH
export LD_LIBRARY_PATH=$ORACLE_HOME/lib:/lib:/usr/lib
export CLASSPATH=$ORACLE_HOME/jlib:$ORACLE_HOME/rdbms/jlib
export NLS_LANG=AMERICAN_AMERICA.UTF8
}

PREVENT_FROM_DUPLE_EXEC
ORACLE_ENV_VAR
CHECK_IF_PUSHED_TAG_ARRIVE
UPDATE_THIS_FILE


