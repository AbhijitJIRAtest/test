CREATE OR REPLACE TRIGGER "TCSIP_CPORTAL"."TRG_TBL_SURVEYRESPONSE_AUDIT" 
AFTER INSERT OR UPDATE OR DELETE ON TCSIP_CPORTAL.TBL_SURVEYRESPONSE
FOR EACH ROW
DECLARE
v_operation tbl_audit.operation%TYPE;
v_auditid   tbl_audit.auditid%TYPE;
v_createdby tbl_audit.createdby%TYPE;
v_createddt tbl_audit.createddt%TYPE;
v_modifiedby tbl_audit.modifiedby%TYPE;
v_modifieddt tbl_audit.modifieddt%TYPE;
v_surveyresponseid  TBL_SURVEYRESPONSE.surveyresponseid%TYPE;
v_belongto  TBL_SURVEYRESPONSE.belongto%TYPE;
v_sysdate DATE:=SYSDATE;
v_lovvalue  TBL_SURVEY.SURVEYCD%TYPE;
BEGIN
  IF INSERTING THEN
    v_operation := pkg_audit.g_operation_create;
    v_createdby := :NEW.createdby;
    v_createddt := :NEW.createddt;
    v_modifiedby := :NEW.createdby;
    v_modifieddt := :NEW.createddt;
    v_surveyresponseid := :NEW.surveyresponseid;
    v_belongto:=:NEW.belongto;
    
  ELSIF UPDATING THEN
      v_operation := pkg_audit.g_operation_update;
    v_createdby := :NEW.modifiedby;
    v_createddt := :NEW.modifieddt;
    v_modifiedby := :NEW.modifiedby;
    v_modifieddt := :NEW.modifieddt;
  v_surveyresponseid := :NEW.surveyresponseid;
  v_belongto:=:NEW.belongto;
  ELSIF DELETING THEN
    v_operation := pkg_audit.g_operation_delete;
    v_createdby := :OLD.modifiedby;
    v_createddt := v_sysdate;
    v_modifiedby := :OLD.modifiedby;
    v_modifieddt := v_sysdate;
  v_surveyresponseid := :OLD.surveyresponseid;
  v_belongto:=:OLD.belongto;
  END IF;
 
  pkg_audit.sp_set_audit
    (v_surveyresponseid,'TBL_SURVEYRESPONSE','SURVEYRESPONSEID',:OLD.SURVEYRESPONSEID,:NEW.SURVEYRESPONSEID,v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

   if v_auditid is not null then
   FOR i IN (SELECT DISTINCT sc.studyid,sr.surveytitle,sc.belongto as surveyid
            FROM tbl_surveysipassociation sc,tbl_survey sr
      WHERE sc.belongto =sr.surveyid
      AND sc.istemplate = 0
            AND sc.belongto = v_belongto
            ) LOOP
  pkg_audit.sp_set_surveyauditreportmap
   (v_auditid,i.surveyid,i.surveytitle,i.studyid, null, v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  end loop;
  end if;

  pkg_audit.sp_set_audit
  (v_surveyresponseid,'TBL_SURVEYRESPONSE','BELONGTO',pkg_audit.fn_get_lov_value(:OLD.BELONGTO, pkg_audit.g_lov_surveycd),pkg_audit.fn_get_lov_value(:NEW.BELONGTO, pkg_audit.g_lov_surveycd),v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

   if v_auditid is not null then
   FOR i IN (SELECT DISTINCT sc.studyid,sr.surveytitle,sc.belongto as surveyid
            FROM tbl_surveysipassociation sc,tbl_survey sr
      WHERE sc.belongto =sr.surveyid
      AND sc.istemplate = 0
            AND sc.belongto = v_belongto
            ) LOOP
  pkg_audit.sp_set_surveyauditreportmap
   (v_auditid,i.surveyid,i.surveytitle,i.studyid, null, v_createddt,v_createdby,v_modifieddt,v_modifiedby);
   end loop;
  end if;

    pkg_audit.sp_set_audit
  (v_surveyresponseid,'TBL_SURVEYRESPONSE','SURVEYVERID',:OLD.SURVEYVERID,:NEW.SURVEYVERID,v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

   if v_auditid is not null then
   FOR i IN (SELECT DISTINCT sc.studyid,sr.surveytitle,sc.belongto as surveyid
            FROM tbl_surveysipassociation sc,tbl_survey sr
      WHERE sc.belongto =sr.surveyid
      AND sc.istemplate = 0
            AND sc.belongto = v_belongto
            ) LOOP
  pkg_audit.sp_set_surveyauditreportmap
   (v_auditid,i.surveyid,i.surveytitle,i.studyid, null, v_createddt,v_createdby,v_modifieddt,v_modifiedby);

   end loop;
   end if;

     pkg_audit.sp_set_audit
  (v_surveyresponseid,'TBL_SURVEYRESPONSE','RESPONSELISTID',:OLD.RESPONSELISTID,:NEW.RESPONSELISTID,v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

   if v_auditid is not null then
   FOR i IN (SELECT DISTINCT sc.studyid,sr.surveytitle,sc.belongto as surveyid
            FROM tbl_surveysipassociation sc,tbl_survey sr
      WHERE sc.belongto =sr.surveyid
      AND sc.istemplate = 0
            AND sc.belongto = v_belongto
            ) LOOP
  pkg_audit.sp_set_surveyauditreportmap
   (v_auditid,i.surveyid,i.surveytitle,i.studyid, null, v_createddt,v_createdby,v_modifieddt,v_modifiedby);

   end loop;
   end if;

     pkg_audit.sp_set_audit
  (v_surveyresponseid,'TBL_SURVEYRESPONSE','CREATEDDT',TO_CHAR(:OLD.createddt, 'DD-MON-YYYY'), TO_CHAR(:NEW.createddt, 'DD-MON-YYYY'),v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

   if v_auditid is not null then
   FOR i IN (SELECT DISTINCT sc.studyid,sr.surveytitle,sc.belongto as surveyid
            FROM tbl_surveysipassociation sc,tbl_survey sr
      WHERE sc.belongto =sr.surveyid
      AND sc.istemplate = 0
            AND sc.belongto = v_belongto
            ) LOOP
  pkg_audit.sp_set_surveyauditreportmap
   (v_auditid,i.surveyid,i.surveytitle,i.studyid, null, v_createddt,v_createdby,v_modifieddt,v_modifiedby);

   end loop;
   end if;

     pkg_audit.sp_set_audit
  (v_surveyresponseid,'TBL_SURVEYRESPONSE','CREATEDBY',:OLD.CREATEDBY,:NEW.CREATEDBY,v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

   if v_auditid is not null then
   FOR i IN (SELECT DISTINCT sc.studyid,sr.surveytitle,sc.belongto as surveyid

            FROM tbl_surveysipassociation sc,tbl_survey sr
      WHERE sc.belongto =sr.surveyid
      AND sc.istemplate = 0
            AND sc.belongto = v_belongto
            ) LOOP
  pkg_audit.sp_set_surveyauditreportmap
   (v_auditid,i.surveyid,i.surveytitle,i.studyid, null, v_createddt,v_createdby,v_modifieddt,v_modifiedby);

   end loop;
   end if;

    pkg_audit.sp_set_audit
  (v_surveyresponseid,'TBL_SURVEYRESPONSE','MODIFIEDDT',TO_CHAR(:OLD.modifieddt, 'DD-MON-YYYY'), TO_CHAR(:NEW.modifieddt, 'DD-MON-YYYY'),v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

   if v_auditid is not null then
   FOR i IN (SELECT DISTINCT sc.studyid,sr.surveytitle,sc.belongto as surveyid

            FROM tbl_surveysipassociation sc,tbl_survey sr
      WHERE sc.belongto =sr.surveyid
      AND sc.istemplate = 0
            AND sc.belongto = v_belongto
            ) LOOP
  pkg_audit.sp_set_surveyauditreportmap
   (v_auditid,i.surveyid,i.surveytitle,i.studyid, null, v_createddt,v_createdby,v_modifieddt,v_modifiedby);

   end loop;
   end if;

    pkg_audit.sp_set_audit
  (v_surveyresponseid,'TBL_SURVEYRESPONSE','MODIFIEDBY',:OLD.MODIFIEDBY,:NEW.MODIFIEDBY,v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

   if v_auditid is not null then
   FOR i IN (SELECT DISTINCT sc.studyid,sr.surveytitle,sc.belongto as surveyid

            FROM tbl_surveysipassociation sc,tbl_survey sr
      WHERE sc.belongto =sr.surveyid
      AND sc.istemplate = 0
            AND sc.belongto = v_belongto
            ) LOOP
  pkg_audit.sp_set_surveyauditreportmap
   (v_auditid,i.surveyid,i.surveytitle,i.studyid, null, v_createddt,v_createdby,v_modifieddt,v_modifiedby);
 end loop;
 end if;


END TRG_TBL_SURVEYRESPONSE_AUDIT;
/