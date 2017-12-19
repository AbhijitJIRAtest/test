CREATE OR REPLACE TRIGGER TRG_TBL_SITECONTACTMAP_AUDIT
AFTER INSERT OR UPDATE OR DELETE ON TBL_SITECONTACTMAP
FOR EACH ROW
DECLARE
v_operation tbl_audit.operation%TYPE;
v_auditid   tbl_audit.auditid%TYPE;  
v_createdby tbl_audit.createdby%TYPE;
v_createddt tbl_audit.createddt%TYPE;
v_modifiedby tbl_audit.modifiedby%TYPE;
v_modifieddt tbl_audit.modifieddt%TYPE;
v_sitecontactid  TBL_SITECONTACTMAP.SITECONTACTID%TYPE;
v_siteid  TBL_SITECONTACTMAP.SITEID%TYPE;
v_studyid TBL_SITE.studyid%TYPE; 
v_contactid TBL_SITECONTACTMAP.contactid%TYPE;
v_contacttype TBL_SITECONTACTMAP.Contacttype%TYPE;
v_sysdate DATE:=SYSDATE;
BEGIN
  IF INSERTING THEN
    v_operation := pkg_audit.g_operation_create;
    v_createdby := :NEW.createdby;
    v_createddt := :NEW.createddt;
    v_modifiedby := :NEW.createdby;
    v_modifieddt := :NEW.createddt;
    v_sitecontactid := :NEW.SITECONTACTID;
    v_siteid:=:NEW.siteid;
    v_contactid:=:NEW.contactid;
    v_contacttype :=:NEW.Contacttype;
  ELSIF UPDATING THEN
    --Always Update Operation even if Soft Delete hence ISACTIVE not considered
    v_operation := pkg_audit.g_operation_update;
    v_sitecontactid := :NEW.SITECONTACTID;
    v_createdby := :NEW.modifiedby;
    v_createddt := :NEW.modifieddt;
    v_modifiedby := :NEW.modifiedby;
    v_modifieddt := :NEW.modifieddt;
    v_siteid:=:NEW.siteid;
    v_contactid:=:NEW.contactid;
    v_contacttype :=:NEW.Contacttype;
  ELSIF DELETING THEN
    v_operation := pkg_audit.g_operation_delete;
    v_createdby := :OLD.modifiedby;
    v_createddt := v_sysdate;
    v_modifiedby := :OLD.modifiedby;
    v_modifieddt := v_sysdate;
    v_sitecontactid := :OLD.SITECONTACTID;
    v_siteid:=:OLD.siteid;
    v_contactid:=:OLD.contactid;
    v_contacttype :=:OLD.Contacttype;
  END IF;

  --Get the Study associated with Contact
  SELECT studyid
  INTO v_studyid
  FROM tbl_site
  WHERE siteid = v_siteid;

  pkg_audit.sp_set_audit
    (v_sitecontactid,'TBL_SITECONTACTMAP','SITECONTACTID',:OLD.SITECONTACTID,:NEW.SITECONTACTID,v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

  if v_auditid is not null then
  FOR i IN (SELECT DISTINCT s.studyid,s.siteid 
            FROM tbl_site s 
            WHERE s.siteid = v_siteid
            AND s.isactive = 'Y') LOOP
    pkg_audit.sp_set_studyauditreportmap
    (v_auditid,i.studyid,i.siteid,v_createddt,v_createdby,v_modifieddt,v_modifiedby);  
  END LOOP;
  end if;

  pkg_audit.sp_set_audit
  (v_sitecontactid,'TBL_SITECONTACTMAP','SITEID',pkg_audit.fn_get_lov_value(:OLD.siteid, pkg_audit.g_lov_site),pkg_audit.fn_get_lov_value(:NEW.siteid, pkg_audit.g_lov_site),v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

   if v_auditid is not null then
  FOR i IN (SELECT DISTINCT s.studyid,s.siteid 
            FROM tbl_site s 
            WHERE s.siteid = v_siteid
            AND s.isactive = 'Y') LOOP
    pkg_audit.sp_set_studyauditreportmap
    (v_auditid,i.studyid,i.siteid,v_createddt,v_createdby,v_modifieddt,v_modifiedby);  
  END LOOP;
  end if;

  pkg_audit.sp_set_audit
  (v_sitecontactid,'TBL_SITECONTACTMAP','CONTACTID',:OLD.CONTACTID,:NEW.CONTACTID,v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

  if v_auditid is not null then
  FOR i IN (SELECT DISTINCT s.studyid,s.siteid 
            FROM tbl_site s 
            WHERE s.siteid = v_siteid
            AND s.isactive = 'Y') LOOP
    pkg_audit.sp_set_studyauditreportmap
    (v_auditid,i.studyid,i.siteid,v_createddt,v_createdby,v_modifieddt,v_modifiedby);  
  END LOOP;
  end if;

  pkg_audit.sp_set_audit
  (v_sitecontactid,'TBL_SITECONTACTMAP','IPID',:OLD.IPID,:NEW.IPID,v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

  if v_auditid is not null then
  FOR i IN (SELECT DISTINCT s.studyid,s.siteid 
            FROM tbl_site s 
            WHERE s.siteid = v_siteid
            AND s.isactive = 'Y') LOOP
    pkg_audit.sp_set_studyauditreportmap
    (v_auditid,i.studyid,i.siteid,v_createddt,v_createdby,v_modifieddt,v_modifiedby);  
  END LOOP;
  end if;


  pkg_audit.sp_set_audit
  (v_sitecontactid,'TBL_SITECONTACTMAP','MASTERCONTACTID',:OLD.MASTERCONTACTID,:NEW.MASTERCONTACTID,v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

   if v_auditid is not null then
  FOR i IN (SELECT DISTINCT s.studyid,s.siteid 
            FROM tbl_site s 
            WHERE s.siteid = v_siteid
            AND s.isactive = 'Y') LOOP
    pkg_audit.sp_set_studyauditreportmap
    (v_auditid,i.studyid,i.siteid,v_createddt,v_createdby,v_modifieddt,v_modifiedby);  
  END LOOP;
  end if;

  pkg_audit.sp_set_audit
  (v_sitecontactid,'TBL_SITECONTACTMAP','FACILITYID',:OLD.FACILITYID,:NEW.FACILITYID,v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

  if v_auditid is not null then
  FOR i IN (SELECT DISTINCT s.studyid,s.siteid 
            FROM tbl_site s 
            WHERE s.siteid = v_siteid
            AND s.isactive = 'Y') LOOP
    pkg_audit.sp_set_studyauditreportmap
    (v_auditid,i.studyid,i.siteid,v_createddt,v_createdby,v_modifieddt,v_modifiedby);  
  END LOOP;
  end if;
  pkg_audit.sp_set_audit
  (v_sitecontactid,'TBL_SITECONTACTMAP','ADDITIONALFACILITYID',:OLD.ADDITIONALFACILITYID,:NEW.ADDITIONALFACILITYID,v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

  if v_auditid is not null then
  FOR i IN (SELECT DISTINCT s.studyid,s.siteid 
            FROM tbl_site s 
            WHERE s.siteid = v_siteid
            AND s.isactive = 'Y') LOOP
    pkg_audit.sp_set_studyauditreportmap
    (v_auditid,i.studyid,i.siteid,v_createddt,v_createdby,v_modifieddt,v_modifiedby);  
  END LOOP;
  end if;


  pkg_audit.sp_set_audit
  (v_sitecontactid,'TBL_SITECONTACTMAP','USERID',(CASE WHEN v_contacttype='IP Ship to' and :OLD.USERID is not null THEN 'Y' ELSE NULL END ),(CASE WHEN v_contacttype='IP Ship to' and :NEW.USERID is not null THEN 'Y' ELSE NULL END ),v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

   if v_auditid is not null then
  FOR i IN (SELECT DISTINCT s.studyid,s.siteid 
            FROM tbl_site s 
            WHERE s.siteid = v_siteid
            AND s.isactive = 'Y') LOOP
    pkg_audit.sp_set_studyauditreportmap
    (v_auditid,i.studyid,i.siteid,v_createddt,v_createdby,v_modifieddt,v_modifiedby);  
  END LOOP;
  end if;

  pkg_audit.sp_set_audit
  (v_sitecontactid,'TBL_SITECONTACTMAP','FIRSTNAME',:OLD.FIRSTNAME,:NEW.FIRSTNAME,v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

  if v_auditid is not null then
  FOR i IN (SELECT DISTINCT s.studyid,s.siteid 
            FROM tbl_site s 
            WHERE s.siteid = v_siteid
            AND s.isactive = 'Y') LOOP
    pkg_audit.sp_set_studyauditreportmap
    (v_auditid,i.studyid,i.siteid,v_createddt,v_createdby,v_modifieddt,v_modifiedby);  
  END LOOP;
  end if;
  pkg_audit.sp_set_audit
  (v_sitecontactid,'TBL_SITECONTACTMAP','LASTNAME',:OLD.LASTNAME,:NEW.LASTNAME,v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

  if v_auditid is not null then
  FOR i IN (SELECT DISTINCT s.studyid,s.siteid 
            FROM tbl_site s 
            WHERE s.siteid = v_siteid
            AND s.isactive = 'Y') LOOP
    pkg_audit.sp_set_studyauditreportmap
    (v_auditid,i.studyid,i.siteid,v_createddt,v_createdby,v_modifieddt,v_modifiedby);  
  END LOOP;
  end if;


  pkg_audit.sp_set_audit
  (v_sitecontactid,'TBL_SITECONTACTMAP','CONTACTTYPE',:OLD.CONTACTTYPE,:NEW.CONTACTTYPE,v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

   if v_auditid is not null then
  FOR i IN (SELECT DISTINCT s.studyid,s.siteid 
            FROM tbl_site s 
            WHERE s.siteid = v_siteid
            AND s.isactive = 'Y') LOOP
    pkg_audit.sp_set_studyauditreportmap
    (v_auditid,i.studyid,i.siteid,v_createddt,v_createdby,v_modifieddt,v_modifiedby);  
  END LOOP;
  end if;

  pkg_audit.sp_set_audit
  (v_sitecontactid,'TBL_SITECONTACTMAP','CREATEDBY',:OLD.CREATEDBY,:NEW.CREATEDBY,v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

  if v_auditid is not null then
  FOR i IN (SELECT DISTINCT s.studyid,s.siteid 
            FROM tbl_site s 
            WHERE s.siteid = v_siteid
            AND s.isactive = 'Y') LOOP
    pkg_audit.sp_set_studyauditreportmap
    (v_auditid,i.studyid,i.siteid,v_createddt,v_createdby,v_modifieddt,v_modifiedby);  
  END LOOP;
  end if;

  pkg_audit.sp_set_audit
  (v_sitecontactid,'TBL_SITECONTACTMAP','CREATEDDT',TO_CHAR(:OLD.CREATEDDT,'DD-Mon-YYYY'),TO_CHAR(:NEW.CREATEDDT,'DD-Mon-YYYY'),v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

  if v_auditid is not null then
  FOR i IN (SELECT DISTINCT s.studyid,s.siteid 
            FROM tbl_site s 
            WHERE s.siteid = v_siteid
            AND s.isactive = 'Y') LOOP
    pkg_audit.sp_set_studyauditreportmap
    (v_auditid,i.studyid,i.siteid,v_createddt,v_createdby,v_modifieddt,v_modifiedby);  
  END LOOP;
  end if;

  pkg_audit.sp_set_audit
  (v_sitecontactid,'TBL_SITECONTACTMAP','MODIFIEDBY',:OLD.MODIFIEDBY,:NEW.MODIFIEDBY,v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

  if v_auditid is not null then
  FOR i IN (SELECT DISTINCT s.studyid,s.siteid 
            FROM tbl_site s 
            WHERE s.siteid = v_siteid
            AND s.isactive = 'Y') LOOP
    pkg_audit.sp_set_studyauditreportmap
    (v_auditid,i.studyid,i.siteid,v_createddt,v_createdby,v_modifieddt,v_modifiedby);  
  END LOOP;
  end if;


  pkg_audit.sp_set_audit
  (v_sitecontactid,'TBL_SITECONTACTMAP','MODIFIEDDT',TO_CHAR(:OLD.MODIFIEDDT,'DD-Mon-YYYY'),TO_CHAR(:NEW.MODIFIEDDT,'DD-Mon-YYYY'),v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

   if v_auditid is not null then
  FOR i IN (SELECT DISTINCT s.studyid,s.siteid 
            FROM tbl_site s 
            WHERE s.siteid = v_siteid
            AND s.isactive = 'Y') LOOP
    pkg_audit.sp_set_studyauditreportmap
    (v_auditid,i.studyid,i.siteid,v_createddt,v_createdby,v_modifieddt,v_modifiedby);  
  END LOOP;
  end if;


  pkg_audit.sp_set_audit
  (v_sitecontactid,'TBL_SITECONTACTMAP','ISACTIVE',pkg_audit.fn_get_lov_value(:OLD.ISACTIVE, pkg_audit.g_lov_activeflag),pkg_audit.fn_get_lov_value(:NEW.ISACTIVE, pkg_audit.g_lov_activeflag),v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

  if v_auditid is not null then
  FOR i IN (SELECT DISTINCT s.studyid,s.siteid 
            FROM tbl_site s 
            WHERE s.siteid = v_siteid
            AND s.isactive = 'Y') LOOP
    pkg_audit.sp_set_studyauditreportmap
    (v_auditid,i.studyid,i.siteid,v_createddt,v_createdby,v_modifieddt,v_modifiedby);  
  END LOOP;
  end if;

  pkg_audit.sp_set_audit
  (v_sitecontactid,'TBL_SITECONTACTMAP','STARTDATE',TO_CHAR(:OLD.STARTDATE,'DD-Mon-YYYY'),TO_CHAR(:NEW.STARTDATE,'DD-Mon-YYYY'),v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

  if v_auditid is not null then
  FOR i IN (SELECT DISTINCT s.studyid,s.siteid 
            FROM tbl_site s 
            WHERE s.siteid = v_siteid
            AND s.isactive = 'Y') LOOP
    pkg_audit.sp_set_studyauditreportmap
    (v_auditid,i.studyid,i.siteid,v_createddt,v_createdby,v_modifieddt,v_modifiedby);  
  END LOOP;
  end if;

  pkg_audit.sp_set_audit
  (v_sitecontactid,'TBL_SITECONTACTMAP','ENDDATE',TO_CHAR(:OLD.ENDDATE,'DD-Mon-YYYY'),TO_CHAR(:NEW.ENDDATE,'DD-Mon-YYYY'),v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

  if v_auditid is not null then
  FOR i IN (SELECT DISTINCT s.studyid,s.siteid 
            FROM tbl_site s 
            WHERE s.siteid = v_siteid
            AND s.isactive = 'Y') LOOP
    pkg_audit.sp_set_studyauditreportmap
    (v_auditid,i.studyid,i.siteid,v_createddt,v_createdby,v_modifieddt,v_modifiedby);  
  END LOOP;
  end if;

  --Update Study Id for Additional Facility added.
  UPDATE TBL_STUDYAUDITREPORTMAP tsarm
  SET tsarm.studyid = v_studyid, 
      tsarm.studysiteid = v_siteid
  WHERE tsarm.studyid IS NULL and tsarm.studysiteid IS NULL
  AND tsarm.studyauditid IN (SELECT ta.auditid
                             FROM tbl_audit ta
                             WHERE ta.tablename IN ('TBL_CONTACT')
                             AND ta.entityrefid = v_contactid);

END trg_tbl_sitecontactmap_audit;
/