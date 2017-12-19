create or replace TRIGGER TRG_TBL_STUDYCENTRALIRB_AUDIT
AFTER INSERT OR UPDATE OR DELETE ON TBL_STUDYCENTRALIRB
FOR EACH ROW
DECLARE
v_operation     TBL_AUDIT.operation%TYPE;
v_auditid       TBL_AUDIT.auditid%TYPE;
v_createdby     TBL_AUDIT.createdby%TYPE;
v_createddt     TBL_AUDIT.createddt%TYPE;
v_modifiedby    TBL_AUDIT.modifiedby%TYPE;
v_modifieddt    TBL_AUDIT.modifieddt%TYPE;
v_studyirbid    TBL_STUDYCENTRALIRB.STUDYIRBID%TYPE;
v_studyid       TBL_STUDYCENTRALIRB.STUDYID%TYPE;
v_contactid     TBL_CONTACT.contactid%TYPE;
v_sysdate       DATE:=SYSDATE;

BEGIN
  IF INSERTING THEN
    v_operation := pkg_audit.g_operation_create;
    v_studyirbid:= :NEW.studyirbid;
    v_studyid := :NEW.studyid;
    v_createdby := :NEW.createdby;
    v_createddt := :NEW.createddt;
    v_modifiedby := :NEW.createdby;
    v_modifieddt := :NEW.createddt;
	v_contactid  := :NEW.contactid;
  ELSIF UPDATING THEN
    IF NVL(:OLD.status,'Y') <> NVL(:NEW.status,'Y') AND :NEW.status = 'D' THEN
      v_operation := pkg_audit.g_operation_delete;
    ELSE    
      v_operation := pkg_audit.g_operation_update;
    END IF;
    v_studyirbid:= :NEW.studyirbid;
    v_studyid := :NEW.studyid;
    v_createdby := :NEW.modifiedby;
    v_createddt := :NEW.modifieddt;
    v_modifiedby := :NEW.modifiedby;
    v_modifieddt := :NEW.modifieddt;
	v_contactid  := :NEW.contactid;
  ELSIF DELETING THEN
    v_operation := pkg_audit.g_operation_delete;
    v_studyirbid:= :OLD.studyirbid;
    v_studyid := :NEW.studyid;
    v_createdby := :OLD.modifiedby;
    v_createddt := v_sysdate;
    v_modifiedby := :OLD.modifiedby;
    v_modifieddt := v_sysdate;
    v_contactid  := :OLD.contactid;
  END IF;
  
  
pkg_audit.sp_set_audit
    (v_studyirbid,'TBL_STUDYCENTRALIRB','STUDYIRBID',:OLD.STUDYIRBID,:NEW.STUDYIRBID,v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

   if v_auditid is not null then
  pkg_audit.sp_set_studyauditreportmap
  (v_auditid,v_studyid,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  end if;
  
pkg_audit.sp_set_audit
    (v_studyirbid,'TBL_STUDYCENTRALIRB','STUDYID',pkg_audit.fn_get_lov_value(:OLD.studyid, pkg_audit.g_lov_study),pkg_audit.fn_get_lov_value(:NEW.studyid, pkg_audit.g_lov_study),v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

   if v_auditid is not null then
  pkg_audit.sp_set_studyauditreportmap
  (v_auditid,v_studyid,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  end if;
  
  
pkg_audit.sp_set_audit
    (v_studyirbid,'TBL_STUDYCENTRALIRB','EXTERNALID',:OLD.EXTERNALID,:NEW.EXTERNALID,v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

   if v_auditid is not null then
  pkg_audit.sp_set_studyauditreportmap
  (v_auditid,v_studyid,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  end if;  
  
  
pkg_audit.sp_set_audit
    (v_studyirbid,'TBL_STUDYCENTRALIRB','IRBNAME',:OLD.IRBNAME,:NEW.IRBNAME,v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

   if v_auditid is not null then
  pkg_audit.sp_set_studyauditreportmap
  (v_auditid,v_studyid,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  end if;
  
  
pkg_audit.sp_set_audit
    (v_studyirbid,'TBL_STUDYCENTRALIRB','CONTACTID',:OLD.CONTACTID,:NEW.CONTACTID,v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

  if v_auditid is not null then
  pkg_audit.sp_set_studyauditreportmap
  (v_auditid,v_studyid,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  end if;
  
pkg_audit.sp_set_audit
    (v_studyirbid,'TBL_STUDYCENTRALIRB','STATUS',pkg_audit.fn_get_lov_value(:OLD.STATUS, pkg_audit.g_lov_activeflag),pkg_audit.fn_get_lov_value(:NEW.STATUS, pkg_audit.g_lov_activeflag),v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

  if v_auditid is not null then
  pkg_audit.sp_set_studyauditreportmap
  (v_auditid,v_studyid,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  end if; 
  
  
pkg_audit.sp_set_audit
    (v_studyirbid,'TBL_STUDYCENTRALIRB','STARTDATE',TO_CHAR(:OLD.STARTDATE,'DD-Mon-YYYY'),TO_CHAR(:NEW.STARTDATE,'DD-Mon-YYYY'),v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);
   
  if v_auditid is not null then
  pkg_audit.sp_set_studyauditreportmap
  (v_auditid,v_studyid,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  end if;   
  
pkg_audit.sp_set_audit
    (v_studyirbid,'TBL_STUDYCENTRALIRB','ENDDATE',TO_CHAR(:OLD.ENDDATE,'DD-Mon-YYYY'),TO_CHAR(:NEW.ENDDATE,'DD-Mon-YYYY'),v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);
   
   if v_auditid is not null then
  pkg_audit.sp_set_studyauditreportmap
  (v_auditid,v_studyid,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  end if; 
  
pkg_audit.sp_set_audit
    (v_studyirbid,'TBL_STUDYCENTRALIRB','CREATEDBY',:OLD.CREATEDBY,:NEW.CREATEDBY,v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);
   
  if v_auditid is not null then
  pkg_audit.sp_set_studyauditreportmap
  (v_auditid,v_studyid,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  end if;  
  
  
pkg_audit.sp_set_audit
    (v_studyirbid,'TBL_STUDYCENTRALIRB','CREATEDDT',TO_CHAR(:OLD.CREATEDDT,'DD-Mon-YYYY'),TO_CHAR(:NEW.CREATEDDT,'DD-Mon-YYYY'),v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);
   
  if v_auditid is not null then
  pkg_audit.sp_set_studyauditreportmap
  (v_auditid,v_studyid,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  end if;   
  
pkg_audit.sp_set_audit
    (v_studyirbid,'TBL_STUDYCENTRALIRB','MODIFIEDBY',:OLD.MODIFIEDBY,:NEW.MODIFIEDBY,v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);
   
  if v_auditid is not null then
  pkg_audit.sp_set_studyauditreportmap
  (v_auditid,v_studyid,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  end if;


pkg_audit.sp_set_audit
    (v_studyirbid,'TBL_STUDYCENTRALIRB','MODIFIEDDT',TO_CHAR(:OLD.MODIFIEDDT,'DD-Mon-YYYY'),TO_CHAR(:NEW.MODIFIEDDT,'DD-Mon-YYYY'),v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);
   
  if v_auditid is not null then
  pkg_audit.sp_set_studyauditreportmap
  (v_auditid,v_studyid,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  end if;  

  --Update Study Id
  UPDATE TBL_STUDYAUDITREPORTMAP tsarm
  SET tsarm.studyid = v_studyid 
  WHERE tsarm.studyid IS NULL
  AND tsarm.studyauditid IN (SELECT ta.auditid
                             FROM tbl_audit ta
                             WHERE ta.tablename IN ('TBL_CONTACT')
                             AND ta.entityrefid = v_contactid);      
  
END TRG_TBL_STUDYCENTRALIRB_AUDIT;

/