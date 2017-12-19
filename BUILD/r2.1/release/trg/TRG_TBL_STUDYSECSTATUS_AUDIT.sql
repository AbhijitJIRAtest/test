create or replace TRIGGER TRG_TBL_STUDYSECSTATUS_AUDIT
AFTER INSERT OR UPDATE OR DELETE ON TBL_STUDYSECTIONSTATUS
FOR EACH ROW
DECLARE
v_operation     			TBL_AUDIT.operation%TYPE;
v_auditid       			TBL_AUDIT.auditid%TYPE;
v_createdby     			TBL_AUDIT.createdby%TYPE;
v_createddt     			TBL_AUDIT.createddt%TYPE;
v_modifiedby    			TBL_AUDIT.modifiedby%TYPE;
v_modifieddt    			TBL_AUDIT.modifieddt%TYPE;
v_studysectionstatusid    	TBL_STUDYSECTIONSTATUS.STUDYSECTIONSTATUSID%TYPE;
v_studyid       			TBL_STUDYSECTIONSTATUS.STUDYID%TYPE;
v_sysdate       			DATE:=SYSDATE;

BEGIN
  IF INSERTING THEN
    v_operation := pkg_audit.g_operation_create;
    v_studysectionstatusid:= :NEW.studysectionstatusid;
    v_studyid := :NEW.studyid;
    v_createdby := :NEW.createdby;
    v_createddt := :NEW.createddt;
    v_modifiedby := :NEW.createdby;
    v_modifieddt := :NEW.createddt;
	
  ELSIF UPDATING THEN
    v_operation := pkg_audit.g_operation_update;
    v_studysectionstatusid:= :NEW.studysectionstatusid;
    v_studyid := :NEW.studyid;
    v_createdby := :NEW.modifiedby;
    v_createddt := :NEW.modifieddt;
    v_modifiedby := :NEW.modifiedby;
    v_modifieddt := :NEW.modifieddt;
	
	ELSIF DELETING THEN
    v_operation := pkg_audit.g_operation_delete;
    v_studysectionstatusid:= :OLD.studysectionstatusid;
    v_studyid := :OLD.studyid;
    v_createdby := :OLD.modifiedby;
    v_createddt := v_sysdate;
    v_modifiedby := :OLD.modifiedby;
    v_modifieddt := v_sysdate;
  END IF;
  
  IF UPDATING THEN
  pkg_audit.sp_set_audit
    (v_studysectionstatusid,'TBL_STUDYSECTIONSTATUS','STUDYSECTIONSTATUSID',:OLD.STUDYSECTIONSTATUSID,:NEW.STUDYSECTIONSTATUSID,v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

   if v_auditid is not null then
  pkg_audit.sp_set_studyauditreportmap
  (v_auditid,v_studyid,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  end if;
  
  
  pkg_audit.sp_set_audit
    (v_studysectionstatusid,'TBL_STUDYSECTIONSTATUS','STUDYID',pkg_audit.fn_get_lov_value(:OLD.studyid, pkg_audit.g_lov_study),pkg_audit.fn_get_lov_value(:NEW.studyid, pkg_audit.g_lov_study),v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

   if v_auditid is not null then
  pkg_audit.sp_set_studyauditreportmap
  (v_auditid,v_studyid,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  end if;
  
  
  pkg_audit.sp_set_audit
    (v_studysectionstatusid,'TBL_STUDYSECTIONSTATUS','SECTIONID',:OLD.SECTIONID,:NEW.SECTIONID,v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

   if v_auditid is not null then
  pkg_audit.sp_set_studyauditreportmap
  (v_auditid,v_studyid,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  end if;
  
  
  pkg_audit.sp_set_audit
    (v_studysectionstatusid,'TBL_STUDYSECTIONSTATUS','STATUS',pkg_audit.fn_get_lov_value(:OLD.STATUS, pkg_audit.g_lov_activeflag),pkg_audit.fn_get_lov_value(:NEW.STATUS, pkg_audit.g_lov_activeflag),v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

   if v_auditid is not null then
  pkg_audit.sp_set_studyauditreportmap
  (v_auditid,v_studyid,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  end if;
  
  
  pkg_audit.sp_set_audit
    (v_studysectionstatusid,'TBL_STUDYSECTIONSTATUS','ISAPPLICABLE',pkg_audit.fn_get_lov_value(:OLD.ISAPPLICABLE,pkg_audit.g_lov_notapplicable),pkg_audit.fn_get_lov_value(:NEW.ISAPPLICABLE, pkg_audit.g_lov_notapplicable),v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

   if v_auditid is not null then
  pkg_audit.sp_set_studyauditreportmap
  (v_auditid,v_studyid,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  end if;
  
  
  pkg_audit.sp_set_audit
    (v_studysectionstatusid,'TBL_STUDYSECTIONSTATUS','CREATEDBY',:OLD.CREATEDBY,:NEW.CREATEDBY,v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

   if v_auditid is not null then
  pkg_audit.sp_set_studyauditreportmap
  (v_auditid,v_studyid,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  end if;
  
  
  pkg_audit.sp_set_audit
    (v_studysectionstatusid,'TBL_STUDYSECTIONSTATUS','MODIFIEDBY',:OLD.MODIFIEDBY,:NEW.MODIFIEDBY,v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

   if v_auditid is not null then
  pkg_audit.sp_set_studyauditreportmap
  (v_auditid,v_studyid,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  end if;
  
  
  pkg_audit.sp_set_audit
    (v_studysectionstatusid,'TBL_STUDYSECTIONSTATUS','CREATEDDT',TO_CHAR(:OLD.createddt,'DD-MON-YYYY'),TO_CHAR(:NEW.createddt,'DD-MON-YYYY'),v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

  IF v_auditid IS NOT NULL THEN
     pkg_audit.sp_set_studyauditreportmap
     (v_auditid,v_studyid,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  END IF;
  
  
  
  pkg_audit.sp_set_audit
    (v_studysectionstatusid,'TBL_STUDYSECTIONSTATUS','MODIFIEDDT',TO_CHAR(:OLD.MODIFIEDDT,'DD-MON-YYYY'),TO_CHAR(:NEW.MODIFIEDDT,'DD-MON-YYYY'),v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

  IF v_auditid IS NOT NULL THEN
     pkg_audit.sp_set_studyauditreportmap
     (v_auditid,v_studyid,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  END IF;
  
  END IF;
  
  END TRG_TBL_STUDYSECSTATUS_AUDIT;
  /