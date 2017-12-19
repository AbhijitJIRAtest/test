create or replace TRIGGER TRG_TBL_STUDYINDICATION_AUDIT
AFTER INSERT OR UPDATE OR DELETE ON TBL_STUDYINDICATION
FOR EACH ROW
DECLARE
v_operation tbl_audit.operation%TYPE;
v_auditid   tbl_audit.auditid%TYPE;
v_createdby tbl_audit.createdby%TYPE;
v_createddt tbl_audit.createddt%TYPE;
v_modifiedby tbl_audit.modifiedby%TYPE;
v_modifieddt tbl_audit.modifieddt%TYPE;
v_studyid  tbl_studyindication.studyid%type;
v_STUDYINDICATIONID  tbl_studyindication.STUDYINDICATIONID%type;
v_sysdate DATE:=SYSDATE;
BEGIN
  IF INSERTING THEN
    v_operation := pkg_audit.g_operation_create;
    v_createdby := :NEW.createdby;
    v_createddt := :NEW.createddt;
    v_modifiedby := :NEW.createdby;
    v_modifieddt := :NEW.createddt;
    v_STUDYINDICATIONID := :NEW.STUDYINDICATIONID;
    v_studyid := :NEW.studyid;
	

  ELSIF UPDATING THEN
    IF NVL(:OLD.isactive,'Y') <> NVL(:NEW.isactive,'Y') AND :NEW.isactive = 'N' THEN
      v_operation := pkg_audit.g_operation_delete;
    ELSE
      v_operation := pkg_audit.g_operation_update;
    END IF;
    v_studyindicationid := :NEW.STUDYINDICATIONID;
    v_studyid := :NEW.studyid;
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
    v_studyindicationid := :OLD.STUDYINDICATIONID;
    v_studyid := :OLD.studyid;
	

  END IF;
  
  
  
  
  
pkg_audit.sp_set_audit
    (v_studyindicationid,'TBL_STUDYINDICATION','STUDYINDICATIONID',:OLD.studyindicationid,:NEW.studyindicationid,v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

   if v_auditid is not null then
  pkg_audit.sp_set_studyauditreportmap
  (v_auditid,v_studyid,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  end if;
  
  
pkg_audit.sp_set_audit
    (v_studyindicationid,'TBL_STUDYINDICATION','STUDYID',:OLD.STUDYID,:NEW.STUDYID,v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

   if v_auditid is not null then
  pkg_audit.sp_set_studyauditreportmap
  (v_auditid,v_studyid,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  end if;  
  
  
  
pkg_audit.sp_set_audit
    (v_studyindicationid,'TBL_STUDYINDICATION','INDICATIONID',pkg_audit.fn_get_lov_value(:OLD.INDICATIONID, pkg_audit.g_lov_indication),pkg_audit.fn_get_lov_value(:NEW.INDICATIONID, pkg_audit.g_lov_indication),v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

   if v_auditid is not null then
  pkg_audit.sp_set_studyauditreportmap
  (v_auditid,v_studyid,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  end if;  
  
  
pkg_audit.sp_set_audit
  (v_studyindicationid,'TBL_STUDYINDICATION','ISACTIVE',:OLD.ISACTIVE,:NEW.ISACTIVE,v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

   if v_auditid is not null then
  pkg_audit.sp_set_studyauditreportmap
  (v_auditid,v_studyid,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  end if;  
  
  
pkg_audit.sp_set_audit
    (v_studyindicationid,'TBL_STUDYINDICATION','CREATEDBY',:OLD.CREATEDBY,:NEW.CREATEDBY,v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

   if v_auditid is not null then
  pkg_audit.sp_set_studyauditreportmap
  (v_auditid,v_studyid,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  end if; 
  
  
pkg_audit.sp_set_audit
    (v_studyindicationid,'TBL_STUDYINDICATION','MODIFIEDBY',:OLD.MODIFIEDBY,:NEW.MODIFIEDBY,v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

   if v_auditid is not null then
  pkg_audit.sp_set_studyauditreportmap
  (v_auditid,v_studyid,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  end if;  
  
  
pkg_audit.sp_set_audit
  (v_studyindicationid,'TBL_STUDYINDICATION','CREATEDDT',TO_CHAR(:OLD.CREATEDDT,'DD-MON-YYYY'),TO_CHAR(:NEW.CREATEDDT,'DD-MON-YYYY'),v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

   if v_auditid is not null then
  pkg_audit.sp_set_studyauditreportmap
  (v_auditid,v_studyid,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  end if;


pkg_audit.sp_set_audit
  (v_studyindicationid,'TBL_STUDYINDICATION','MODIFIEDDT',TO_CHAR(:OLD.MODIFIEDDT,'DD-MON-YYYY'),TO_CHAR(:NEW.MODIFIEDDT,'DD-MON-YYYY'),v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

   if v_auditid is not null then
  pkg_audit.sp_set_studyauditreportmap
  (v_auditid,v_studyid,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  end if;

  
  
  
END TRG_TBL_STUDYINDICATION_AUDIT;

/