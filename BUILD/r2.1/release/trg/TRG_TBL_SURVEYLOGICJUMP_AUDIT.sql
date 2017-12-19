CREATE OR REPLACE TRIGGER TCSIP_CPORTAL.TRG_TBL_SURVEYLOGICJUMP_AUDIT
AFTER INSERT OR UPDATE OR DELETE ON TCSIP_CPORTAL.TBL_SURVEYLOGICJUMP
FOR EACH ROW
DECLARE
v_operation     tbl_audit.operation%TYPE;
v_auditid       tbl_audit.auditid%TYPE;
v_createdby     tbl_audit.createdby%TYPE;
v_createddt     tbl_audit.createddt%TYPE;
v_modifiedby    tbl_audit.modifiedby%TYPE;
v_modifieddt    tbl_audit.modifieddt%TYPE;
v_SURVEYQUESID  TBL_SURVEYLOGICJUMP.SURVEYQUESID%TYPE;
v_SURVEYLOGICID TBL_SURVEYLOGICJUMP.SURVEYLOGICID%TYPE;
v_SURVEYANSID   TBL_SURVEYLOGICJUMP.SURVEYANSID%TYPE;
v_sysdate DATE:=SYSDATE;
BEGIN
  IF INSERTING THEN
    v_operation := pkg_audit.g_operation_create;
    v_createdby := :NEW.createdby;
    v_createddt := :NEW.createddt;
    v_modifiedby := :NEW.createdby;
    v_modifieddt := :NEW.createddt;
    v_SURVEYQUESID:= :NEW.surveyquesid;
    v_SURVEYLOGICID :=:NEW.SURVEYLOGICID;
    v_SURVEYANSID   :=:NEW.Surveyansid;

  ELSIF UPDATING THEN
    v_operation := pkg_audit.g_operation_update;
    v_createdby := :NEW.modifiedby;
    v_createddt := :NEW.modifieddt;
    v_modifiedby := :NEW.modifiedby;
    v_modifieddt := :NEW.modifieddt;
    v_SURVEYQUESID:= :NEW.surveyquesid;
    v_SURVEYLOGICID :=:NEW.SURVEYLOGICID;
    v_SURVEYANSID   :=:NEW.Surveyansid;

 ELSIF DELETING THEN
    v_operation := pkg_audit.g_operation_delete;
    v_createdby := :OLD.modifiedby;
    v_createddt := :OLD.modifieddt;
    v_modifiedby := :OLD.modifiedby;
    v_modifieddt := :OLD.modifieddt;
    v_SURVEYQUESID:= :OLD.surveyquesid;
    v_SURVEYLOGICID :=:OLD.SURVEYLOGICID;
    v_SURVEYANSID   :=:OLD.Surveyansid;

  END IF;

  pkg_audit.sp_set_audit
  (v_SURVEYLOGICID,'TBL_SURVEYLOGICJUMP','SURVEYLOGICID',:OLD.SURVEYLOGICID,:NEW.SURVEYLOGICID,v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

if v_auditid is not null then
  FOR i IN (SELECT ts.surveyid,ts.surveytitle surveyname,NULL surveyrecipient,tssa.studyid
      FROM TCSIP_CPORTAL.tbl_surveysipassociation tssa,TCSIP_CPORTAL.tbl_surveyquestion tsu,tbl_surveyanswer suans,
      TCSIP_CPORTAL.tbl_survey ts
      WHERE ts.surveyid = tssa.belongto
      AND   tsu.BELONGTO=ts.SURVEYID
      AND   tssa.istemplate = 0
      AND   tsu.surveyquesid= suans.surveyquesid
      AND   suans.surveyansid=v_SURVEYANSID) LOOP
    pkg_audit.sp_set_surveyauditreportmap
    (v_auditid,i.surveyid,i.surveyname,i.studyid, i.surveyrecipient, v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  END LOOP;
  end if;

  pkg_audit.sp_set_audit
  (v_SURVEYLOGICID,'TBL_SURVEYLOGICJUMP','SURVEYLOGICDESC',:OLD.SURVEYLOGICDESC,:NEW.SURVEYLOGICDESC,v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

if v_auditid is not null then
   FOR i IN (SELECT ts.surveyid,ts.surveytitle surveyname,NULL surveyrecipient,tssa.studyid
      FROM TCSIP_CPORTAL.tbl_surveysipassociation tssa,TCSIP_CPORTAL.tbl_surveyquestion tsu,tbl_surveyanswer suans,
      TCSIP_CPORTAL.tbl_survey ts
      WHERE ts.surveyid = tssa.belongto
      AND   tsu.BELONGTO=ts.SURVEYID
      AND   tssa.istemplate = 0
      AND   tsu.surveyquesid= suans.surveyquesid
      AND   suans.surveyansid=v_SURVEYANSID) LOOP
    pkg_audit.sp_set_surveyauditreportmap
    (v_auditid,i.surveyid,i.surveyname,i.studyid, i.surveyrecipient, v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  END LOOP;
  end if;

  pkg_audit.sp_set_audit
  (v_SURVEYLOGICID,'TBL_SURVEYLOGICJUMP','SURVEYQUESID',:OLD.SURVEYQUESID,:NEW.SURVEYQUESID,v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

if v_auditid is not null then
  FOR i IN (SELECT ts.surveyid,ts.surveytitle surveyname,NULL surveyrecipient,tssa.studyid
      FROM TCSIP_CPORTAL.tbl_surveysipassociation tssa,TCSIP_CPORTAL.tbl_surveyquestion tsu,tbl_surveyanswer suans,
      TCSIP_CPORTAL.tbl_survey ts
      WHERE ts.surveyid = tssa.belongto
      AND   tsu.BELONGTO=ts.SURVEYID
      AND   tssa.istemplate = 0
      AND   tsu.surveyquesid= suans.surveyquesid
      AND   suans.surveyansid=v_SURVEYANSID) LOOP
    pkg_audit.sp_set_surveyauditreportmap
    (v_auditid,i.surveyid,i.surveyname,i.studyid, i.surveyrecipient, v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  END LOOP;
  end if;

   pkg_audit.sp_set_audit
  (v_SURVEYLOGICID,'TBL_SURVEYLOGICJUMP','SURVEYANSID',(CASE WHEN :OLD.SURVEYANSID IS NOT NULL THEN 'Y' ELSE 'N' END),(CASE WHEN :NEW.SURVEYANSID IS NOT NULL THEN 'Y' ELSE 'N' END),v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

if v_auditid is not null then
   FOR i IN (SELECT ts.surveyid,ts.surveytitle surveyname,NULL surveyrecipient,tssa.studyid
      FROM TCSIP_CPORTAL.tbl_surveysipassociation tssa,TCSIP_CPORTAL.tbl_surveyquestion tsu,tbl_surveyanswer suans,
      TCSIP_CPORTAL.tbl_survey ts
      WHERE ts.surveyid = tssa.belongto
      AND   tsu.BELONGTO=ts.SURVEYID
      AND   tssa.istemplate = 0
      AND   tsu.surveyquesid= suans.surveyquesid
      AND   suans.surveyansid=v_SURVEYANSID) LOOP
    pkg_audit.sp_set_surveyauditreportmap
    (v_auditid,i.surveyid,i.surveyname,i.studyid, i.surveyrecipient, v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  END LOOP;
  end if;

   pkg_audit.sp_set_audit
  (v_SURVEYLOGICID,'TBL_SURVEYLOGICJUMP','ISVISIBLE',(CASE WHEN :OLD.ISVISIBLE='1' THEN 'Y' ELSE 'N' END),(CASE WHEN :OLD.ISVISIBLE='1' THEN 'Y' ELSE 'N' END),v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

if v_auditid is not null then
    FOR i IN (SELECT ts.surveyid,ts.surveytitle surveyname,NULL surveyrecipient,tssa.studyid
      FROM TCSIP_CPORTAL.tbl_surveysipassociation tssa,TCSIP_CPORTAL.tbl_surveyquestion tsu,tbl_surveyanswer suans,
      TCSIP_CPORTAL.tbl_survey ts
      WHERE ts.surveyid = tssa.belongto
      AND   tsu.BELONGTO=ts.SURVEYID
      AND   tssa.istemplate = 0
      AND   tsu.surveyquesid= suans.surveyquesid
      AND   suans.surveyansid=v_SURVEYANSID) LOOP
    pkg_audit.sp_set_surveyauditreportmap
    (v_auditid,i.surveyid,i.surveyname,i.studyid, i.surveyrecipient, v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  END LOOP;
  end if;

   pkg_audit.sp_set_audit
  (v_SURVEYLOGICID,'TBL_SURVEYLOGICJUMP','ISREQUIRED',(CASE WHEN :OLD.ISREQUIRED='1' THEN 'Y' ELSE 'N' END),(CASE WHEN :OLD.ISREQUIRED='1' THEN 'Y' ELSE 'N' END),v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

if v_auditid is not null then
    FOR i IN (SELECT ts.surveyid,ts.surveytitle surveyname,NULL surveyrecipient,tssa.studyid
      FROM TCSIP_CPORTAL.tbl_surveysipassociation tssa,TCSIP_CPORTAL.tbl_surveyquestion tsu,tbl_surveyanswer suans,
      TCSIP_CPORTAL.tbl_survey ts
      WHERE ts.surveyid = tssa.belongto
      AND   tsu.BELONGTO=ts.SURVEYID
      AND   tssa.istemplate = 0
      AND   tsu.surveyquesid= suans.surveyquesid
      AND   suans.surveyansid=v_SURVEYANSID) LOOP
    pkg_audit.sp_set_surveyauditreportmap
    (v_auditid,i.surveyid,i.surveyname,i.studyid, i.surveyrecipient, v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  END LOOP;
  end if;

   pkg_audit.sp_set_audit
  (v_SURVEYLOGICID,'TBL_SURVEYLOGICJUMP','CREATEDDT',TO_CHAR(:OLD.createddt, 'DD-MON-YYYY'), TO_CHAR(:NEW.createddt, 'DD-MON-YYYY'),v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

if v_auditid is not null then
   FOR i IN (SELECT ts.surveyid,ts.surveytitle surveyname,NULL surveyrecipient,tssa.studyid
      FROM TCSIP_CPORTAL.tbl_surveysipassociation tssa,TCSIP_CPORTAL.tbl_surveyquestion tsu,tbl_surveyanswer suans,
      TCSIP_CPORTAL.tbl_survey ts
      WHERE ts.surveyid = tssa.belongto
      AND   tsu.BELONGTO=ts.SURVEYID
      AND   tssa.istemplate = 0
      AND   tsu.surveyquesid= suans.surveyquesid
      AND   suans.surveyansid=v_SURVEYANSID) LOOP
    pkg_audit.sp_set_surveyauditreportmap
    (v_auditid,i.surveyid,i.surveyname,i.studyid, i.surveyrecipient, v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  END LOOP;
  end if;

   pkg_audit.sp_set_audit
  (v_SURVEYLOGICID,'TBL_SURVEYLOGICJUMP','CREATEDBY',:OLD.CREATEDBY,:NEW.CREATEDBY,v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

if v_auditid is not null then
    FOR i IN (SELECT ts.surveyid,ts.surveytitle surveyname,NULL surveyrecipient,tssa.studyid
      FROM TCSIP_CPORTAL.tbl_surveysipassociation tssa,TCSIP_CPORTAL.tbl_surveyquestion tsu,tbl_surveyanswer suans,
      TCSIP_CPORTAL.tbl_survey ts
      WHERE ts.surveyid = tssa.belongto
      AND   tsu.BELONGTO=ts.SURVEYID
      AND   tssa.istemplate = 0
      AND   tsu.surveyquesid= suans.surveyquesid
      AND   suans.surveyansid=v_SURVEYANSID) LOOP
    pkg_audit.sp_set_surveyauditreportmap
    (v_auditid,i.surveyid,i.surveyname,i.studyid, i.surveyrecipient, v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  END LOOP;
  end if;

   pkg_audit.sp_set_audit
  (v_SURVEYLOGICID,'TBL_SURVEYLOGICJUMP','MODIFIEDDT',TO_CHAR(:OLD.MODIFIEDDT, 'DD-MON-YYYY'), TO_CHAR(:NEW.MODIFIEDDT, 'DD-MON-YYYY'),v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

if v_auditid is not null then
   FOR i IN (SELECT ts.surveyid,ts.surveytitle surveyname,NULL surveyrecipient,tssa.studyid
      FROM TCSIP_CPORTAL.tbl_surveysipassociation tssa,TCSIP_CPORTAL.tbl_surveyquestion tsu,tbl_surveyanswer suans,
      TCSIP_CPORTAL.tbl_survey ts
      WHERE ts.surveyid = tssa.belongto
      AND   tsu.BELONGTO=ts.SURVEYID
      AND   tssa.istemplate = 0
      AND   tsu.surveyquesid= suans.surveyquesid
      AND   suans.surveyansid=v_SURVEYANSID) LOOP
    pkg_audit.sp_set_surveyauditreportmap
    (v_auditid,i.surveyid,i.surveyname,i.studyid, i.surveyrecipient, v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  END LOOP;
  end if;

   pkg_audit.sp_set_audit
  (v_SURVEYLOGICID,'TBL_SURVEYLOGICJUMP','MODIFIEDBY',:OLD.MODIFIEDBY,:NEW.MODIFIEDBY,v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

if v_auditid is not null then
   FOR i IN (SELECT ts.surveyid,ts.surveytitle surveyname,NULL surveyrecipient,tssa.studyid
      FROM TCSIP_CPORTAL.tbl_surveysipassociation tssa,TCSIP_CPORTAL.tbl_surveyquestion tsu,tbl_surveyanswer suans,
      TCSIP_CPORTAL.tbl_survey ts
      WHERE ts.surveyid = tssa.belongto
      AND   tsu.BELONGTO=ts.SURVEYID
      AND   tssa.istemplate = 0
      AND   tsu.surveyquesid= suans.surveyquesid
      AND   suans.surveyansid=v_SURVEYANSID) LOOP
    pkg_audit.sp_set_surveyauditreportmap
    (v_auditid,i.surveyid,i.surveyname,i.studyid, i.surveyrecipient, v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  END LOOP;
  end if;

   pkg_audit.sp_set_audit
  (v_SURVEYLOGICID,'TBL_SURVEYLOGICJUMP','SURVEYELSESECTIONID',:OLD.SURVEYELSESECTIONID,:NEW.SURVEYELSESECTIONID,v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

if v_auditid is not null then
   FOR i IN (SELECT ts.surveyid,ts.surveytitle surveyname,NULL surveyrecipient,tssa.studyid
      FROM TCSIP_CPORTAL.tbl_surveysipassociation tssa,TCSIP_CPORTAL.tbl_surveyquestion tsu,tbl_surveyanswer suans,
      TCSIP_CPORTAL.tbl_survey ts
      WHERE ts.surveyid = tssa.belongto
      AND   tsu.BELONGTO=ts.SURVEYID
      AND   tssa.istemplate = 0
      AND   tsu.surveyquesid= suans.surveyquesid
      AND   suans.surveyansid=v_SURVEYANSID) LOOP
    pkg_audit.sp_set_surveyauditreportmap
    (v_auditid,i.surveyid,i.surveyname,i.studyid, i.surveyrecipient, v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  END LOOP;
  end if;


END TRG_TBL_SURVEYQUESTION_AUDIT;
/