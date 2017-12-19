create or replace TRIGGER TRG_TBL_USERROLEMAP_AUDIT
AFTER INSERT OR UPDATE OR DELETE ON TBL_USERROLEMAP
FOR EACH ROW
DECLARE
v_operation tbl_audit.operation%TYPE;
v_auditid   tbl_audit.auditid%TYPE;
v_createdby tbl_audit.createdby%TYPE;
v_createddt tbl_audit.createddt%TYPE;
v_modifiedby tbl_audit.modifiedby%TYPE;
v_modifieddt tbl_audit.modifieddt%TYPE;
v_studyid tbl_studyauditreportmap.studyid%TYPE;
v_siteid tbl_studyauditreportmap.studysiteid%TYPE;
v_sysdate DATE:=SYSDATE;
v_userid  TBL_USERROLEMAP.userid%TYPE;
v_issponsor tbl_userprofiles.issponsor%TYPE ;
BEGIN
  IF INSERTING THEN
    v_operation := pkg_audit.g_operation_create;
    v_createdby := :NEW.createdby;
    v_createddt := :NEW.createddt;
    v_modifiedby := :NEW.createdby;
    v_modifieddt := :NEW.createddt;
    v_studyid:= :NEW.studyid;
    v_siteid:= :NEW.siteid;
    v_userid:= :NEW.userid;
  ELSIF UPDATING THEN
    v_operation := pkg_audit.g_operation_update;

    v_createdby := :NEW.modifiedby;
    v_createddt := :NEW.modifieddt;
    v_modifiedby := :NEW.modifiedby;
    v_modifieddt := :NEW.modifieddt;
    v_studyid:= :NEW.studyid;
    v_siteid:= :NEW.siteid;
    v_userid:= :NEW.userid;

  ELSIF DELETING THEN
    v_operation := pkg_audit.g_operation_delete;
    v_createdby := :OLD.modifiedby;
    v_createddt := v_sysdate;
    v_modifiedby := :OLD.modifiedby;
    v_modifieddt := v_sysdate;
    v_studyid:= :OLD.studyid;
    v_siteid:= :OLD.siteid;
    v_userid:= :OLD.userid;

  END IF;

SELECT issponsor INTO v_issponsor FROM tbl_userprofiles WHERE userid = v_userid ;

  pkg_audit.sp_set_audit
    (:NEW.USERROLEID,'TBL_USERROLEMAP','USERROLEID',:OLD.USERROLEID,:NEW.USERROLEID,v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);
  IF v_auditid IS NOT NULL THEN 
  IF (v_studyid IS NOT NULL and v_issponsor = 'N') THEN
      pkg_audit.sp_set_studyauditreportmap
     (v_auditid,v_studyid,v_siteid,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  END IF;
  END IF;

  pkg_audit.sp_set_audit
    (:NEW.USERROLEID,'TBL_USERROLEMAP','USERID',pkg_audit.fn_get_lov_value(:OLD.USERID,pkg_audit.g_lov_userprofile_userid_trans),pkg_audit.fn_get_lov_value(:NEW.USERID, pkg_audit.g_lov_userprofile_userid_trans),v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);
  IF v_auditid IS NOT NULL THEN 
  IF (v_studyid IS NOT NULL and v_issponsor = 'N') THEN
      pkg_audit.sp_set_studyauditreportmap
     (v_auditid,v_studyid,v_siteid,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  END IF;
  END IF;

  pkg_audit.sp_set_audit
    (:NEW.USERROLEID,'TBL_USERROLEMAP','ROLEID',pkg_audit.fn_get_lov_value(:OLD.ROLEID,pkg_audit.g_lov_role),pkg_audit.fn_get_lov_value(:NEW.ROLEID, pkg_audit.g_lov_role),v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);
  IF v_auditid IS NOT NULL THEN 
  IF (v_studyid IS NOT NULL and v_issponsor = 'N') THEN
      pkg_audit.sp_set_studyauditreportmap
     (v_auditid,v_studyid,v_siteid,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  END IF;
  END IF;

  pkg_audit.sp_set_audit
    (:NEW.USERROLEID,'TBL_USERROLEMAP','STUDYID',pkg_audit.fn_get_lov_value(:OLD.studyid, pkg_audit.g_lov_study),pkg_audit.fn_get_lov_value(:NEW.studyid, pkg_audit.g_lov_study),v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);
  IF v_auditid IS NOT NULL THEN 
  IF (v_studyid IS NOT NULL and v_issponsor = 'N') THEN
      pkg_audit.sp_set_studyauditreportmap
     (v_auditid,v_studyid,v_siteid,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  END IF;
  END IF;

  pkg_audit.sp_set_audit
    (:NEW.USERROLEID,'TBL_USERROLEMAP','SITEID',pkg_audit.fn_get_lov_value(:OLD.siteid, pkg_audit.g_lov_site),pkg_audit.fn_get_lov_value(:NEW.siteid, pkg_audit.g_lov_site),v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);
  IF v_auditid IS NOT NULL THEN 
  IF (v_studyid IS NOT NULL and v_issponsor = 'N') THEN
      pkg_audit.sp_set_studyauditreportmap
     (v_auditid,v_studyid,v_siteid,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  END IF;
  END IF;

  pkg_audit.sp_set_audit
    (:NEW.USERROLEID,'TBL_USERROLEMAP','EFFECTIVESTARTDATE',TO_CHAR(:OLD.EFFECTIVESTARTDATE,'DD-Mon-YYYY'),TO_CHAR(:NEW.EFFECTIVESTARTDATE,'DD-Mon-YYYY'),v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);
  IF v_auditid IS NOT NULL THEN 
  IF (v_studyid IS NOT NULL and v_issponsor = 'N') THEN
      pkg_audit.sp_set_studyauditreportmap
     (v_auditid,v_studyid,v_siteid,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  END IF;
  END IF;

  pkg_audit.sp_set_audit
    (:NEW.USERROLEID,'TBL_USERROLEMAP','EFFECTIVEENDDATE',TO_CHAR(:OLD.EFFECTIVEENDDATE,'DD-Mon-YYYY'),TO_CHAR(:NEW.EFFECTIVEENDDATE,'DD-Mon-YYYY'),v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);
  IF v_auditid IS NOT NULL THEN 
  IF (v_studyid IS NOT NULL and v_issponsor = 'N') THEN
      pkg_audit.sp_set_studyauditreportmap
     (v_auditid,v_studyid,v_siteid,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  END IF;
  END IF;

  pkg_audit.sp_set_audit
    (:NEW.USERROLEID,'TBL_USERROLEMAP','CREATEDBY',:OLD.CREATEDBY,:NEW.CREATEDBY,v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);
  IF v_auditid IS NOT NULL THEN 
  IF (v_studyid IS NOT NULL and v_issponsor = 'N') THEN
      pkg_audit.sp_set_studyauditreportmap
     (v_auditid,v_studyid,v_siteid,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  END IF;
  END IF;

  pkg_audit.sp_set_audit
    (:NEW.USERROLEID,'TBL_USERROLEMAP','CREATEDDT',TO_CHAR(:OLD.CREATEDDT,'DD-Mon-YYYY'),TO_CHAR(:NEW.CREATEDDT,'DD-Mon-YYYY'),v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);
  IF v_auditid IS NOT NULL THEN 
  IF (v_studyid IS NOT NULL and v_issponsor = 'N') THEN
      pkg_audit.sp_set_studyauditreportmap
     (v_auditid,v_studyid,v_siteid,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  END IF;
  END IF;

  pkg_audit.sp_set_audit
    (:NEW.USERROLEID,'TBL_USERROLEMAP','MODIFIEDBY',:OLD.MODIFIEDBY,:NEW.MODIFIEDBY,v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);
  IF v_auditid IS NOT NULL THEN 
  IF (v_studyid IS NOT NULL and v_issponsor = 'N') THEN
      pkg_audit.sp_set_studyauditreportmap
     (v_auditid,v_studyid,v_siteid,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  END IF;
  END IF;

  pkg_audit.sp_set_audit
    (:NEW.USERROLEID,'TBL_USERROLEMAP','MODIFIEDDT',TO_CHAR(:OLD.MODIFIEDDT,'DD-Mon-YYYY'),TO_CHAR(:NEW.MODIFIEDDT,'DD-Mon-YYYY'),v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);
  IF v_auditid IS NOT NULL THEN 
  IF (v_studyid IS NOT NULL and v_issponsor = 'N') THEN
      pkg_audit.sp_set_studyauditreportmap
     (v_auditid,v_studyid,v_siteid,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  END IF;
  END IF;

  pkg_audit.sp_set_audit
    (:NEW.USERROLEID,'TBL_USERROLEMAP','ROLECHANGEREASON',:OLD.ROLECHANGEREASON,:NEW.ROLECHANGEREASON,v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);
  IF v_auditid IS NOT NULL THEN 
  IF (v_studyid IS NOT NULL and v_issponsor = 'N') THEN
      pkg_audit.sp_set_studyauditreportmap
     (v_auditid,v_studyid,v_siteid,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  END IF;
  END IF;

    pkg_audit.sp_set_audit
    (:NEW.USERROLEID,'TBL_USERROLEMAP','DOCEXUSERROLEID',:OLD.DOCEXUSERROLEID,:NEW.DOCEXUSERROLEID,v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);
  IF v_auditid IS NOT NULL THEN 
  IF (v_studyid IS NOT NULL and v_issponsor = 'N') THEN
      pkg_audit.sp_set_studyauditreportmap
     (v_auditid,v_studyid,v_siteid,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  END IF;
  END IF;

    pkg_audit.sp_set_audit
    (:NEW.USERROLEID,'TBL_USERROLEMAP','ACT_ISINTEGRATED',:OLD.ACT_ISINTEGRATED,:NEW.ACT_ISINTEGRATED,v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);
  IF v_auditid IS NOT NULL THEN 
  IF (v_studyid IS NOT NULL and v_issponsor = 'N') THEN
      pkg_audit.sp_set_studyauditreportmap
     (v_auditid,v_studyid,v_siteid,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  END IF;
  END IF;

    pkg_audit.sp_set_audit
    (:NEW.USERROLEID,'TBL_USERROLEMAP','DEACT_ISINTEGRATED',:OLD.DEACT_ISINTEGRATED,:NEW.DEACT_ISINTEGRATED,v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);
  IF v_auditid IS NOT NULL THEN 
  IF (v_studyid IS NOT NULL and v_issponsor = 'N') THEN
      pkg_audit.sp_set_studyauditreportmap
     (v_auditid,v_studyid,v_siteid,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  END IF;
  END IF;

      pkg_audit.sp_set_audit
    (:NEW.USERROLEID,'TBL_USERROLEMAP','COUNTRYID',:OLD.COUNTRYID,:NEW.COUNTRYID,v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);
  IF v_auditid IS NOT NULL THEN 
  IF (v_studyid IS NOT NULL and v_issponsor = 'N') THEN
      pkg_audit.sp_set_studyauditreportmap
     (v_auditid,v_studyid,v_siteid,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  END IF;
  END IF;
  
  END TRG_TBL_USERROLEMAP_AUDIT;
  
  /