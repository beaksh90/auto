SET_BASELINE()
{
echo "
SET PAGESIZE 0 FEEDBACK OFF VERIFY OFF HEADING OFF ECHO OFF;
select mfo_release_ver from ( select * from mfo_tag order by 1 desc ) where rownum < 3;" > latest_two_baseline.sql

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
echo "
curl \
-X POST https://wh.jandi.com/connect-api/webhook/11671944/2f7c4e5a519db8021cdbda11d6f12c16 \
-H \"Accept: application/vnd.tosslab.jandi-v2+json\" \
-H \"Content-Type: application/json\" \
--data-binary '{\"body\":\"MFO Build & Environment Setting START.\n:D\",\"connectColor\":\"#99CCFF\",\"connectInfo\":[
{\"title\":\"[ Baseline : ${FROM_BASELINE_DATE} >> ${TO_BASELINE_DATE} ]\"}]}' " > jandi_api.sh
}


SET_BASELINE
JANDI_WEBHOOK
sh jandi_api.sh
rm jandi_api.sh

