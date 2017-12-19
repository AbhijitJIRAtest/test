create or replace TRIGGER TRG_TBL_STUDYSYSTEMMAP_AUDIT
AFTER INSERT OR UPDATE OR DELETE ON TBL_STUDYSYSTEMMAP
FOR EACH ROW
DECLARE
v_operation tbl_audit.operation%TYPE;
v_auditid   tbl_audit.auditid%TYPE;
v_createdby tbl_audit.createdby%TYPE;
v_createddt tbl_audit.createddt%TYPE;
v_modifiedby tbl_audit.modifiedby%TYPE;
v_modifieddt tbl_audit.modifieddt%TYPE;
v_studysystemid  TBL_STUDYSYSTEMMAP.STUDYSYSTEMID%TYPE;
v_studyid TBL_SITE.studyid%TYPE;
v_sysdate DATE:=SYSDATE;
BEGIN
  IF INSERTING THEN
    v_operation := pkg_audit.g_operation_create;
    v_createdby := :NEW.createdby;
    v_createddt := :NEW.createddt;
    v_modifiedby := :NEW.createdby;
    v_modifieddt := :NEW.createddt;
    v_studysystemid := :NEW.STUDYSYSTEMID;
	v_studyid := :NEW.STUDYID;

  ELSIF UPDATING THEN
     IF NVL(:OLD.status,'Y') <> NVL(:NEW.status,'Y') AND :NEW.status = 'N' THEN
      v_operation := pkg_audit.g_operation_delete;
    ELSE
      v_operation := pkg_audit.g_operation_update;
     END IF;
    v_studysystemid := :NEW.STUDYSYSTEMID;
    v_createdby := :NEW.modifiedby;
    v_createddt := :NEW.modifieddt;
    v_modifiedby := :NEW.modifiedby;
    v_modifieddt := :NEW.modifieddt;
	v_studyid := :NEW.STUDYID;

  ELSIF DELETING THEN
    v_operation := pkg_audit.g_operation_delete;
    v_createdby := :OLD.modifiedby;
    v_createddt := v_sysdate;
    v_modifiedby := :OLD.modifiedby;
    v_modifieddt := v_sysdate;
    v_studysystemid := :OLD.STUDYSYSTEMID;
	v_studyid := :OLD.STUDYID;

  END IF;

  


  pkg_audit.sp_set_audit
    (v_studysystemid,'TBL_STUDYSYSTEMMAP','STUDYSYSTEMID',:OLD.STUDYSYSTEMID,:NEW.STUDYSYSTEMID,v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

  if v_auditid is not null then
    pkg_audit.sp_set_studyauditreportmap
    (v_auditid,v_studyid,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  end if;

  pkg_audit.sp_set_audit
  (v_studysystemid,'TBL_STUDYSYSTEMMAP','STUDYID',pkg_audit.fn_get_lov_value(:OLD.ORGSYSTEMID, pkg_audit.g_lov_access),pkg_audit.fn_get_lov_value(:NEW.ORGSYSTEMID, pkg_audit.g_lov_access),v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

  if v_auditid is not null then
    pkg_audit.sp_set_studyauditreportmap
    (v_auditid,v_studyid,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  end if;


    pkg_audit.sp_set_audit
  (v_studysystemid,'TBL_STUDYSYSTEMMAP','ORGSYSTEMID',pkg_audit.fn_get_lov_value(:OLD.ORGSYSTEMID, pkg_audit.g_lov_orgsysname),pkg_audit.fn_get_lov_value(:NEW.ORGSYSTEMID, pkg_audit.g_lov_orgsysname),v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

  if v_auditid is not null then
    pkg_audit.sp_set_studyauditreportmap
    (v_auditid,v_studyid,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  end if;


      pkg_audit.sp_set_audit
  (v_studysystemid,'TBL_STUDYSYSTEMMAP','STATUS',:OLD.STATUS,:NEW.STATUS,v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

  if v_auditid is not null then
    pkg_audit.sp_set_studyauditreportmap
    (v_auditid,v_studyid,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  end if;

        pkg_audit.sp_set_audit
  (v_studysystemid,'TBL_STUDYSYSTEMMAP','SIPSTUDYSYSTEMID',:OLD.SIPSTUDYSYSTEMID,:NEW.SIPSTUDYSYSTEMID,v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

  if v_auditid is not null then
    pkg_audit.sp_set_studyauditreportmap
    (v_auditid,v_studyid,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  end if;


  pkg_audit.sp_set_audit
    (v_studysystemid,'TBL_STUDYSYSTEMMAP','CREATEDBY',:OLD.CREATEDBY,:NEW.CREATEDBY,v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

  if v_auditid is not null then
    pkg_audit.sp_set_studyauditreportmap
    (v_auditid,v_studyid,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  end if;

    pkg_audit.sp_set_audit
    (v_studysystemid,'TBL_STUDYSYSTEMMAP','CREATEDDT',:OLD.CREATEDDT,:NEW.CREATEDDT,v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

  if v_auditid is not null then
    pkg_audit.sp_set_studyauditreportmap
    (v_auditid,v_studyid,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  end if;

    pkg_audit.sp_set_audit
    (v_studysystemid,'TBL_STUDYSYSTEMMAP','MODIFIEDBY',:OLD.MODIFIEDBY,:NEW.MODIFIEDBY,v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

  if v_auditid is not null then
    pkg_audit.sp_set_studyauditreportmap
    (v_auditid,v_studyid,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  end if;

    pkg_audit.sp_set_audit
    (v_studysystemid,'TBL_STUDYSYSTEMMAP','MODIFIEDDT',:OLD.MODIFIEDDT,:NEW.MODIFIEDDT,v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

  if v_auditid is not null then
    pkg_audit.sp_set_studyauditreportmap
    (v_auditid,v_studyid,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  end if;


END trg_tbl_studysystemmap_audit;

/