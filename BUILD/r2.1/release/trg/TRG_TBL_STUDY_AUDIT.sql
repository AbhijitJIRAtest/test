create or replace TRIGGER TRG_TBL_STUDY_AUDIT
AFTER INSERT OR UPDATE OR DELETE ON TBL_STUDY
FOR EACH ROW
DECLARE
v_operation tbl_audit.operation%TYPE;
v_auditid   tbl_audit.auditid%TYPE;  
v_createdby tbl_audit.createdby%TYPE;
v_createddt tbl_audit.createddt%TYPE;
v_modifiedby tbl_audit.modifiedby%TYPE;
v_modifieddt tbl_audit.modifieddt%TYPE;
v_studyid    tbl_study.studyid%TYPE;
v_sysdate DATE:=SYSDATE;
BEGIN
  IF INSERTING THEN
    v_operation := pkg_audit.g_operation_create;
    v_createdby := :NEW.createdby;
    v_createddt := :NEW.createddt;
    v_modifiedby := :NEW.createdby;
    v_modifieddt := :NEW.createddt;
    v_studyid := :NEW.STUDYID;
    
  ELSIF UPDATING THEN  
      v_operation := pkg_audit.g_operation_update;
     v_studyid := :NEW.STUDYID;
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
    v_studyid := :OLD.STUDYID;
  END IF;
  
  pkg_audit.sp_set_audit
    (v_studyid,'TBL_STUDY','STUDYID',pkg_audit.fn_get_lov_value(:OLD.studyid, pkg_audit.g_lov_study),pkg_audit.fn_get_lov_value(:NEW.studyid, pkg_audit.g_lov_study),v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);
  
   if v_auditid is not null then
  pkg_audit.sp_set_studyauditreportmap
  (v_auditid,v_studyid,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  end if;
  
  pkg_audit.sp_set_audit
  (v_studyid,'TBL_STUDY','STUDYNAME',:OLD.studyname,(CASE WHEN :new.ISACTIVE is null then null else :NEW.studyname end),v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);
 
 if v_auditid is not null then 
 pkg_audit.sp_set_studyauditreportmap
  (v_auditid,v_studyid,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  end if;
  
  pkg_audit.sp_set_audit
  (v_studyid,'TBL_STUDY','PROGID',pkg_audit.fn_get_lov_value(:OLD.PROGID, pkg_audit.g_lov_program),(CASE WHEN :new.ISACTIVE is null then null else pkg_audit.fn_get_lov_value(:NEW.PROGID, pkg_audit.g_lov_program) end),v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);
  
   if v_auditid is not null then
  pkg_audit.sp_set_studyauditreportmap
  (v_auditid,v_studyid,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  end if;
  
  pkg_audit.sp_set_audit
  (v_studyid,'TBL_STUDY','CONTACTID',:OLD.CONTACTID,(CASE WHEN :new.ISACTIVE is null then null else :NEW.CONTACTID end),v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);
  
   if v_auditid is not null then
  pkg_audit.sp_set_studyauditreportmap
  (v_auditid,v_studyid,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  end if;
  
 pkg_audit.sp_set_audit
  (v_studyid,'TBL_STUDY','THERAPEUTICAREAID',pkg_audit.fn_get_lov_value(:OLD.THERAPEUTICAREAID, pkg_audit.g_lov_therapeuticarea),(CASE WHEN :new.ISACTIVE is null then null else pkg_audit.fn_get_lov_value(:NEW.THERAPEUTICAREAID, pkg_audit.g_lov_therapeuticarea) end),v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);
  
   if v_auditid is not null then
  pkg_audit.sp_set_studyauditreportmap
  (v_auditid,v_studyid,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  end if;
  
  pkg_audit.sp_set_audit
  (v_studyid,'TBL_STUDY','STUDYTYPECD',:OLD.STUDYTYPECD,(CASE WHEN :new.ISACTIVE is null then null else :NEW.STUDYTYPECD end),v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);
  
   if v_auditid is not null then
  pkg_audit.sp_set_studyauditreportmap
  (v_auditid,v_studyid,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  end if;
  
  pkg_audit.sp_set_audit
  (v_studyid,'TBL_STUDY','STUDYSHORTDESC',:OLD.STUDYSHORTDESC,(CASE WHEN :new.ISACTIVE is null then null else :NEW.STUDYSHORTDESC end),v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);
  
   if v_auditid is not null then
  pkg_audit.sp_set_studyauditreportmap
  (v_auditid,v_studyid,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  
  end if;
  
  pkg_audit.sp_set_audit
  (v_studyid,'TBL_STUDY','STUDYLONGDESC',:OLD.STUDYLONGDESC,(CASE WHEN :new.ISACTIVE is null then null else :NEW.STUDYLONGDESC end),v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);
 
 if v_auditid is not null then
 pkg_audit.sp_set_studyauditreportmap
  (v_auditid,v_studyid,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  end if;
  
  pkg_audit.sp_set_audit
  (v_studyid,'TBL_STUDY','DISEASEID',pkg_audit.fn_get_lov_value(:OLD.DISEASEID, pkg_audit.g_lov_disease),(CASE WHEN :new.ISACTIVE is null then null else pkg_audit.fn_get_lov_value(:NEW.DISEASEID, pkg_audit.g_lov_disease) end),v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);
 

 if v_auditid is not null then
 pkg_audit.sp_set_studyauditreportmap
  (v_auditid,v_studyid,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  end if;
  
  pkg_audit.sp_set_audit
  (v_studyid,'TBL_STUDY','INDICATIONID',pkg_audit.fn_get_lov_value(:OLD.INDICATIONID, pkg_audit.g_lov_indication),(CASE WHEN :new.ISACTIVE is null then null else pkg_audit.fn_get_lov_value(:NEW.INDICATIONID, pkg_audit.g_lov_indication) end),v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);
  
   if v_auditid is not null then
  pkg_audit.sp_set_studyauditreportmap
  (v_auditid,v_studyid,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  end if;
  
  pkg_audit.sp_set_audit
  (v_studyid,'TBL_STUDY','COMPOUNDID',pkg_audit.fn_get_lov_value(:OLD.COMPOUNDID, pkg_audit.g_lov_compound),(CASE WHEN :new.ISACTIVE is null then null else pkg_audit.fn_get_lov_value(:NEW.COMPOUNDID, pkg_audit.g_lov_compound) end),v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);
 
 if v_auditid is not null then
 pkg_audit.sp_set_studyauditreportmap
  (v_auditid,v_studyid,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  end if;
  
  pkg_audit.sp_set_audit
  (v_studyid,'TBL_STUDY','NCTNUMBER',:OLD.NCTNUMBER,(CASE WHEN :new.ISACTIVE is null then null else :NEW.NCTNUMBER end),v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);
 
 if v_auditid is not null then
 pkg_audit.sp_set_studyauditreportmap
  (v_auditid,v_studyid,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  end if;
  
  pkg_audit.sp_set_audit
  (v_studyid,'TBL_STUDY','EUDRACTNUMBER',:OLD.EUDRACTNUMBER,(CASE WHEN :new.ISACTIVE is null then null else :NEW.EUDRACTNUMBER end),v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);
 
 if v_auditid is not null then
 pkg_audit.sp_set_studyauditreportmap
  (v_auditid,v_studyid,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  end if;
  
  pkg_audit.sp_set_audit
  (v_studyid,'TBL_STUDY','EXTSTUDYNUMBER',:OLD.EXTSTUDYNUMBER,(CASE WHEN :new.ISACTIVE is null then null else :NEW.EXTSTUDYNUMBER end),v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);
 
 if v_auditid is not null then
 pkg_audit.sp_set_studyauditreportmap
  (v_auditid,v_studyid,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  end if;
  
  pkg_audit.sp_set_audit
  (v_studyid,'TBL_STUDY','SPONCONTFIRSTNAME',:OLD.SPONCONTFIRSTNAME,(CASE WHEN :new.ISACTIVE is null then null else :NEW.SPONCONTFIRSTNAME end),v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);
 
 if v_auditid is not null then
 pkg_audit.sp_set_studyauditreportmap
  (v_auditid,v_studyid,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  end if;
  
  pkg_audit.sp_set_audit
  (v_studyid,'TBL_STUDY','SPONCONTLASTNAME',:OLD.SPONCONTLASTNAME,(CASE WHEN :new.ISACTIVE is null then null else :NEW.SPONCONTLASTNAME end),v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);
  
   if v_auditid is not null then
  pkg_audit.sp_set_studyauditreportmap
  (v_auditid,v_studyid,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  end if;
  
  if :OLD.PLANNEDSTARTDT is null AND :NEW.PLANNEDSTARTDT is not null then
  pkg_audit.sp_set_audit
  (v_studyid,'TBL_STUDY','PLANNEDSTARTDT',TO_CHAR(:OLD.PLANNEDSTARTDT,'DD-Mon-YYYY'),(CASE WHEN :new.ISACTIVE is null then null else TO_CHAR(:NEW.PLANNEDSTARTDT,'DD-Mon-YYYY') end),pkg_audit.g_operation_create,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);
  else
  pkg_audit.sp_set_audit
  (v_studyid,'TBL_STUDY','PLANNEDSTARTDT',TO_CHAR(:OLD.PLANNEDSTARTDT,'DD-Mon-YYYY'),(CASE WHEN :new.ISACTIVE is null then null else TO_CHAR(:NEW.PLANNEDSTARTDT,'DD-Mon-YYYY') end),v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);
  end if;
  
   if v_auditid is not null then
  pkg_audit.sp_set_studyauditreportmap
  (v_auditid,v_studyid,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  end if;
  
  pkg_audit.sp_set_audit
  (v_studyid,'TBL_STUDY','ACTUALSTARTDT',TO_CHAR(:OLD.ACTUALSTARTDT,'DD-Mon-YYYY'),(CASE WHEN :new.ISACTIVE is null then null else TO_CHAR(:NEW.ACTUALSTARTDT,'DD-Mon-YYYY') end),v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);
  
   if v_auditid is not null then
  pkg_audit.sp_set_studyauditreportmap
  (v_auditid,v_studyid,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  end if;
  
  if :OLD.PLANNEDENDDT is null AND :NEW.PLANNEDENDDT is not null then
  pkg_audit.sp_set_audit
  (v_studyid,'TBL_STUDY','PLANNEDENDDT',TO_CHAR(:OLD.PLANNEDENDDT,'DD-Mon-YYYY'),(CASE WHEN :new.ISACTIVE is null then null else TO_CHAR(:NEW.PLANNEDENDDT,'DD-Mon-YYYY') end),pkg_audit.g_operation_create,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);
  else
  pkg_audit.sp_set_audit
  (v_studyid,'TBL_STUDY','PLANNEDENDDT',TO_CHAR(:OLD.PLANNEDENDDT,'DD-Mon-YYYY'),(CASE WHEN :new.ISACTIVE is null then null else TO_CHAR(:NEW.PLANNEDENDDT,'DD-Mon-YYYY') end),v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);
  end if;
  
   if v_auditid is not null then
  pkg_audit.sp_set_studyauditreportmap
  (v_auditid,v_studyid,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  end if;
  
  pkg_audit.sp_set_audit
  (v_studyid,'TBL_STUDY','ACTUALENDDT',TO_CHAR(:OLD.ACTUALENDDT,'DD-Mon-YYYY'),(CASE WHEN :new.ISACTIVE is null then null else TO_CHAR(:NEW.ACTUALENDDT,'DD-Mon-YYYY') end),v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);
 
 if v_auditid is not null then
 pkg_audit.sp_set_studyauditreportmap
  (v_auditid,v_studyid,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  end if;
  
  pkg_audit.sp_set_audit
  (v_studyid,'TBL_STUDY','STUDYSTATUSCD',:OLD.STUDYSTATUSCD,(CASE WHEN :new.ISACTIVE is null then null else :NEW.STUDYSTATUSCD end),v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);
  
   if v_auditid is not null then
  pkg_audit.sp_set_studyauditreportmap
  (v_auditid,v_studyid,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  end if;
  
  pkg_audit.sp_set_audit
  (v_studyid,'TBL_STUDY','STUDYRECRUITMENTSTATUSCD',:OLD.STUDYRECRUITMENTSTATUSCD,(CASE WHEN :new.ISACTIVE is null then null else :NEW.STUDYRECRUITMENTSTATUSCD end),v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);
  
   if v_auditid is not null then
  pkg_audit.sp_set_studyauditreportmap
  (v_auditid,v_studyid,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  end if;
  
  pkg_audit.sp_set_audit
  (v_studyid,'TBL_STUDY','STUDYCANCELLATIONREASON',:OLD.STUDYCANCELLATIONREASON,(CASE WHEN :new.ISACTIVE is null then null else :NEW.STUDYCANCELLATIONREASON end),v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);
  
   if v_auditid is not null then
  pkg_audit.sp_set_studyauditreportmap
  (v_auditid,v_studyid,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  end if;
  
  pkg_audit.sp_set_audit
  (v_studyid,'TBL_STUDY','STUDYOVERALLSTSSTRTDT',TO_CHAR(:OLD.STUDYOVERALLSTSSTRTDT,'DD-Mon-YYYY'),(CASE WHEN :new.ISACTIVE is null then null else TO_CHAR(:NEW.STUDYOVERALLSTSSTRTDT,'DD-Mon-YYYY') end),v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);
  
   if v_auditid is not null then
  pkg_audit.sp_set_studyauditreportmap
  (v_auditid,v_studyid,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  end if;
  
  pkg_audit.sp_set_audit
  (v_studyid,'TBL_STUDY','STUDYOVERALLSTSSTPDT',TO_CHAR(:OLD.STUDYOVERALLSTSSTPDT,'DD-Mon-YYYY'),(CASE WHEN :new.ISACTIVE is null then null else TO_CHAR(:NEW.STUDYOVERALLSTSSTPDT,'DD-Mon-YYYY') end),v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);
 
 if v_auditid is not null then
 pkg_audit.sp_set_studyauditreportmap
  (v_auditid,v_studyid,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  end if;
  
  pkg_audit.sp_set_audit
  (v_studyid,'TBL_STUDY','REASONSTUDYSTOPPEDCD',:OLD.REASONSTUDYSTOPPEDCD,(CASE WHEN :new.ISACTIVE is null then null else :NEW.REASONSTUDYSTOPPEDCD end),v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);
  
   if v_auditid is not null then
  pkg_audit.sp_set_studyauditreportmap
  (v_auditid,v_studyid,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  end if;
  
  pkg_audit.sp_set_audit
  (v_studyid,'TBL_STUDY','OVERALLSTUDYSTATUSDESCRIPTION',:OLD.OVERALLSTUDYSTATUSDESCRIPTION,(CASE WHEN :new.ISACTIVE is null then null else :NEW.OVERALLSTUDYSTATUSDESCRIPTION end),v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);
 
 if v_auditid is not null then
 pkg_audit.sp_set_studyauditreportmap
  (v_auditid,v_studyid,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  end if;
  
  pkg_audit.sp_set_audit
  (v_studyid,'TBL_STUDY','OVERALLSTUDYSTATUSSTATECD',:OLD.OVERALLSTUDYSTATUSSTATECD,(CASE WHEN :new.ISACTIVE is null then null else :NEW.OVERALLSTUDYSTATUSSTATECD end),v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);
 
 if v_auditid is not null then
 pkg_audit.sp_set_studyauditreportmap
  (v_auditid,v_studyid,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  end if;
  
  pkg_audit.sp_set_audit
  (v_studyid,'TBL_STUDY','OVERALLSTUDYSTATUSSTATEDT',TO_CHAR(:OLD.OVERALLSTUDYSTATUSSTATEDT,'DD-Mon-YYYY'),(CASE WHEN :new.ISACTIVE is null then null else TO_CHAR(:NEW.OVERALLSTUDYSTATUSSTATEDT,'DD-Mon-YYYY') end),v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);
 
 if v_auditid is not null then
 pkg_audit.sp_set_studyauditreportmap
  (v_auditid,v_studyid,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  end if;
  
  pkg_audit.sp_set_audit
  (v_studyid,'TBL_STUDY','TRIALCLOSEOUTDT',TO_CHAR(:OLD.TRIALCLOSEOUTDT,'DD-Mon-YYYY'),(CASE WHEN :new.ISACTIVE is null then null else TO_CHAR(:NEW.TRIALCLOSEOUTDT,'DD-Mon-YYYY') end),v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);
  
   if v_auditid is not null then
  pkg_audit.sp_set_studyauditreportmap
  (v_auditid,v_studyid,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  end if;
  
  pkg_audit.sp_set_audit
  (v_studyid,'TBL_STUDY','TRIALCLOSEOUTREMDAYS',:OLD.TRIALCLOSEOUTREMDAYS,(CASE WHEN :new.ISACTIVE is null then null else :NEW.TRIALCLOSEOUTREMDAYS end),v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);
 
 if v_auditid is not null then
 pkg_audit.sp_set_studyauditreportmap
  (v_auditid,v_studyid,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  end if;
  
  pkg_audit.sp_set_audit
  (v_studyid,'TBL_STUDY','REASONSTUDYSTOPPED',:OLD.REASONSTUDYSTOPPED,(CASE WHEN :new.ISACTIVE is null then null else :NEW.REASONSTUDYSTOPPED end),v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);
  
   if v_auditid is not null then
  pkg_audit.sp_set_studyauditreportmap
  (v_auditid,v_studyid,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  end if;
  
  pkg_audit.sp_set_audit
  (v_studyid,'TBL_STUDY','STUDYRECSTATUSDT',TO_CHAR(:OLD.STUDYRECSTATUSDT,'DD-Mon-YYYY'),(CASE WHEN :new.ISACTIVE is null then null else TO_CHAR(:NEW.STUDYRECSTATUSDT,'DD-Mon-YYYY') end),v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);
  
   if v_auditid is not null then
  pkg_audit.sp_set_studyauditreportmap
  (v_auditid,v_studyid,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  end if;
  
  pkg_audit.sp_set_audit
  (v_studyid,'TBL_STUDY','ANTICIPATEDSTUDYCOMPLETIONDT',TO_CHAR(:OLD.ANTICIPATEDSTUDYCOMPLETIONDT,'DD-Mon-YYYY'),(CASE WHEN :new.ISACTIVE is null then null else TO_CHAR(:NEW.ANTICIPATEDSTUDYCOMPLETIONDT,'DD-Mon-YYYY') end),v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);
  
   if v_auditid is not null then
  pkg_audit.sp_set_studyauditreportmap
  (v_auditid,v_studyid,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  end if;
  
  pkg_audit.sp_set_audit
  (v_studyid,'TBL_STUDY','ACTUALSTUDYCOMPLETIONDT',TO_CHAR(:OLD.ACTUALSTUDYCOMPLETIONDT,'DD-Mon-YYYY'),(CASE WHEN :new.ISACTIVE is null then null else TO_CHAR(:NEW.ACTUALSTUDYCOMPLETIONDT,'DD-Mon-YYYY') end),v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);
 
 if v_auditid is not null then
 pkg_audit.sp_set_studyauditreportmap
  (v_auditid,v_studyid,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  end if;
  
  pkg_audit.sp_set_audit
  (v_studyid,'TBL_STUDY','ANTICIPATEDSTUDYCOMPFINALDT',TO_CHAR(:OLD.ANTICIPATEDSTUDYCOMPFINALDT,'DD-Mon-YYYY'),(CASE WHEN :new.ISACTIVE is null then null else TO_CHAR(:NEW.ANTICIPATEDSTUDYCOMPFINALDT,'DD-Mon-YYYY') end),v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);
  
   if v_auditid is not null then
  pkg_audit.sp_set_studyauditreportmap
  (v_auditid,v_studyid,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  end if;
  
  pkg_audit.sp_set_audit
  (v_studyid,'TBL_STUDY','ACTUALSTUDYCOMPFINALDT',TO_CHAR(:OLD.ACTUALSTUDYCOMPFINALDT,'DD-Mon-YYYY'),(CASE WHEN :new.ISACTIVE is null then null else TO_CHAR(:NEW.ACTUALSTUDYCOMPFINALDT,'DD-Mon-YYYY') end),v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);
  
   if v_auditid is not null then
  pkg_audit.sp_set_studyauditreportmap
  (v_auditid,v_studyid,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  end if;
  
  pkg_audit.sp_set_audit
  (v_studyid,'TBL_STUDY','ISACTIVE',:OLD.isactive,:NEW.isactive,v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);
  
   if v_auditid is not null then
  pkg_audit.sp_set_studyauditreportmap
  (v_auditid,v_studyid,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  end if;
  
  pkg_audit.sp_set_audit
  (v_studyid,'TBL_STUDY','ESTIMATEDSTUDYDURATION',:OLD.ESTIMATEDSTUDYDURATION,(CASE WHEN :new.ISACTIVE is null then null else :NEW.ESTIMATEDSTUDYDURATION end),v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);
  
   if v_auditid is not null then
  pkg_audit.sp_set_studyauditreportmap
  (v_auditid,v_studyid,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  end if;
  
  pkg_audit.sp_set_audit
  (v_studyid,'TBL_STUDY','ISCRFSUBMITTED',:OLD.ISCRFSUBMITTED,(CASE WHEN :new.ISACTIVE is null then null else :NEW.ISCRFSUBMITTED end),v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);
  
   if v_auditid is not null then
  pkg_audit.sp_set_studyauditreportmap
  (v_auditid,v_studyid,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  end if;
  
  pkg_audit.sp_set_audit
  (v_studyid,'TBL_STUDY','CRFSDESCRIPTIONUSED',:OLD.CRFSDESCRIPTIONUSED,(CASE WHEN :new.ISACTIVE is null then null else :NEW.CRFSDESCRIPTIONUSED end),v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);
 
 if v_auditid is not null then
 pkg_audit.sp_set_studyauditreportmap
  (v_auditid,v_studyid,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  end if;
  
  pkg_audit.sp_set_audit
  (v_studyid,'TBL_STUDY','CREATEDBY',:OLD.CREATEDBY,(CASE WHEN :new.ISACTIVE is null then null else :NEW.CREATEDBY end),v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);
 
 if v_auditid is not null then
 pkg_audit.sp_set_studyauditreportmap
  (v_auditid,v_studyid,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  end if;
  
  pkg_audit.sp_set_audit
  (v_studyid,'TBL_STUDY','CREATEDDT',TO_CHAR(:OLD.CREATEDDT,'DD-Mon-YYYY'),(CASE WHEN :new.ISACTIVE is null then null else TO_CHAR(:NEW.CREATEDDT,'DD-Mon-YYYY') end),v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);
 
 if v_auditid is not null then
 pkg_audit.sp_set_studyauditreportmap
  (v_auditid,v_studyid,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
 end if; 
  
  pkg_audit.sp_set_audit
  (v_studyid,'TBL_STUDY','MODIFIEDBY',:OLD.MODIFIEDBY,(CASE WHEN :new.ISACTIVE is null then null else :NEW.MODIFIEDBY end),v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);
  
   if v_auditid is not null then
  pkg_audit.sp_set_studyauditreportmap
  (v_auditid,v_studyid,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  end if;
  
  pkg_audit.sp_set_audit
  (v_studyid,'TBL_STUDY','MODIFIEDDT',TO_CHAR(:OLD.MODIFIEDDT,'DD-Mon-YYYY'),(CASE WHEN :new.ISACTIVE is null then null else TO_CHAR(:NEW.MODIFIEDDT,'DD-Mon-YYYY') end),v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);
 
 if v_auditid is not null then
 pkg_audit.sp_set_studyauditreportmap
  (v_auditid,v_studyid,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  end if;
  
  pkg_audit.sp_set_audit
  (v_studyid,'TBL_STUDY','ORGID',pkg_audit.fn_get_lov_value(:OLD.ORGID, pkg_audit.g_lov_organization),(CASE WHEN :new.ISACTIVE is null then null else pkg_audit.fn_get_lov_value(:NEW.ORGID, pkg_audit.g_lov_organization) end),v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);
  
   if v_auditid is not null then
  pkg_audit.sp_set_studyauditreportmap
  (v_auditid,v_studyid,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  end if;
  
  
  if :OLD.PLANNEDNEXTDATABASELOCK is null AND :NEW.PLANNEDNEXTDATABASELOCK is not null then
    pkg_audit.sp_set_audit
  (v_studyid,'TBL_STUDY','PLANNEDNEXTDATABASELOCK',TO_CHAR(:OLD.PLANNEDNEXTDATABASELOCK,'DD-Mon-YYYY'),(CASE WHEN :new.ISACTIVE is null then null else TO_CHAR(:NEW.PLANNEDNEXTDATABASELOCK,'DD-Mon-YYYY') end),pkg_audit.g_operation_create,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);
  else
    pkg_audit.sp_set_audit
  (v_studyid,'TBL_STUDY','PLANNEDNEXTDATABASELOCK',TO_CHAR(:OLD.PLANNEDNEXTDATABASELOCK,'DD-Mon-YYYY'),(CASE WHEN :new.ISACTIVE is null then null else TO_CHAR(:NEW.PLANNEDNEXTDATABASELOCK,'DD-Mon-YYYY') end),v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);
  end if;
  
   if v_auditid is not null then
  pkg_audit.sp_set_studyauditreportmap
  (v_auditid,v_studyid,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  end if;
  
  if :OLD.PLANNEDFINALDATABASELOCK is null AND :NEW.PLANNEDFINALDATABASELOCK is not null then
    pkg_audit.sp_set_audit
  (v_studyid,'TBL_STUDY','PLANNEDFINALDATABASELOCK',TO_CHAR(:OLD.PLANNEDFINALDATABASELOCK,'DD-Mon-YYYY'),(CASE WHEN :new.ISACTIVE is null then null else TO_CHAR(:NEW.PLANNEDFINALDATABASELOCK,'DD-Mon-YYYY') end),pkg_audit.g_operation_create,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);
  else
    pkg_audit.sp_set_audit
  (v_studyid,'TBL_STUDY','PLANNEDFINALDATABASELOCK',TO_CHAR(:OLD.PLANNEDFINALDATABASELOCK,'DD-Mon-YYYY'),(CASE WHEN :new.ISACTIVE is null then null else TO_CHAR(:NEW.PLANNEDFINALDATABASELOCK,'DD-Mon-YYYY') end),v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);
  end if;
 
 if v_auditid is not null then
 pkg_audit.sp_set_studyauditreportmap
  (v_auditid,v_studyid,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  end if;
  
 if :OLD.SUBJECTSPLANNED is null AND :NEW.SUBJECTSPLANNED is not null then
  pkg_audit.sp_set_audit
  (v_studyid,'TBL_STUDY','SUBJECTSPLANNED',:OLD.SUBJECTSPLANNED,(CASE WHEN :new.ISACTIVE is null then null else :NEW.SUBJECTSPLANNED end),pkg_audit.g_operation_create,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);
  else
  pkg_audit.sp_set_audit
  (v_studyid,'TBL_STUDY','SUBJECTSPLANNED',:OLD.SUBJECTSPLANNED,(CASE WHEN :new.ISACTIVE is null then null else :NEW.SUBJECTSPLANNED end),v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);
  end if;
 
 if v_auditid is not null then
 pkg_audit.sp_set_studyauditreportmap
  (v_auditid,v_studyid,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  end if;
  
  if :OLD.SUBJECTSENROLLED is null AND :NEW.SUBJECTSENROLLED is not null then
 pkg_audit.sp_set_audit
  (v_studyid,'TBL_STUDY','SUBJECTSENROLLED',:OLD.SUBJECTSENROLLED,(CASE WHEN :new.ISACTIVE is null then null else :NEW.SUBJECTSENROLLED end),pkg_audit.g_operation_create,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);
else
 pkg_audit.sp_set_audit
  (v_studyid,'TBL_STUDY','SUBJECTSENROLLED',:OLD.SUBJECTSENROLLED,(CASE WHEN :new.ISACTIVE is null then null else :NEW.SUBJECTSENROLLED end),v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);
end if;
 
 if v_auditid is not null then
 pkg_audit.sp_set_studyauditreportmap
  (v_auditid,v_studyid,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  end if;
  
  pkg_audit.sp_set_audit
  (v_studyid,'TBL_STUDY','ISCREATEDBYINTEGRATION',:OLD.ISCREATEDBYINTEGRATION,(CASE WHEN :new.ISACTIVE is null then null else :NEW.ISCREATEDBYINTEGRATION end),v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);
  
   if v_auditid is not null then
  pkg_audit.sp_set_studyauditreportmap
  (v_auditid,v_studyid,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  end if;

    pkg_audit.sp_set_audit
  (v_studyid,'TBL_STUDY','SIPSTUDYID',:OLD.SIPSTUDYID,(CASE WHEN :new.ISACTIVE is null then null else :NEW.SIPSTUDYID end),v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);
 
 if v_auditid is not null then
 pkg_audit.sp_set_studyauditreportmap
  (v_auditid,v_studyid,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  end if;
  
  pkg_audit.sp_set_audit
  (v_studyid,'TBL_STUDY','STUDYPHASE',pkg_audit.fn_get_lov_value(:OLD.STUDYPHASE, pkg_audit.g_lov_phaseofint),(CASE WHEN :new.ISACTIVE is null then null else pkg_audit.fn_get_lov_value(:NEW.STUDYPHASE, pkg_audit.g_lov_phaseofint) end),v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);
 
 if v_auditid is not null then
 pkg_audit.sp_set_studyauditreportmap
  (v_auditid,v_studyid,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  end if;
  
  pkg_audit.sp_set_audit
  (v_studyid,'TBL_STUDY','SIP_STUDYCLOSUREDATE',TO_CHAR(:OLD.SIP_STUDYCLOSUREDATE,'DD-Mon-YYYY'),(CASE WHEN :new.ISACTIVE is null then null else TO_CHAR(:NEW.SIP_STUDYCLOSUREDATE,'DD-Mon-YYYY') end),v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);
  
   if v_auditid is not null then
  pkg_audit.sp_set_studyauditreportmap
  (v_auditid,v_studyid,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  end if;
    
END trg_tbl_study_audit;
/