create or replace TRIGGER TRG_TBL_STUDYTHERAAREA_AUDIT
AFTER INSERT OR UPDATE OR DELETE ON TBL_STUDYTHERAPEUTICAREA
FOR EACH ROW
DECLARE
v_operation 				tbl_audit.operation%TYPE;
v_auditid   				tbl_audit.auditid%TYPE;
v_createdby 				tbl_audit.createdby%TYPE;
v_createddt 				tbl_audit.createddt%TYPE;
v_modifiedby 				tbl_audit.modifiedby%TYPE;
v_modifieddt 				tbl_audit.modifieddt%TYPE;
v_studyid    				tbl_studytherapeuticarea.studyid%TYPE;
v_studytherapeuticareaid	tbl_studytherapeuticarea.studytherapeuticareaid%TYPE;
v_sysdate DATE:=SYSDATE;
BEGIN
  IF INSERTING THEN
    v_operation := pkg_audit.g_operation_create;
    v_createdby := :NEW.createdby;
    v_createddt := :NEW.createddt;
    v_modifiedby := :NEW.createdby;
    v_modifieddt := :NEW.createddt;
    v_studyid := :NEW.STUDYID;
	v_studytherapeuticareaid := :NEW.studytherapeuticareaid;

  ELSIF UPDATING THEN
    IF NVL(:OLD.isactive,'Y') <> NVL(:NEW.isactive,'Y') AND :NEW.isactive = 'N' THEN
      v_operation := pkg_audit.g_operation_delete;
    ELSE
      v_operation := pkg_audit.g_operation_update;
    END IF;
     v_studyid := :NEW.STUDYID;
    v_createdby := :NEW.modifiedby;
    v_createddt := :NEW.modifieddt;
    v_modifiedby := :NEW.modifiedby;
    v_modifieddt := :NEW.modifieddt;
	v_studytherapeuticareaid := :NEW.studytherapeuticareaid;
	
  ELSIF DELETING THEN
    v_operation := pkg_audit.g_operation_delete;
    v_createdby := :OLD.modifiedby;
    v_createddt := v_sysdate;
    v_modifiedby := :OLD.modifiedby;
    v_modifieddt := v_sysdate;
    v_studyid := :OLD.STUDYID;
	v_studytherapeuticareaid := :OLD.studytherapeuticareaid;
	
  END IF;
  

pkg_audit.sp_set_audit
    (v_studytherapeuticareaid,'TBL_STUDYTHERAPEUTICAREA','STUDYTHERAPEUTICAREAID',:OLD.STUDYTHERAPEUTICAREAID,:NEW.STUDYTHERAPEUTICAREAID,v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

   if v_auditid is not null then
  pkg_audit.sp_set_studyauditreportmap
  (v_auditid,v_studyid,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  end if;  
  
  
pkg_audit.sp_set_audit
    (v_studytherapeuticareaid,'TBL_STUDYTHERAPEUTICAREA','STUDYID',:OLD.STUDYID,:NEW.STUDYID,v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

   if v_auditid is not null then
  pkg_audit.sp_set_studyauditreportmap
  (v_auditid,v_studyid,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  end if;
  
  
pkg_audit.sp_set_audit
    (v_studytherapeuticareaid,'TBL_STUDYTHERAPEUTICAREA','THERAPEUTICAREAID',pkg_audit.fn_get_lov_value(:OLD.THERAPEUTICAREAID, pkg_audit.g_lov_studytheraarea),pkg_audit.fn_get_lov_value(:NEW.THERAPEUTICAREAID, pkg_audit.g_lov_studytheraarea),v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

   if v_auditid is not null then
  pkg_audit.sp_set_studyauditreportmap
  (v_auditid,v_studyid,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  end if;
  
  
pkg_audit.sp_set_audit
  (v_studytherapeuticareaid,'TBL_STUDYTHERAPEUTICAREA','ISACTIVE',:OLD.isactive,:NEW.isactive,v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

   if v_auditid is not null then
  pkg_audit.sp_set_studyauditreportmap
  (v_auditid,v_studyid,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  end if;
  
  
pkg_audit.sp_set_audit
    (v_studytherapeuticareaid,'TBL_STUDYTHERAPEUTICAREA','CREATEDBY',:OLD.CREATEDBY,:NEW.CREATEDBY,v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

   if v_auditid is not null then
  pkg_audit.sp_set_studyauditreportmap
  (v_auditid,v_studyid,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  end if;
  
  
pkg_audit.sp_set_audit
    (v_studytherapeuticareaid,'TBL_STUDYTHERAPEUTICAREA','MODIFIEDBY',:OLD.MODIFIEDBY,:NEW.MODIFIEDBY,v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

   if v_auditid is not null then
  pkg_audit.sp_set_studyauditreportmap
  (v_auditid,v_studyid,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  end if;
  
pkg_audit.sp_set_audit
  (v_studytherapeuticareaid,'TBL_STUDYTHERAPEUTICAREA','CREATEDDT',TO_CHAR(:OLD.CREATEDDT,'DD-MON-YYYY'),TO_CHAR(:NEW.CREATEDDT,'DD-MON-YYYY'),v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

   if v_auditid is not null then
  pkg_audit.sp_set_studyauditreportmap
  (v_auditid,v_studyid,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  end if;  
  
  
pkg_audit.sp_set_audit
  (v_studytherapeuticareaid,'TBL_STUDYTHERAPEUTICAREA','MODIFIEDDT',TO_CHAR(:OLD.MODIFIEDDT,'DD-MON-YYYY'),TO_CHAR(:NEW.MODIFIEDDT,'DD-MON-YYYY'),v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

   if v_auditid is not null then
  pkg_audit.sp_set_studyauditreportmap
  (v_auditid,v_studyid,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  end if;
  
  
  
END TRG_TBL_STUDYTHERAAREA_AUDIT;

/