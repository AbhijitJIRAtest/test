CREATE OR REPLACE TRIGGER TCSIP_CPORTAL.TRG_TBL_SURVEYANSWER_AUDIT
AFTER INSERT OR UPDATE OR DELETE ON TCSIP_CPORTAL.TBL_SURVEYANSWER
FOR EACH ROW
DECLARE
v_operation     tbl_audit.operation%TYPE;
v_auditid       tbl_audit.auditid%TYPE;
v_createdby     tbl_audit.createdby%TYPE;
v_createddt     tbl_audit.createddt%TYPE;
v_modifiedby    tbl_audit.modifiedby%TYPE;
v_modifieddt    tbl_audit.modifieddt%TYPE;
v_surveyansid   tbl_surveyanswer.surveyansid%TYPE;
v_surveyquesid  tbl_surveyanswer.SURVEYQUESID%TYPE;
v_sysdate DATE:=SYSDATE;
BEGIN
  IF INSERTING THEN
    v_operation := pkg_audit.g_operation_create;
    v_createdby := :NEW.createdby;
    v_createddt := :NEW.createddt;
    v_modifiedby := :NEW.createdby;
    v_modifieddt := :NEW.createddt;
    v_surveyansid:= :NEW.surveyansid;
    v_surveyquesid:=:NEW.SURVEYQUESID;
  ELSIF UPDATING THEN
    v_operation := pkg_audit.g_operation_update;
    v_createdby := :NEW.modifiedby;
    v_createddt := :NEW.modifieddt;
    v_modifiedby := :NEW.modifiedby;
    v_modifieddt := :NEW.modifieddt;
    v_surveyansid:= :NEW.surveyansid;
    v_surveyquesid:=:NEW.SURVEYQUESID;
  ELSIF DELETING THEN
    v_operation := pkg_audit.g_operation_delete;
    v_surveyansid:= :OLD.surveyansid;
    v_surveyquesid:=:OLD.SURVEYQUESID;
	v_createdby := pkg_audit.fn_get_del_createdby('TBL_SURVEYANSWER',v_surveyansid);
    v_createddt := pkg_audit.fn_get_del_createddt('TBL_SURVEYANSWER',v_surveyansid);
    v_modifiedby := pkg_audit.fn_get_del_createdby('TBL_SURVEYANSWER',v_surveyansid);
    v_modifieddt := pkg_audit.fn_get_del_createddt('TBL_SURVEYANSWER',v_surveyansid);
  END IF;

  pkg_audit.sp_set_audit
  (v_surveyansid,'TBL_SURVEYANSWER','SURVEYANSID',:OLD.SURVEYANSID,:NEW.SURVEYANSID,v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

  if v_auditid is not null then
  FOR i IN (SELECT tssa.belongto surveyid,ts.surveytitle surveyname,NULL surveyrecipient,tssa.studyid
			FROM TCSIP_CPORTAL.tbl_surveysipassociation tssa,
            TCSIP_CPORTAL.tbl_survey ts,
            TCSIP_CPORTAL.TBL_SURVEYQUESTION tsq
			WHERE ts.surveyid = tssa.belongto
			AND tsq.belongto = tssa.belongto
			AND tsq.istemplate = tssa.istemplate
			AND tssa.istemplate = 0
			AND tsq.surveyquesid = v_surveyquesid) LOOP
    pkg_audit.sp_set_surveyauditreportmap
	(v_auditid,i.surveyid,i.surveyname,i.studyid, i.surveyrecipient, v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  END LOOP;
  end if;

  pkg_audit.sp_set_audit
  (v_surveyansid,'TBL_SURVEYANSWER','SURVEYQUESID',pkg_audit.fn_get_lov_value(:OLD.SURVEYANSID, pkg_audit.g_lov_surveyans),pkg_audit.fn_get_lov_value(:NEW.SURVEYANSID, pkg_audit.g_lov_surveyans),v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

  if v_auditid is not null then
  FOR i IN (SELECT tssa.belongto surveyid,ts.surveytitle surveyname,NULL surveyrecipient,tssa.studyid
			FROM TCSIP_CPORTAL.tbl_surveysipassociation tssa,
            TCSIP_CPORTAL.tbl_survey ts,
            TCSIP_CPORTAL.TBL_SURVEYQUESTION tsq
			WHERE ts.surveyid = tssa.belongto
			AND tsq.belongto = tssa.belongto
			AND tsq.istemplate = tssa.istemplate
			AND tssa.istemplate = 0
			AND tsq.surveyquesid = v_surveyquesid) LOOP
    pkg_audit.sp_set_surveyauditreportmap
	(v_auditid,i.surveyid,i.surveyname,i.studyid, i.surveyrecipient, v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  END LOOP;
  end if;

  pkg_audit.sp_set_audit
  (v_surveyansid,'TBL_SURVEYANSWER','SURVEYANSTITLE',:OLD.SURVEYANSTITLE,:NEW.SURVEYANSTITLE,v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

  if v_auditid is not null then
  FOR i IN (SELECT tssa.belongto surveyid,ts.surveytitle surveyname,NULL surveyrecipient,tssa.studyid
			FROM TCSIP_CPORTAL.tbl_surveysipassociation tssa,
            TCSIP_CPORTAL.tbl_survey ts,
            TCSIP_CPORTAL.TBL_SURVEYQUESTION tsq
			WHERE ts.surveyid = tssa.belongto
			AND tsq.belongto = tssa.belongto
			AND tsq.istemplate = tssa.istemplate
			AND tssa.istemplate = 0
			AND tsq.surveyquesid = v_surveyquesid) LOOP
    pkg_audit.sp_set_surveyauditreportmap
	(v_auditid,i.surveyid,i.surveyname,i.studyid, i.surveyrecipient, v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  END LOOP;
  end if;

  pkg_audit.sp_set_audit
  (v_surveyansid,'TBL_SURVEYANSWER','ANSPOSITION',:OLD.ANSPOSITION,:NEW.ANSPOSITION,v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

  if v_auditid is not null then
  FOR i IN (SELECT tssa.belongto surveyid,ts.surveytitle surveyname,NULL surveyrecipient,tssa.studyid
			FROM TCSIP_CPORTAL.tbl_surveysipassociation tssa,
            TCSIP_CPORTAL.tbl_survey ts,
            TCSIP_CPORTAL.TBL_SURVEYQUESTION tsq
			WHERE ts.surveyid = tssa.belongto
			AND tsq.belongto = tssa.belongto
			AND tsq.istemplate = tssa.istemplate
			AND tssa.istemplate = 0
			AND tsq.surveyquesid = v_surveyquesid) LOOP
    pkg_audit.sp_set_surveyauditreportmap
	(v_auditid,i.surveyid,i.surveyname,i.studyid, i.surveyrecipient, v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  END LOOP;
  end if;

  pkg_audit.sp_set_audit
  (v_surveyansid,'TBL_SURVEYANSWER','SURVEYANSWEIGHTAGE',:OLD.SURVEYANSWEIGHTAGE,:NEW.SURVEYANSWEIGHTAGE,v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

  if v_auditid is not null then
  FOR i IN (SELECT tssa.belongto surveyid,ts.surveytitle surveyname,NULL surveyrecipient,tssa.studyid
			FROM TCSIP_CPORTAL.tbl_surveysipassociation tssa,
            TCSIP_CPORTAL.tbl_survey ts,
            TCSIP_CPORTAL.TBL_SURVEYQUESTION tsq
			WHERE ts.surveyid = tssa.belongto
			AND tsq.belongto = tssa.belongto
			AND tsq.istemplate = tssa.istemplate
			AND tssa.istemplate = 0
			AND tsq.surveyquesid = v_surveyquesid) LOOP
    pkg_audit.sp_set_surveyauditreportmap
	(v_auditid,i.surveyid,i.surveyname,i.studyid, i.surveyrecipient, v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  END LOOP;
  end if;

  pkg_audit.sp_set_audit
  (v_surveyansid,'TBL_SURVEYANSWER','CREATEDDT',TO_CHAR(:OLD.createddt, 'DD-MON-YYYY'), TO_CHAR(:NEW.createddt, 'DD-MON-YYYY'),v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

  if v_auditid is not null then
  FOR i IN (SELECT tssa.belongto surveyid,ts.surveytitle surveyname,NULL surveyrecipient,tssa.studyid
			FROM TCSIP_CPORTAL.tbl_surveysipassociation tssa,
            TCSIP_CPORTAL.tbl_survey ts,
            TCSIP_CPORTAL.TBL_SURVEYQUESTION tsq
			WHERE ts.surveyid = tssa.belongto
			AND tsq.belongto = tssa.belongto
			AND tsq.istemplate = tssa.istemplate
			AND tssa.istemplate = 0
			AND tsq.surveyquesid = v_surveyquesid) LOOP
    pkg_audit.sp_set_surveyauditreportmap
	(v_auditid,i.surveyid,i.surveyname,i.studyid, i.surveyrecipient, v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  END LOOP;
  end if;

  pkg_audit.sp_set_audit
  (v_surveyansid,'TBL_SURVEYANSWER','CREATEDBY',:OLD.CREATEDBY,:NEW.CREATEDBY,v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

  if v_auditid is not null then
  FOR i IN (SELECT tssa.belongto surveyid,ts.surveytitle surveyname,NULL surveyrecipient,tssa.studyid
			FROM TCSIP_CPORTAL.tbl_surveysipassociation tssa,
            TCSIP_CPORTAL.tbl_survey ts,
            TCSIP_CPORTAL.TBL_SURVEYQUESTION tsq
			WHERE ts.surveyid = tssa.belongto
			AND tsq.belongto = tssa.belongto
			AND tsq.istemplate = tssa.istemplate
			AND tssa.istemplate = 0
			AND tsq.surveyquesid = v_surveyquesid) LOOP
    pkg_audit.sp_set_surveyauditreportmap
	(v_auditid,i.surveyid,i.surveyname,i.studyid, i.surveyrecipient, v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  END LOOP;
  end if;

  pkg_audit.sp_set_audit
  (v_surveyansid,'TBL_SURVEYANSWER','MODIFIEDDT',TO_CHAR(:OLD.modifieddt, 'DD-MON-YYYY'), TO_CHAR(:NEW.modifieddt, 'DD-MON-YYYY'),v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

  if v_auditid is not null then
  FOR i IN (SELECT tssa.belongto surveyid,ts.surveytitle surveyname,NULL surveyrecipient,tssa.studyid
			FROM TCSIP_CPORTAL.tbl_surveysipassociation tssa,
            TCSIP_CPORTAL.tbl_survey ts,
            TCSIP_CPORTAL.TBL_SURVEYQUESTION tsq
			WHERE ts.surveyid = tssa.belongto
			AND tsq.belongto = tssa.belongto
			AND tsq.istemplate = tssa.istemplate
			AND tssa.istemplate = 0
			AND tsq.surveyquesid = v_surveyquesid) LOOP
    pkg_audit.sp_set_surveyauditreportmap
	(v_auditid,i.surveyid,i.surveyname,i.studyid, i.surveyrecipient, v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  END LOOP;
  end if;

  pkg_audit.sp_set_audit
  (v_surveyansid,'TBL_SURVEYANSWER','MODIFIEDBY',:OLD.MODIFIEDBY,:NEW.MODIFIEDBY,v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

  if v_auditid is not null then
  FOR i IN (SELECT tssa.belongto surveyid,ts.surveytitle surveyname,NULL surveyrecipient,tssa.studyid
			FROM TCSIP_CPORTAL.tbl_surveysipassociation tssa,
            TCSIP_CPORTAL.tbl_survey ts,
            TCSIP_CPORTAL.TBL_SURVEYQUESTION tsq
			WHERE ts.surveyid = tssa.belongto
			AND tsq.belongto = tssa.belongto
			AND tsq.istemplate = tssa.istemplate
			AND tssa.istemplate = 0
			AND tsq.surveyquesid = v_surveyquesid) LOOP
    pkg_audit.sp_set_surveyauditreportmap
	(v_auditid,i.surveyid,i.surveyname,i.studyid, i.surveyrecipient, v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  END LOOP;
  end if;

  pkg_audit.sp_set_audit
  (v_surveyansid,'TBL_SURVEYANSWER','ISCORRECT',:OLD.ISCORRECT,:NEW.ISCORRECT,v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

    if v_auditid is not null then
	FOR i IN (SELECT tssa.belongto surveyid,ts.surveytitle surveyname,NULL surveyrecipient,tssa.studyid
			FROM TCSIP_CPORTAL.tbl_surveysipassociation tssa,
            TCSIP_CPORTAL.tbl_survey ts,
            TCSIP_CPORTAL.TBL_SURVEYQUESTION tsq
			WHERE ts.surveyid = tssa.belongto
			AND tsq.belongto = tssa.belongto
			AND tsq.istemplate = tssa.istemplate
			AND tssa.istemplate = 0
			AND tsq.surveyquesid = v_surveyquesid) LOOP
    pkg_audit.sp_set_surveyauditreportmap
	(v_auditid,i.surveyid,i.surveyname,i.studyid, i.surveyrecipient, v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  END LOOP;
  end if;

   pkg_audit.sp_set_audit
  (v_surveyansid,'TBL_SURVEYANSWER','SURVEYANSTIER',:OLD.SURVEYANSTIER,:NEW.SURVEYANSTIER,v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

    if v_auditid is not null then
	FOR i IN (SELECT tssa.belongto surveyid,ts.surveytitle surveyname,NULL surveyrecipient,tssa.studyid
			FROM TCSIP_CPORTAL.tbl_surveysipassociation tssa,
            TCSIP_CPORTAL.tbl_survey ts,
            TCSIP_CPORTAL.TBL_SURVEYQUESTION tsq
			WHERE ts.surveyid = tssa.belongto
			AND tsq.belongto = tssa.belongto
			AND tsq.istemplate = tssa.istemplate
			AND tssa.istemplate = 0
			AND tsq.surveyquesid = v_surveyquesid) LOOP
    pkg_audit.sp_set_surveyauditreportmap
	(v_auditid,i.surveyid,i.surveyname,i.studyid, i.surveyrecipient, v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  END LOOP;
  end if;

  pkg_audit.sp_del_deletedrecords('TBL_SURVEYANSWER',v_surveyansid);

END TRG_TBL_SURVEYANSWER_AUDIT;
/