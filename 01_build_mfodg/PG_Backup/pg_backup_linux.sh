#!/bin/bash

##############################
### Create by Lim Gil Hyun ###
###      2016 10 20        ###
##############################
clear
echo ""
echo "Welcome this is"
echo "PG Backup  &  Restore shell"
echo ""
echo ""
echo "######################################################"
echo "###                     INFOM                      ###"
echo "###                                                ###"
echo "###  When you first use or change the environment, ###"
echo "###  please choose the number [1].                 ###"
echo "###                                                ###"
echo "######################################################"
echo -------------------------------------------------
echo ""
echo 1. Create env file mode
echo ""
echo 2. Use env file mode
echo ""
echo -------------------------------------------------
echo ""
echo ""
echo -n "Enter your choice : "
read choice
echo ""
case $choice in
        1)


echo "Create env file mode"

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




rm -rf $SCRIPT_PATH/env.txt

touch $SCRIPT_PATH/env.txt

echo "PG_PATH = $PG_PATH" >> $SCRIPT_PATH/env.txt
echo "PG_IP = $PG_IP" >> $SCRIPT_PATH/env.txt
echo "PG_PORT = $PG_PORT" >> $SCRIPT_PATH/env.txt
echo "PG_USER = $PG_USER" >> $SCRIPT_PATH/env.txt
echo "PG_PASS = $PG_PASS" >> $SCRIPT_PATH/env.txt
echo "DBNAME = $DBNAME" >> $SCRIPT_PATH/env.txt
echo "BACKUP_PATH = $BACKUP_PATH" >> $SCRIPT_PATH/env.txt
echo "SCRIPT_PATH = $SCRIPT_PATH" >> $SCRIPT_PATH/env.txt



echo ''

echo  Select Menu [Interactive Mode]
echo -------------------------------------------------
echo 1. Full Backup
echo 2. Public Backup
echo 3. Daily Backup
echo 4. Export
echo 5. Restore
echo 6. Exit
echo''

echo -n "Enter your choice : "
read choice
echo ""

case $choice in
        1)
echo''
echo ' Select Instance List [Interactive Mode]'
echo -------------------------------------------------
$PG_PATH/psql --host $PG_IP --port $PG_PORT --username $PG_USER -t -d $DBNAME > $SCRIPT_PATH/dblst.txt <<EOF -c "select db_id,instance_name from apm_db_info order by db_id;"
EOF

#awk '{print $1, $2, $3}' $SCRIPT_PATH/dblst.txt

#echo -n "Enter the DB ID  "
#read db_id
#if [ "$db_id" = "" ]; then
#        db_id="all"
#fi

#schemae=`awk '$1 == '"${db_id}"' {print $3}' $SCRIPT_PATH/dblst.txt | tr '[A-Z]' '[a-z]'`





echo '     0 | ALL' >> $SCRIPT_PATH/dblst.txt

awk '{print $1, $2, $3}' $SCRIPT_PATH/dblst.txt

echo -n "Enter the DB ID  "

read db_id
if [ "$db_id" = "" ]; then
        db_id="0"
fi

schemae=`awk '$1 == '"${db_id}"' {print $3}' $SCRIPT_PATH/dblst.txt`

while [  "$schemae" = "" ] ; do

        echo "========================================"
        echo ""
        echo "There is no DB ID. please check again."
        echo ""
        echo "========================================"
	echo -n "Enter the DB ID  "

read db_id
if [ "$db_id" = "" ]; then
        db_id="0"
fi

schemae=`awk '$1 == '"${db_id}"' {print $3}' $SCRIPT_PATH/dblst.txt | tr '[A-Z]' '[a-z]'`


done









if [ $db_id = 0 ] ; then
	echo all

	$PG_PATH/pg_dump --verbose --host $PG_IP --port $PG_PORT --username $PG_USER --no-password --format custom --encoding UTF8 --file "$BACKUP_PATH/Full_Backup.backup" $DBNAME
 	echo''
	echo''
else 
	echo $schemae

	$PG_PATH/pg_dump --verbose --host $PG_IP --port $PG_PORT --username $PG_USER -n $schemae --no-password --format custom --encoding UTF8 --file "$BACKUP_PATH/Full_Backup_$schemae.backup" $DBNAME

fi


echo "========================"
echo "PG dump Finish"
echo "========================"

 ;;


        2)

 echo 'Only Public Schema Backup'
sleep 3

        $PG_PATH/pg_dump --verbose --host $PG_IP --port $PG_PORT --username $PG_USER -n public --no-password --format custom --encoding UTF8 --file "$BACKUP_PATH/Full_Backup_public.backup" $DBNAME


echo "========================"
echo "Public Backup Finish"
echo "========================"


;;








        3)
       echo''
echo ' Select Instance List [Daily Backup]'
echo -------------------------------------------------
$PG_PATH/psql --host $PG_IP --port $PG_PORT --username $PG_USER -t -d $DBNAME > $SCRIPT_PATH/dblst.txt <<EOF -c "select db_id,instance_name from apm_db_info order by db_id;"
EOF

echo '     0 | all' >> $SCRIPT_PATH/dblst.txt

awk '{print $1, $2, $3}' $SCRIPT_PATH/dblst.txt

echo -n "Enter the DB ID  "

read db_id
if [ "$db_id" = "" ]; then
        db_id="0"
fi

schemae=`awk '$1 == '"${db_id}"' {print $3}' $SCRIPT_PATH/dblst.txt`

while [  "$schemae" = "" ] ; do

        echo "========================================"
        echo ""
        echo "There is no DB ID. please check again."
        echo ""
        echo "========================================"
	echo -n "Enter the DB ID  "

read db_id
if [ "$db_id" = "" ]; then
        db_id="0"
fi

schemae=`awk '$1 == '"${db_id}"' {print $3}' $SCRIPT_PATH/dblst.txt`


done




$PG_PATH/psql --host $PG_IP --port $PG_PORT --username $PG_USER -t -d $DBNAME > $SCRIPT_PATH/YDATE.txt <<EOF -c  "select distinct(substring(tablename,length(tablename)-8,6)) as date from pg_tables a, apm_db_info b where b.instance_name =upper(a.schemaname) and tableowner='postgres' and tablename in (select tablename from pg_tables where tablename like ('%%p1%%') and to_date(substring(tablename,length(tablename)-8,6),'yymmdd') <= current_date -1) order by 1 desc limit 1"
EOF



YDATE=`awk '{print $1}' $SCRIPT_PATH/YDATE.txt`


if [ $YDATE = "" ]; then
        echo "==========================================="
        echo ""
        echo "There is no Date DATA. please check again."
        echo ""
        echo "==========================================="
fi    



if [ $db_id = 0 ];

then

echo all
echo $YDATE
$PG_PATH/psql --host $PG_IP --port $PG_PORT --username $PG_USER -t -d $DBNAME > $SCRIPT_PATH/temp.txt <<EOF -c "select 'test'||' '||string_agg(tablename,' ') from (select ('--table'||' '||schemaname||'.'||tablename) as tablename,schemaname from pg_tables where tableowner='postgres' and tablename not like ('%%p1%%') and schemaname not in ('pg_catalog','information_schema','public') union all select ('--table'||' '||schemaname||'.'||tablename) as tablename,schemaname from pg_tables where tableowner='postgres' and tablename in (select tablename from pg_tables where tablename like ('%%p1%%') and to_date(substring(tablename,length(tablename)-8,6),'yymmdd') = current_date - 1)) a"
EOF


for tablst in $(cat $SCRIPT_PATH/temp.txt);
do


$PG_PATH/pg_dump --verbose --host $PG_IP --port $PG_PORT --username $PG_USER --no-password --format custom --encoding UTF8 --file "$BACKUP_PATH/Daily_$YDATE Backup.backup" --table $tablst  $DBNAME

done


else


echo $schemae
echo $YDATE

$PG_PATH/psql --host $PG_IP --port $PG_PORT --username $PG_USER -t -d $DBNAME --no-password > $SCRIPT_PATH/temp2.txt <<EOF -c "select 'test'||' '||string_agg(tablename,' ') from(select ('--table'||' '||a.schemaname||'.'||a.tablename) as tablename from pg_tables a, apm_db_info b where b.instance_name =upper(a.schemaname) and a.tableowner='postgres' and a.tablename not like ('%%p1%%') and a.schemaname not in ('pg_catalog','information_schema','public') and b.instance_name ='$schemae' union all select ('--table'||' '||schemaname||'.'||tablename) as tablename from pg_tables a, apm_db_info b where b.instance_name =upper(a.schemaname) and tableowner='postgres' and tablename in (select tablename from pg_tables where tablename like ('%%p1%%') and to_date(substring(tablename,length(tablename)-8,6),'yymmdd') = current_date - 1) and b.instance_name ='$schemae')  a;"
EOF



for tablst in $(cat $SCRIPT_PATH/temp2.txt);
do

$PG_PATH/pg_dump --verbose --host $PG_IP --port $PG_PORT --username $PG_USER --no-password --format custom --encoding UTF8 --file "$BACKUP_PATH/Daily_$YDATE $schemae.backup" --table $tablst $DBNAME

done


fi

echo "========================"
echo "PG dump Finish"
echo "========================"


 ;;

        4)
        echo''
echo -------------------------------------------------
echo  Select Menu [One Day or Long Turm Export Backup]
echo -------------------------------------------------
echo 1. One Day Export Backup
echo 2. Long Turm Export Backup
echo''

echo -n "Enter your choice : "
read choice
echo ""

case $choice in
        1)

        echo''
echo ' Select Instance List [Export Backup]'
echo -------------------------------------------------

$PG_PATH/psql --host $PG_IP --port $PG_PORT --username $PG_USER -t -d $DBNAME > $SCRIPT_PATH/dblst.txt <<EOF -c "select db_id,instance_name from apm_db_info order by db_id;"
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


while [  "$schemae" = "" ] ; do

        echo "========================================"
        echo ""
        echo "There is no DB ID. please check again."
        echo ""
        echo "========================================"
	echo -n "Enter the DB ID  "

read db_id
if [ "$db_id" = "" ]; then
        db_id="0"
fi

schemae=`awk '$1 == '"${db_id}"' {print $3}' $SCRIPT_PATH/dblst.txt`


done




echo ' Available Date [Export Backup]'
echo -------------------------------------------------

$PG_PATH/psql --host $PG_IP --port $PG_PORT --username $PG_USER -t -d $DBNAME > $SCRIPT_PATH/datelst.txt <<EOF  -c "select rownum||' | '||date as num from (select row_number() over() as rownum,a.date from (select distinct(substring(tablename,length(tablename)-8,6)) as date from pg_tables a, apm_db_info b where b.instance_name =upper(a.schemaname) and tableowner='postgres' and tablename in (select tablename from pg_tables where tablename like ('%%p1%%') and to_date(substring(tablename,length(tablename)-8,6),'yymmdd') <= current_date - 1) and b.db_id =$db_id order by 1)a)b;"
EOF


awk '{print $1, $2, $3}' $SCRIPT_PATH/datelst.txt

echo ''
echo "Select Export for Date Number : "
read select_date

seldate=`awk '$1 == '"${select_date}"' {print $3}' $SCRIPT_PATH/datelst.txt`


while [ "$seldate" = "" ]; do

        echo "Select Export for Date Number : "
        stty echo
        read select_date
        stty echo


seldate=`awk '$1 == '"${select_date}"' {print $3}' $SCRIPT_PATH/datelst.txt`


done


echo ''



$PG_PATH/psql --host $PG_IP --port $PG_PORT --username $PG_USER -t -d $DBNAME >> $SCRIPT_PATH/temp.txt <<EOF -c "select 'test'||' '||string_agg(tablename,' ') from(select ('--table'||' '||a.schemaname||'.'||a.tablename) as tablename from pg_tables a, apm_db_info b where b.instance_name =upper(a.schemaname) and a.tableowner='postgres' and a.tablename not like ('%%p1%%') and a.schemaname not in ('pg_catalog','information_schema','public') and b.db_id =$db_id union all select ('--table'||' '||schemaname||'.'||tablename) as tablename from pg_tables a, apm_db_info b where b.instance_name =upper(a.schemaname) and tableowner='postgres' and tablename in (select tablename from pg_tables where tablename like ('%%p1%%') and substring(tablename,length(tablename)-8,6) like '%$seldate' and b.db_id = $db_id)) a;"
EOF



for tablst in $(cat $SCRIPT_PATH/temp.txt);
do

$PG_PATH/pg_dump --verbose --host $PG_IP --port $PG_PORT --username $PG_USER --no-password --format custom --encoding UTF8 --file "$BACKUP_PATH/Daily_$schemae $db_id $seldate.backup" --table $tablst $DBNAME

done

echo "============================="
echo "One Day Export Backup Finish"
echo "============================="



;;

	2)

$PG_PATH/psql --host $PG_IP --port $PG_PORT --username $PG_USER -t -d $DBNAME > $SCRIPT_PATH/dblst.txt <<EOF -c "select db_id,instance_name from apm_db_info order by db_id;"
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


while [  "$schemae" = "" ] ; do

        echo "========================================"
        echo ""
        echo "There is no DB ID. please check again."
        echo ""
        echo "========================================"
	echo -n "Enter the DB ID  "

read db_id
if [ "$db_id" = "" ]; then
        db_id="0"
fi

schemae=`awk '$1 == '"${db_id}"' {print $3}' $SCRIPT_PATH/dblst.txt`


done




echo ' Available Date [Export Backup]'
echo -------------------------------------------------

$PG_PATH/psql --host $PG_IP --port $PG_PORT --username $PG_USER -t -d $DBNAME > $SCRIPT_PATH/datelst.txt <<EOF  -c "select rownum||' | '||date as num from (select row_number() over() as rownum,a.date from (select distinct(substring(tablename,length(tablename)-8,6)) as date from pg_tables a, apm_db_info b where b.instance_name =upper(a.schemaname) and tableowner='postgres' and tablename in (select tablename from pg_tables where tablename like ('%%p1%%') and to_date(substring(tablename,length(tablename)-8,6),'yymmdd') <= current_date + 10) and b.db_id =$db_id order by 1)a)b;"
EOF


awk '{print $1, $2, $3}' $SCRIPT_PATH/datelst.txt

echo ''
echo "Select Export for Begin Date Number : "
read select_date1

seldate1=`awk '$1 == '"${select_date1}"' {print $3}' $SCRIPT_PATH/datelst.txt`


while [ "$seldate1" = "" ]; do

        echo "Select Export for Begin Date Number : "
        stty echo
        read select_date1
        stty echo


seldate1=`awk '$1 == '"${select_date1}"' {print $3}' $SCRIPT_PATH/datelst.txt`


done


echo ''
echo "Select Export for End Date Number : "
read select_date2

seldate2=`awk '$1 == '"${select_date2}"' {print $3}' $SCRIPT_PATH/datelst.txt`


while [ "$seldate2" = "" ]; do

        echo "Select Export for End Date Number : "
        stty echo
        read select_date2
        stty echo


seldate2=`awk '$1 == '"${select_date2}"' {print $3}' $SCRIPT_PATH/datelst.txt`


done


echo ''



$PG_PATH/psql --host $PG_IP --port $PG_PORT --username $PG_USER -t -d $DBNAME >> $SCRIPT_PATH/temp.txt <<EOF -c "select 'test'||' '||string_agg(tablename,' ') from(select ('--table'||' '||a.schemaname||'.'||a.tablename) as tablename from pg_tables a, apm_db_info b where b.instance_name =upper(a.schemaname) and a.tableowner='postgres' and a.tablename not like ('%%p1%%') and a.schemaname not in ('pg_catalog','information_schema','public') and b.db_id =$db_id union all select ('--table'||' '||schemaname||'.'||tablename) as tablename from pg_tables a, apm_db_info b where b.instance_name =upper(a.schemaname) and tableowner='postgres' and tablename in (select tablename from pg_tables where tablename like ('%%p1%%') and substring(tablename,length(tablename)-8,6) between '$seldate1' and '$seldate2' and b.db_id = $db_id)) a;"
EOF



for tablst in $(cat $SCRIPT_PATH/temp.txt);
do

$PG_PATH/pg_dump --verbose --host $PG_IP --port $PG_PORT --username $PG_USER --no-password --format custom --encoding UTF8 --file "$BACKUP_PATH/Daily_$schemae $db_id $seldate1-$seldate2.backup" --table $tablst $DBNAME

done

echo "==============================="
echo "Long Turm Export Backup Finish"
echo "==============================="



;;

esac







 ;;

        5)
        echo''
echo ' [Restore List]'
echo -------------------------------------------------
echo ''

cd  $BACKUP_PATH

rename " " "_" *
sleep 1
rename " " "_" *
sleep 1
rename " " "_" *
sleep 1
rename " " "_" *
sleep 1


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

	$PG_PATH/pg_restore -h $PG_IP -p $PG_PORT -U $PG_USER --no-password -w -d $DBNAME -v $BACKUP_PATH/$file_name

echo "Restore Finish"
;;

        6)
        echo Bye

exit ;;


        *)
        echo "Enter [ 1 to 5]"
esac

;;

	2)
echo "Use env File mode"

echo "Where is the env file?"
echo " Script Path  : [/home/postgres/log]"
read SCRIPT_PATH
if [ "$SCRIPT_PATH" = "" ]; then
SCRIPT_PATH="/home/postgres/log"
fi


PG_PATH=`awk '$1 == "PG_PATH"  {print $3}' $SCRIPT_PATH/env.txt`
PG_IP=`awk '$1 == "PG_IP"  {print $3}' $SCRIPT_PATH/env.txt`
PG_PORT=`awk '$1 == "PG_PORT" {print $3}' $SCRIPT_PATH/env.txt`
PG_USER=`awk '$1 == "PG_USER" {print $3}' $SCRIPT_PATH/env.txt`
PG_PASS=`awk '$1 == "PG_PASS" {print $3}' $SCRIPT_PATH/env.txt`
DBNAME=`awk '$1 == "DBNAME" {print $3}' $SCRIPT_PATH/env.txt`
BACKUP_PATH=`awk '$1 == "BACKUP_PATH" {print $3}' $SCRIPT_PATH/env.txt`
SCRIPT_PATH=`awk '$1 == "SCRIPT_PATH" {print $3}' $SCRIPT_PATH/env.txt`


echo

echo "========================================================"
echo "PG DATA Path       : "  $PG_PATH
echo "PG IP Address      : "  $PG_IP
echo "PG Port number     : "  $PG_PORT
echo "PostgreSQL user    : "  $PG_USER
echo "PG DB name         : "  $DBNAME
echo "Backup output Path : "  $BACKUP_PATH
echo "Backup Script Path : "  $SCRIPT_PATH
echo "========================================================"



echo ''
echo ''


echo  Select Menu [Interactive Mode]
echo -------------------------------------------------
echo 1. Full Backup 
echo 2. Public Backup 
echo 3. Daily Backup
echo 4. Export
echo 5. Restore
echo 6. Exit
echo''

echo -n "Enter your choice : "
read choice
echo ""

case $choice in
        1)
echo''
echo ' Select Instance List [Interactive Mode]'
echo -------------------------------------------------
$PG_PATH/psql --host $PG_IP --port $PG_PORT --username $PG_USER -t -d $DBNAME > $SCRIPT_PATH/dblst.txt <<EOF -c "select db_id,instance_name from apm_db_info order by db_id;"
EOF





echo '     0 | ALL' >> $SCRIPT_PATH/dblst.txt

awk '{print $1, $2, $3}' $SCRIPT_PATH/dblst.txt

echo -n "Enter the DB ID  "

read db_id
if [ "$db_id" = "" ]; then
        db_id="0"
fi

schemae=`awk '$1 == '"${db_id}"' {print $3}' $SCRIPT_PATH/dblst.txt`

while [  "$schemae" = "" ] ; do

        echo "========================================"
        echo ""
        echo "There is no DB ID. please check again."
        echo ""
        echo "========================================"
	echo -n "Enter the DB ID  "

read db_id
if [ "$db_id" = "" ]; then
        db_id="0"
fi

schemae=`awk '$1 == '"${db_id}"' {print $3}' $SCRIPT_PATH/dblst.txt | tr '[A-Z]' '[a-z]'`


done




if [ $db_id = 0 ] ; then
	echo all

	$PG_PATH/pg_dump --verbose --host $PG_IP --port $PG_PORT --username $PG_USER --no-password --format custom --encoding UTF8 --file "$BACKUP_PATH/Full_Backup.backup" $DBNAME
 	echo''
	echo''
echo "========================"
echo "PG dump Finish"
echo "========================"

else 
	echo $schemae

	$PG_PATH/pg_dump --verbose --host $PG_IP --port $PG_PORT --username $PG_USER -n $schemae --no-password --format custom --encoding UTF8 --file "$BACKUP_PATH/Full_Backup_$schemae.backup" $DBNAME



echo "========================"
echo "PG dump Finish"
echo "========================"
fi
 ;;


	2)

 echo 'Only Public Schema Backup'
sleep 3

        $PG_PATH/pg_dump --verbose --host $PG_IP --port $PG_PORT --username $PG_USER -n public --no-password --format custom --encoding UTF8 --file "$BACKUP_PATH/Full_Backup_public.backup" $DBNAME

echo "========================"
echo "Public Backup Finish"
echo "========================"




;;


        3)
       echo''
echo ' Select Instance List [Daily Backup]'
echo -------------------------------------------------
$PG_PATH/psql --host $PG_IP --port $PG_PORT --username $PG_USER -t -d $DBNAME > $SCRIPT_PATH/dblst.txt <<EOF -c "select db_id,instance_name from apm_db_info order by db_id;"
EOF

echo '     0 | all' >> $SCRIPT_PATH/dblst.txt

awk '{print $1, $2, $3}' $SCRIPT_PATH/dblst.txt

echo -n "Enter the DB ID  "

read db_id
if [ "$db_id" = "" ]; then
        db_id="0"
fi

schemae=`awk '$1 == '"${db_id}"' {print $3}' $SCRIPT_PATH/dblst.txt`

while [  "$schemae" = "" ] ; do

        echo "========================================"
        echo ""
        echo "There is no DB ID. please check again."
        echo ""
        echo "========================================"
	echo -n "Enter the DB ID  "

read db_id
if [ "$db_id" = "" ]; then
        db_id="0"
fi

schemae=`awk '$1 == '"${db_id}"' {print $3}' $SCRIPT_PATH/dblst.txt`


done




$PG_PATH/psql --host $PG_IP --port $PG_PORT --username $PG_USER -t -d $DBNAME > $SCRIPT_PATH/YDATE.txt <<EOF -c  "select distinct(substring(tablename,length(tablename)-8,6)) as date from pg_tables a, apm_db_info b where b.instance_name =upper(a.schemaname) and tableowner='postgres' and tablename in (select tablename from pg_tables where tablename like ('%%p1%%') and to_date(substring(tablename,length(tablename)-8,6),'yymmdd') <= current_date -1) order by 1 desc limit 1"
EOF



YDATE=`awk '{print $1}' $SCRIPT_PATH/YDATE.txt`


if [ $YDATE = "" ]; then
        echo "==========================================="
        echo ""
        echo "There is no Date DATA. please check again."
        echo ""
        echo "==========================================="
fi    



if [ $db_id = 0 ];

then

echo all
echo $YDATE
$PG_PATH/psql --host $PG_IP --port $PG_PORT --username $PG_USER -t -d $DBNAME > $SCRIPT_PATH/temp.txt <<EOF -c "select 'test'||' '||string_agg(tablename,' ') from (select ('--table'||' '||schemaname||'.'||tablename) as tablename,schemaname from pg_tables where tableowner='postgres' and tablename not like ('%%p1%%') and schemaname not in ('pg_catalog','information_schema','public') union all select ('--table'||' '||schemaname||'.'||tablename) as tablename,schemaname from pg_tables where tableowner='postgres' and tablename in (select tablename from pg_tables where tablename like ('%%p1%%') and to_date(substring(tablename,length(tablename)-8,6),'yymmdd') = current_date - 1)) a"
EOF


for tablst in $(cat $SCRIPT_PATH/temp.txt);
do


$PG_PATH/pg_dump --verbose --host $PG_IP --port $PG_PORT --username $PG_USER --no-password --format custom --encoding UTF8 --file "$BACKUP_PATH/Daily_$YDATE Backup.backup" --table $tablst  $DBNAME

done


else


echo $schemae
echo $YDATE

$PG_PATH/psql --host $PG_IP --port $PG_PORT --username $PG_USER -t -d $DBNAME --no-password > $SCRIPT_PATH/temp2.txt <<EOF -c "select 'test'||' '||string_agg(tablename,' ') from(select ('--table'||' '||a.schemaname||'.'||a.tablename) as tablename from pg_tables a, apm_db_info b where b.instance_name =upper(a.schemaname) and a.tableowner='postgres' and a.tablename not like ('%%p1%%') and a.schemaname not in ('pg_catalog','information_schema','public') and b.instance_name ='$schemae' union all select ('--table'||' '||schemaname||'.'||tablename) as tablename from pg_tables a, apm_db_info b where b.instance_name =upper(a.schemaname) and tableowner='postgres' and tablename in (select tablename from pg_tables where tablename like ('%%p1%%') and to_date(substring(tablename,length(tablename)-8,6),'yymmdd') = current_date - 1) and b.instance_name ='$schemae')  a;"
EOF



for tablst in $(cat $SCRIPT_PATH/temp2.txt);
do

$PG_PATH/pg_dump --verbose --host $PG_IP --port $PG_PORT --username $PG_USER --no-password --format custom --encoding UTF8 --file "$BACKUP_PATH/Daily_$YDATE $schemae.backup" --table $tablst $DBNAME

done


fi

echo "========================"
echo "PG dump Finish"
echo "========================"


 ;;


        4)
        echo''
echo -------------------------------------------------
echo  Select Menu [One Day or Long Turm Export Backup]
echo -------------------------------------------------
echo 1. One Day Export Backup
echo 2. Long Turm Export Backup
echo''

echo -n "Enter your choice : "
read choice
echo ""

case $choice in
        1)

        echo''
echo ' Select Instance List [Export Backup]'
echo -------------------------------------------------

$PG_PATH/psql --host $PG_IP --port $PG_PORT --username $PG_USER -t -d $DBNAME > $SCRIPT_PATH/dblst.txt <<EOF -c "select db_id,instance_name from apm_db_info order by db_id;"
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


while [  "$schemae" = "" ] ; do

        echo "========================================"
        echo ""
        echo "There is no DB ID. please check again."
        echo ""
        echo "========================================"
	echo -n "Enter the DB ID  "

read db_id
if [ "$db_id" = "" ]; then
        db_id="0"
fi

schemae=`awk '$1 == '"${db_id}"' {print $3}' $SCRIPT_PATH/dblst.txt`


done




echo ' Available Date [Export Backup]'
echo -------------------------------------------------

$PG_PATH/psql --host $PG_IP --port $PG_PORT --username $PG_USER -t -d $DBNAME > $SCRIPT_PATH/datelst.txt <<EOF  -c "select rownum||' | '||date as num from (select row_number() over() as rownum,a.date from (select distinct(substring(tablename,length(tablename)-8,6)) as date from pg_tables a, apm_db_info b where b.instance_name =upper(a.schemaname) and tableowner='postgres' and tablename in (select tablename from pg_tables where tablename like ('%%p1%%') and to_date(substring(tablename,length(tablename)-8,6),'yymmdd') <= current_date - 1) and b.db_id =$db_id order by 1)a)b;"
EOF


awk '{print $1, $2, $3}' $SCRIPT_PATH/datelst.txt

echo ''
echo "Select Export for Date Number : "
read select_date

seldate=`awk '$1 == '"${select_date}"' {print $3}' $SCRIPT_PATH/datelst.txt`


while [ "$seldate" = "" ]; do

        echo "Select Export for Date Number : "
        stty echo
        read select_date
        stty echo


seldate=`awk '$1 == '"${select_date}"' {print $3}' $SCRIPT_PATH/datelst.txt`


done


echo ''


$PG_PATH/psql --host $PG_IP --port $PG_PORT --username $PG_USER -t -d $DBNAME >> $SCRIPT_PATH/temp.txt <<EOF -c "select 'test'||' '||string_agg(tablename,' ') from(select ('--table'||' '||a.schemaname||'.'||a.tablename) as tablename from pg_tables a, apm_db_info b where b.instance_name =upper(a.schemaname) and a.tableowner='postgres' and a.tablename not like ('%%p1%%') and a.schemaname not in ('pg_catalog','information_schema','public') and b.db_id =$db_id union all select ('--table'||' '||schemaname||'.'||tablename) as tablename from pg_tables a, apm_db_info b where b.instance_name =upper(a.schemaname) and tableowner='postgres' and tablename in (select tablename from pg_tables where tablename like ('%%p1%%') and substring(tablename,length(tablename)-8,6) like '%$seldate' and b.db_id = $db_id)) a;"
EOF


for tablst in $(cat $SCRIPT_PATH/temp.txt);
do

$PG_PATH/pg_dump --verbose --host $PG_IP --port $PG_PORT --username $PG_USER --no-password --format custom --encoding UTF8 --file "$BACKUP_PATH/Daily_$schemae $db_id $seldate.backup" --table $tablst $DBNAME

done

echo "============================="
echo "One Day Export Backup Finish"
echo "============================="


;;

	2)

$PG_PATH/psql --host $PG_IP --port $PG_PORT --username $PG_USER -t -d $DBNAME > $SCRIPT_PATH/dblst.txt <<EOF -c "select db_id,instance_name from apm_db_info order by db_id;"
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


while [  "$schemae" = "" ] ; do

        echo "========================================"
        echo ""
        echo "There is no DB ID. please check again."
        echo ""
        echo "========================================"
	echo -n "Enter the DB ID  "

read db_id
if [ "$db_id" = "" ]; then
        db_id="0"
fi

schemae=`awk '$1 == '"${db_id}"' {print $3}' $SCRIPT_PATH/dblst.txt`


done




echo ' Available Date [Export Backup]'
echo -------------------------------------------------

$PG_PATH/psql --host $PG_IP --port $PG_PORT --username $PG_USER -t -d $DBNAME > $SCRIPT_PATH/datelst.txt <<EOF  -c "select rownum||' | '||date as num from (select row_number() over() as rownum,a.date from (select distinct(substring(tablename,length(tablename)-8,6)) as date from pg_tables a, apm_db_info b where b.instance_name =upper(a.schemaname) and tableowner='postgres' and tablename in (select tablename from pg_tables where tablename like ('%%p1%%') and to_date(substring(tablename,length(tablename)-8,6),'yymmdd') <= current_date - 1) and b.db_id =$db_id order by 1)a)b;"
EOF


awk '{print $1, $2, $3}' $SCRIPT_PATH/datelst.txt

echo ''
echo "Select Export for Begin Date Number : "
read select_date1

seldate1=`awk '$1 == '"${select_date1}"' {print $3}' $SCRIPT_PATH/datelst.txt`


while [ "$seldate1" = "" ]; do

        echo "Select Export for Begin Date Number : "
        stty echo
        read select_date1
        stty echo


seldate1=`awk '$1 == '"${select_date1}"' {print $3}' $SCRIPT_PATH/datelst.txt`


done


echo ''
echo "Select Export for End Date Number : "
read select_date2

seldate2=`awk '$1 == '"${select_date2}"' {print $3}' $SCRIPT_PATH/datelst.txt`


while [ "$seldate2" = "" ]; do

        echo "Select Export for End Date Number : "
        stty echo
        read select_date2
        stty echo


seldate2=`awk '$1 == '"${select_date2}"' {print $3}' $SCRIPT_PATH/datelst.txt`


done


echo ''


$PG_PATH/psql --host $PG_IP --port $PG_PORT --username $PG_USER -t -d $DBNAME >> $SCRIPT_PATH/temp.txt <<EOF -c "select 'test'||' '||string_agg(tablename,' ') from(select ('--table'||' '||a.schemaname||'.'||a.tablename) as tablename from pg_tables a, apm_db_info b where b.instance_name =upper(a.schemaname) and a.tableowner='postgres' and a.tablename not like ('%%p1%%') and a.schemaname not in ('pg_catalog','information_schema','public') and b.db_id =$db_id union all select ('--table'||' '||schemaname||'.'||tablename) as tablename from pg_tables a, apm_db_info b where b.instance_name =upper(a.schemaname) and tableowner='postgres' and tablename in (select tablename from pg_tables where tablename like ('%%p1%%') and substring(tablename,length(tablename)-8,6) between '$seldate1' and '$seldate2' and b.db_id = $db_id)) a;"
EOF


for tablst in $(cat $SCRIPT_PATH/temp.txt);
do

$PG_PATH/pg_dump --verbose --host $PG_IP --port $PG_PORT --username $PG_USER --no-password --format custom --encoding UTF8 --file "$BACKUP_PATH/Daily_$schemae $db_id $seldate1-$seldate2.backup" --table $tablst $DBNAME

done

echo "==============================="
echo "Long Turm Export Backup Finish"
echo "==============================="



;;

esac







 ;;

        5)
        echo''
echo ' [Restore List]'
echo -------------------------------------------------
echo ''

cd $BACKUP_PATH

rename " " "_" *
sleep 1
rename " " "_" *
sleep 1
rename " " "_" *
sleep 1
rename " " "_" *
sleep 1

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

	$PG_PATH/pg_restore -h $PG_IP -p $PG_PORT -U $PG_USER --no-password -w -d $DBNAME -v $BACKUP_PATH/$file_name

echo "Restore Finish"
;;

        6)
        echo Bye

exit ;;


        *)
        echo "Enter [ 1 to 5]"
esac
;;


esac


