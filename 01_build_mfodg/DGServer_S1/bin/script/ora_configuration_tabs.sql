CREATE TABLE APM_DB_INFO
(
  DB_ID            SMALLINT      ,
  INSTANCE_NAME    VARCHAR2(64)  ,
  HOST_IP          VARCHAR2(16)  ,
  HOST_NAME        VARCHAR2(64)  ,
  PORT             NUMBER        ,
  DAEMON_USER      VARCHAR2(64)  ,
  DAEMON_PASSWORD  VARCHAR2(64)  ,
  DB_USER          VARCHAR2(64)  ,
  DB_PASSWORD      VARCHAR2(64)  ,
  JDBC_URL         VARCHAR2(512) ,
  CHAR_SET         VARCHAR2(64)  ,
  ALERT_GROUP_NAME VARCHAR2(64)  ,
  RAC_GROUP_ID     NUMBER        ,
  GATHER_ID        NUMBER        ,
  DB_TYPE          VARCHAR2(16)  ,
  SID              VARCHAR2(64)  ,
  LSNR_PORT        NUMBER        ,
  OS_TYPE          VARCHAR2(64)  ,
  ORACLE_VERSION   VARCHAR2(64)
)
storage ( INITIAL 10k next 2m pctincrease 0 ) nologging;

CREATE UNIQUE INDEX APM_DB_INFO_UX ON APM_DB_INFO ( DB_ID ) storage ( INITIAL 10k next 2m pctincrease 0 ) nologging;
CREATE INDEX APM_DB_INFO_IX ON APM_DB_INFO ( DB_ID, INSTANCE_NAME ) storage ( INITIAL 10k next 2m pctincrease 0 ) nologging;


CREATE TABLE ORA_RAC_GROUP_NAME
(
  RAC_GROUP_ID NUMBER        ,
  NAME         VARCHAR2(16)  ,
  DESCRIPTION  VARCHAR2(512)
)
storage ( INITIAL 10k next 2m pctincrease 0 ) nologging;

CREATE UNIQUE INDEX ORA_RAC_GROUP_NAME_UX ON ORA_RAC_GROUP_NAME ( RAC_GROUP_ID ) storage ( INITIAL 10k next 2m pctincrease 0 ) nologging;


CREATE TABLE ORA_SERVICE_INFO 
(
  SERVICE_ID NUMBER   ,
  DB_ID      SMALLINT
)
storage ( INITIAL 10k next 2m pctincrease 0 ) nologging;

CREATE UNIQUE INDEX ORA_SERVICE_INFO_UX ON ORA_SERVICE_INFO ( DB_ID ) storage ( INITIAL 10k next 2m pctincrease 0 ) nologging;


CREATE TABLE ORA_SERVICE_NAME 
(
  SERVICE_ID  NUMBER       ,
  NAME        VARCHAR2(64) ,
  DESCRIPTION VARCHAR2(512)
)
storage ( INITIAL 10k next 2m pctincrease 0 ) nologging;

CREATE UNIQUE INDEX ORA_SERVICE_NAME_UX ON ORA_SERVICE_NAME ( SERVICE_ID ) storage ( INITIAL 10k next 2m pctincrease 0 ) nologging;


CREATE TABLE ORA_LC_CONFIG 
(
  DB_ID                     SMALLINT      ,
  DOWNLOAD_PARAMETER        VARCHAR2(1)   ,
  DOWNLOAD_TABLESPACE       VARCHAR2(1)   ,
  DOWNLOAD_SGASTAT          VARCHAR2(1)   ,
  DOWNLOAD_SGASTAT_INTERVAL NUMBER        ,
  DOWNLOAD_SGASTAT_SQL      VARCHAR2(512) ,
  PLANNER_RUN               VARCHAR2(1)   ,
  PLANNER_SCHEMAS           VARCHAR2(512) ,
  PLANNER_MAKE_BIND         VARCHAR2(1)   ,
  PLANNER_USE_EXPLAIN       VARCHAR2(1)   ,
  LAST_MODIFIED_TIME        DATE
)
storage ( INITIAL 10k next 2m pctincrease 0 ) nologging;

CREATE UNIQUE INDEX ORA_LC_CONFIG_UX ON ORA_LC_CONFIG ( DB_ID ) storage ( INITIAL 10k next 2m pctincrease 0 ) nologging;
