CREATE OR REPLACE TRIGGER TRG_TBL_STUDYCNTRYMSTONE_AUDIT
AFTER INSERT OR UPDATE OR DELETE ON TBL_STUDYCOUNTRYMILESTONE
FOR EACH ROW
DECLARE
v_operation           TBL_AUDIT.operation%TYPE;
v_auditid             TBL_AUDIT.auditid%TYPE;  
v_createdby           TBL_AUDIT.createdby%TYPE;
v_createddt           TBL_AUDIT.createddt%TYPE;
v_modifiedby          TBL_AUDIT.modifiedby%TYPE;
v_modifieddt          TBL_AUDIT.modifieddt%TYPE;
v_studycountryid      TBL_STUDYCOUNTRYMILESTONE.studycountryid%TYPE;
v_studyid             TBL_STUDYCOUNTRYMILESTONE.studyid%TYPE;
v_sysdate             DATE:=SYSDATE;

BEGIN
  IF INSERTING THEN
    v_operation := pkg_audit.g_operation_create;
    v_createdby := :NEW.createdby;
    v_createddt := :NEW.createddt;
    v_modifiedby := :NEW.createdby;
    v_modifieddt := :NEW.createddt;
    v_studycountryid := :NEW.studycountryid;
    v_studyid := :NEW.studyid;
  ELSIF UPDATING THEN
    IF NVL(:OLD.isactive,'Y') <> NVL(:NEW.isactive,'Y') AND :NEW.isactive = 'N' THEN
      v_operation := pkg_audit.g_operation_delete;
    ELSE    
      v_operation := pkg_audit.g_operation_update;
    END IF;
    v_createdby := :NEW.modifiedby;
    v_createddt := :NEW.modifieddt;
    v_modifiedby := :NEW.modifiedby;
    v_modifieddt := :NEW.modifieddt;
    v_studycountryid := :NEW.studycountryid;
    v_studyid := :NEW.studyid;
  ELSIF DELETING THEN
    v_operation := pkg_audit.g_operation_delete;
    v_createdby := :OLD.modifiedby;
    v_createddt := v_sysdate;
    v_modifiedby := :OLD.modifiedby;
    v_modifieddt := v_sysdate;
    v_studycountryid := :OLD.studycountryid;
    v_studyid := :OLD.studyid;
  END IF;
  
  pkg_audit.sp_set_audit
    (v_studycountryid,'TBL_STUDYCOUNTRYMILESTONE','STUDYCOUNTRYID',:OLD.studycountryid,:NEW.studycountryid,v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);
 
  IF v_auditid IS NOT NULL THEN
     pkg_audit.sp_set_studyauditreportmap
     (v_auditid,v_studyid,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby); 
  END IF;
  
  pkg_audit.sp_set_audit
    (v_studycountryid,'TBL_STUDYCOUNTRYMILESTONE','STUDYID',pkg_audit.fn_get_lov_value(:OLD.studyid, pkg_audit.g_lov_study),pkg_audit.fn_get_lov_value(:NEW.studyid, pkg_audit.g_lov_study),v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);
 
  IF v_auditid IS NOT NULL THEN
     pkg_audit.sp_set_studyauditreportmap
     (v_auditid,v_studyid,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby); 
  END IF;
  
  pkg_audit.sp_set_audit
    (v_studycountryid,'TBL_STUDYCOUNTRYMILESTONE','COUNTRYID',pkg_audit.fn_get_lov_value(:OLD.countryid,pkg_audit.g_lov_country_id),pkg_audit.fn_get_lov_value(:NEW.countryid,pkg_audit.g_lov_country_id),v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);
 
  IF v_auditid IS NOT NULL THEN
     pkg_audit.sp_set_studyauditreportmap
     (v_auditid,v_studyid,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby); 
  END IF;
  
  pkg_audit.sp_set_audit
    (v_studycountryid,'TBL_STUDYCOUNTRYMILESTONE','ISACTIVE',:OLD.isactive,:NEW.isactive,v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);
 
  IF v_auditid IS NOT NULL THEN
     pkg_audit.sp_set_studyauditreportmap
     (v_auditid,v_studyid,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby); 
  END IF;
  
  pkg_audit.sp_set_audit
    (v_studycountryid,'TBL_STUDYCOUNTRYMILESTONE','CREATEDBY',:OLD.createdby,:NEW.createdby,v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);
 
  IF v_auditid IS NOT NULL THEN
     pkg_audit.sp_set_studyauditreportmap
     (v_auditid,v_studyid,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby); 
  END IF;
  
  pkg_audit.sp_set_audit
    (v_studycountryid,'TBL_STUDYCOUNTRYMILESTONE','CREATEDDT',TO_CHAR(:OLD.createddt,'DD-MON-YYYY'),TO_CHAR(:NEW.createddt,'DD-MON-YYYY'),v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);
 
  IF v_auditid IS NOT NULL THEN
     pkg_audit.sp_set_studyauditreportmap
     (v_auditid,v_studyid,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby); 
  END IF;
  
  pkg_audit.sp_set_audit
    (v_studycountryid,'TBL_STUDYCOUNTRYMILESTONE','MODIFIEDBY',:OLD.modifiedby,:NEW.modifiedby,v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);
 
  IF v_auditid IS NOT NULL THEN
     pkg_audit.sp_set_studyauditreportmap
     (v_auditid,v_studyid,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby); 
  END IF;
  
  pkg_audit.sp_set_audit
    (v_studycountryid,'TBL_STUDYCOUNTRYMILESTONE','MODIFIEDDT',TO_CHAR(:OLD.modifieddt,'DD-MON-YYYY'),TO_CHAR(:NEW.modifieddt,'DD-MON-YYYY'),v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);
 
  IF v_auditid IS NOT NULL THEN
     pkg_audit.sp_set_studyauditreportmap
     (v_auditid,v_studyid,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby); 
  END IF;

 if :OLD.PLANNED_FSFV is null AND :NEW.PLANNED_FSFV is not null then
  pkg_audit.sp_set_audit(v_studycountryid,'TBL_STUDYCOUNTRYMILESTONE','PLANNED_FSFV',TO_CHAR(:OLD.PLANNED_FSFV,'DD-Mon-YYYY'),TO_CHAR(:NEW.PLANNED_FSFV,'DD-Mon-YYYY'),pkg_audit.g_operation_create,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);
 else
  pkg_audit.sp_set_audit(v_studycountryid,'TBL_STUDYCOUNTRYMILESTONE','PLANNED_FSFV',TO_CHAR(:OLD.PLANNED_FSFV,'DD-Mon-YYYY'),TO_CHAR(:NEW.PLANNED_FSFV,'DD-Mon-YYYY'),v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);
 end if;
 
  IF v_auditid IS NOT NULL THEN
     pkg_audit.sp_set_studyauditreportmap
     (v_auditid,v_studyid,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby); 
  END IF;
  if :OLD.PLANNED_LSLV is null AND :NEW.PLANNED_LSLV is not null then
    pkg_audit.sp_set_audit(v_studycountryid,'TBL_STUDYCOUNTRYMILESTONE','PLANNED_LSLV',TO_CHAR(:OLD.PLANNED_LSLV,'DD-Mon-YYYY'),TO_CHAR(:NEW.PLANNED_LSLV,'DD-Mon-YYYY'),pkg_audit.g_operation_create,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);
  else
    pkg_audit.sp_set_audit(v_studycountryid,'TBL_STUDYCOUNTRYMILESTONE','PLANNED_LSLV',TO_CHAR(:OLD.PLANNED_LSLV,'DD-Mon-YYYY'),TO_CHAR(:NEW.PLANNED_LSLV,'DD-Mon-YYYY'),v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);
  end if;
 
  IF v_auditid IS NOT NULL THEN
     pkg_audit.sp_set_studyauditreportmap
     (v_auditid,v_studyid,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby); 
  END IF;
  if :OLD.PLANNED_SUBJECTENROLLED is null AND :NEW.PLANNED_SUBJECTENROLLED is not null then
    pkg_audit.sp_set_audit(v_studycountryid,'TBL_STUDYCOUNTRYMILESTONE','PLANNED_SUBJECTENROLLED',:OLD.PLANNED_SUBJECTENROLLED,:NEW.PLANNED_SUBJECTENROLLED,pkg_audit.g_operation_create,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);
  else
    pkg_audit.sp_set_audit(v_studycountryid,'TBL_STUDYCOUNTRYMILESTONE','PLANNED_SUBJECTENROLLED',:OLD.PLANNED_SUBJECTENROLLED,:NEW.PLANNED_SUBJECTENROLLED,v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);
  end if;
 
  IF v_auditid IS NOT NULL THEN
     pkg_audit.sp_set_studyauditreportmap
     (v_auditid,v_studyid,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby); 
  END IF;
  
  if :OLD.ACTUAL_SUBJECTENROLLED is null AND :NEW.ACTUAL_SUBJECTENROLLED is not null then
    pkg_audit.sp_set_audit    (v_studycountryid,'TBL_STUDYCOUNTRYMILESTONE','ACTUAL_SUBJECTENROLLED',:OLD.ACTUAL_SUBJECTENROLLED,:NEW.ACTUAL_SUBJECTENROLLED,pkg_audit.g_operation_create,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);
  else
    pkg_audit.sp_set_audit    (v_studycountryid,'TBL_STUDYCOUNTRYMILESTONE','ACTUAL_SUBJECTENROLLED',:OLD.ACTUAL_SUBJECTENROLLED,:NEW.ACTUAL_SUBJECTENROLLED,v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);
  end if;
 
  IF v_auditid IS NOT NULL THEN
     pkg_audit.sp_set_studyauditreportmap
     (v_auditid,v_studyid,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby); 
  END IF;  
END TRG_TBL_STUDYCNTRYMSTONE_AUDIT;
/