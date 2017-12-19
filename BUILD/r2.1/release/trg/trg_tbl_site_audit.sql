CREATE OR REPLACE TRIGGER TRG_TBL_SITE_AUDIT
AFTER INSERT OR UPDATE OR DELETE ON TBL_SITE
FOR EACH ROW
DECLARE
v_operation tbl_audit.operation%TYPE;
v_auditid   tbl_audit.auditid%TYPE;
v_createdby tbl_audit.createdby%TYPE;
v_createddt tbl_audit.createddt%TYPE;
v_modifiedby tbl_audit.modifiedby%TYPE;
v_modifieddt tbl_audit.modifieddt%TYPE;
v_siteid   tbl_site.siteid%TYPE;
v_studyid  tbl_site.studyid%TYPE;
v_contactid  tbl_site.contactid%TYPE;
v_sysdate DATE:=SYSDATE;
BEGIN
  IF INSERTING THEN
    v_operation := pkg_audit.g_operation_create;
    v_createdby := :NEW.createdby;
    v_createddt := :NEW.createddt;
    v_modifiedby := :NEW.createdby;
    v_modifieddt := :NEW.createddt;
    v_siteid := :NEW.siteid;
    v_studyid := :NEW.studyid;
	v_contactid := :NEW.contactid;

  ELSIF UPDATING THEN
    v_operation := pkg_audit.g_operation_update;
    v_siteid := :NEW.siteid;
    v_studyid := :NEW.studyid;
	v_contactid := :NEW.contactid;
    v_createdby := :NEW.modifiedby;
    v_createddt := :NEW.modifieddt;
    v_modifiedby := :NEW.modifiedby;
    v_modifieddt := :NEW.modifieddt;
  ELSIF DELETING THEN
    v_operation := pkg_audit.g_operation_delete;
    v_createdby := :OLD.modifiedby;
    v_createddt := v_sysdate;
    v_modifiedby := :OLD.modifiedby;
    v_modifieddt := v_sysdate;
    v_siteid := :OLD.siteid;
    v_studyid := :OLD.studyid;
	v_contactid := :OLD.contactid;

  END IF;

  pkg_audit.sp_set_audit
    (v_siteid,'TBL_SITE','SITEID',pkg_audit.fn_get_lov_value(:OLD.siteid, pkg_audit.g_lov_site),pkg_audit.fn_get_lov_value(:NEW.siteid, pkg_audit.g_lov_site),v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

 if v_auditid is not null then
 pkg_audit.sp_set_studyauditreportmap
  (v_auditid,v_studyid,v_siteid,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  end if;

  pkg_audit.sp_set_audit
  (v_siteid,'TBL_SITE','STUDYID',pkg_audit.fn_get_lov_value(:OLD.studyid, pkg_audit.g_lov_study),pkg_audit.fn_get_lov_value(:NEW.studyid, pkg_audit.g_lov_study),v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

   if v_auditid is not null then
  pkg_audit.sp_set_studyauditreportmap
  (v_auditid,v_studyid,v_siteid,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
   end if;

  pkg_audit.sp_set_audit
  (v_siteid,'TBL_SITE','PRINCIPALFACILITYID',pkg_audit.fn_get_lov_value(:OLD.PRINCIPALFACILITYID, pkg_audit.g_lov_facility),pkg_audit.fn_get_lov_value(:NEW.PRINCIPALFACILITYID, pkg_audit.g_lov_facility),v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

 if v_auditid is not null then
 pkg_audit.sp_set_studyauditreportmap
  (v_auditid,v_studyid,v_siteid,v_createddt,v_createdby,v_modifieddt,v_modifiedby);

  end if;

  pkg_audit.sp_set_audit
  (v_siteid,'TBL_SITE','PIID',pkg_encrypt.fn_encrypt(pkg_audit.fn_get_lov_value(:OLD.PIID, pkg_audit.g_lov_userprofile_user_flname)),pkg_encrypt.fn_encrypt(pkg_audit.fn_get_lov_value(:NEW.PIID, pkg_audit.g_lov_userprofile_user_flname)),v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

   if v_auditid is not null then
  pkg_audit.sp_set_studyauditreportmap
  (v_auditid,v_studyid,v_siteid,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  end if;

 pkg_audit.sp_set_audit
  (v_siteid,'TBL_SITE','TRANSCELERATESITEID',:OLD.TRANSCELERATESITEID,:NEW.TRANSCELERATESITEID,v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

   if v_auditid is not null then
  pkg_audit.sp_set_studyauditreportmap
  (v_auditid,v_studyid,v_siteid,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  end if;

  pkg_audit.sp_set_audit
  (v_siteid,'TBL_SITE','SITENAME',:OLD.SITENAME,:NEW.SITENAME,v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

 if v_auditid is not null then
 pkg_audit.sp_set_studyauditreportmap
  (v_auditid,v_studyid,v_siteid,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
end if;

 pkg_audit.sp_set_audit
  (v_siteid,'TBL_SITE','ISAFFILIATED',:OLD.ISAFFILIATED,:NEW.ISAFFILIATED,v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

  if v_auditid is not null then
 pkg_audit.sp_set_studyauditreportmap
  (v_auditid,v_studyid,v_siteid,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  end if;

  pkg_audit.sp_set_audit
  (v_siteid,'TBL_SITE','CLOSUREDT',TO_CHAR(:OLD.CLOSUREDT,'DD-MON-YYYY'),TO_CHAR(:NEW.CLOSUREDT,'DD-MON-YYYY'),v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

   if v_auditid is not null then
  pkg_audit.sp_set_studyauditreportmap
  (v_auditid,v_studyid,v_siteid,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  end if;

  pkg_audit.sp_set_audit
  (v_siteid,'TBL_SITE','INSTITUTIONNAME',:OLD.INSTITUTIONNAME,:NEW.INSTITUTIONNAME,v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

 if v_auditid is not null then
 pkg_audit.sp_set_studyauditreportmap
  (v_auditid,v_studyid,v_siteid,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  end if;

  pkg_audit.sp_set_audit
  (v_siteid,'TBL_SITE','CONTACTID',:OLD.CONTACTID,:NEW.CONTACTID,v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

 if v_auditid is not null then
 pkg_audit.sp_set_studyauditreportmap
  (v_auditid,v_studyid,v_siteid,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  end if;

  pkg_audit.sp_set_audit
  (v_siteid,'TBL_SITE','ISACTIVE',:OLD.ISACTIVE,:NEW.ISACTIVE,v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

   if v_auditid is not null then
  pkg_audit.sp_set_studyauditreportmap
  (v_auditid,v_studyid,v_siteid,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  end if;

  pkg_audit.sp_set_audit
  (v_siteid,'TBL_SITE','CREATEDBY',:OLD.CREATEDBY,:NEW.CREATEDBY,v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

   if v_auditid is not null then
  pkg_audit.sp_set_studyauditreportmap
  (v_auditid,v_studyid,v_siteid,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  end if;

  pkg_audit.sp_set_audit
  (v_siteid,'TBL_SITE','CREATEDDT',TO_CHAR(:OLD.CREATEDDT,'DD-MON-YYYY'),TO_CHAR(:NEW.CREATEDDT,'DD-MON-YYYY'),v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

   if v_auditid is not null then
  pkg_audit.sp_set_studyauditreportmap
  (v_auditid,v_studyid,v_siteid,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  end if;

  pkg_audit.sp_set_audit
  (v_siteid,'TBL_SITE','MODIFIEDBY',:OLD.MODIFIEDBY,:NEW.MODIFIEDBY,v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

   if v_auditid is not null then
  pkg_audit.sp_set_studyauditreportmap
  (v_auditid,v_studyid,v_siteid,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  end if;

  pkg_audit.sp_set_audit
  (v_siteid,'TBL_SITE','MODIFIEDDT',TO_CHAR(:OLD.MODIFIEDDT,'DD-MON-YYYY'),TO_CHAR(:NEW.MODIFIEDDT,'DD-MON-YYYY'),v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

   if v_auditid is not null then
  pkg_audit.sp_set_studyauditreportmap
  (v_auditid,v_studyid,v_siteid,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  end if;

  pkg_audit.sp_set_audit
  (v_siteid,'TBL_SITE','CTMSITENUM',:OLD.CTMSITENUM,:NEW.CTMSITENUM,v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

   if v_auditid is not null then
  pkg_audit.sp_set_studyauditreportmap
  (v_auditid,v_studyid,v_siteid,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  end if;

  pkg_audit.sp_set_audit
  (v_siteid,'TBL_SITE','ORGID',pkg_audit.fn_get_lov_value(:OLD.ORGID, pkg_audit.g_lov_organization),pkg_audit.fn_get_lov_value(:NEW.ORGID, pkg_audit.g_lov_organization),v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

 if v_auditid is not null then
 pkg_audit.sp_set_studyauditreportmap
  (v_auditid,v_studyid,v_siteid,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  end if;

  pkg_audit.sp_set_audit
  (v_siteid,'TBL_SITE','PLANNEDENDDATE',TO_CHAR(:OLD.PLANNEDENDDATE,'DD-MON-YYYY'),TO_CHAR(:NEW.PLANNEDENDDATE,'DD-MON-YYYY'),v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

 if v_auditid is not null then
 pkg_audit.sp_set_studyauditreportmap
  (v_auditid,v_studyid,v_siteid,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  end if;
 
 pkg_audit.sp_set_audit
 (v_siteid,'TBL_SITE','SIPREADONLYDATE',TO_CHAR(:OLD.SIPREADONLYDATE,'DD-MON-YYYY'),TO_CHAR(:NEW.SIPREADONLYDATE,'DD-MON-YYYY'),v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

 IF v_auditid IS NOT NULL THEN
    pkg_audit.sp_set_studyauditreportmap
    (v_auditid,v_studyid,v_siteid,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
 END IF; 
 
 pkg_audit.sp_set_audit
 (v_siteid,'TBL_SITE','SAFETY_NOTIFICATION_STARTDATE',TO_CHAR(:OLD.SAFETY_NOTIFICATION_STARTDATE,'DD-MON-YYYY'),TO_CHAR(:NEW.SAFETY_NOTIFICATION_STARTDATE,'DD-MON-YYYY'),v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

 IF v_auditid IS NOT NULL THEN
    pkg_audit.sp_set_studyauditreportmap
    (v_auditid,v_studyid,v_siteid,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
 END IF;
 
 pkg_audit.sp_set_audit
 (v_siteid,'TBL_SITE','SAFETY_NOTIFICATION_ENDDATE',TO_CHAR(:OLD.SAFETY_NOTIFICATION_ENDDATE,'DD-MON-YYYY'),TO_CHAR(:NEW.SAFETY_NOTIFICATION_ENDDATE,'DD-MON-YYYY'),v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

 IF v_auditid IS NOT NULL THEN
    pkg_audit.sp_set_studyauditreportmap
    (v_auditid,v_studyid,v_siteid,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
 END IF;

 UPDATE TBL_STUDYAUDITREPORTMAP tsarm
  SET tsarm.studyid = v_studyid,
      tsarm.studysiteid = v_siteid
  WHERE tsarm.studyid IS NULL and tsarm.studysiteid IS NULL
  AND tsarm.studyauditid IN (SELECT ta.auditid
                             FROM tbl_audit ta
                             WHERE ta.tablename IN ('TBL_CONTACT')
                             AND ta.entityrefid = v_contactid);


END trg_tbl_site_audit;
/