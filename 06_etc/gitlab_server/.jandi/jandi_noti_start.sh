SET_BASELINE()
{
echo "
SET PAGESIZE 0 FEEDBACK OFF VERIFY OFF HEADING OFF ECHO OFF;
select mfo_release_ver from ( select * from mfo_tag where mfo_release_ver like '${REQURIER_GROUP}%' order by 1 desc ) where rownum < 3;" > latest_two_baseline.sql

TWO_BASELINE=`echo exit | sqlplus -silent git/git@DEVQA23 @latest_two_baseline.sql`
rm latest_two_baseline.sql

TO_BASELINE=`echo ${TWO_BASELINE} | awk '{print $1}' `
FROM_BASELINE=`echo ${TWO_BASELINE} | awk '{print $2}' `

echo "
exec update_report_req('${TO_BASELINE}','${FROM_BASELINE}','j')" > jandi_order.sql
echo exit | sqlplus -silent git/git@DEVQA23 @jandi_order.sql
rm jandi_order.sql


TO_BASELINE_DATE=`echo ${TWO_BASELINE} | awk '{print $1}' | awk -F "_" '{print $2}'`
FROM_BASELINE_DATE=`echo ${TWO_BASELINE} | awk '{print $2}' | awk -F "_" '{print $2}'`
}

JANDI_WEBHOOK ()
{
PIPELINE_NUM=`curl --silent --header "PRIVATE-TOKEN: sG2UzXShy7HyuXN8GSR5" "http://10.10.32.101/api/v3/projects/${PROJECT_ID}/pipelines" | jq .[0].id | tr -d '"'`
echo $PIPELINE_NUM

echo "
curl \
-X POST ${JANDI_API_KEY} \
-H \"Accept: application/vnd.tosslab.jandi-v2+json\" \
-H \"Content-Type: application/json\" \
--data-binary '{\"body\":\"Build & Environment Setting START.\n:D\",\"connectColor\":\"#99CCFF\",\"connectInfo\":[
{\"title\":\"[[ Baseline : ${FROM_BASELINE_DATE} >> ${TO_BASELINE_DATE} ]](http://10.10.32.101/${REQURIER_GROUP}/${REQURIER_GROUP}build/pipelines/${PIPELINE_NUM})\"}]}' " > jandi_api.sh
}


SET_BASELINE
JANDI_WEBHOOK
sh jandi_api.sh
rm jandi_api.sh

