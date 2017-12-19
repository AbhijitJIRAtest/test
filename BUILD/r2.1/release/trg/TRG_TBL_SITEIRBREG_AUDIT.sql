create or replace TRIGGER TRG_TBL_SITEIRBREG_AUDIT
AFTER INSERT OR UPDATE OR DELETE ON TBL_SITEIRBREGISTRATION
FOR EACH ROW
DECLARE
v_operation     			TBL_AUDIT.operation%TYPE;
v_auditid       			TBL_AUDIT.auditid%TYPE;
v_createdby     			TBL_AUDIT.createdby%TYPE;
v_createddt     			TBL_AUDIT.createddt%TYPE;
v_modifiedby    			TBL_AUDIT.modifiedby%TYPE;
v_modifieddt    			TBL_AUDIT.modifieddt%TYPE;
v_siteirbregistrationid    	TBL_SITEIRBREGISTRATION.SITEIRBREGISTRATIONID%TYPE;
v_sysdate       			DATE:=SYSDATE;
v_studyid             TBL_SITE.STUDYID%TYPE;
v_siteid              TBL_SITE.SITEID%TYPE;
v_siteirbid           TBL_SITEIRBREGISTRATION.SITEIRBID%TYPE;


BEGIN
  IF INSERTING THEN
    v_operation := pkg_audit.g_operation_create;
    v_siteirbregistrationid:= :NEW.SITEIRBREGISTRATIONID;
    v_createdby := :NEW.createdby;
    v_createddt := :NEW.createddt;
    v_modifiedby := :NEW.createdby;
    v_modifieddt := :NEW.createddt;
    v_siteirbid := :NEW.SITEIRBID;
	
  ELSIF UPDATING THEN
    v_operation := pkg_audit.g_operation_update;
    v_siteirbregistrationid:= :NEW.siteirbregistrationid;
    v_createdby := :NEW.modifiedby;
    v_createddt := :NEW.modifieddt;
    v_modifiedby := :NEW.modifiedby;
    v_modifieddt := :NEW.modifieddt;
    v_siteirbid := :NEW.SITEIRBID;
	
	ELSIF DELETING THEN
    v_operation := pkg_audit.g_operation_delete;
    v_siteirbregistrationid:= :OLD.siteirbregistrationid;
    v_createdby := :OLD.modifiedby;
    v_createddt := v_sysdate;
    v_modifiedby := :OLD.modifiedby;
    v_modifieddt := v_sysdate;
    v_siteirbid := :OLD.SITEIRBID;
  END IF;
  
 select SITEID 
 into v_siteid 
FROM TBL_SITEIRBMAP 
WHERE SITEIRBID = v_siteirbid ;

select STUDYID 
into v_studyid
FROM TBL_SITE
WHERE SITEID = v_siteid ;

pkg_audit.sp_set_audit
    (v_siteirbid,'TBL_SITEIRBREGISTRATION','SITEIRBREGISTRATIONID',:OLD.SITEIRBREGISTRATIONID,:NEW.SITEIRBREGISTRATIONID,v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

   if v_auditid is not null then
  pkg_audit.sp_set_studyauditreportmap
  (v_auditid,v_studyid,v_siteid,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  end if; 
  
  
pkg_audit.sp_set_audit
    (v_siteirbid,'TBL_SITEIRBREGISTRATION','SITEIRBID',:OLD.SITEIRBID,:NEW.SITEIRBID,v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

   if v_auditid is not null then
  pkg_audit.sp_set_studyauditreportmap
  (v_auditid,v_studyid,v_siteid,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  end if;
  
  
pkg_audit.sp_set_audit
    (v_siteirbid,'TBL_SITEIRBREGISTRATION','REGISTRATIONNUMBER',:OLD.REGISTRATIONNUMBER,:NEW.REGISTRATIONNUMBER,v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

   if v_auditid is not null then
  pkg_audit.sp_set_studyauditreportmap
  (v_auditid,v_studyid,v_siteid,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  end if;
  
  
pkg_audit.sp_set_audit
    (v_siteirbid,'TBL_SITEIRBREGISTRATION','REGISTERINTBODY',:OLD.REGISTERINTBODY,:NEW.REGISTERINTBODY,v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

   if v_auditid is not null then
  pkg_audit.sp_set_studyauditreportmap
  (v_auditid,v_studyid,v_siteid,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  end if;
  
  
pkg_audit.sp_set_audit
    (v_siteirbid,'TBL_SITEIRBREGISTRATION','STATUS',:OLD.STATUS,:NEW.STATUS,v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

   if v_auditid is not null then
  pkg_audit.sp_set_studyauditreportmap
  (v_auditid,v_studyid,v_siteid,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  end if;
  
  
pkg_audit.sp_set_audit
    (v_siteirbid,'TBL_SITEIRBREGISTRATION','CREATEDBY',:OLD.CREATEDBY,:NEW.CREATEDBY,v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

   if v_auditid is not null then
  pkg_audit.sp_set_studyauditreportmap
  (v_auditid,v_studyid,v_siteid,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  end if;
  
  
  
pkg_audit.sp_set_audit
    (v_siteirbid,'TBL_SITEIRBREGISTRATION','CREATEDDT',TO_CHAR(:OLD.CREATEDDT,'DD-Mon-YYYY'),TO_CHAR(:NEW.CREATEDDT,'DD-Mon-YYYY'),v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);
   
  if v_auditid is not null then
  pkg_audit.sp_set_studyauditreportmap
  (v_auditid,v_studyid,v_siteid,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  end if;
  
  
pkg_audit.sp_set_audit
    (v_siteirbid,'TBL_SITEIRBREGISTRATION','MODIFIEDDT',TO_CHAR(:OLD.MODIFIEDDT,'DD-Mon-YYYY'),TO_CHAR(:NEW.MODIFIEDDT,'DD-Mon-YYYY'),v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);
   
  if v_auditid is not null then
  pkg_audit.sp_set_studyauditreportmap
  (v_auditid,v_studyid,v_siteid,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  end if;
  
  
pkg_audit.sp_set_audit
    (v_siteirbid,'TBL_SITEIRBREGISTRATION','MODIFIEDBY',:OLD.MODIFIEDBY,:NEW.MODIFIEDBY,v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

   if v_auditid is not null then
  pkg_audit.sp_set_studyauditreportmap
  (v_auditid,v_studyid,v_siteid,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  end if;
  

  
END TRG_TBL_SITEIRBREG_AUDIT;

/