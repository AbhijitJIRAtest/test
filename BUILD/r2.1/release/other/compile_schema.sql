BEGIN
  FOR i IN (SELECT du.username 
            FROM DBA_USERS du 
            WHERE du.username LIKE 'DB%ADMIN' OR du.username LIKE '%PORTAL') LOOP
      DBMS_UTILITY.COMPILE_SCHEMA(i.username);
  END LOOP;
END;
/