create or replace TRIGGER TRG_TBL_SITEIRBMAP_AUDIT
AFTER INSERT OR UPDATE OR DELETE ON TBL_SITEIRBMAP
FOR EACH ROW
DECLARE
v_operation     			TBL_AUDIT.operation%TYPE;
v_auditid       			TBL_AUDIT.auditid%TYPE;
v_createdby     			TBL_AUDIT.createdby%TYPE;
v_createddt     			TBL_AUDIT.createddt%TYPE;
v_modifiedby    			TBL_AUDIT.modifiedby%TYPE;
v_modifieddt    			TBL_AUDIT.modifieddt%TYPE;
v_siteirbid    	      TBL_SITEIRBMAP.SITEIRBID%TYPE;
v_siteid              TBL_SITE.SITEID%TYPE;
v_studyid             TBL_SITE.STUDYID%TYPE;  
v_contactid           tbl_contact.contactid%TYPE;
v_sysdate       	  DATE:=SYSDATE;
BEGIN
  IF INSERTING THEN
    v_operation := pkg_audit.g_operation_create;
    v_siteirbid:= :NEW.siteirbid;
    v_createdby := :NEW.createdby;
    v_createddt := :NEW.createddt;
    v_modifiedby := :NEW.createdby;
    v_modifieddt := :NEW.createddt;
	v_siteid := :NEW.SITEID;
    v_contactid := :NEW.contactid;
  ELSIF UPDATING THEN
    IF NVL(:OLD.status,'Y') <> NVL(:NEW.status,'Y') AND :NEW.status = 'D' THEN
      v_operation := pkg_audit.g_operation_delete;
    ELSE    
      v_operation := pkg_audit.g_operation_update;
    END IF;  
    v_siteirbid:= :NEW.siteirbid;
    v_createdby := :NEW.modifiedby;
    v_createddt := :NEW.modifieddt;
    v_modifiedby := :NEW.modifiedby;
    v_modifieddt := :NEW.modifieddt;
	v_siteid := :NEW.SITEID;
    v_contactid := :NEW.contactid;
	ELSIF DELETING THEN
    v_operation := pkg_audit.g_operation_delete;
    v_siteirbid:= :OLD.siteirbid;
    v_createdby := :OLD.modifiedby;
    v_createddt := v_sysdate;
    v_modifiedby := :OLD.modifiedby;
    v_modifieddt := v_sysdate;
	v_siteid := :OLD.SITEID;
    v_contactid := :OLD.contactid;
  END IF;
  
  SELECT studyid
  INTO v_studyid
  FROM tbl_site
  WHERE siteid = v_siteid;

  
pkg_audit.sp_set_audit
    (v_siteirbid,'TBL_SITEIRBMAP','SITEIRBID',:OLD.SITEIRBID,:NEW.SITEIRBID,v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

   if v_auditid is not null then
  pkg_audit.sp_set_studyauditreportmap
  (v_auditid,v_studyid,v_siteid,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  end if; 
 

pkg_audit.sp_set_audit
    (v_siteirbid,'TBL_SITEIRBMAP','SITEID',:OLD.SITEID,:NEW.SITEID,v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

 if v_auditid is not null then
 pkg_audit.sp_set_studyauditreportmap
  (v_auditid,v_studyid,v_siteid,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  end if;
 

pkg_audit.sp_set_audit
  (v_siteirbid,'TBL_SITEIRBMAP','STUDYID',:OLD.STUDYID,:NEW.STUDYID,v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

   if v_auditid is not null then
  pkg_audit.sp_set_studyauditreportmap
  (v_auditid,v_studyid,v_siteid,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
   end if; 
 
 
pkg_audit.sp_set_audit
    (v_siteirbid,'TBL_SITEIRBMAP','IRBTYPE',pkg_audit.fn_get_lov_value(:OLD.IRBTYPE, pkg_audit.g_lov_irbtype),pkg_audit.fn_get_lov_value(:NEW.IRBTYPE, pkg_audit.g_lov_irbtype),v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

   if v_auditid is not null then
  pkg_audit.sp_set_studyauditreportmap
  (v_auditid,v_studyid,v_siteid,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  end if; 



pkg_audit.sp_set_audit
    (v_siteirbid,'TBL_SITEIRBMAP','IRBNAME',:OLD.IRBNAME,:NEW.IRBNAME,v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

   if v_auditid is not null then
  pkg_audit.sp_set_studyauditreportmap
  (v_auditid,v_studyid,v_siteid,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  end if;  
 
 
pkg_audit.sp_set_audit
    (v_siteirbid,'TBL_SITEIRBMAP','CONTACTID',:OLD.CONTACTID,:NEW.CONTACTID,v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

   if v_auditid is not null then
  pkg_audit.sp_set_studyauditreportmap
  (v_auditid,v_studyid,v_siteid,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  end if;


pkg_audit.sp_set_audit
    (v_siteirbid,'TBL_SITEIRBMAP','STATUS',pkg_audit.fn_get_lov_value(:OLD.STATUS, pkg_audit.g_lov_activeflag),pkg_audit.fn_get_lov_value(:NEW.STATUS, pkg_audit.g_lov_activeflag),v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

   if v_auditid is not null then
  pkg_audit.sp_set_studyauditreportmap
  (v_auditid,v_studyid,v_siteid,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  end if;  
  
  
  
pkg_audit.sp_set_audit
  (v_siteirbid,'TBL_SITEIRBMAP','STARTDATE',TO_CHAR(:OLD.STARTDATE,'DD-MON-YYYY'),TO_CHAR(:NEW.STARTDATE,'DD-MON-YYYY'),v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

   if v_auditid is not null then
  pkg_audit.sp_set_studyauditreportmap
  (v_auditid,v_studyid,v_siteid,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  end if;
  
  
pkg_audit.sp_set_audit
  (v_siteirbid,'TBL_SITEIRBMAP','ENDDATE',TO_CHAR(:OLD.ENDDATE,'DD-MON-YYYY'),TO_CHAR(:NEW.ENDDATE,'DD-MON-YYYY'),v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

   if v_auditid is not null then
  pkg_audit.sp_set_studyauditreportmap
  (v_auditid,v_studyid,v_siteid,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  end if;  
 
pkg_audit.sp_set_audit
    (v_siteirbid,'TBL_SITEIRBMAP','FACILITYID',:OLD.FACILITYID,:NEW.FACILITYID,v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

   if v_auditid is not null then
  pkg_audit.sp_set_studyauditreportmap
  (v_auditid,v_studyid,v_siteid,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  end if; 
  
  
  
pkg_audit.sp_set_audit
    (v_siteirbid,'TBL_SITEIRBMAP','ISINCLUDED1572',:OLD.ISINCLUDED1572,:NEW.ISINCLUDED1572,v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

   if v_auditid is not null then
  pkg_audit.sp_set_studyauditreportmap
  (v_auditid,v_studyid,v_siteid,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  end if;
  
  
pkg_audit.sp_set_audit
    (v_siteirbid,'TBL_SITEIRBMAP','MEETINGFREQUENCY',pkg_audit.fn_get_lov_value(:OLD.MEETINGFREQUENCY, pkg_audit.g_lov_meetfreq),pkg_audit.fn_get_lov_value(:NEW.MEETINGFREQUENCY, pkg_audit.g_lov_meetfreq),v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

   if v_auditid is not null then
  pkg_audit.sp_set_studyauditreportmap
  (v_auditid,v_studyid,v_siteid,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  end if;
  
  
  
pkg_audit.sp_set_audit
    (v_siteirbid,'TBL_SITEIRBMAP','OTHMTNGFREQNAME',:OLD.OTHMTNGFREQNAME,:NEW.OTHMTNGFREQNAME,v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

   if v_auditid is not null then
  pkg_audit.sp_set_studyauditreportmap
  (v_auditid,v_studyid,v_siteid,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  end if;
  
  
  
pkg_audit.sp_set_audit
    (v_siteirbid,'TBL_SITEIRBMAP','PACKSUBMISSION',pkg_audit.fn_get_lov_value(:OLD.PACKSUBMISSION, pkg_audit.g_lov_pkgsub),pkg_audit.fn_get_lov_value(:NEW.PACKSUBMISSION, pkg_audit.g_lov_pkgsub),v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

   if v_auditid is not null then
  pkg_audit.sp_set_studyauditreportmap
  (v_auditid,v_studyid,v_siteid,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  end if;
  
  
pkg_audit.sp_set_audit
    (v_siteirbid,'TBL_SITEIRBMAP','REQPAYMENTAPPROVAL',:OLD.REQPAYMENTAPPROVAL,:NEW.REQPAYMENTAPPROVAL,v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

   if v_auditid is not null then
  pkg_audit.sp_set_studyauditreportmap
  (v_auditid,v_studyid,v_siteid,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  end if;
  
  
pkg_audit.sp_set_audit
    (v_siteirbid,'TBL_SITEIRBMAP','REQBUDGETAPPROVAL',:OLD.REQBUDGETAPPROVAL,:NEW.REQBUDGETAPPROVAL,v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

   if v_auditid is not null then
  pkg_audit.sp_set_studyauditreportmap
  (v_auditid,v_studyid,v_siteid,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  end if;
  
  
  
pkg_audit.sp_set_audit
    (v_siteirbid,'TBL_SITEIRBMAP','EXTERNALCENTRALIRBID',:OLD.EXTERNALCENTRALIRBID,:NEW.EXTERNALCENTRALIRBID,v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

   if v_auditid is not null then
  pkg_audit.sp_set_studyauditreportmap
  (v_auditid,v_studyid,v_siteid,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  end if;
  
  
  
pkg_audit.sp_set_audit
    (v_siteirbid,'TBL_SITEIRBMAP','CREATEDBY',:OLD.CREATEDBY,:NEW.CREATEDBY,v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

   if v_auditid is not null then
  pkg_audit.sp_set_studyauditreportmap
  (v_auditid,v_studyid,v_siteid,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  end if;
  
  
  
pkg_audit.sp_set_audit
    (v_siteirbid,'TBL_SITEIRBMAP','MODIFIEDBY',:OLD.MODIFIEDBY,:NEW.MODIFIEDBY,v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

   if v_auditid is not null then
  pkg_audit.sp_set_studyauditreportmap
  (v_auditid,v_studyid,v_siteid,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  end if;  
  
  
pkg_audit.sp_set_audit
  (v_siteirbid,'TBL_SITEIRBMAP','CREATEDDT',TO_CHAR(:OLD.CREATEDDT,'DD-MON-YYYY'),TO_CHAR(:NEW.CREATEDDT,'DD-MON-YYYY'),v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

   if v_auditid is not null then
  pkg_audit.sp_set_studyauditreportmap
  (v_auditid,v_studyid,v_siteid,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  end if;
  
  
pkg_audit.sp_set_audit
  (v_siteirbid,'TBL_SITEIRBMAP','MODIFIEDDT',TO_CHAR(:OLD.MODIFIEDDT,'DD-MON-YYYY'),TO_CHAR(:NEW.MODIFIEDDT,'DD-MON-YYYY'),v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

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
 
END TRG_TBL_SITEIRBMAP_AUDIT;

/