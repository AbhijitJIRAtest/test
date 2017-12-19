--Read/Write Grants
--Admin Schema to TBI User
BEGIN
  FOR x IN (SELECT username FROM DBA_USERS WHERE username LIKE '%_TBI') LOOP
    FOR i IN (SELECT 
                    CASE 
                        WHEN o.object_type = 'TABLE' THEN
                             'GRANT SELECT,INSERT,UPDATE,DELETE ON ' || o.owner || '.' || o.object_name || ' TO '|| x.username
                        WHEN o.object_type IN('VIEW','SEQUENCE') THEN
                             'GRANT SELECT ON ' || o.owner || '.' || o.object_name || ' TO '|| x.username
                        WHEN o.object_type IN('PACKAGE','PROCEDURE','FUNCTION','TYPE') THEN
                             'GRANT EXECUTE ON ' || o.owner || '.' ||  o.object_name || ' TO '|| x.username
                    END grant_sql
              FROM all_objects o
              WHERE o.object_type IN ('TABLE','VIEW','SEQUENCE','TYPE','PACKAGE','PROCEDURE','FUNCTION')
              AND (o.owner LIKE 'DB%ADMIN')
              ) LOOP
    
        EXECUTE IMMEDIATE i.grant_sql;
    END LOOP;
  END LOOP;
END;
/

--Read/Write Grants
--Portal Schema to TBI User
BEGIN
  FOR x IN (SELECT username FROM DBA_USERS WHERE username LIKE '%_TBI') LOOP
    FOR i IN (SELECT 
                    CASE 
                        WHEN o.object_type = 'TABLE'  AND o.object_name IN ('TBL_SIP_TASK','TBL_AUTO_LOGIN','TBL_AUDIT_LOG', 'TBL_EXPORTREPORTFILE','TBL_EXPORTFACFILE','TBL_EXPORTUSERPROFILE','TBL_SURVEYREFERINVESTIGATOR') THEN
                             'GRANT SELECT,INSERT,UPDATE,DELETE ON ' || o.owner || '.' || o.object_name || ' TO '|| x.username
                         WHEN o.object_type = 'TABLE'  AND o.object_name NOT IN ('TBL_SIP_TASK','TBL_AUTO_LOGIN','TBL_AUDIT_LOG') THEN
                             'GRANT SELECT ON ' || o.owner || '.' || o.object_name || ' TO '|| x.username     
                        WHEN o.object_type IN('VIEW','SEQUENCE') THEN
                             'GRANT SELECT ON ' || o.owner || '.' || o.object_name || ' TO '|| x.username
                        WHEN o.object_type IN('PACKAGE','PROCEDURE','FUNCTION','TYPE') THEN
                             'GRANT EXECUTE ON ' || o.owner || '.' ||  o.object_name || ' TO '|| x.username
                    END grant_sql
              FROM all_objects o
              WHERE o.object_type IN ('TABLE','VIEW','SEQUENCE','TYPE','PACKAGE','PROCEDURE','FUNCTION')
              AND (o.owner LIKE '%PORTAL')
              ) LOOP
    
        EXECUTE IMMEDIATE i.grant_sql;
    END LOOP;
  END LOOP;
END;
/

--Read/Write Grants
--From Admin Schema to Portal Schema
BEGIN
  FOR i IN (SELECT 
                    CASE 
                        WHEN o.object_type = 'TABLE' THEN
                             'GRANT SELECT,INSERT,UPDATE,DELETE ON ' || o.owner || '.' || o.object_name || ' TO TCSIP_CPORTAL '
                        WHEN o.object_type IN('VIEW','SEQUENCE') THEN
                             'GRANT SELECT ON ' || o.owner || '.' || o.object_name || ' TO TCSIP_CPORTAL '
                        WHEN o.object_type IN('PACKAGE','PROCEDURE','FUNCTION','TYPE') THEN
                             'GRANT EXECUTE ON ' || o.owner || '.' ||  o.object_name || ' TO TCSIP_CPORTAL '
                    END grant_sql
              FROM all_objects o
              WHERE o.object_type IN ('TABLE','VIEW','SEQUENCE','TYPE','PACKAGE','PROCEDURE','FUNCTION')
              AND (o.owner LIKE 'DB%ADMIN')
              AND o.object_name IN ('TBL_AUDIT','TBL_STUDYAUDITREPORTMAP','TBL_SURVEYAUDITREPORTMAP','TBL_TRNGCREDITSAUDITREPORTMAP',
                                    'TBL_DOCAUDITREPORTMAP','TBL_USERPROFILES','PKG_AUDIT','PKG_ENCRYPT','PKG_SEARCH','TBL_SITEUSERCV','SEQ_SITEUSERCV',
                                    'TBL_COUNTRIES','TBL_THERAPEUTICAREA','TBL_ORGANIZATION','TBL_PROGRAM','TBL_COMPOUND','TBL_INDICATION','TBL_POTENTIALINVESTIGATOR','TBL_CODE','TBL_POTENTIALINVTITLES')
              ) LOOP
    
        EXECUTE IMMEDIATE i.grant_sql;
  END LOOP;
END;
/

--Read Grants 
--Admin to TCSIP_CPORTAL schema

BEGIN
   FOR i IN (SELECT 'GRANT SELECT ON ' || o.owner || '.' || o.object_name || ' TO TCSIP_CPORTAL' grant_sql
              FROM all_objects o
              WHERE o.object_type IN ('TABLE')
              AND (o.owner LIKE 'DB%ADMIN')
              ) LOOP
      EXECUTE IMMEDIATE i.grant_sql;
    END LOOP;
END;
/
--Read Grants
--Dlfileentry in Liferay Schema

BEGIN
  FOR x IN (SELECT username FROM DBA_USERS WHERE username LIKE '%_TBI') LOOP
    FOR i IN (SELECT 'GRANT SELECT ON ' || o.owner || '.' || o.object_name || ' TO '|| x.username grant_sql
              FROM all_objects o
              WHERE o.object_type IN ('TABLE') and o.object_name IN ('DLFILEENTRY')
              AND (o.owner LIKE '%_LR')
              ) LOOP
    
        EXECUTE IMMEDIATE i.grant_sql;
    END LOOP;
  END LOOP;
END;
/
