#!/bin/bash
## Written by EXEM Co., Ltd. DEVQA BSH, ASM
## Last modified 2017.04.14
## Default source Directory
## tag count list file  '. ./.mxctl/tag_checker.conf'

MAIN_DIR="/var/opt/gitlab/git-data/repositories"
WORKING_DIR=`pwd`
sh /root/.bash_profile
CONF_ITEM_LIST="mfobuild mfonp mfoweb mfosql mfodg mforts " ## mfaweb mfasql mftweb mftsql"

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
                EXTRACT_DEV_MENTION $PREVIOUS_TAG $TAG 
                echo "insert into mfo_tag_part values('${TAG}','${MFO_BUILD_TAG_NEWEST}');" >> insert_tag.sql
                UPDATER=`expr $UPDATER + 1`
                #STATIC_ANALYSIS_SONARQUBE $CONF_ITEM $TAG $CONF_ITEM_GROUP $MAIN_DIR
                SEND_MAIL $CONF_ITEM $PREVIOUS_TAG $TAG $CONF_ITEM_GROUP
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
IFS="
"
for STATEMENT in `git log ${PREVIOUS_TAG}..${TAG}`;
do
    case `echo $STATEMENT | awk '{print $1}'` in
        commit)
            if [ `echo $STATEMENT | grep -E "commit .{40}"` ]; 
            then
                NEXT_HASH_CODE=`echo $STATEMENT | awk '{print $2}'`;
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
    STATEMENT=`echo $STATEMENT | sed -re 's:\x27:\x27\x27:g'`
    if [ "${NEXT_HASH_CODE}" != "${HASH_CODE}" ]&&[ $HASH_CODE ]; 
    then
        COMMIT_MENT_INSERT_QUERY
        unset QUERY_DEV_MENTION
    fi
    QUERY_DEV_MENTION="$QUERY_DEV_MENTION $STATEMENT"
    HASH_CODE=$NEXT_HASH_CODE
}

COMMIT_MENT_INSERT_QUERY ()
{
    echo "insert into mfo_git_comment values('${TAG}','${HASH_CODE}','${QUERY_DEV_MENTION}');"
    echo "insert into mfo_git_comment values('${TAG}','${HASH_CODE}','${QUERY_DEV_MENTION}');"  >> insert_tag.sql                              
}

STATIC_ANALYSIS_SONARQUBE ()
{
if [ "${CONF_ITEM}" = "mfonp" ]||[ "${CONF_ITEM}" = "mfoweb" ]||[ "${CONF_ITEM}" = "mfodg" ]; then
    cd /app/sonarqube/static_analysis_items/${CONF_ITEM}
    git fetch git@10.10.32.101:mfo/${CONF_ITEM}.git --tag
    git checkout $TAG
    sed -i s/sonar.projectVersion=.*/sonar.projectVersion=$TAG/g ./sonar-project.properties
    sonar-scanner
    cd ${MAIN_DIR}/${CONF_ITEM_GROUP}/${CONF_ITEM}.git
    SONAR_URL=" 3.SONAR QUBE URL : http://10.10.32.101:9000/ "
fi
}

SEND_MAIL ()
{
    mfo_ALL_RECEIVER="beaksh90@naver.com mookiang@ex-em.com bsa@ex-em.com cryingpcs@ex-em.com"
    mfosql_RECEIVER="hwankb@ex-em.com daru87@ex-em.com kangjm103@ex-em.com wnsrl56@ex-em.com gayoon.huh@ex-em.com"
    mfoweb_RECEIVER="hwankb@ex-em.com daru87@ex-em.com kangjm103@ex-em.com wnsrl56@ex-em.com gayoon.huh@ex-em.com"
    mfodg_RECEIVER="ezra@ex-em.com magyeon@ex-em.com"
    mforts_RECEIVER="jeungwoo.we@ex-em.com jcwon@ex-em.com wonsik@ex-em.com"
    mfonp_RECEIVER="uizu99@ex-em.com hwankb@ex-em.com "

    GET_WEBPAGE_SCREENSHOT $CONF_ITEM $PREVIOUS_TAG $TAG
    
    GROUP_CONF_ITEM=`echo ${CONF_ITEM_GROUP}_ALL_RECEIVER` 
    EACH_CONF_ITEM=`echo ${CONF_ITEM}_RECEIVER`
    
    MAIL_TEXT ${!GROUP_CONF_ITEM} ${!EACH_CONF_ITEM}
    
    rm -rf ./difference*.png
    rm -rf ./getpage.js
}


MAIL_TEXT ()
{
    echo -e " 1.GITLAB URL : http://10.10.32.101/mfo/${CONF_ITEM}/compare/${PREVIOUS_TAG}...${TAG}?view=parallel\n\n 2.DEV_COMMENT\n$DEV_MENTION\n\n$SONAR_URL"  | mail -a difference*.png -s "MFO TAG '${TAG}' is just pushed." $@
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
  page.open(\"http://10.10.32.101/mfo/$1/compare/$2...$3?view=parallel\");
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
   page.render('difference_$2..$3.png');
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
    echo -e "$ATTACHMENT" > var/opt/gitlab/.mxctl/tag_checker.conf 
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