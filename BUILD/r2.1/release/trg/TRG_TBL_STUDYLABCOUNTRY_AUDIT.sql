create or replace TRIGGER TRG_TBL_STUDYLABCOUNTRY_AUDIT
AFTER INSERT OR UPDATE OR DELETE ON TBL_STUDYLABCOUNTRY
FOR EACH ROW
DECLARE
v_operation     			TBL_AUDIT.operation%TYPE;
v_auditid       			TBL_AUDIT.auditid%TYPE;
v_createdby     			TBL_AUDIT.createdby%TYPE;
v_createddt     			TBL_AUDIT.createddt%TYPE;
v_modifiedby    			TBL_AUDIT.modifiedby%TYPE;
v_modifieddt    			TBL_AUDIT.modifieddt%TYPE;
v_studylabcountryid    	TBL_STUDYLABCOUNTRY.STUDYLABCOUNTRYID%TYPE;
v_sysdate       			DATE:=SYSDATE;
v_studyid             TBL_SITE.STUDYID%TYPE;
v_sitelabid           TBL_STUDYLABCOUNTRY.STUDYLABID%TYPE;


BEGIN
  IF INSERTING THEN
    v_operation := pkg_audit.g_operation_create;
    v_studylabcountryid:= :NEW.STUDYLABCOUNTRYID;
    v_createdby := :NEW.createdby;
    v_createddt := :NEW.createddt;
    v_modifiedby := :NEW.createdby;
    v_modifieddt := :NEW.createddt;
    v_sitelabid := :NEW.STUDYLABID;
	
  ELSIF UPDATING THEN
    v_operation := pkg_audit.g_operation_update;
    v_studylabcountryid:= :NEW.STUDYLABCOUNTRYID;
    v_createdby := :NEW.modifiedby;
    v_createddt := :NEW.modifieddt;
    v_modifiedby := :NEW.modifiedby;
    v_modifieddt := :NEW.modifieddt;
    v_sitelabid := :NEW.STUDYLABID;
	
	ELSIF DELETING THEN
    v_operation := pkg_audit.g_operation_delete;
    v_studylabcountryid:= :OLD.STUDYLABCOUNTRYID;
    v_createdby := :OLD.modifiedby;
    v_createddt := v_sysdate;
    v_modifiedby := :OLD.modifiedby;
    v_modifieddt := v_sysdate;
    v_sitelabid := :OLD.STUDYLABID;
  END IF;
  

select STUDYID 
into v_studyid
FROM TBL_STUDYCENTRALLAB
WHERE STUDYLABID = v_sitelabid ;

pkg_audit.sp_set_audit
    (v_studylabcountryid,'TBL_STUDYLABCOUNTRY','STUDYLABCOUNTRYID',:OLD.STUDYLABCOUNTRYID,:NEW.STUDYLABCOUNTRYID,v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

   if v_auditid is not null then
  pkg_audit.sp_set_studyauditreportmap
  (v_auditid,v_studyid,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  end if; 
  
  
pkg_audit.sp_set_audit
    (v_studylabcountryid,'TBL_STUDYLABCOUNTRY','STUDYLABID',:OLD.STUDYLABID,:NEW.STUDYLABID,v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

   if v_auditid is not null then
  pkg_audit.sp_set_studyauditreportmap
  (v_auditid,v_studyid,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  end if;
  
  
pkg_audit.sp_set_audit
    (v_studylabcountryid,'TBL_STUDYLABCOUNTRY','COUNTRYID',pkg_audit.fn_get_lov_value(:OLD.COUNTRYID, pkg_audit.g_lov_country_id),pkg_audit.fn_get_lov_value(:NEW.COUNTRYID, pkg_audit.g_lov_country_id),v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

   if v_auditid is not null then
  pkg_audit.sp_set_studyauditreportmap
  (v_auditid,v_studyid,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  end if;
  
  
pkg_audit.sp_set_audit
    (v_studylabcountryid,'TBL_STUDYLABCOUNTRY','STATUS',:OLD.STATUS,:NEW.STATUS,v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

   if v_auditid is not null then
  pkg_audit.sp_set_studyauditreportmap
  (v_auditid,v_studyid,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  end if;
  
  
pkg_audit.sp_set_audit
    (v_studylabcountryid,'TBL_STUDYLABCOUNTRY','STARTDATE',:OLD.STARTDATE,:NEW.STARTDATE,v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

   if v_auditid is not null then
  pkg_audit.sp_set_studyauditreportmap
  (v_auditid,v_studyid,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  end if;
  
  
pkg_audit.sp_set_audit
    (v_studylabcountryid,'TBL_STUDYLABCOUNTRY','ENDDATE',:OLD.ENDDATE,:NEW.ENDDATE,v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

   if v_auditid is not null then
  pkg_audit.sp_set_studyauditreportmap
  (v_auditid,v_studyid,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  end if;
  
  
pkg_audit.sp_set_audit
    (v_studylabcountryid,'TBL_STUDYLABCOUNTRY','CREATEDBY',:OLD.CREATEDBY,:NEW.CREATEDBY,v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

   if v_auditid is not null then
  pkg_audit.sp_set_studyauditreportmap
  (v_auditid,v_studyid,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  end if;
  
  
  
pkg_audit.sp_set_audit
    (v_studylabcountryid,'TBL_STUDYLABCOUNTRY','CREATEDDT',TO_CHAR(:OLD.CREATEDDT,'DD-Mon-YYYY'),TO_CHAR(:NEW.CREATEDDT,'DD-Mon-YYYY'),v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);
   
  if v_auditid is not null then
  pkg_audit.sp_set_studyauditreportmap
  (v_auditid,v_studyid,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  end if;
  
  
pkg_audit.sp_set_audit
    (v_studylabcountryid,'TBL_STUDYLABCOUNTRY','MODIFIEDDT',TO_CHAR(:OLD.MODIFIEDDT,'DD-Mon-YYYY'),TO_CHAR(:NEW.MODIFIEDDT,'DD-Mon-YYYY'),v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);
   
  if v_auditid is not null then
  pkg_audit.sp_set_studyauditreportmap
  (v_auditid,v_studyid,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  end if;
  
  
pkg_audit.sp_set_audit
    (v_studylabcountryid,'TBL_STUDYLABCOUNTRY','MODIFIEDBY',:OLD.MODIFIEDBY,:NEW.MODIFIEDBY,v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

   if v_auditid is not null then
  pkg_audit.sp_set_studyauditreportmap
  (v_auditid,v_studyid,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  end if;
  

  
END TRG_TBL_STUDYLABCOUNTRY_AUDIT;

/