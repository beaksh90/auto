SELECT localtimestamp( 0 ) as time , -- 현재 시간
       datname as dbname ,	     -- DB 이름	
       to_char(age( datfrozenxid ),'9,999,999,999') as max_age , -- 해당 db 에서 age 가 제일 큰 값
       (
        SELECT to_char(setting :: integer,'99,999,999,999')
        FROM   pg_settings
        WHERE  name = 'autovacuum_freeze_max_age' 
       ) as parameter_max_age,		-- parameter 설정 값. max_age (limit)
       to_char(txid_current(),'99,999,999,999') as current_txid		-- current txid
FROM   pg_database;

select relname as max_age_table_name,age(relfrozenxid) as age from pg_class
where age(relfrozenxid) =
(
    select 
    max(age(relfrozenxid))
    from pg_class
    where relkind = 'r'
    )
limit 1;


