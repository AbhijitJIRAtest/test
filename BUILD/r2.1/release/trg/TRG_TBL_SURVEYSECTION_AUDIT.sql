CREATE OR REPLACE TRIGGER TCSIP_CPORTAL.TRG_TBL_SURVEYSECTION_AUDIT
AFTER INSERT OR UPDATE OR DELETE ON TCSIP_CPORTAL.TBL_SURVEYSECTION
FOR EACH ROW
DECLARE
v_operation     tbl_audit.operation%TYPE;
v_auditid       tbl_audit.auditid%TYPE;
v_createdby     tbl_audit.createdby%TYPE;
v_createddt     tbl_audit.createddt%TYPE;
v_modifiedby    tbl_audit.modifiedby%TYPE;
v_modifieddt    tbl_audit.modifieddt%TYPE;
v_surveysectionid  tbl_surveysection.surveysectionid%TYPE;
v_belongto  TBL_SURVEYSECTION.belongto%TYPE;
v_istemplate  TBL_SURVEYSECTION.istemplate%TYPE;
v_sysdate DATE:=SYSDATE;
BEGIN
  IF INSERTING THEN
    v_operation := pkg_audit.g_operation_create;
    v_createdby := :NEW.createdby;
    v_createddt := :NEW.createddt;
    v_modifiedby := :NEW.createdby;
    v_modifieddt := :NEW.createddt;
    v_surveysectionid:= :NEW.surveysectionid;
    v_belongto:=:NEW.belongto;
    v_istemplate:=:NEW.istemplate;
  ELSIF UPDATING THEN
    v_operation := pkg_audit.g_operation_update;
    v_createdby := :NEW.modifiedby;
    v_createddt := :NEW.modifieddt;
    v_modifiedby := :NEW.modifiedby;
    v_modifieddt := :NEW.modifieddt;
    v_surveysectionid:= :NEW.surveysectionid;
    v_belongto:=:NEW.belongto;
    v_istemplate:=:NEW.istemplate;
  ELSIF DELETING THEN
    v_operation := pkg_audit.g_operation_delete;
    v_createdby := :OLD.modifiedby;
    v_createddt := v_sysdate;
    v_modifiedby := :OLD.modifiedby;
    v_modifieddt := v_sysdate;
    v_surveysectionid:= :OLD.surveysectionid;
    v_belongto:=:OLD.belongto;
    v_istemplate:=:OLD.istemplate;
  END IF;

  pkg_audit.sp_set_audit
  (v_surveysectionid,'TBL_SURVEYSECTION','SURVEYSECTIONID',:OLD.SURVEYSECTIONID,:NEW.SURVEYSECTIONID,v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

  if v_auditid is not null then
  FOR i IN (SELECT tssa.belongto surveyid, ts.surveytitle surveyname, tssa.studyid
            FROM TCSIP_CPORTAL.tbl_surveysipassociation tssa,
                 TCSIP_CPORTAL.tbl_survey ts
            WHERE ts.surveyid = tssa.belongto
            AND tssa.istemplate = 0
            AND tssa.istemplate = v_istemplate
            AND tssa.belongto = v_belongto) LOOP
    pkg_audit.sp_set_surveyauditreportmap
    (v_auditid,i.surveyid,i.surveyname,i.studyid, null, v_createddt,v_createdby,v_modifieddt,v_modifiedby);
    end loop;
	end if;


    pkg_audit.sp_set_audit
  (v_surveysectionid,'TBL_SURVEYSECTION','SECTIONTITLE',:OLD.SECTIONTITLE,:NEW.SECTIONTITLE,v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

  if v_auditid is not null then
  FOR i IN (SELECT tssa.belongto surveyid, ts.surveytitle surveyname, tssa.studyid
            FROM TCSIP_CPORTAL.tbl_surveysipassociation tssa,
                 TCSIP_CPORTAL.tbl_survey ts
            WHERE ts.surveyid = tssa.belongto
            AND tssa.istemplate = 0
            AND tssa.istemplate = v_istemplate
            AND tssa.belongto = v_belongto) LOOP
    pkg_audit.sp_set_surveyauditreportmap
    (v_auditid,i.surveyid,i.surveyname,i.studyid, null, v_createddt,v_createdby,v_modifieddt,v_modifiedby);
    end loop;
	end if;


    pkg_audit.sp_set_audit
  (v_surveysectionid,'TBL_SURVEYSECTION','BELONGTO',:OLD.BELONGTO,:NEW.BELONGTO,v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

  if v_auditid is not null then
  FOR i IN (SELECT tssa.belongto surveyid, ts.surveytitle surveyname, tssa.studyid
            FROM TCSIP_CPORTAL.tbl_surveysipassociation tssa,
                 TCSIP_CPORTAL.tbl_survey ts
            WHERE ts.surveyid = tssa.belongto
            AND tssa.istemplate = 0
            AND tssa.istemplate = v_istemplate
            AND tssa.belongto = v_belongto) LOOP
    pkg_audit.sp_set_surveyauditreportmap
    (v_auditid,i.surveyid,i.surveyname,i.studyid, null, v_createddt,v_createdby,v_modifieddt,v_modifiedby);
    end loop;
	end if;


    pkg_audit.sp_set_audit
  (v_surveysectionid,'TBL_SURVEYSECTION','CREATEDDT',TO_CHAR(:OLD.createddt, 'DD-MON-YYYY'), TO_CHAR(:NEW.createddt, 'DD-MON-YYYY'),v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

  if v_auditid is not null then
  FOR i IN (SELECT tssa.belongto surveyid, ts.surveytitle surveyname, tssa.studyid
            FROM TCSIP_CPORTAL.tbl_surveysipassociation tssa,
                 TCSIP_CPORTAL.tbl_survey ts
            WHERE ts.surveyid = tssa.belongto
            AND tssa.istemplate = 0
            AND tssa.istemplate = v_istemplate
            AND tssa.belongto = v_belongto) LOOP
    pkg_audit.sp_set_surveyauditreportmap
    (v_auditid,i.surveyid,i.surveyname,i.studyid, null, v_createddt,v_createdby,v_modifieddt,v_modifiedby);
    end loop;
	end if;

    pkg_audit.sp_set_audit
  (v_surveysectionid,'TBL_SURVEYSECTION','CREATEDBY',:OLD.CREATEDBY,:NEW.CREATEDBY,v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

  if v_auditid is not null then
  FOR i IN (SELECT tssa.belongto surveyid, ts.surveytitle surveyname, tssa.studyid
            FROM TCSIP_CPORTAL.tbl_surveysipassociation tssa,
                 TCSIP_CPORTAL.tbl_survey ts
            WHERE ts.surveyid = tssa.belongto
            AND tssa.istemplate = 0
            AND tssa.istemplate = v_istemplate
            AND tssa.belongto = v_belongto) LOOP
    pkg_audit.sp_set_surveyauditreportmap
    (v_auditid,i.surveyid,i.surveyname,i.studyid, null, v_createddt,v_createdby,v_modifieddt,v_modifiedby);
    end loop;
	end if;

    pkg_audit.sp_set_audit
  (v_surveysectionid,'TBL_SURVEYSECTION','MODIFIEDDT',TO_CHAR(:OLD.modifieddt, 'DD-MON-YYYY'), TO_CHAR(:NEW.modifieddt, 'DD-MON-YYYY'),v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

  if v_auditid is not null then
  FOR i IN (SELECT tssa.belongto surveyid, ts.surveytitle surveyname, tssa.studyid
            FROM TCSIP_CPORTAL.tbl_surveysipassociation tssa,
                 TCSIP_CPORTAL.tbl_survey ts
            WHERE ts.surveyid = tssa.belongto
            AND tssa.istemplate = 0
            AND tssa.istemplate = v_istemplate
            AND tssa.belongto = v_belongto) LOOP
    pkg_audit.sp_set_surveyauditreportmap
    (v_auditid,i.surveyid,i.surveyname,i.studyid, null, v_createddt,v_createdby,v_modifieddt,v_modifiedby);
    end loop;
	end if;


    pkg_audit.sp_set_audit
  (v_surveysectionid,'TBL_SURVEYSECTION','MODIFIEDBY',:OLD.MODIFIEDBY,:NEW.MODIFIEDBY,v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

  if v_auditid is not null then
  FOR i IN (SELECT tssa.belongto surveyid, ts.surveytitle surveyname, tssa.studyid
            FROM TCSIP_CPORTAL.tbl_surveysipassociation tssa,
                 TCSIP_CPORTAL.tbl_survey ts
            WHERE ts.surveyid = tssa.belongto
            AND tssa.istemplate = 0
            AND tssa.istemplate = v_istemplate
            AND tssa.belongto = v_belongto) LOOP
    pkg_audit.sp_set_surveyauditreportmap
    (v_auditid,i.surveyid,i.surveyname,i.studyid, null, v_createddt,v_createdby,v_modifieddt,v_modifiedby);
    end loop;
	end if;

    pkg_audit.sp_set_audit
  (v_surveysectionid,'TBL_SURVEYSECTION','ISTEMPLATE',:OLD.ISTEMPLATE,:NEW.ISTEMPLATE,v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

  if v_auditid is not null then
  FOR i IN (SELECT tssa.belongto surveyid, ts.surveytitle surveyname, tssa.studyid
            FROM TCSIP_CPORTAL.tbl_surveysipassociation tssa,
                 TCSIP_CPORTAL.tbl_survey ts
            WHERE ts.surveyid = tssa.belongto
            AND tssa.istemplate = 0
            AND tssa.istemplate = v_istemplate
            AND tssa.belongto = v_belongto) LOOP
    pkg_audit.sp_set_surveyauditreportmap
    (v_auditid,i.surveyid,i.surveyname,i.studyid, null, v_createddt,v_createdby,v_modifieddt,v_modifiedby);
    end loop;
	end if;


    pkg_audit.sp_set_audit
  (v_surveysectionid,'TBL_SURVEYSECTION','ISDELEGATED',:OLD.ISDELEGATED,:NEW.ISDELEGATED,v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

  if v_auditid is not null then
  FOR i IN (SELECT tssa.belongto surveyid, ts.surveytitle surveyname, tssa.studyid
            FROM TCSIP_CPORTAL.tbl_surveysipassociation tssa,
                 TCSIP_CPORTAL.tbl_survey ts
            WHERE ts.surveyid = tssa.belongto
            AND tssa.istemplate = 0
            AND tssa.istemplate = v_istemplate
            AND tssa.belongto = v_belongto) LOOP
    pkg_audit.sp_set_surveyauditreportmap
    (v_auditid,i.surveyid,i.surveyname,i.studyid, null, v_createddt,v_createdby,v_modifieddt,v_modifiedby);
    end loop;
	end if;

    pkg_audit.sp_set_audit
  (v_surveysectionid,'TBL_SURVEYSECTION','PARENTSECTIONID',:OLD.PARENTSECTIONID,:NEW.PARENTSECTIONID,v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

  if v_auditid is not null then
  FOR i IN (SELECT tssa.belongto surveyid, ts.surveytitle surveyname, tssa.studyid
            FROM TCSIP_CPORTAL.tbl_surveysipassociation tssa,
                 TCSIP_CPORTAL.tbl_survey ts
            WHERE ts.surveyid = tssa.belongto
            AND tssa.istemplate = 0
            AND tssa.istemplate = v_istemplate
            AND tssa.belongto = v_belongto) LOOP
    pkg_audit.sp_set_surveyauditreportmap
    (v_auditid,i.surveyid,i.surveyname,i.studyid, null, v_createddt,v_createdby,v_modifieddt,v_modifiedby);

  END LOOP;
  end if;
   pkg_audit.sp_set_audit
  (v_surveysectionid,'TBL_SURVEYSECTION','SHOWINSURVEY',(CASE WHEN :OLD.SHOWINSURVEY='1' THEN 'Y' ELSE 'N' END),(CASE WHEN :NEW.SHOWINSURVEY='1' THEN 'Y' ELSE 'N' END),v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

  if v_auditid is not null then
  FOR i IN (SELECT tssa.belongto surveyid, ts.surveytitle surveyname, tssa.studyid
            FROM TCSIP_CPORTAL.tbl_surveysipassociation tssa,
                 TCSIP_CPORTAL.tbl_survey ts
            WHERE ts.surveyid = tssa.belongto
            AND tssa.istemplate = 0
            AND tssa.istemplate = v_istemplate
            AND tssa.belongto = v_belongto) LOOP
    pkg_audit.sp_set_surveyauditreportmap
    (v_auditid,i.surveyid,i.surveyname,i.studyid, null, v_createddt,v_createdby,v_modifieddt,v_modifiedby);

  END LOOP;
  end if;
   pkg_audit.sp_set_audit
  (v_surveysectionid,'TBL_SURVEYSECTION','SECPOSITION',:OLD.SECPOSITION,:NEW.SECPOSITION,v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

  if v_auditid is not null then
  FOR i IN (SELECT tssa.belongto surveyid, ts.surveytitle surveyname, tssa.studyid
            FROM TCSIP_CPORTAL.tbl_surveysipassociation tssa,
                 TCSIP_CPORTAL.tbl_survey ts
            WHERE ts.surveyid = tssa.belongto
            AND tssa.istemplate = 0
            AND tssa.istemplate = v_istemplate
            AND tssa.belongto = v_belongto) LOOP
    pkg_audit.sp_set_surveyauditreportmap
    (v_auditid,i.surveyid,i.surveyname,i.studyid, null, v_createddt,v_createdby,v_modifieddt,v_modifiedby);

  END LOOP;
  end if;

END TRG_TBL_SURVEYSECTION_AUDIT;
/