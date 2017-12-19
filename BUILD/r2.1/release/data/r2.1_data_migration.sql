spool r2.1_data_migration.log;

set serveroutput on size 1000000;

set define off;

prompt --r2.1_data_migration.sql

BEGIN
DBMS_OUTPUT.PUT_LINE(SYSTIMESTAMP);
END;
/

prompt -- pre_scripts.sql
@./release/other/pre_scripts.sql
prompt --study_data_migration.sql
@./release/data/study_data_migration.sql
prompt --Survey_data_migration.sql
@./release/data/Survey_data_migration.sql
prompt --role_data_migration.sql
@./release/data/role_data_migration.sql
prompt -- post_scripts.sql
@./release/other/post_scripts.sql

BEGIN
DBMS_OUTPUT.PUT_LINE(SYSTIMESTAMP);
END;
/

set define on;

spool off;