CREATE OR REPLACE TRIGGER TCSIP_CPORTAL.TRG_TBL_SURVEYRSPNSWR_AUDIT
AFTER INSERT OR UPDATE OR DELETE ON TCSIP_CPORTAL.TBL_SURVEYRESPONSEANSWER
FOR EACH ROW
DECLARE
v_operation tbl_audit.operation%TYPE;
v_auditid   tbl_audit.auditid%TYPE;
v_createdby tbl_audit.createdby%TYPE;
v_createddt tbl_audit.createddt%TYPE;
v_modifiedby tbl_audit.modifiedby%TYPE;
v_modifieddt tbl_audit.modifieddt%TYPE;
v_SURVEYRESPONSEANSID  TBL_SURVEYRESPONSEANSWER.SURVEYRESPONSEANSID%TYPE;
v_SURVEYRESPONSEID     TBL_SURVEYRESPONSEANSWER.SURVEYRESPONSEID%TYPE;
V_SURVEYANSWER         TBL_SURVEYRESPONSEANSWER.Surveyansid%TYPE;
V_SURVEYQUESTION         TBL_SURVEYRESPONSEANSWER.Surveyquesid%TYPE;
v_sysdate DATE:=SYSDATE;
BEGIN
  IF INSERTING THEN
    v_operation := pkg_audit.g_operation_create;
    v_createdby := :NEW.createdby;
    v_createddt := :NEW.createddt;
    v_modifiedby := :NEW.createdby;
    v_modifieddt := :NEW.createddt;
    v_SURVEYRESPONSEANSID := :NEW.SURVEYRESPONSEANSID;
    v_SURVEYRESPONSEID    := :NEW.SURVEYRESPONSEID;
    V_SURVEYANSWER        :=:NEW.Surveyansid;
    V_SURVEYQUESTION      :=:NEW.Surveyquesid;
  ELSIF UPDATING THEN
    v_operation := pkg_audit.g_operation_update;
    v_createdby := :NEW.modifiedby;
    v_createddt := :NEW.modifieddt;
    v_modifiedby := :NEW.modifiedby;
    v_modifieddt := :NEW.modifieddt;
    v_SURVEYRESPONSEANSID := :NEW.SURVEYRESPONSEANSID;
    v_SURVEYRESPONSEID    := :NEW.SURVEYRESPONSEID;
     V_SURVEYANSWER        :=:NEW.Surveyansid;
     V_SURVEYQUESTION      :=:NEW.Surveyquesid;
  ELSIF DELETING THEN
    v_operation := pkg_audit.g_operation_delete;
    v_createdby := :OLD.modifiedby;
    v_createddt := v_sysdate;
    v_modifiedby := :OLD.modifiedby;
    v_modifieddt := v_sysdate;
    v_SURVEYRESPONSEANSID := :OLD.SURVEYRESPONSEANSID;
    v_SURVEYRESPONSEID    := :OLD.SURVEYRESPONSEID;
    V_SURVEYANSWER        := :OLD.Surveyansid;
    V_SURVEYQUESTION      :=:OLD.Surveyquesid;
  END IF;

  pkg_audit.sp_set_audit
    (v_SURVEYRESPONSEANSID,'TBL_SURVEYRESPONSEANSWER','SURVEYRESPONSEANSID',:OLD.SURVEYRESPONSEANSID,:NEW.SURVEYRESPONSEANSID,v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

   if v_auditid is not null then
   FOR i IN (
          SELECT DISTINCT sc.studyid,sr.surveytitle,sc.belongto as surveyid
            FROM tbl_surveysipassociation sc,tbl_survey sr,Tbl_Surveyquestion RES,tbl_surveyanswer ans
      WHERE sc.belongto =sr.surveyid
      AND sc.istemplate = 0
      and RES.BELONGTO=sr.Surveyid
      and res.surveyquesid=ans.surveyansid
        AND res.surveyquesid =V_SURVEYQUESTION
            ) LOOP
  pkg_audit.sp_set_surveyauditreportmap
   (v_auditid,i.surveyid,i.surveytitle,i.studyid, null, v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  end loop;
  end if;

  pkg_audit.sp_set_audit
  (v_SURVEYRESPONSEANSID,'TBL_SURVEYRESPONSEANSWER','SURVEYQUESID',pkg_audit.fn_get_lov_value(:OLD.SURVEYQUESID, pkg_audit.g_lov_surveyquestion),pkg_audit.fn_get_lov_value(:NEW.SURVEYQUESID, pkg_audit.g_lov_surveyquestion),v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

  if v_auditid is not null then
   FOR i IN (
           SELECT DISTINCT sc.studyid,sr.surveytitle,sc.belongto as surveyid
            FROM tbl_surveysipassociation sc,tbl_survey sr,Tbl_Surveyquestion RES,tbl_surveyanswer ans
      WHERE sc.belongto =sr.surveyid
      AND sc.istemplate = 0
      and RES.BELONGTO=sr.Surveyid
      and res.surveyquesid=ans.surveyansid
        AND res.surveyquesid =V_SURVEYQUESTION
            ) LOOP
  pkg_audit.sp_set_surveyauditreportmap
   (v_auditid,i.surveyid,i.surveytitle,i.studyid, null, v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  end loop;
  end if;

    pkg_audit.sp_set_audit
  (v_SURVEYRESPONSEANSID,'TBL_SURVEYRESPONSEANSWER','SURVEYANSID',pkg_audit.fn_get_lov_value(:OLD.SURVEYANSID, pkg_audit.g_lov_surveyanswer),pkg_audit.fn_get_lov_value(:NEW.SURVEYANSID, pkg_audit.g_lov_surveyanswer),v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

      if v_auditid is not null then
   FOR i IN (
          SELECT DISTINCT sc.studyid,sr.surveytitle,sc.belongto as surveyid
            FROM tbl_surveysipassociation sc,tbl_survey sr,Tbl_Surveyquestion RES,tbl_surveyanswer ans
      WHERE sc.belongto =sr.surveyid
      AND sc.istemplate = 0
      and RES.BELONGTO=sr.Surveyid
      and res.surveyquesid=ans.surveyansid
        AND res.surveyquesid =V_SURVEYQUESTION
            ) LOOP
  pkg_audit.sp_set_surveyauditreportmap
   (v_auditid,i.surveyid,i.surveytitle,i.studyid, null, v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  end loop;
  end if;

     pkg_audit.sp_set_audit
  (v_SURVEYRESPONSEANSID,'TBL_SURVEYRESPONSEANSWER','ISFREETEXT',:OLD.ISFREETEXT,:NEW.ISFREETEXT,v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

 if v_auditid is not null then
   FOR i IN (
          SELECT DISTINCT sc.studyid,sr.surveytitle,sc.belongto as surveyid
            FROM tbl_surveysipassociation sc,tbl_survey sr,Tbl_Surveyquestion RES,tbl_surveyanswer ans
      WHERE sc.belongto =sr.surveyid
      AND sc.istemplate = 0
      and RES.BELONGTO=sr.Surveyid
      and res.surveyquesid=ans.surveyansid
        AND res.surveyquesid =V_SURVEYQUESTION
            ) LOOP
  pkg_audit.sp_set_surveyauditreportmap
   (v_auditid,i.surveyid,i.surveytitle,i.studyid, null, v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  end loop;
  end if;
  
     pkg_audit.sp_set_audit
  (v_SURVEYRESPONSEANSID,'TBL_SURVEYRESPONSEANSWER','CREATEDDT',TO_CHAR(:OLD.CREATEDDT, 'DD-MON-YYYY'), TO_CHAR(:NEW.CREATEDDT, 'DD-MON-YYYY'),v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

if v_auditid is not null then
   FOR i IN (
          SELECT DISTINCT sc.studyid,sr.surveytitle,sc.belongto as surveyid
            FROM tbl_surveysipassociation sc,tbl_survey sr,Tbl_Surveyquestion RES,tbl_surveyanswer ans
      WHERE sc.belongto =sr.surveyid
      AND sc.istemplate = 0
      and RES.BELONGTO=sr.Surveyid
      and res.surveyquesid=ans.surveyansid
        AND res.surveyquesid =V_SURVEYQUESTION
            ) LOOP
  pkg_audit.sp_set_surveyauditreportmap
   (v_auditid,i.surveyid,i.surveytitle,i.studyid, null, v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  end loop;
  end if;

     pkg_audit.sp_set_audit
  (v_SURVEYRESPONSEANSID,'TBL_SURVEYRESPONSEANSWER','CREATEDBY',:OLD.CREATEDBY,:NEW.CREATEDBY,v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

  if v_auditid is not null then
   FOR i IN (
         SELECT DISTINCT sc.studyid,sr.surveytitle,sc.belongto as surveyid
            FROM tbl_surveysipassociation sc,tbl_survey sr,Tbl_Surveyquestion RES,tbl_surveyanswer ans
      WHERE sc.belongto =sr.surveyid
      AND sc.istemplate = 0
      and RES.BELONGTO=sr.Surveyid
      and res.surveyquesid=ans.surveyansid
        AND res.surveyquesid =V_SURVEYQUESTION
            ) LOOP
  pkg_audit.sp_set_surveyauditreportmap
   (v_auditid,i.surveyid,i.surveytitle,i.studyid, null, v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  end loop;
  end if;

    pkg_audit.sp_set_audit
  (v_SURVEYRESPONSEANSID,'TBL_SURVEYRESPONSEANSWER','MODIFIEDDT',TO_CHAR(:OLD.modifieddt, 'DD-MON-YYYY'), TO_CHAR(:NEW.modifieddt, 'DD-MON-YYYY'),v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

  if v_auditid is not null then
   FOR i IN (
           SELECT DISTINCT sc.studyid,sr.surveytitle,sc.belongto as surveyid
            FROM tbl_surveysipassociation sc,tbl_survey sr,Tbl_Surveyquestion RES,tbl_surveyanswer ans
      WHERE sc.belongto =sr.surveyid
      AND sc.istemplate = 0
      and RES.BELONGTO=sr.Surveyid
      and res.surveyquesid=ans.surveyansid
        AND res.surveyquesid =V_SURVEYQUESTION
            ) LOOP
  pkg_audit.sp_set_surveyauditreportmap
   (v_auditid,i.surveyid,i.surveytitle,i.studyid, null, v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  end loop;
  end if;

    pkg_audit.sp_set_audit
  (v_SURVEYRESPONSEANSID,'TBL_SURVEYRESPONSEANSWER','MODIFIEDBY',:OLD.MODIFIEDBY,:NEW.MODIFIEDBY,v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

   if v_auditid is not null then
   FOR i IN (
          SELECT DISTINCT sc.studyid,sr.surveytitle,sc.belongto as surveyid
            FROM tbl_surveysipassociation sc,tbl_survey sr,Tbl_Surveyquestion RES,tbl_surveyanswer ans
      WHERE sc.belongto =sr.surveyid
      AND sc.istemplate = 0
      and RES.BELONGTO=sr.Surveyid
      and res.surveyquesid=ans.surveyansid
        AND res.surveyquesid =V_SURVEYQUESTION
            ) LOOP
  pkg_audit.sp_set_surveyauditreportmap
   (v_auditid,i.surveyid,i.surveytitle,i.studyid, null, v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  end loop;
  end if;

   pkg_audit.sp_set_audit
  (v_SURVEYRESPONSEANSID,'TBL_SURVEYRESPONSEANSWER','SURVEYRESPONSEID',:OLD.SURVEYRESPONSEID,:NEW.SURVEYRESPONSEID,v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

    if v_auditid is not null then
   FOR i IN (
           SELECT DISTINCT sc.studyid,sr.surveytitle,sc.belongto as surveyid
            FROM tbl_surveysipassociation sc,tbl_survey sr,Tbl_Surveyquestion RES,tbl_surveyanswer ans
      WHERE sc.belongto =sr.surveyid
      AND sc.istemplate = 0
      and RES.BELONGTO=sr.Surveyid
      and res.surveyquesid=ans.surveyansid
        AND res.surveyquesid =V_SURVEYQUESTION
            ) LOOP
  pkg_audit.sp_set_surveyauditreportmap
   (v_auditid,i.surveyid,i.surveytitle,i.studyid, null, v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  end loop;
  end if;

   pkg_audit.sp_set_audit
  (v_SURVEYRESPONSEANSID,'TBL_SURVEYRESPONSEANSWER','FREETEXT',:OLD.FREETEXT,:NEW.FREETEXT,v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

    if v_auditid is not null then
   FOR i IN (
          SELECT DISTINCT sc.studyid,sr.surveytitle,sc.belongto as surveyid
            FROM tbl_surveysipassociation sc,tbl_survey sr,Tbl_Surveyquestion RES,tbl_surveyanswer ans
      WHERE sc.belongto =sr.surveyid
      AND sc.istemplate = 0
      and RES.BELONGTO=sr.Surveyid
      and res.surveyquesid=ans.surveyansid
        AND res.surveyquesid =V_SURVEYQUESTION
            ) LOOP
  pkg_audit.sp_set_surveyauditreportmap
   (v_auditid,i.surveyid,i.surveytitle,i.studyid, null, v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  end loop;
  end if;

   pkg_audit.sp_set_audit
  (v_SURVEYRESPONSEANSID,'TBL_SURVEYRESPONSEANSWER','RANK',:OLD.RANK,:NEW.RANK,v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

    if v_auditid is not null then
   FOR i IN (
           SELECT DISTINCT sc.studyid,sr.surveytitle,sc.belongto as surveyid
            FROM tbl_surveysipassociation sc,tbl_survey sr,Tbl_Surveyquestion RES,tbl_surveyanswer ans
      WHERE sc.belongto =sr.surveyid
      AND sc.istemplate = 0
      and RES.BELONGTO=sr.Surveyid
      and res.surveyquesid=ans.surveyansid
        AND res.surveyquesid =V_SURVEYQUESTION
            ) LOOP
  pkg_audit.sp_set_surveyauditreportmap
   (v_auditid,i.surveyid,i.surveytitle,i.studyid, null, v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  end loop;
  end if;

END TRG_TBL_SURVEYRSPNSWR_AUDIT;
/