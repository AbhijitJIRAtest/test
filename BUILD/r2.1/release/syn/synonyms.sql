--SYNONYM COUNT
SET SERVEROUTPUT ON;
select count(*) before_count_sunonym from dba_objects a where a.OBJECT_TYPE='SYNONYM' ;
--Create PUBLIC Synonyms
BEGIN
  FOR i IN (SELECT 'CREATE OR REPLACE PUBLIC SYNONYM ' || o.object_name || ' FOR ' || o.owner || '.' || o.object_name syn_sql
            FROM all_objects o
            WHERE o.object_type IN ('TABLE','VIEW','SEQUENCE','TYPE','PACKAGE','PROCEDURE','FUNCTION','TRIGGER')
            AND (o.owner LIKE 'DB%ADMIN' OR (o.owner LIKE '%PORTAL' AND o.object_name NOT IN('TBL_COUNTRIES','TBL_LANGUAGEMASTER')))
            ) LOOP
  
      EXECUTE IMMEDIATE i.syn_sql;
  END LOOP;  
END;
/

BEGIN
  FOR i IN (SELECT 'CREATE OR REPLACE PUBLIC SYNONYM ' || o.object_name || ' FOR ' || o.owner || '.' || o.object_name syn_sql
            FROM all_objects o
            WHERE o.object_type IN ('TABLE') and o.object_name IN ('DLFILEENTRY')
            AND (o.owner LIKE '%_LR')
            ) LOOP
  
      EXECUTE IMMEDIATE i.syn_sql;
  END LOOP;  
END;
/
select count(*) after_count_sunonym from dba_objects a where a.OBJECT_TYPE='SYNONYM' ;