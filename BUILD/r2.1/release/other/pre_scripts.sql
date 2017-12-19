SET DEFINE OFF;
SET SERVEROUTPUT ON;
ALTER SESSION SET NLS_LENGTH_SEMANTICS=CHAR;
alter session set deferred_segment_creation=false;
select count(*) before_sp_email_failure_log from dba_objects a where a.OBJECT_TYPE='PROCEDURE' and upper(a.OBJECT_NAME)=UPPER('sp_email_failure_log');