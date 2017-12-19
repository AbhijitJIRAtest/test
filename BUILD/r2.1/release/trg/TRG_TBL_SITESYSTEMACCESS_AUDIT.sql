create or replace TRIGGER TRG_TBL_SITESYSTEMACCESS_AUDIT
AFTER INSERT OR UPDATE OR DELETE ON TBL_SITESYSTEMACCESS
FOR EACH ROW
DECLARE
v_operation tbl_audit.operation%TYPE;
v_auditid   tbl_audit.auditid%TYPE;
v_createdby tbl_audit.createdby%TYPE;
v_createddt tbl_audit.createddt%TYPE;
v_modifiedby tbl_audit.modifiedby%TYPE;
v_modifieddt tbl_audit.modifieddt%TYPE;
v_sitesystemaccessid  TBL_SITESYSTEMACCESS.SITESYSTEMACCESSID%TYPE;
v_studyid TBL_SITE.studyid%TYPE;
v_siteid TBL_SITE.studyid%TYPE;
v_sysdate DATE:=SYSDATE;
BEGIN
  IF INSERTING THEN
    v_operation := pkg_audit.g_operation_create;
    v_createdby := :NEW.createdby;
    v_createddt := :NEW.createddt;
    v_modifiedby := :NEW.createdby;
    v_modifieddt := :NEW.createddt;
    v_sitesystemaccessid := :NEW.SITESYSTEMACCESSID;
	v_siteid := :NEW.SITEID;
	
  ELSIF UPDATING THEN
    IF NVL(:OLD.ISACTIVE,'Y') <> NVL(:NEW.ISACTIVE,'Y') AND :NEW.ISACTIVE = 'N' THEN
      v_operation := pkg_audit.g_operation_delete;
    ELSE
      v_operation := pkg_audit.g_operation_update;
     END IF;
    v_sitesystemaccessid := :NEW.SITESYSTEMACCESSID;
    v_createdby := :NEW.modifiedby;
    v_createddt := :NEW.modifieddt;
    v_modifiedby := :NEW.modifiedby;
    v_modifieddt := :NEW.modifieddt;
	v_siteid := :NEW.SITEID;

  ELSIF DELETING THEN
    v_operation := pkg_audit.g_operation_delete;
    v_createdby := :OLD.modifiedby;
    v_createddt := v_sysdate;
    v_modifiedby := :OLD.modifiedby;
    v_modifieddt := v_sysdate;
    v_sitesystemaccessid := :OLD.SITESYSTEMACCESSID;
	v_siteid := :OLD.SITEID;

  END IF;

  SELECT studyid
  INTO v_studyid
  FROM tbl_site
  WHERE siteid = v_siteid;


  pkg_audit.sp_set_audit
    (v_sitesystemaccessid,'TBL_SITESYSTEMACCESS','SITESYSTEMACCESSID',:OLD.SITESYSTEMACCESSID,:NEW.SITESYSTEMACCESSID,v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

  if v_auditid is not null then
    pkg_audit.sp_set_studyauditreportmap
    (v_auditid,v_studyid,v_siteid,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  end if;

  pkg_audit.sp_set_audit
  (v_sitesystemaccessid,'TBL_SITESYSTEMACCESS','SITEID',pkg_audit.fn_get_lov_value(:OLD.SYSTEMID, pkg_audit.g_lov_access),pkg_audit.fn_get_lov_value(:NEW.SYSTEMID, pkg_audit.g_lov_access),v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

  if v_auditid is not null then
    pkg_audit.sp_set_studyauditreportmap
    (v_auditid,v_studyid,v_siteid,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  end if;


    pkg_audit.sp_set_audit
  (v_sitesystemaccessid,'TBL_SITESYSTEMACCESS','SYSTEMID',pkg_audit.fn_get_lov_value(:OLD.SYSTEMID, pkg_audit.g_lov_orgsysname),pkg_audit.fn_get_lov_value(:NEW.SYSTEMID, pkg_audit.g_lov_orgsysname),v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

  if v_auditid is not null then
    pkg_audit.sp_set_studyauditreportmap
    (v_auditid,v_studyid,v_siteid,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  end if;


      pkg_audit.sp_set_audit
  (v_sitesystemaccessid,'TBL_SITESYSTEMACCESS','ISACTIVE',:OLD.ISACTIVE,:NEW.ISACTIVE,v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

  if v_auditid is not null then
    pkg_audit.sp_set_studyauditreportmap
    (v_auditid,v_studyid,v_siteid,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  end if;

        pkg_audit.sp_set_audit
  (v_sitesystemaccessid,'TBL_SITESYSTEMACCESS','USERID',pkg_audit.fn_get_lov_value(:OLD.USERID,pkg_audit.g_lov_userprofile_user_flname),pkg_audit.fn_get_lov_value(:NEW.USERID, pkg_audit.g_lov_userprofile_user_flname),v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

  if v_auditid is not null then
    pkg_audit.sp_set_studyauditreportmap
    (v_auditid,v_studyid,v_siteid,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  end if;

        pkg_audit.sp_set_audit
  (v_sitesystemaccessid,'TBL_SITESYSTEMACCESS','REQUESTED_DATE',:OLD.REQUESTED_DATE,:NEW.REQUESTED_DATE,v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

  if v_auditid is not null then
    pkg_audit.sp_set_studyauditreportmap
    (v_auditid,v_studyid,v_siteid,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  end if;

  pkg_audit.sp_set_audit
    (v_sitesystemaccessid,'TBL_SITESYSTEMACCESS','CREATEDBY',:OLD.CREATEDBY,:NEW.CREATEDBY,v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

  if v_auditid is not null then
    pkg_audit.sp_set_studyauditreportmap
    (v_auditid,v_studyid,v_siteid,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  end if;

    pkg_audit.sp_set_audit
    (v_sitesystemaccessid,'TBL_SITESYSTEMACCESS','CREATEDDT',:OLD.CREATEDDT,:NEW.CREATEDDT,v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

  if v_auditid is not null then
    pkg_audit.sp_set_studyauditreportmap
    (v_auditid,v_studyid,v_siteid,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  end if;

    pkg_audit.sp_set_audit
    (v_sitesystemaccessid,'TBL_SITESYSTEMACCESS','MODIFIEDBY',:OLD.MODIFIEDBY,:NEW.MODIFIEDBY,v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

  if v_auditid is not null then
    pkg_audit.sp_set_studyauditreportmap
    (v_auditid,v_studyid,v_siteid,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  end if;

    pkg_audit.sp_set_audit
    (v_sitesystemaccessid,'TBL_SITESYSTEMACCESS','MODIFIEDDT',:OLD.MODIFIEDDT,:NEW.MODIFIEDDT,v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

  if v_auditid is not null then
    pkg_audit.sp_set_studyauditreportmap
    (v_auditid,v_studyid,v_siteid,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  end if;


END TRG_TBL_SITESYSTEMACCESS_AUDIT;

/