spool r2.1_db_unit_test.log;

set serveroutput on size 1000000;

set define off;

prompt --r2.1_db_release_script.sql

BEGIN
DBMS_OUTPUT.PUT_LINE(SYSTIMESTAMP);
END;
/

prompt -- pre_scripts.sql
@./release/other/pre_scripts.sql
--prompt -- sip_ddl.sql
--@./release/ddl/sip_ddl.sql
--prompt -- portal_ddl.sql
--@./release/ddl/portal_ddl.sql
--prompt -- se_ddl.sql
--@./release/ddl/se_ddl.sql
--prompt -- survey_ddl.sql
--@./release/ddl/survey_ddl.sql
--prompt -- integ_ddl.sql
--@./release/ddl/integ_ddl.sql
--prompt -- comment_ddl.sql
--@./release/ddl/comment_ddl.sql
--prompt -- trainingassignment_ddl.sql
--@./release/ddl/trainingassignment_ddl.sql
--prompt -- unique_sip_studycontact.sql
--@./release/ddl/unique_sip_studycontact.sql
--prompt -- unique_sip_studysystem.sql
--@./release/ddl/unique_sip_studysystem.sql
--prompt -- unique_sip_facility.sql
--@./release/ddl/unique_sip_facility.sql
--prompt -- unique_sip_sitecontact.sql
--@./release/ddl/unique_sip_sitecontact.sql
--prompt --unique_sip_systemaccess.sql
--@./release/ddl/unique_sip_systemaccess.sql
--prompt --liferay_table_in_portal.sql
--@./release/ddl/liferay_table_in_portal.sql
--prompt -- sip_dml.sql
--@./release/dml/sip_dml.sql
--prompt -- packages.sql
--@./release/pkg/packages.sql
--prompt -- triggers.sql
--@./release/trg/triggers.sql
prompt -- proc.sql
@./release/proc/sp_email_failure_log.sql
prompt --synonyms.sql 
@./release/syn/synonyms.sql
prompt --grants.sql 
@./release/grant/grants.sql
prompt -- post_scripts.sql
@./release/other/post_scripts.sql
prompt --compile_schema.sql 
@./release/other/compile_schema.sql

BEGIN
DBMS_OUTPUT.PUT_LINE(SYSTIMESTAMP);
END;
/
set define on;

spool off;