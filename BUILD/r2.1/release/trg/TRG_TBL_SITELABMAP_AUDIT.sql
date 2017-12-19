create or replace TRIGGER TRG_TBL_SITELABMAP_AUDIT
AFTER INSERT OR UPDATE OR DELETE ON TBL_SITELABMAP
FOR EACH ROW
DECLARE
v_operation     	TBL_AUDIT.operation%TYPE;
v_auditid       	TBL_AUDIT.auditid%TYPE;
v_createdby     	TBL_AUDIT.createdby%TYPE;
v_createddt     	TBL_AUDIT.createddt%TYPE;
v_modifiedby    	TBL_AUDIT.modifiedby%TYPE;
v_modifieddt    	TBL_AUDIT.modifieddt%TYPE;
v_sitelabid    	    TBL_SITELABMAP.SITELABID%TYPE;
v_siteid            TBL_SITELABMAP.SITEID%TYPE;
v_studyid           TBL_SITELABMAP.STUDYID%TYPE;   
v_contactid         tbl_contact.contactid%TYPE;
v_sysdate       	DATE:=SYSDATE;

BEGIN
  IF INSERTING THEN
    v_operation := pkg_audit.g_operation_create;
    v_sitelabid:= :NEW.sitelabid;
    v_createdby := :NEW.createdby;
    v_createddt := :NEW.createddt;
    v_modifiedby := :NEW.createdby;
    v_modifieddt := :NEW.createddt;
	v_siteid := :NEW.siteid;
    v_contactid := :NEW.contactid;
  ELSIF UPDATING THEN
    IF NVL(:OLD.status,'Y') <> NVL(:NEW.status,'Y') AND :NEW.status = 'D' THEN
      v_operation := pkg_audit.g_operation_delete;
    ELSE    
      v_operation := pkg_audit.g_operation_update;
    END IF;
    v_sitelabid:= :NEW.sitelabid;
    v_createdby := :NEW.modifiedby;
    v_createddt := :NEW.modifieddt;
    v_modifiedby := :NEW.modifiedby;
    v_modifieddt := :NEW.modifieddt;
	v_siteid := :NEW.siteid;
    v_contactid := :NEW.contactid;
	ELSIF DELETING THEN
    v_operation := pkg_audit.g_operation_delete;
    v_sitelabid:= :OLD.sitelabid;
    v_createdby := :OLD.modifiedby;
    v_createddt := v_sysdate;
    v_modifiedby := :OLD.modifiedby;
    v_modifieddt := v_sysdate;
	v_siteid := :OLD.siteid;
    v_contactid := :OLD.contactid;
  END IF;
  
  SELECT studyid
  INTO v_studyid
  FROM tbl_site
  WHERE siteid = v_siteid;

   
pkg_audit.sp_set_audit
    (v_sitelabid,'TBL_SITELABMAP','SITELABID',:OLD.SITELABID,:NEW.SITELABID,v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

   if v_auditid is not null then
  pkg_audit.sp_set_studyauditreportmap
  (v_auditid,v_studyid,v_siteid,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  end if; 
  
pkg_audit.sp_set_audit
    (v_sitelabid,'TBL_SITELABMAP','SITEID',:OLD.siteid,:NEW.siteid,v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

 if v_auditid is not null then
 pkg_audit.sp_set_studyauditreportmap
  (v_auditid,v_studyid,v_siteid,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  end if;
 

pkg_audit.sp_set_audit
  (v_sitelabid,'TBL_SITELABMAP','STUDYID',:OLD.studyid,:NEW.studyid,v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

   if v_auditid is not null then
  pkg_audit.sp_set_studyauditreportmap
  (v_auditid,v_studyid,v_siteid,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
   end if;   
  
pkg_audit.sp_set_audit
    (v_sitelabid,'TBL_SITELABMAP','LABTYPE',:OLD.LABTYPE,:NEW.LABTYPE,v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

   if v_auditid is not null then
  pkg_audit.sp_set_studyauditreportmap
  (v_auditid,v_studyid,v_siteid,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  end if;  


pkg_audit.sp_set_audit
    (v_sitelabid,'TBL_SITELABMAP','LABNAME',:OLD.LABNAME,:NEW.LABNAME,v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

   if v_auditid is not null then
  pkg_audit.sp_set_studyauditreportmap
  (v_auditid,v_studyid,v_siteid,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  end if; 


pkg_audit.sp_set_audit
    (v_sitelabid,'TBL_SITELABMAP','CONTACTID',:OLD.CONTACTID,:NEW.CONTACTID,v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

   if v_auditid is not null then
  pkg_audit.sp_set_studyauditreportmap
  (v_auditid,v_studyid,v_siteid,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  end if;  
  
  
pkg_audit.sp_set_audit
    (v_sitelabid,'TBL_SITELABMAP','STATUS',pkg_audit.fn_get_lov_value(:OLD.STATUS, pkg_audit.g_lov_activeflag),pkg_audit.fn_get_lov_value(:NEW.STATUS, pkg_audit.g_lov_activeflag),v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

   if v_auditid is not null then
  pkg_audit.sp_set_studyauditreportmap
  (v_auditid,v_studyid,v_siteid,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  end if; 
  
  
pkg_audit.sp_set_audit
    (v_sitelabid,'TBL_SITELABMAP','FACILITYID',:OLD.FACILITYID,:NEW.FACILITYID,v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

   if v_auditid is not null then
  pkg_audit.sp_set_studyauditreportmap
  (v_auditid,v_studyid,v_siteid,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  end if;
  
  
pkg_audit.sp_set_audit
    (v_sitelabid,'TBL_SITELABMAP','ISINCLUDED1572',:OLD.ISINCLUDED1572,:NEW.ISINCLUDED1572,v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

   if v_auditid is not null then
  pkg_audit.sp_set_studyauditreportmap
  (v_auditid,v_studyid,v_siteid,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  end if; 


pkg_audit.sp_set_audit
    (v_sitelabid,'TBL_SITELABMAP','EXTERNALCENTRALLABID',:OLD.EXTERNALCENTRALLABID,:NEW.EXTERNALCENTRALLABID,v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

   if v_auditid is not null then
  pkg_audit.sp_set_studyauditreportmap
  (v_auditid,v_studyid,v_siteid,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  end if;  
  
  
pkg_audit.sp_set_audit
    (v_sitelabid,'TBL_SITELABMAP','CREATEDBY',:OLD.CREATEDBY,:NEW.CREATEDBY,v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

   if v_auditid is not null then
  pkg_audit.sp_set_studyauditreportmap
  (v_auditid,v_studyid,v_siteid,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  end if;  
  
  
pkg_audit.sp_set_audit
    (v_sitelabid,'TBL_SITELABMAP','MODIFIEDBY',:OLD.MODIFIEDBY,:NEW.MODIFIEDBY,v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

   if v_auditid is not null then
  pkg_audit.sp_set_studyauditreportmap
  (v_auditid,v_studyid,v_siteid,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  end if;   
  
  
pkg_audit.sp_set_audit
  (v_sitelabid,'TBL_SITELABMAP','CREATEDDT',TO_CHAR(:OLD.CREATEDDT,'DD-MON-YYYY'),TO_CHAR(:NEW.CREATEDDT,'DD-MON-YYYY'),v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

   if v_auditid is not null then
  pkg_audit.sp_set_studyauditreportmap
  (v_auditid,v_studyid,v_siteid,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  end if;
  
  
pkg_audit.sp_set_audit
  (v_sitelabid,'TBL_SITELABMAP','MODIFIEDDT',TO_CHAR(:OLD.MODIFIEDDT,'DD-MON-YYYY'),TO_CHAR(:NEW.MODIFIEDDT,'DD-MON-YYYY'),v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

   if v_auditid is not null then
  pkg_audit.sp_set_studyauditreportmap
  (v_auditid,v_studyid,v_siteid,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  end if;  
  
  
pkg_audit.sp_set_audit
  (v_sitelabid,'TBL_SITELABMAP','STARTDATE',TO_CHAR(:OLD.STARTDATE,'DD-MON-YYYY'),TO_CHAR(:NEW.STARTDATE,'DD-MON-YYYY'),v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

   if v_auditid is not null then
  pkg_audit.sp_set_studyauditreportmap
  (v_auditid,v_studyid,v_siteid,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  end if;  


pkg_audit.sp_set_audit
  (v_sitelabid,'TBL_SITELABMAP','ENDDATE',TO_CHAR(:OLD.ENDDATE,'DD-MON-YYYY'),TO_CHAR(:NEW.ENDDATE,'DD-MON-YYYY'),v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

   if v_auditid is not null then
  pkg_audit.sp_set_studyauditreportmap
  (v_auditid,v_studyid,v_siteid,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  end if;    

  --Update Study Id and Siteid
  UPDATE TBL_STUDYAUDITREPORTMAP tsarm
  SET tsarm.studyid = v_studyid, 
      tsarm.studysiteid = v_siteid
  WHERE tsarm.studyid IS NULL and tsarm.studysiteid IS NULL
  AND tsarm.studyauditid IN (SELECT ta.auditid
                             FROM tbl_audit ta
                             WHERE ta.tablename IN ('TBL_CONTACT')
                             AND ta.entityrefid = v_contactid);   
  
END TRG_TBL_SITELABMAP_AUDIT;

/