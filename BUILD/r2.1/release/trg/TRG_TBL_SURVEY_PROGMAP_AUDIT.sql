CREATE OR REPLACE TRIGGER TCSIP_CPORTAL.TRG_TBL_SURVEY_PROGMAP_AUDIT
AFTER INSERT OR UPDATE OR DELETE ON TCSIP_CPORTAL.TBL_SURVEY_PROGRAMMAP
FOR EACH ROW
DECLARE
v_operation tbl_audit.operation%TYPE;
v_auditid   tbl_audit.auditid%TYPE;
v_createdby tbl_audit.createdby%TYPE;
v_createddt tbl_audit.createddt%TYPE;
v_modifiedby tbl_audit.modifiedby%TYPE;
v_modifieddt tbl_audit.modifieddt%TYPE;
v_MAPID   TBL_SURVEY_PROGRAMMAP.MAPID%TYPE;
v_belongto TBL_SURVEY_PROGRAMMAP.BELONGTO%TYPE;
v_PROGRAMID TBL_SURVEY_PROGRAMMAP.PROGRAMID%TYPE;
v_sysdate DATE:=SYSDATE;
BEGIN
  IF INSERTING THEN
    v_operation        := pkg_audit.g_operation_create;
    v_createdby        := :NEW.createdby;
    v_createddt        := :NEW.createddt;
    v_modifiedby       := :NEW.createdby;
    v_modifieddt       := :NEW.createddt;
    v_MAPID            := :NEW.MAPID;
   v_belongto          := :NEW.belongto;
   v_PROGRAMID         := :NEW.PROGRAMID;

  ELSIF UPDATING THEN
      v_operation  := pkg_audit.g_operation_update;
    v_createdby    := :NEW.modifiedby;
    v_createddt    := :NEW.modifieddt;
    v_modifiedby   := :NEW.modifiedby;
    v_modifieddt   := :NEW.modifieddt;
     v_MAPID       := :NEW.MAPID;
   v_belongto      := :NEW.belongto;
   v_PROGRAMID     := :NEW.PROGRAMID;

  ELSIF DELETING THEN
    v_operation  := pkg_audit.g_operation_delete;
    v_createdby  := :OLD.modifiedby;
    v_createddt  := v_sysdate;
    v_modifiedby := :OLD.modifiedby;
    v_modifieddt := v_sysdate;
    v_MAPID      := :OLD.MAPID;
   v_belongto    := :OLD.belongto;
   v_PROGRAMID   := :OLD.PROGRAMID;

  END IF;

  pkg_audit.sp_set_audit
    (v_MAPID,'TBL_SURVEY_PROGRAMMAP','MAPID',:OLD.MAPID,:NEW.MAPID,v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

  if v_auditid is not null then
  FOR i IN (SELECT tssa.belongto surveyid, ts.surveytitle surveyname, tssa.studyid
            FROM TCSIP_CPORTAL.tbl_surveysipassociation tssa,
                 TCSIP_CPORTAL.tbl_survey ts
            WHERE ts.surveyid = tssa.belongto
            AND tssa.istemplate = 0
            AND tssa.belongto = v_belongto) LOOP
    pkg_audit.sp_set_surveyauditreportmap
	(v_auditid,i.surveyid,i.surveyname,i.studyid, NULL, v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  END LOOP;
  end if;

    pkg_audit.sp_set_audit
    (v_MAPID,'TBL_SURVEY_PROGRAMMAP','BELONGTO',pkg_audit.fn_get_lov_value(:OLD.BELONGTO, pkg_audit.g_lov_survey_id),pkg_audit.fn_get_lov_value(:NEW.BELONGTO, pkg_audit.g_lov_survey_id),v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

  if v_auditid is not null then
  FOR i IN (SELECT tssa.belongto surveyid, ts.surveytitle surveyname, tssa.studyid
            FROM TCSIP_CPORTAL.tbl_surveysipassociation tssa,
                 TCSIP_CPORTAL.tbl_survey ts
            WHERE ts.surveyid = tssa.belongto
            AND tssa.istemplate = 0
            AND tssa.belongto = v_belongto) LOOP
    pkg_audit.sp_set_surveyauditreportmap
	(v_auditid,i.surveyid,i.surveyname,i.studyid, NULL, v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  END LOOP;
  end if;

    pkg_audit.sp_set_audit
    (v_MAPID,'TBL_SURVEY_PROGRAMMAP','ISTEMPLATE',:OLD.ISTEMPLATE,:NEW.ISTEMPLATE,v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

  if v_auditid is not null then
  FOR i IN (SELECT tssa.belongto surveyid, ts.surveytitle surveyname, tssa.studyid
            FROM TCSIP_CPORTAL.tbl_surveysipassociation tssa,
                 TCSIP_CPORTAL.tbl_survey ts
            WHERE ts.surveyid = tssa.belongto
            AND tssa.istemplate = 0
            AND tssa.belongto = v_belongto) LOOP
    pkg_audit.sp_set_surveyauditreportmap
	(v_auditid,i.surveyid,i.surveyname,i.studyid, NULL, v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  END LOOP;
  end if;

    pkg_audit.sp_set_audit
    (v_MAPID,'TBL_SURVEY_PROGRAMMAP','PROGRAMID',pkg_audit.fn_get_lov_value(:OLD.PROGRAMID, pkg_audit.g_lov_program),pkg_audit.fn_get_lov_value(:NEW.PROGRAMID, pkg_audit.g_lov_program),v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

  if v_auditid is not null then
  FOR i IN (SELECT tssa.belongto surveyid, ts.surveytitle surveyname, tssa.studyid
            FROM TCSIP_CPORTAL.tbl_surveysipassociation tssa,
                 TCSIP_CPORTAL.tbl_survey ts
            WHERE ts.surveyid = tssa.belongto
            AND tssa.istemplate = 0
            AND tssa.belongto = v_belongto) LOOP
    pkg_audit.sp_set_surveyauditreportmap
	(v_auditid,i.surveyid,i.surveyname,i.studyid, NULL, v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  END LOOP;
  end if;

   pkg_audit.sp_set_audit
  (v_mapid,'TBL_SURVEY_COMPOUNDMAP','CREATEDDT',TO_CHAR(:OLD.createddt, 'DD-MON-YYYY'), TO_CHAR(:NEW.createddt, 'DD-MON-YYYY'),v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

  if v_auditid is not null then
  FOR i IN (SELECT tssa.belongto surveyid, ts.surveytitle surveyname, tssa.studyid
            FROM TCSIP_CPORTAL.tbl_surveysipassociation tssa,
                 TCSIP_CPORTAL.tbl_survey ts
            WHERE ts.surveyid = tssa.belongto
            AND tssa.istemplate = 0
            AND tssa.belongto = v_belongto) LOOP
    pkg_audit.sp_set_surveyauditreportmap
	(v_auditid,i.surveyid,i.surveyname,i.studyid, NULL, v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  END LOOP;
  end if;


	   pkg_audit.sp_set_audit
  (v_mapid,'TBL_SURVEY_COMPOUNDMAP','CREATEDBY',:OLD.CREATEDBY,:NEW.CREATEDBY,v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

  if v_auditid is not null then
  FOR i IN (SELECT tssa.belongto surveyid, ts.surveytitle surveyname, tssa.studyid
            FROM TCSIP_CPORTAL.tbl_surveysipassociation tssa,
                 TCSIP_CPORTAL.tbl_survey ts
            WHERE ts.surveyid = tssa.belongto
            AND tssa.istemplate = 0
            AND tssa.belongto = v_belongto) LOOP
    pkg_audit.sp_set_surveyauditreportmap
	(v_auditid,i.surveyid,i.surveyname,i.studyid, NULL, v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  END LOOP;
  end if;


   pkg_audit.sp_set_audit
  (v_mapid,'TBL_SURVEY_COMPOUNDMAP','MODIFIEDDT',TO_CHAR(:OLD.modifieddt, 'DD-MON-YYYY'), TO_CHAR(:NEW.modifieddt, 'DD-MON-YYYY'),v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

  if v_auditid is not null then
  FOR i IN (SELECT tssa.belongto surveyid, ts.surveytitle surveyname, tssa.studyid
            FROM TCSIP_CPORTAL.tbl_surveysipassociation tssa,
                 TCSIP_CPORTAL.tbl_survey ts
            WHERE ts.surveyid = tssa.belongto
            AND tssa.istemplate = 0
            AND tssa.belongto = v_belongto) LOOP
    pkg_audit.sp_set_surveyauditreportmap
	(v_auditid,i.surveyid,i.surveyname,i.studyid, NULL, v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  END LOOP;
  end if;


     pkg_audit.sp_set_audit
  (v_mapid,'TBL_SURVEY_COMPOUNDMAP','MODIFIEDBY',:OLD.MODIFIEDBY,:NEW.MODIFIEDBY,v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

  if v_auditid is not null then
  FOR i IN (SELECT tssa.belongto surveyid, ts.surveytitle surveyname, tssa.studyid
            FROM TCSIP_CPORTAL.tbl_surveysipassociation tssa,
                 TCSIP_CPORTAL.tbl_survey ts
            WHERE ts.surveyid = tssa.belongto
            AND tssa.istemplate = 0
            AND tssa.belongto = v_belongto) LOOP
    pkg_audit.sp_set_surveyauditreportmap
	(v_auditid,i.surveyid,i.surveyname,i.studyid, NULL, v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  END LOOP;
  end if;

END TRG_TBL_SURVEY_PROGMAP_AUDIT;
/
