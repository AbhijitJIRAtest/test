create or replace TRIGGER TRG_TBL_STUDYCENTRALLAB_AUDIT
AFTER INSERT OR UPDATE OR DELETE ON TBL_STUDYCENTRALLAB
FOR EACH ROW
DECLARE
v_operation           TBL_AUDIT.operation%TYPE;
v_auditid             TBL_AUDIT.auditid%TYPE;
v_createdby           TBL_AUDIT.createdby%TYPE;
v_createddt           TBL_AUDIT.createddt%TYPE;
v_modifiedby          TBL_AUDIT.modifiedby%TYPE;
v_modifieddt          TBL_AUDIT.modifieddt%TYPE;
v_studylabid      	  TBL_STUDYCENTRALLAB.studylabid%TYPE;
v_studyid             TBL_STUDYCENTRALLAB.studyid%TYPE;
v_contactid           TBL_CONTACT.contactid%TYPE;
v_sysdate             DATE:=SYSDATE;

BEGIN
  IF INSERTING THEN
    v_operation 	:= pkg_audit.g_operation_create;
    v_createdby 	:= :NEW.createdby;
    v_createddt 	:= :NEW.createddt;
    v_modifiedby 	:= :NEW.createdby;
    v_modifieddt 	:= :NEW.createddt;
    v_studylabid 	:= :NEW.studylabid;
    v_studyid 		:= :NEW.studyid;
    v_contactid     := :NEW.contactid;
  ELSIF UPDATING THEN
    IF NVL(:OLD.status,'Y') <> NVL(:NEW.status,'Y') AND :NEW.status = 'D' THEN
      v_operation := pkg_audit.g_operation_delete;
    ELSE    
      v_operation := pkg_audit.g_operation_update;
    END IF;
    v_createdby := :NEW.modifiedby;
    v_createddt := :NEW.modifieddt;
    v_modifiedby := :NEW.modifiedby;
    v_modifieddt := :NEW.modifieddt;
    v_studylabid 	:= :NEW.studylabid;
    v_studyid 		:= :NEW.studyid;
    v_contactid     := :NEW.contactid;
  ELSIF DELETING THEN
    v_operation := pkg_audit.g_operation_delete;
    v_createdby := :OLD.modifiedby;
    v_createddt := v_sysdate;
    v_modifiedby := :OLD.modifiedby;
    v_modifieddt := v_sysdate;
	v_studylabid 	:= :OLD.studylabid;
    v_studyid 		:= :OLD.studyid;
    v_contactid     := :OLD.contactid;
  END IF;

  pkg_audit.sp_set_audit
    (v_studylabid,'TBL_STUDYCENTRALLAB','STUDYLABID',:OLD.studylabid,:NEW.studylabid,v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

    if v_auditid is not null then
  pkg_audit.sp_set_studyauditreportmap
  (v_auditid,v_studyid,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  end if;
  
	pkg_audit.sp_set_audit
    (v_studylabid,'TBL_STUDYCENTRALLAB','STUDYID',:OLD.studyid,:NEW.studyid,v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

    if v_auditid is not null then
  pkg_audit.sp_set_studyauditreportmap
  (v_auditid,v_studyid,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  end if;
  
	pkg_audit.sp_set_audit
    (v_studylabid,'TBL_STUDYCENTRALLAB','EXTERNALID',:OLD.externalid,:NEW.externalid,v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);
   
    if v_auditid is not null then
  pkg_audit.sp_set_studyauditreportmap
  (v_auditid,v_studyid,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  end if;
    
	pkg_audit.sp_set_audit
    (v_studylabid,'TBL_STUDYCENTRALLAB','LABNAME',:OLD.LABNAME,:NEW.LABNAME,v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

    if v_auditid is not null then
  pkg_audit.sp_set_studyauditreportmap
  (v_auditid,v_studyid,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  end if;
  
  pkg_audit.sp_set_audit
    (v_studylabid,'TBL_STUDYCENTRALLAB','LABTYPE',:OLD.LABTYPE,:NEW.LABTYPE,v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

    if v_auditid is not null then
  pkg_audit.sp_set_studyauditreportmap
  (v_auditid,v_studyid,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  end if;

	pkg_audit.sp_set_audit
    (v_studylabid,'TBL_STUDYCENTRALLAB','CONTACTID',:OLD.CONTACTID,:NEW.CONTACTID,v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

    if v_auditid is not null then
  pkg_audit.sp_set_studyauditreportmap
  (v_auditid,v_studyid,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  end if;
  
	pkg_audit.sp_set_audit
    (v_studylabid,'TBL_STUDYCENTRALLAB','STARTDATE',TO_CHAR(:OLD.STARTDATE,'DD-MON-YYYY'),TO_CHAR(:NEW.STARTDATE,'DD-MON-YYYY'),v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);
    
    if v_auditid is not null then
  pkg_audit.sp_set_studyauditreportmap
  (v_auditid,v_studyid,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  end if;
  
  
	pkg_audit.sp_set_audit
    (v_studylabid,'TBL_STUDYCENTRALLAB','ENDDATE',TO_CHAR(:OLD.ENDDATE,'DD-MON-YYYY'),TO_CHAR(:NEW.ENDDATE,'DD-MON-YYYY'),v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

if v_auditid is not null then
  pkg_audit.sp_set_studyauditreportmap
  (v_auditid,v_studyid,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  end if;    
  pkg_audit.sp_set_audit
    (v_studylabid,'TBL_STUDYCENTRALLAB','CREATEDBY',:OLD.createdby,:NEW.createdby,v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

    if v_auditid is not null then
  pkg_audit.sp_set_studyauditreportmap
  (v_auditid,v_studyid,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  end if;
  
  pkg_audit.sp_set_audit
    (v_studylabid,'TBL_STUDYCENTRALLAB','MODIFIEDBY',:OLD.modifiedby,:NEW.modifiedby,v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

    if v_auditid is not null then
  pkg_audit.sp_set_studyauditreportmap
  (v_auditid,v_studyid,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  end if;
  

  pkg_audit.sp_set_audit
    (v_studylabid,'TBL_STUDYCENTRALLAB','CREATEDDT',TO_CHAR(:OLD.createddt,'DD-MON-YYYY'),TO_CHAR(:NEW.createddt,'DD-MON-YYYY'),v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);
    
    if v_auditid is not null then
  pkg_audit.sp_set_studyauditreportmap
  (v_auditid,v_studyid,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  end if;
  
  pkg_audit.sp_set_audit
    (v_studylabid,'TBL_STUDYCENTRALLAB','MODIFIEDDT',TO_CHAR(:OLD.modifieddt,'DD-MON-YYYY'),TO_CHAR(:NEW.modifieddt,'DD-MON-YYYY'),v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);
    
    if v_auditid is not null then
  pkg_audit.sp_set_studyauditreportmap
  (v_auditid,v_studyid,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  end if;

  
	pkg_audit.sp_set_audit
    (v_studylabid,'TBL_STUDYCENTRALLAB','STATUS',pkg_audit.fn_get_lov_value(:OLD.STATUS, pkg_audit.g_lov_activeflag),pkg_audit.fn_get_lov_value(:NEW.STATUS, pkg_audit.g_lov_activeflag),v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);
    
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

END TRG_TBL_STUDYCENTRALLAB_AUDIT;

/