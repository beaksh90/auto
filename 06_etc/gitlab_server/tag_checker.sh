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
            ##  SEND_MAIL $CONF_ITEM $PREVIOUS_TAG $TAG $CONF_ITEM_GROUP
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
if [ $NEXT_REDMINE_ISSUE_NO ]; then
    REDMINE_API_CALL $REDMINE_ISSUE_NO
fi
unset IFS
unset HASH_CODE
unset REDMINE_ISSUE_NO
}

COLLECT_STATEMENT ()
{
    DEV_MENTION="$DEV_MENTION $STATEMENT\n"
    #TREAT_REDMINE_STATEMENT
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
            MAKE_REDMINE_HYPERLINK

            if [ "${NEXT_HASH_CODE}" != "${HASH_CODE}" ]&&[ ${HASH_CODE} ];
            then
                JANDI_DEV_MENTION="$JANDI_DEV_MENTION\n     ※\n"
            fi
            JANDI_DEV_MENTION="$JANDI_DEV_MENTION $PRE_JANDI_STATEMENT \n"
    fi
}

MAKE_REDMINE_HYPERLINK()
{
if [ `echo $PRE_JANDI_STATEMENT | grep -E "#[0-9]{3,6}"` ];
then
        unset IFS
        for FIND_NUM in $PRE_JANDI_STATEMENT
        do
                if [ `echo $FIND_NUM | grep -E "#[0-9]{3,5}"` ]; then
                REDMINE_NUM=`echo $FIND_NUM | grep -E "#[0-9]{3,5}" | tr -d "#"`
                fi
        done
        PRE_JANDI_STATEMENT=`echo $PRE_JANDI_STATEMENT | sed -re 's@'#$REDMINE_NUM'@['#$REDMINE_NUM'](http://115.178.73.20:32798/issues/'$REDMINE_NUM')@g'`
        PRE_JANDI_STATEMENT="     $PRE_JANDI_STATEMENT"
        echo $PRE_JANDI_STATEMENT
IFS="
"
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

TREAT_REDMINE_STATEMENT ()
{
    if [ `echo $STATEMENT | grep -E  "#[0-9]{4,5}"` ]; then
        NEXT_REDMINE_ISSUE_NO=`echo ${STATEMENT} | grep -o "#[0-9]*" | awk -F"[#]" '{print $2}'`
    fi

    if [ $NEXT_REDMINE_ISSUE_NO ]; then
        if [ "${NEXT_REDMINE_ISSUE_NO}" != "${REDMINE_ISSUE_NO}" ]&&[ $REDMINE_ISSUE_NO ]; then
            REDMINE_API_CALL
        elif [ "${NEXT_HASH_CODE}" != "${HASH_CODE}" ]&&[ $REDMINE_ISSUE_NO ] ; then
            REDMINE_API_CALL
            unset NEXT_REDMINE_ISSUE_NO
            unset REDMINE_ISSUE_NO
        fi
        REDMINE_DEV_MENTION="$REDMINE_DEV_MENTION 
        $STATEMENT"
        REDMINE_ISSUE_NO=$NEXT_REDMINE_ISSUE_NO
    fi
}

COMMIT_MENT_INSERT_QUERY ()
{
    echo "insert into mfo_git_comment values('${TAG}','${HASH_CODE}','${QUERY_DEV_MENTION}');"
    echo "insert into mfo_git_comment values('${TAG}','${HASH_CODE}','${QUERY_DEV_MENTION}');"  >> insert_tag.sql
    unset QUERY_DEV_MENTION
}

# redmine 주소 변경
GET_ISSUE(){
curl --include 'http://10.10.100.230:3000/issues/${REDMINE_ISSUE_NO}.xml' 1>temp.txt 2>&1
}

# redmine 주소 변경
UPDATE_ISSUE(){
curl --include \
         --request PUT \
         --header "Content-Type: application/xml" \
         --data-binary "<issue>
        <subject>${SUBJECT}</subject>
        <notes>${REDMINE_DEV_MENTION}</notes>
        </issue>" \
    'http://10.10.100.230:3000/issues/${REDMINE_ISSUE_NO}.xml?include=journals&key=f3bac7fb2f8e8dc26e702d15295c0d8c18ab0560' 1>/dev/null 2>$1
}

# origin : https://wh.jandi.com/connect-api/webhook/11671944/f8ae192012daed50247b8c2a221f62f3
REDMINE_API_CALL()
{
        echo -e "api call : $REDMINE_DEV_MENTION"
        echo ${REDMINE_ISSUE_NO}
        GET_ISSUE

        TEMP_TXT=`cat ./temp.txt`
        SUBJECT=`echo $TEMP |grep -oE "(<subject>+[a-zA-Z0-9가-힣 .,:]*)<\/subject>" | awk -F"[>]" '{print $2}' | awk -F"[<]" '{print $1}'`
        echo ${SUBJECT}
        rm -rf ./sub.txt

        UPDATE_ISSUE
        unset REDMINE_DEV_MENTION
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

SEND_MAIL ()
{
    WEB_FRONT_END_TEAM="hwankb@ex-em.com daru87@ex-em.com kangjm103@ex-em.com wnsrl56@ex-em.com gayoon.huh@ex-em.com"	

    mfo_ALL_RECEIVER="beaksh90@naver.com mookiang@ex-em.com bsa@ex-em.com cryingpcs@ex-em.com kibbeum6738@ex-em.com hyewon@ex-em.com"
    mfosql_RECEIVER=${WEB_FRONT_END_TEAM}
    mfoweb_RECEIVER=${WEB_FRONT_END_TEAM}
    mfodg_RECEIVER="ezra@ex-em.com magyeon@ex-em.com"
    mforts_RECEIVER="jeungwoo.we@ex-em.com jcwon@ex-em.com wonsik@ex-em.com"
    mfonp_RECEIVER="uizu99@ex-em.com hwankb@ex-em.com jcwon@ex-em.com"
    
    mfa_ALL_RECEIVER="kibbeum6738@ex-em.com hyewon@ex-em.com bsa@ex-em.com cryingpcs@ex-em.com"	
    mfasql_RECEIVER=${WEB_FRONT_END_TEAM}
    mfaweb_RECEIVER=${WEB_FRONT_END_TEAM}
    
    mft_ALL_RECEIVER="kibbeum6738@ex-em.com hyewon@ex-em.com bsa@ex-em.com cryingpcs@ex-em.com"
    mftsql_RECEIVER=${WEB_FRONT_END_TEAM}
    mftweb_RECEIVER=${WEB_FRONT_END_TEAM}

    GET_WEBPAGE_SCREENSHOT $CONF_ITEM $CONF_ITEM_GROUP $PREVIOUS_TAG $TAG
    
    GROUP_CONF_ITEM_RECEIVER=`echo ${CONF_ITEM_GROUP}_ALL_RECEIVER` 
    EACH_CONF_ITEM_RECEIVER=`echo ${CONF_ITEM}_RECEIVER`
    
    MAIL_TEXT ${!GROUP_CONF_ITEM_RECEIVER} ${!EACH_CONF_ITEM_RECEIVER}
    
    rm -rf ./difference*.png
    rm -rf ./getpage.js
}

MAIL_TEXT ()
{
    echo -e " 1.GITLAB URL : http://10.10.32.101/${CONF_ITEM_GROUP}/${CONF_ITEM}/compare/${PREVIOUS_TAG}...${TAG}?view=parallel\n\n 2.DEV_COMMENT\n$DEV_MENTION\n\n$SONAR_URL\n\n$BRANCH_INFO "  | mail -a difference*.png -s "${CONF_ITEM_GROUP} tag '${TAG}' is just pushed." $@
    unset SONAR_URL
}

GET_WEBPAGE_SCREENSHOT ()
{
echo "var page = new WebPage(), testindex = 0, loadInProgress = false;

page.onConsoleMessage = function(msg) {
  console.log(msg);
};

page.onLoadStarted = function() {
  loadInProgress = true;
  console.log(\"load started\");
};

page.onLoadFinished = function() {
  loadInProgress = false;
  console.log(\"load finished\");
};

var stepName = [\"page open\", \"insert id pw\", \"login\", \"render\"];
var steps = [
function() {
  page.viewportSize = { width: 1980, height: 1200 }
  page.open(\"http://10.10.32.101/$2/$1/compare/$3...$4?view=parallel\");
},
function() {
  page.evaluate(function() {
    document.getElementById('user_login').value = 'maxgauge';
    document.getElementById('user_password').value = 'dev7u8i9o0p';
  });
},
function() {
  page.evaluate(function() {
    document.getElementById('new_user').submit();
  });
},
function() {
   page.render('difference_$3..$4.png');
  }
  ];

  interval = setInterval(function() {
    if (!loadInProgress && typeof steps[testindex] == \"function\") {
      console.log(stepName[(testindex)] + \" start\");
      steps[testindex]();
      testindex++;
    }
    if (typeof steps[testindex] != \"function\") {
      console.log(\"finish!!!!\");
      phantom.exit();
    }
}, 50);" > getpage.js

phantomjs getpage.js
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


