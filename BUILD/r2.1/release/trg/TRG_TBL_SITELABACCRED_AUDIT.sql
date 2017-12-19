create or replace TRIGGER TRG_TBL_SITELABACCRED_AUDIT
AFTER INSERT OR UPDATE OR DELETE ON TBL_SITELABACCREDITATION
FOR EACH ROW
DECLARE
v_operation           TBL_AUDIT.operation%TYPE;
v_auditid             TBL_AUDIT.auditid%TYPE;
v_createdby           TBL_AUDIT.createdby%TYPE;
v_createddt           TBL_AUDIT.createddt%TYPE;
v_modifiedby          TBL_AUDIT.modifiedby%TYPE;
v_modifieddt          TBL_AUDIT.modifieddt%TYPE;
v_siteaccreditationid TBL_SITELABACCREDITATION.siteaccreditationid%TYPE;
v_sitelabid			  TBL_SITELABACCREDITATION.SITELABID%TYPE;
v_siteid              TBL_SITE.SITEID%TYPE;
v_studyid             TBL_SITE.STUDYID%TYPE;   
v_sysdate             DATE:=SYSDATE;

BEGIN
  IF INSERTING THEN
    v_operation 				:= pkg_audit.g_operation_create;
    v_createdby 				:= :NEW.createdby;
    v_createddt 				:= :NEW.createddt;
    v_modifiedby 				:= :NEW.createdby;
    v_modifieddt 				:= :NEW.createddt;
    v_siteaccreditationid 		:= :NEW.siteaccreditationid;
	v_sitelabid					:= :NEW.SITELABID;
  ELSIF UPDATING THEN
    v_operation 				:= pkg_audit.g_operation_update;
    v_createdby 				:= :NEW.modifiedby;
    v_createddt 				:= :NEW.modifieddt;
    v_modifiedby 				:= :NEW.modifiedby;
    v_modifieddt 				:= :NEW.modifieddt;
    v_siteaccreditationid 		:= :NEW.siteaccreditationid;
	v_sitelabid					:= :NEW.SITELABID;	
  ELSIF DELETING THEN
    v_operation 				:= pkg_audit.g_operation_delete;
    v_createdby 				:= :OLD.modifiedby;
    v_createddt 				:= v_sysdate;
    v_modifiedby 				:= :OLD.modifiedby;
    v_modifieddt 				:= v_sysdate;
	v_siteaccreditationid 		:= :OLD.siteaccreditationid;
	v_sitelabid					:= :OLD.SITELABID;

  END IF;

  select SITEID 
  INTO v_siteid 
  from TBL_SITELABMAP 
  where SITELABID = v_sitelabid ;

  SELECT studyid
  INTO v_studyid
  FROM tbl_site
  WHERE siteid = v_siteid;
  
  
  pkg_audit.sp_set_audit
    (v_siteaccreditationid,'TBL_SITELABACCREDITATION','SITEACCREDITATIONID',:OLD.siteaccreditationid,:NEW.siteaccreditationid,v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

    if v_auditid is not null then
  pkg_audit.sp_set_studyauditreportmap
  (v_auditid,v_studyid,v_siteid,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  end if;

	pkg_audit.sp_set_audit
    (v_siteaccreditationid,'TBL_SITELABACCREDITATION','SITELABID',:OLD.sitelabid,:NEW.sitelabid,v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

    if v_auditid is not null then
  pkg_audit.sp_set_studyauditreportmap
  (v_auditid,v_studyid,v_siteid,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  end if;

	pkg_audit.sp_set_audit
    (v_siteaccreditationid,'TBL_SITELABACCREDITATION','STATUS',:OLD.status,:NEW.status,v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

    if v_auditid is not null then
  pkg_audit.sp_set_studyauditreportmap
  (v_auditid,v_studyid,v_siteid,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  end if;

	pkg_audit.sp_set_audit
    (v_siteaccreditationid,'TBL_SITELABACCREDITATION','CREATEDBY',:OLD.createdby,:NEW.createdby,v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

    if v_auditid is not null then
  pkg_audit.sp_set_studyauditreportmap
  (v_auditid,v_studyid,v_siteid,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  end if;

  pkg_audit.sp_set_audit
    (v_siteaccreditationid,'TBL_STUDYCENTRALLAB','CREATEDDT',TO_CHAR(:OLD.createddt,'DD-MON-YYYY'),TO_CHAR(:NEW.createddt,'DD-MON-YYYY'),v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

    if v_auditid is not null then
  pkg_audit.sp_set_studyauditreportmap
  (v_auditid,v_studyid,v_siteid,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  end if;

  pkg_audit.sp_set_audit
    (v_siteaccreditationid,'TBL_SITELABACCREDITATION','MODIFIEDBY',:OLD.modifiedby,:NEW.modifiedby,v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

    if v_auditid is not null then
  pkg_audit.sp_set_studyauditreportmap
  (v_auditid,v_studyid,v_siteid,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  end if;

  pkg_audit.sp_set_audit
    (v_siteaccreditationid,'TBL_STUDYCENTRALLAB','MODIFIEDDT',TO_CHAR(:OLD.modifieddt,'DD-MON-YYYY'),TO_CHAR(:NEW.modifieddt,'DD-MON-YYYY'),v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

    if v_auditid is not null then
  pkg_audit.sp_set_studyauditreportmap
  (v_auditid,v_studyid,v_siteid,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  end if;

  pkg_audit.sp_set_audit
    (v_siteaccreditationid,'TBL_SITELABACCREDITATION','LABACCREDITATIONID',pkg_audit.fn_get_lov_value(:OLD.LABACCREDITATIONID, pkg_audit.g_lov_study),pkg_audit.fn_get_lov_value(:NEW.LABACCREDITATIONID, pkg_audit.g_lov_study),v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

    if v_auditid is not null then
  pkg_audit.sp_set_studyauditreportmap
  (v_auditid,v_studyid,v_siteid,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  end if;

  pkg_audit.sp_set_audit
    (v_siteaccreditationid,'TBL_SITELABACCREDITATION','OTHERLABACCREDITATION',:OLD.otherlabaccreditation,:NEW.otherlabaccreditation,v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

    if v_auditid is not null then
  pkg_audit.sp_set_studyauditreportmap
  (v_auditid,v_studyid,v_siteid,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  end if;


END TRG_TBL_SITELABACCRED_AUDIT;

/