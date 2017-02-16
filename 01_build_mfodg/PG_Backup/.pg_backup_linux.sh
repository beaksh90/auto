#!/bin/bash

echo "PG Backup  & Restore"

echo''


echo " PG DATA Path  : [/home/postgres/pg]"
read PG_PATH
if [ "$PG_PATH" = "" ]; then
  PG_PATH="/home/postgres/pg"
fi

echo " PG IP Address : [127.0.0.1] "
read PG_IP
if [ "$PG_IP" = "" ]; then
        PG_IP="127.0.0.1"
fi

echo " PG Port number : [5432] "
read PG_PORT
if [ "$PG_PORT" = "" ]; then
        PG_PORT="5432"
fi

echo " PostgreSQL user: [postgres]"
read PG_USER
if [ "$PG_USER" = "" ]; then
        PG_USER="postgres"
fi

PG_PASS=""
while [ -z "$PG_PASS" ]
do
        echo " PostgreSQL pass: "
        stty -echo
        read PG_PASS
        stty echo
done

echo ''

echo " PG DB name: [MFO]"
read DBNAME
if [ "$DBNAME" = "" ]; then
        DBNAME="MFO"
fi

echo ''
echo "Create Backup output & Script Path"

echo ''
echo " Backup Path  : [/home/postgres/backup]"
read BACKUP_PATH
if [ "$BACKUP_PATH" = "" ]; then

mkdir -p /home/postgres/backup
BACKUP_PATH="/home/postgres/backup"

else

mkdir -p $BACKUP_PATH

fi

echo ''

echo " Script Path  : [/home/postgres/log]"
read SCRIPT_PATH
if [ "$SCRIPT_PATH" = "" ]; then

mkdir -p /home/postgres/log
SCRIPT_PATH="/home/postgres/log"

else

mkdir -p $SCRIPT_PATH

fi




echo

echo ========================================================
echo PG DATA Path       : $PG_PATH
echo PG IP Address      : $PG_IP
echo PG Port number     : $PG_PORT
echo PostgreSQL user    : $PG_USER
echo PG DB name         : $DBNAME
echo Backup output Path : $BACKUP_PATH
echo Backup Script Path : $SCRIPT_PATH
echo ========================================================

echo ''
echo ''


echo  Select Menu [Interactive Mode]
echo -------------------------------------------------
echo 1. Full Backup 
echo 2. Daily Backup 
echo 3. Export
echo 4. Restore
echo 5. Exit
echo''

echo -n "Enter your choice : "
read choice
echo ""

case $choice in
        1)
echo''
echo ' Select Instance List [Interactive Mode]'
echo -------------------------------------------------
psql --host $PG_IP --port $PG_PORT --username $PG_USER -t -d $DBNAME > $SCRIPT_PATH/dblst.txt <<EOF -c "select db_id,instance_name from apm_db_info order by db_id;"
EOF

awk '{print $1, $2, $3}' $SCRIPT_PATH/dblst.txt

echo -n "Enter the DB ID  "
read db_id
if [ "$db_id" = "" ]; then
        db_id="all"
fi

schemae=`awk '$1 == '"${db_id}"' {print $3}' $SCRIPT_PATH/dblst.txt | tr '[A-Z]' '[a-z]'`



if [ "$db_id"= "all"]; then
	echo all

	pg_dump --verbose --host $PG_IP --port $PG_PORT --username $PG_USER --no-password --format custom --encoding UTF8 --file "$BACKUP_PATH/Full_Backup.backup" $DBNAME
 	echo''
	echo''
else 
	echo $schemae

	pg_dump --verbose --host $PG_IP --port $PG_PORT --username $PG_USER -n $schemae --no-password --format custom --encoding UTF8 --file "$BACKUP_PATH/Full_Backup_public.backup" $DBNAME
	pg_dump --verbose --host $PG_IP --port $PG_PORT --username $PG_USER -n $schemae --no-password --format custom --encoding UTF8 --file "$BACKUP_PATH/Full_Backup_$schemae.backup" $DBNAME

fi
 ;;



        2)
       echo''
echo ' Select Instance List [Daily Backup]'
echo -------------------------------------------------
psql --host $PG_IP --port $PG_PORT --username $PG_USER -t -d $DBNAME > $SCRIPT_PATH/dblst.txt <<EOF -c "select db_id,instance_name from apm_db_info order by db_id;"
EOF

awk '{print $1, $2, $3}' $SCRIPT_PATH/dblst.txt

echo -n "Enter the DB ID  "
read db_id
if [ "$db_id" = "" ]; then
        db_id="all"
fi

schemae=`awk '$1 == '"${db_id}"' {print $3}' $SCRIPT_PATH/dblst.txt`

psql --host $PG_IP --port $PG_PORT --username $PG_USER -t -d $DBNAME > $SCRIPT_PATH/YDATE.txt <<EOF -c  "select distinct(substring(tablename,length(tablename)-8,6)) as date from pg_tables a, apm_db_info b where b.instance_name =upper(a.schemaname) and tableowner='postgres' and tablename in (select tablename from pg_tables where tablename like ('%%p1%%') and to_date(substring(tablename,length(tablename)-8,6),'yymmdd') <= current_date -1) order by 1 desc limit 1"
EOF


YDATE=`awk '{print $1}' $SCRIPT_PATH/YDATE.txt`



if [ $db_id = all ];

then

echo all
echo $YDATE
psql --host $PG_IP --port $PG_PORT --username $PG_USER -t -d $DBNAME > $SCRIPT_PATH/temp.txt <<EOF -c "select 'test'||' '||string_agg(tablename,' ') from (select ('--table'||' '||schemaname||'.'||tablename) as tablename,schemaname from pg_tables where tableowner='postgres' and tablename not like ('%%p1%%') and schemaname not in ('pg_catalog','information_schema','public') union all select ('--table'||' '||schemaname||'.'||tablename) as tablename,schemaname from pg_tables where tableowner='postgres' and tablename in (select tablename from pg_tables where tablename like ('%%p1%%') and to_date(substring(tablename,length(tablename)-8,6),'yymmdd') = current_date - 1)) a"
EOF


for tablst in $(cat $SCRIPT_PATH/temp.txt);
do


pg_dump --verbose --host $PG_IP --port $PG_PORT --username $PG_USER --no-password --format custom --encoding UTF8 --file "$BACKUP_PATH/Daily_$YDATE _Backup.backup" --table $tablst  $DBNAME

done


else 

echo $schemae
echo $YDATE

psql --host $PG_IP --port $PG_PORT --username $PG_USER -t -d $DBNAME --no-password > $SCRIPT_PATH/temp2.txt <<EOF -c "select 'test'||' '||string_agg(tablename,' ') from(select ('--table'||' '||a.schemaname||'.'||a.tablename) as tablename from pg_tables a, apm_db_info b where b.instance_name =upper(a.schemaname) and a.tableowner='postgres' and a.tablename not like ('%%p1%%') and a.schemaname not in ('pg_catalog','information_schema','public') and b.instance_name ='$schemae') a;" 
EOF

psql --host $PG_IP --port $PG_PORT --username $PG_USER -t -d $DBNAME --no-password >> $SCRIPT_PATH/temp2.txt <<EOF -c "select 'test'||' '||string_agg(tablename,' ') from(select ('--table'||' '||schemaname||'.'||tablename) as tablename from pg_tables a, apm_db_info b where b.instance_name =upper(a.schemaname) and tableowner='postgres' and tablename in (select tablename from pg_tables where tablename like ('%%p1%%') and to_date(substring(tablename,length(tablename)-8,6),'yymmdd') = current_date - 1) and b.instance_name ='$schemae')  a;"
EOF



for tablst in $(cat $SCRIPT_PATH/temp2.txt);
do

pg_dump --verbose --host $PG_IP --port $PG_PORT --username $PG_USER --no-password --format custom --encoding UTF8 --file "$BACKUP_PATH/Daily_$YDATE _$schemae.backup" --table $tablst $DBNAME

done


fi

 ;;

        3)
        echo''
echo ' Select Instance List [Export Backup]'
echo -------------------------------------------------

psql --host $PG_IP --port $PG_PORT --username $PG_USER -t -d $DBNAME > $SCRIPT_PATH/dblst.txt <<EOF -c "select db_id,instance_name from apm_db_info order by db_id;"
EOF

awk '{print $1, $2, $3}' $SCRIPT_PATH/dblst.txt


db_id=""
while [ -z "$db_id" ]
do
        echo "Enter the DB ID  "
        stty echo
        read db_id
        stty echo
done

echo ''



schemae=`awk '$1 == '"${db_id}"' {print $3}' $SCRIPT_PATH/dblst.txt | tr '[A-Z]' '[a-z]'`

echo ' Available Date [Export Backup]'
echo -------------------------------------------------

psql --host $PG_IP --port $PG_PORT --username $PG_USER -t -d $DBNAME > $SCRIPT_PATH/datelst.txt <<EOF  -c "select rownum||'.'||date as num from (select row_number() over() as rownum,a.date from (select distinct(substring(tablename,length(tablename)-8,6)) as date from pg_tables a, apm_db_info b where b.instance_name =upper(a.schemaname) and tableowner='postgres' and tablename in (select tablename from pg_tables where tablename like ('%%p1%%') and to_date(substring(tablename,length(tablename)-8,6),'yymmdd') <= current_date - 1) and b.db_id =$db_id order by 1)a)b;"
EOF


awk '{print $1}' $SCRIPT_PATH/datelst.txt

echo ''
select_date=""
while [ -z "$select_date" ]
do
        echo "Select Export for Date : (ex 161007) : "
        stty echo
        read select_date
        stty echo
done

echo ''


psql --host $PG_IP --port $PG_PORT --username $PG_USER -t -d $DBNAME > $SCRIPT_PATH/temp.txt <<EOF -c "select 'test'||' '||string_agg(tablename,' ') from(select ('--table'||' '||schemaname||'.'||tablename) as tablename from pg_tables a, apm_db_info b where b.instance_name =upper(a.schemaname) and tableowner='postgres' and tablename in (select tablename from pg_tables where tablename like ('%%p1%%') and substring(tablename,length(tablename)-8,6) like '%$select_date' and b.db_id = $db_id)) a;"
EOF

psql --host $PG_IP --port $PG_PORT --username $PG_USER -t -d $DBNAME >> $SCRIPT_PATH/temp.txt <<EOF -c "select 'test'||' '||string_agg(tablename,' ') from(select ('--table'||' '||a.schemaname||'.'||a.tablename) as tablename from pg_tables a, apm_db_info b where b.instance_name =upper(a.schemaname) and a.tableowner='postgres' and a.tablename not like ('%%p1%%') and a.schemaname not in ('pg_catalog','information_schema','public') and b.db_id =$db_id) a;"
EOF


for tablst in $(cat $SCRIPT_PATH/temp.txt);
do

pg_dump --verbose --host $PG_IP --port $PG_PORT --username $PG_USER --no-password --format custom --encoding UTF8 --file "$BACKUP_PATH/Daily_$schemae_$db_id_$select_date.backup" --table $tablst $DBNAME

done

 ;;

        4)
        echo''
echo ' [Restore List]'
echo -------------------------------------------------
echo ''

ls  $BACKUP_PATH > $SCRIPT_PATH/bklst.txt

awk '{print $1}' $SCRIPT_PATH/bklst.txt

echo ''
echo -------------------------------------------------


file_name=""
while [ -z "$file_name" ]
do
        echo "Enter the Restore file name : "
        stty echo
        read file_name
        stty echo
done


echo $file_name restore....... 

	pg_restore -h $PG_IP -p $PG_PORT -U $PG_USER --no-password -w -d $DBNAME -v $BACKUP_PATH/$file_name

echo "Restore Finish"
;;

        5)
        echo Bye

exit ;;


        *)
        echo "Enter [ 1 to 5]"
esac

