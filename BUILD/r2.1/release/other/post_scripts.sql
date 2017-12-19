ALTER SESSION SET NLS_LENGTH_SEMANTICS=BYTE;
alter session set deferred_segment_creation=TRUE;
SET DEFINE ON;
SET SERVEROUTPUT ON;
select count(*) after_sp_email_failure_log from dba_objects a where a.OBJECT_TYPE='PROCEDURE' and upper(a.OBJECT_NAME)=UPPER('sp_email_failure_log');