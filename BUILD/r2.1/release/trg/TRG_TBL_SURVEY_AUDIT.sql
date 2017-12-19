CREATE OR REPLACE TRIGGER TCSIP_CPORTAL.TRG_TBL_SURVEY_AUDIT
AFTER INSERT OR UPDATE OR DELETE ON TCSIP_CPORTAL.TBL_SURVEY
FOR EACH ROW
DECLARE
v_operation tbl_audit.operation%TYPE;
v_auditid   tbl_audit.auditid%TYPE;
v_createdby tbl_audit.createdby%TYPE;
v_createddt tbl_audit.createddt%TYPE;
v_modifiedby tbl_audit.modifiedby%TYPE;
v_modifieddt tbl_audit.modifieddt%TYPE;
v_surveyid   TBL_SURVEY.surveyid%TYPE;
v_surveytitle TBL_SURVEY.surveytitle%TYPE;
v_reasonlistid  TBL_SURVEY.REASONLISTID%TYPE;
v_count PLS_INTEGER:=0;
v_sysdate DATE:=SYSDATE;

BEGIN
  IF INSERTING THEN
    v_operation := pkg_audit.g_operation_create;
    v_createdby := :NEW.createdby;
    v_createddt := :NEW.createddt;
    v_modifiedby := :NEW.createdby;
    v_modifieddt := :NEW.createddt;
    v_surveyid := :NEW.surveyid;
    v_surveytitle:=:NEW.surveytitle;
                v_reasonlistid:=:NEW.reasonlistid;

  ELSIF UPDATING THEN
      v_operation := pkg_audit.g_operation_update;
    v_createdby := :NEW.modifiedby;
    v_createddt := :NEW.modifieddt;
    v_modifiedby := :NEW.modifiedby;
    v_modifieddt := :NEW.modifieddt;
    v_surveyid := :NEW.surveyid;
    v_surveytitle:=:NEW.surveytitle;
                v_reasonlistid:=:NEW.reasonlistid;

  ELSIF DELETING THEN
    v_operation := pkg_audit.g_operation_delete;
    v_createdby := :OLD.modifiedby;
    v_createddt := v_sysdate;
    v_modifiedby := :OLD.modifiedby;
    v_modifieddt := v_sysdate;
    v_surveyid := :OLD.surveyid;
    v_surveytitle:=:OLD.surveytitle;
                v_reasonlistid:=:OLD.reasonlistid;

  END IF;

  SELECT COUNT(1)
  INTO v_count
  FROM TCSIP_CPORTAL.tbl_surveysipassociation sc
  WHERE sc.belongto = v_surveyid and sc.ISTEMPLATE=0;

  pkg_audit.sp_set_audit
    (v_surveyid,'TBL_SURVEY','SURVEYID',:OLD.SURVEYCD,:NEW.SURVEYCD,v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

  if v_auditid is not null then
IF  v_count <> 0 THEN
  FOR i IN (SELECT DISTINCT sc.studyid
            FROM TCSIP_CPORTAL.tbl_surveysipassociation sc
            WHERE sc.belongto = v_surveyid and sc.ISTEMPLATE=0
            ) LOOP
  pkg_audit.sp_set_surveyauditreportmap
  (v_auditid,v_surveyid,v_surveytitle,i.studyid, null, v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  end loop;
  ELSE
  pkg_audit.sp_set_surveyauditreportmap
  (v_auditid,v_surveyid,v_surveytitle,NULL, null, v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  END IF;
  end if;

  pkg_audit.sp_set_audit
  (v_surveyid,'TBL_SURVEY','SURVEYTITLE',:OLD.SURVEYTITLE,:NEW.SURVEYTITLE,v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

   if v_auditid is not null then
  IF  v_count <> 0 THEN
  FOR i IN (SELECT DISTINCT sc.studyid
            FROM TCSIP_CPORTAL.tbl_surveysipassociation sc
            WHERE sc.belongto = v_surveyid and sc.ISTEMPLATE=0
            ) LOOP
  pkg_audit.sp_set_surveyauditreportmap
  (v_auditid,v_surveyid,v_surveytitle,i.studyid, null, v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  end loop;
  ELSE
  pkg_audit.sp_set_surveyauditreportmap
  (v_auditid,v_surveyid,v_surveytitle,NULL, null, v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  END IF;
  end if;


    pkg_audit.sp_set_audit
  (v_surveyid,'TBL_SURVEY','PARENTSURVEYID',:OLD.PARENTSURVEYID,:NEW.PARENTSURVEYID,v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

   if v_auditid is not null then
  IF  v_count <> 0 THEN
  FOR i IN (SELECT DISTINCT sc.studyid
            FROM TCSIP_CPORTAL.tbl_surveysipassociation sc
            WHERE sc.belongto = v_surveyid and sc.ISTEMPLATE=0
            ) LOOP
  pkg_audit.sp_set_surveyauditreportmap
  (v_auditid,v_surveyid,v_surveytitle,i.studyid, null, v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  end loop;
  ELSE
  pkg_audit.sp_set_surveyauditreportmap
  (v_auditid,v_surveyid,v_surveytitle,NULL, null, v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  END IF;
  end if;


    pkg_audit.sp_set_audit
    (v_surveyid,'TBL_SURVEY','SURVEYDESC',:OLD.SURVEYDESC,:NEW.SURVEYDESC,v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

   if v_auditid is not null then
   IF  v_count <> 0 THEN
  FOR i IN (SELECT DISTINCT sc.studyid
            FROM TCSIP_CPORTAL.tbl_surveysipassociation sc
            WHERE sc.belongto = v_surveyid and sc.ISTEMPLATE=0
            ) LOOP
  pkg_audit.sp_set_surveyauditreportmap
  (v_auditid,v_surveyid,v_surveytitle,i.studyid, null, v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  end loop;
  ELSE
  pkg_audit.sp_set_surveyauditreportmap
  (v_auditid,v_surveyid,v_surveytitle,NULL, null, v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  END IF;
  end if;

  pkg_audit.sp_set_audit
  (v_surveyid,'TBL_SURVEY','SURVEYCREATIONDT',TO_CHAR(:OLD.SURVEYCREATIONDT, 'DD-MON-YYYY'), TO_CHAR(:NEW.SURVEYCREATIONDT, 'DD-MON-YYYY'),v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

   if v_auditid is not null then
   IF  v_count <> 0 THEN
  FOR i IN (SELECT DISTINCT sc.studyid
            FROM TCSIP_CPORTAL.tbl_surveysipassociation sc
            WHERE sc.belongto = v_surveyid and sc.ISTEMPLATE=0
            ) LOOP
  pkg_audit.sp_set_surveyauditreportmap
  (v_auditid,v_surveyid,v_surveytitle,i.studyid, null, v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  end loop;
  ELSE
  pkg_audit.sp_set_surveyauditreportmap
  (v_auditid,v_surveyid,v_surveytitle,NULL, null, v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  END IF;
  end if;


    pkg_audit.sp_set_audit
  (v_surveyid,'TBL_SURVEY','SURVEYCLOSEDDT',TO_CHAR(:OLD.SURVEYCLOSEDDT, 'DD-MON-YYYY'), TO_CHAR(:NEW.SURVEYCLOSEDDT, 'DD-MON-YYYY'),v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

   if v_auditid is not null then
   IF  v_count <> 0 THEN
  FOR i IN (SELECT DISTINCT sc.studyid
            FROM TCSIP_CPORTAL.tbl_surveysipassociation sc
            WHERE sc.belongto = v_surveyid and sc.ISTEMPLATE=0
            ) LOOP
  pkg_audit.sp_set_surveyauditreportmap
  (v_auditid,v_surveyid,v_surveytitle,i.studyid, null, v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  end loop;
  ELSE
  pkg_audit.sp_set_surveyauditreportmap
  (v_auditid,v_surveyid,v_surveytitle,NULL, null, v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  END IF;
  end if;

    pkg_audit.sp_set_audit
    (v_surveyid,'TBL_SURVEY','SURVEYSTATUS',(CASE WHEN :OLD.SURVEYSTATUS=0 then 'TEST' else pkg_audit.fn_get_lov_value(:OLD.SURVEYSTATUS, pkg_audit.g_lov_surveystatus) end),(CASE WHEN :NEW.SURVEYSTATUS=0 then 'TEST' else pkg_audit.fn_get_lov_value(:NEW.SURVEYSTATUS, pkg_audit.g_lov_surveystatus) end),v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

   if v_auditid is not null then
  IF  v_count <> 0 THEN
  FOR i IN (SELECT DISTINCT sc.studyid
            FROM TCSIP_CPORTAL.tbl_surveysipassociation sc
            WHERE sc.belongto = v_surveyid and sc.ISTEMPLATE=0
            ) LOOP
  pkg_audit.sp_set_surveyauditreportmap
  (v_auditid,v_surveyid,v_surveytitle,i.studyid, null, v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  end loop;
  ELSE
  pkg_audit.sp_set_surveyauditreportmap
  (v_auditid,v_surveyid,v_surveytitle,NULL, null, v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  END IF;
  end if;

  pkg_audit.sp_set_audit
  (v_surveyid,'TBL_SURVEY','ISCDAREQ',(case when :OLD.ISCDAREQ='0' then 'N' else 'Y' end),(case when :NEW.ISCDAREQ='0' then 'N' else 'Y' end),v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

   if v_auditid is not null then
  IF  v_count <> 0 THEN
  FOR i IN (SELECT DISTINCT sc.studyid
            FROM TCSIP_CPORTAL.tbl_surveysipassociation sc
            WHERE sc.belongto = v_surveyid and sc.ISTEMPLATE=0
            ) LOOP
  pkg_audit.sp_set_surveyauditreportmap
  (v_auditid,v_surveyid,v_surveytitle,i.studyid, null, v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  end loop;
  ELSE
  pkg_audit.sp_set_surveyauditreportmap
  (v_auditid,v_surveyid,v_surveytitle,NULL, null, v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  END IF;
  end if;


    pkg_audit.sp_set_audit
  (v_surveyid,'TBL_SURVEY','CREATEDDT',TO_CHAR(:OLD.createddt, 'DD-MON-YYYY'), TO_CHAR(:NEW.createddt, 'DD-MON-YYYY'),v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

   if v_auditid is not null then
  IF  v_count <> 0 THEN
 FOR i IN (SELECT DISTINCT sc.studyid
            FROM TCSIP_CPORTAL.tbl_surveysipassociation sc
            WHERE sc.belongto = v_surveyid and sc.ISTEMPLATE=0
            ) LOOP
  pkg_audit.sp_set_surveyauditreportmap
  (v_auditid,v_surveyid,v_surveytitle,i.studyid, null, v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  end loop;
  ELSE
  pkg_audit.sp_set_surveyauditreportmap
  (v_auditid,v_surveyid,v_surveytitle,NULL, null, v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  END IF;
  end if;


    pkg_audit.sp_set_audit
    (v_surveyid,'TBL_SURVEY','CREATEDBY',:OLD.CREATEDBY,:NEW.CREATEDBY,v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

   if v_auditid is not null then
  IF  v_count <> 0 THEN
  FOR i IN (SELECT DISTINCT sc.studyid
            FROM TCSIP_CPORTAL.tbl_surveysipassociation sc
            WHERE sc.belongto = v_surveyid and sc.ISTEMPLATE=0
            ) LOOP
  pkg_audit.sp_set_surveyauditreportmap
  (v_auditid,v_surveyid,v_surveytitle,i.studyid, null, v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  end loop;
  ELSE
  pkg_audit.sp_set_surveyauditreportmap
  (v_auditid,v_surveyid,v_surveytitle,NULL, null, v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  END IF;
  end if;

  pkg_audit.sp_set_audit
  (v_surveyid,'TBL_SURVEY','MODIFIEDDT',TO_CHAR(:OLD.modifieddt, 'DD-MON-YYYY'), TO_CHAR(:NEW.modifieddt, 'DD-MON-YYYY'),v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

   if v_auditid is not null then
  IF  v_count <> 0 THEN
  FOR i IN (SELECT DISTINCT sc.studyid
            FROM TCSIP_CPORTAL.tbl_surveysipassociation sc
            WHERE sc.belongto = v_surveyid and sc.ISTEMPLATE=0
            ) LOOP
  pkg_audit.sp_set_surveyauditreportmap
  (v_auditid,v_surveyid,v_surveytitle,i.studyid, null, v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  end loop;
  ELSE
  pkg_audit.sp_set_surveyauditreportmap
  (v_auditid,v_surveyid,v_surveytitle,NULL, null, v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  END IF;
  end if;


    pkg_audit.sp_set_audit
  (v_surveyid,'TBL_SURVEY','MODIFIEDBY',:OLD.MODIFIEDBY,:NEW.MODIFIEDBY,v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

  if v_auditid is not null then
  IF  v_count <> 0 THEN
  FOR i IN (SELECT DISTINCT sc.studyid
            FROM TCSIP_CPORTAL.tbl_surveysipassociation sc
            WHERE sc.belongto = v_surveyid and sc.ISTEMPLATE=0
            ) LOOP
  pkg_audit.sp_set_surveyauditreportmap
  (v_auditid,v_surveyid,v_surveytitle,i.studyid, null, v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  end loop;
  ELSE
  pkg_audit.sp_set_surveyauditreportmap
  (v_auditid,v_surveyid,v_surveytitle,NULL, null, v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  END IF;
  end if;


   pkg_audit.sp_set_audit
    (v_surveyid,'TBL_SURVEY','SURVEYCD',:OLD.SURVEYCD,:NEW.SURVEYCD,v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

   if v_auditid is not null then
  IF  v_count <> 0 THEN
  FOR i IN (SELECT DISTINCT sc.studyid
            FROM TCSIP_CPORTAL.tbl_surveysipassociation sc
            WHERE sc.belongto = v_surveyid and sc.ISTEMPLATE=0
            ) LOOP
  pkg_audit.sp_set_surveyauditreportmap
  (v_auditid,v_surveyid,v_surveytitle,i.studyid, null, v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  end loop;
  ELSE
  pkg_audit.sp_set_surveyauditreportmap
  (v_auditid,v_surveyid,v_surveytitle,NULL, null, v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  END IF;
  end if;

  pkg_audit.sp_set_audit
  (v_surveyid,'TBL_SURVEY','SURVEYTYPEID',(CASE WHEN :OLD.SURVEYTYPEID=21 THEN 'Site Users'  WHEN :OLD.SURVEYTYPEID=22 THEN 'Sponsor Users' ELSE NULL END),(CASE WHEN :NEW.SURVEYTYPEID=21 THEN 'Site Users'  WHEN :NEW.SURVEYTYPEID=22 THEN 'Sponsor Users' ELSE NULL END),v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

   if v_auditid is not null then
  IF  v_count <> 0 THEN
  FOR i IN (SELECT DISTINCT sc.studyid
            FROM TCSIP_CPORTAL.tbl_surveysipassociation sc
            WHERE sc.belongto = v_surveyid and sc.ISTEMPLATE=0
            ) LOOP
  pkg_audit.sp_set_surveyauditreportmap
  (v_auditid,v_surveyid,v_surveytitle,i.studyid, null, v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  end loop;
  ELSE
  pkg_audit.sp_set_surveyauditreportmap
  (v_auditid,v_surveyid,v_surveytitle,NULL, null, v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  END IF;
  end if;


    pkg_audit.sp_set_audit
  (v_surveyid,'TBL_SURVEY','TEMPLATEID',pkg_audit.fn_get_lov_value(:OLD.TEMPLATEID, pkg_audit.g_lov_template),pkg_audit.fn_get_lov_value(:NEW.TEMPLATEID, pkg_audit.g_lov_template),v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

if v_auditid is not null then
  IF  v_count <> 0 THEN
  FOR i IN (SELECT DISTINCT sc.studyid
            FROM TCSIP_CPORTAL.tbl_surveysipassociation sc
            WHERE sc.belongto = v_surveyid and sc.ISTEMPLATE=0
            ) LOOP
  pkg_audit.sp_set_surveyauditreportmap
  (v_auditid,v_surveyid,v_surveytitle,i.studyid, null, v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  end loop;
  ELSE
  pkg_audit.sp_set_surveyauditreportmap
  (v_auditid,v_surveyid,v_surveytitle,NULL, null, v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  END IF;
  end if;

    pkg_audit.sp_set_audit
    (v_surveyid,'TBL_SURVEY','LANGUAGEID',pkg_audit.fn_get_lov_value(:OLD.LANGUAGEID, pkg_audit.g_lov_language),pkg_audit.fn_get_lov_value(:NEW.LANGUAGEID, pkg_audit.g_lov_language),v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

   if v_auditid is not null then
  IF  v_count <> 0 THEN
  FOR i IN (SELECT DISTINCT sc.studyid
            FROM TCSIP_CPORTAL.tbl_surveysipassociation sc
            WHERE sc.belongto = v_surveyid and sc.ISTEMPLATE=0
            ) LOOP
  pkg_audit.sp_set_surveyauditreportmap
  (v_auditid,v_surveyid,v_surveytitle,i.studyid, null, v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  end loop;
  ELSE
  pkg_audit.sp_set_surveyauditreportmap
  (v_auditid,v_surveyid,v_surveytitle,NULL, null, v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  END IF;
  end if;

  pkg_audit.sp_set_audit
  (v_surveyid,'TBL_SURVEY','COUNTRYID',pkg_audit.fn_get_lov_value(:OLD.COUNTRYID, pkg_audit.g_lov_country_id),pkg_audit.fn_get_lov_value(:NEW.COUNTRYID, pkg_audit.g_lov_country_id),v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

   if v_auditid is not null then
  IF  v_count <> 0 THEN
  FOR i IN (SELECT DISTINCT sc.studyid
            FROM TCSIP_CPORTAL.tbl_surveysipassociation sc
            WHERE sc.belongto = v_surveyid and sc.ISTEMPLATE=0
            ) LOOP
  pkg_audit.sp_set_surveyauditreportmap
  (v_auditid,v_surveyid,v_surveytitle,i.studyid, null, v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  end loop;
  ELSE
  pkg_audit.sp_set_surveyauditreportmap
  (v_auditid,v_surveyid,v_surveytitle,NULL, null, v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  END IF;
  end if;


    pkg_audit.sp_set_audit
  (v_surveyid,'TBL_SURVEY','ISDELEGATED',:OLD.ISDELEGATED,:NEW.ISDELEGATED,v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

   if v_auditid is not null then
  IF  v_count <> 0 THEN
  FOR i IN (SELECT DISTINCT sc.studyid
            FROM TCSIP_CPORTAL.tbl_surveysipassociation sc
            WHERE sc.belongto = v_surveyid and sc.ISTEMPLATE=0
            ) LOOP
  pkg_audit.sp_set_surveyauditreportmap
  (v_auditid,v_surveyid,v_surveytitle,i.studyid, null, v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  end loop;
  ELSE
  pkg_audit.sp_set_surveyauditreportmap
  (v_auditid,v_surveyid,v_surveytitle,NULL, null, v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  END IF;
  end if;


      pkg_audit.sp_set_audit
    (v_surveyid,'TBL_SURVEY','ISCHECKEDIN',:OLD.ISCHECKEDIN,:NEW.ISCHECKEDIN,v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

   if v_auditid is not null then
  IF  v_count <> 0 THEN
  FOR i IN (SELECT DISTINCT sc.studyid
            FROM TCSIP_CPORTAL.tbl_surveysipassociation sc
            WHERE sc.belongto = v_surveyid and sc.ISTEMPLATE=0
            ) LOOP
  pkg_audit.sp_set_surveyauditreportmap
  (v_auditid,v_surveyid,v_surveytitle,i.studyid, null, v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  end loop;
  ELSE
  pkg_audit.sp_set_surveyauditreportmap
  (v_auditid,v_surveyid,v_surveytitle,NULL, null, v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  END IF;
  end if;

  pkg_audit.sp_set_audit
  (v_surveyid,'TBL_SURVEY','INTRODUCTION',:OLD.INTRODUCTION,:NEW.INTRODUCTION,v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

   if v_auditid is not null then
  IF  v_count <> 0 THEN
  FOR i IN (SELECT DISTINCT sc.studyid
            FROM TCSIP_CPORTAL.tbl_surveysipassociation sc
            WHERE sc.belongto = v_surveyid and sc.ISTEMPLATE=0
            ) LOOP
  pkg_audit.sp_set_surveyauditreportmap
  (v_auditid,v_surveyid,v_surveytitle,i.studyid, null, v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  end loop;
  ELSE
  pkg_audit.sp_set_surveyauditreportmap
  (v_auditid,v_surveyid,v_surveytitle,NULL, null, v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  END IF;
  end if;


    pkg_audit.sp_set_audit
  (v_surveyid,'TBL_SURVEY','CONCLUSION',:OLD.CONCLUSION,:NEW.CONCLUSION,v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

   if v_auditid is not null then
  IF  v_count <> 0 THEN
  FOR i IN (SELECT DISTINCT sc.studyid
            FROM TCSIP_CPORTAL.tbl_surveysipassociation sc
            WHERE sc.belongto = v_surveyid and sc.ISTEMPLATE=0
            ) LOOP
  pkg_audit.sp_set_surveyauditreportmap
  (v_auditid,v_surveyid,v_surveytitle,i.studyid, null, v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  end loop;
  ELSE
  pkg_audit.sp_set_surveyauditreportmap
  (v_auditid,v_surveyid,v_surveytitle,NULL, null, v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  END IF;end if;

    pkg_audit.sp_set_audit
    (v_surveyid,'TBL_SURVEY','REASONLISTID',pkg_audit.fn_get_lov_value(:OLD.REASONLISTID, pkg_audit.g_lov_reasonlist),pkg_audit.fn_get_lov_value(:NEW.REASONLISTID, pkg_audit.g_lov_reasonlist),v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

   if v_auditid is not null then
  IF  v_count <> 0 THEN
  FOR i IN (SELECT DISTINCT sc.studyid
            FROM TCSIP_CPORTAL.tbl_surveysipassociation sc
            WHERE sc.belongto = v_surveyid and sc.ISTEMPLATE=0
           ) LOOP
  pkg_audit.sp_set_surveyauditreportmap
  (v_auditid,v_surveyid,v_surveytitle,i.studyid, null, v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  end loop;
  ELSE
  pkg_audit.sp_set_surveyauditreportmap
  (v_auditid,v_surveyid,v_surveytitle,NULL, null, v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  END IF;end if;

  pkg_audit.sp_set_audit
  (v_surveyid,'TBL_SURVEY','ISDECLINEREASONMANDATORY',:OLD.ISDECLINEREASONMANDATORY,:NEW.ISDECLINEREASONMANDATORY,v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

   if v_auditid is not null then
  IF  v_count <> 0 THEN
  FOR i IN (SELECT DISTINCT sc.studyid
            FROM TCSIP_CPORTAL.tbl_surveysipassociation sc
            WHERE sc.belongto = v_surveyid and sc.ISTEMPLATE=0
            ) LOOP
  pkg_audit.sp_set_surveyauditreportmap
  (v_auditid,v_surveyid,v_surveytitle,i.studyid, null, v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  end loop;
  ELSE
  pkg_audit.sp_set_surveyauditreportmap
  (v_auditid,v_surveyid,v_surveytitle,NULL, null, v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  END IF;
  end if;


    pkg_audit.sp_set_audit
  (v_surveyid,'TBL_SURVEY','ISCCCREATOR',:OLD.ISCCCREATOR,:NEW.ISCCCREATOR,v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

   if v_auditid is not null then
  IF  v_count <> 0 THEN
  FOR i IN (SELECT DISTINCT sc.studyid
            FROM TCSIP_CPORTAL.tbl_surveysipassociation sc
            WHERE sc.belongto = v_surveyid and sc.ISTEMPLATE=0
            ) LOOP
  pkg_audit.sp_set_surveyauditreportmap
  (v_auditid,v_surveyid,v_surveytitle,i.studyid, null, v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  end loop;
  ELSE
  pkg_audit.sp_set_surveyauditreportmap
  (v_auditid,v_surveyid,v_surveytitle,NULL, null, v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  END IF;
  end if;
  ---
    pkg_audit.sp_set_audit
  (v_surveyid,'TBL_SURVEY','SURVEYSUBTYPE',pkg_audit.fn_get_lov_value(:OLD.SURVEYSUBTYPE, pkg_audit.g_lov_surveytype),pkg_audit.fn_get_lov_value(:NEW.SURVEYSUBTYPE, pkg_audit.g_lov_surveytype),v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

   if v_auditid is not null then
  IF  v_count <> 0 THEN
  FOR i IN (SELECT DISTINCT sc.studyid
            FROM TCSIP_CPORTAL.tbl_surveysipassociation sc
            WHERE sc.belongto = v_surveyid and sc.ISTEMPLATE=0
            ) LOOP
  pkg_audit.sp_set_surveyauditreportmap
  (v_auditid,v_surveyid,v_surveytitle,i.studyid, null, v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  end loop;
  ELSE
  pkg_audit.sp_set_surveyauditreportmap
  (v_auditid,v_surveyid,v_surveytitle,NULL, null, v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  END IF;
  end if;

    pkg_audit.sp_set_audit
  (v_surveyid,'TBL_SURVEY','OTHERSURVEYTYPETEXT',:OLD.OTHERSURVEYTYPETEXT,:NEW.OTHERSURVEYTYPETEXT,v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

   if v_auditid is not null then
  IF  v_count <> 0 THEN
  FOR i IN (SELECT DISTINCT sc.studyid
            FROM TCSIP_CPORTAL.tbl_surveysipassociation sc
            WHERE sc.belongto = v_surveyid and sc.ISTEMPLATE=0
            ) LOOP
  pkg_audit.sp_set_surveyauditreportmap
  (v_auditid,v_surveyid,v_surveytitle,i.studyid, null, v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  end loop;
  ELSE
  pkg_audit.sp_set_surveyauditreportmap
  (v_auditid,v_surveyid,v_surveytitle,NULL, null, v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  END IF;
  end if;

    pkg_audit.sp_set_audit
  (v_surveyid,'TBL_SURVEY','CONCLUSIONDELEGATED',:OLD.CONCLUSIONDELEGATED,:NEW.CONCLUSIONDELEGATED,v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

   if v_auditid is not null then
  IF  v_count <> 0 THEN
  FOR i IN (SELECT DISTINCT sc.studyid
            FROM TCSIP_CPORTAL.tbl_surveysipassociation sc
            WHERE sc.belongto = v_surveyid and sc.ISTEMPLATE=0
            ) LOOP
  pkg_audit.sp_set_surveyauditreportmap
  (v_auditid,v_surveyid,v_surveytitle,i.studyid, null, v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  end loop;
  ELSE
  pkg_audit.sp_set_surveyauditreportmap
  (v_auditid,v_surveyid,v_surveytitle,NULL, null, v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  END IF;
  end if;

    pkg_audit.sp_set_audit
  (v_surveyid,'TBL_SURVEY','CONCLUSIONDECLINED',:OLD.CONCLUSIONDECLINED,:NEW.CONCLUSIONDECLINED,v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

   if v_auditid is not null then
  IF  v_count <> 0 THEN
  FOR i IN (SELECT DISTINCT sc.studyid
            FROM TCSIP_CPORTAL.tbl_surveysipassociation sc
            WHERE sc.belongto = v_surveyid and sc.ISTEMPLATE=0
            ) LOOP
  pkg_audit.sp_set_surveyauditreportmap
  (v_auditid,v_surveyid,v_surveytitle,i.studyid, null, v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  end loop;
  ELSE
  pkg_audit.sp_set_surveyauditreportmap
  (v_auditid,v_surveyid,v_surveytitle,NULL, null, v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  END IF;
  end if;

    pkg_audit.sp_set_audit
  (v_surveyid,'TBL_SURVEY','ISREFALLOWED',(case when :OLD.ISREFALLOWED='0' then 'N' else 'Y' end),(case when :NEW.ISREFALLOWED='0' then 'N' else 'Y' end),v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

   if v_auditid is not null then
  IF  v_count <> 0 THEN
  FOR i IN (SELECT DISTINCT sc.studyid
            FROM TCSIP_CPORTAL.tbl_surveysipassociation sc
            WHERE sc.belongto = v_surveyid and sc.ISTEMPLATE=0
            ) LOOP
  pkg_audit.sp_set_surveyauditreportmap
  (v_auditid,v_surveyid,v_surveytitle,i.studyid, null, v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  end loop;
  ELSE
  pkg_audit.sp_set_surveyauditreportmap
  (v_auditid,v_surveyid,v_surveytitle,NULL, null, v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  END IF;
  end if;

    pkg_audit.sp_set_audit
  (v_surveyid,'TBL_SURVEY','ISDELEGATIONALLOWED',(case when :OLD.ISDELEGATIONALLOWED='0' then 'N' else 'Y' end),(case when :NEW.ISDELEGATIONALLOWED='0' then 'N' else 'Y' end),v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

   if v_auditid is not null then
  IF  v_count <> 0 THEN
  FOR i IN (SELECT DISTINCT sc.studyid
            FROM TCSIP_CPORTAL.tbl_surveysipassociation sc
            WHERE sc.belongto = v_surveyid and sc.ISTEMPLATE=0
            ) LOOP
  pkg_audit.sp_set_surveyauditreportmap
  (v_auditid,v_surveyid,v_surveytitle,i.studyid, null, v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  end loop;
  ELSE
  pkg_audit.sp_set_surveyauditreportmap
  (v_auditid,v_surveyid,v_surveytitle,NULL, null, v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  END IF;
  end if;

    pkg_audit.sp_set_audit
  (v_surveyid,'TBL_SURVEY','ISCALLBACKALLOWED',(case when :OLD.ISCALLBACKALLOWED='0' then 'N' else 'Y' end),(case when :NEW.ISCALLBACKALLOWED='0' then 'N' else 'Y' end),v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

   if v_auditid is not null then
  IF  v_count <> 0 THEN
  FOR i IN (SELECT DISTINCT sc.studyid
            FROM TCSIP_CPORTAL.tbl_surveysipassociation sc
            WHERE sc.belongto = v_surveyid and sc.ISTEMPLATE=0
            ) LOOP
  pkg_audit.sp_set_surveyauditreportmap
  (v_auditid,v_surveyid,v_surveytitle,i.studyid, null, v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  end loop;
  ELSE
  pkg_audit.sp_set_surveyauditreportmap
  (v_auditid,v_surveyid,v_surveytitle,NULL, null, v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  END IF;
  end if;

    pkg_audit.sp_set_audit
  (v_surveyid,'TBL_SURVEY','ISSTUDYSPECIFIC',(case when :OLD.ISSTUDYSPECIFIC='0'  then 'N' else case when :OLD.ISSTUDYSPECIFIC='1' THEN 'Y' else NULL end end),(case when :NEW.ISSTUDYSPECIFIC='0'  then 'N' else case when :NEW.ISSTUDYSPECIFIC='1' THEN 'Y' else NULL end end),v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

   if v_auditid is not null then
  IF  v_count <> 0 THEN
  FOR i IN (SELECT DISTINCT sc.studyid
            FROM TCSIP_CPORTAL.tbl_surveysipassociation sc
            WHERE sc.belongto = v_surveyid and sc.ISTEMPLATE=0
            ) LOOP
  pkg_audit.sp_set_surveyauditreportmap
  (v_auditid,v_surveyid,v_surveytitle,i.studyid, null, v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  end loop;
  ELSE
  pkg_audit.sp_set_surveyauditreportmap
  (v_auditid,v_surveyid,v_surveytitle,NULL, null, v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  END IF;
  end if;

    pkg_audit.sp_set_audit
  (v_surveyid,'TBL_SURVEY','RESPONSEDAYS',:OLD.RESPONSEDAYS,:NEW.RESPONSEDAYS,v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

   if v_auditid is not null then
  IF  v_count <> 0 THEN
  FOR i IN (SELECT DISTINCT sc.studyid
            FROM TCSIP_CPORTAL.tbl_surveysipassociation sc
            WHERE sc.belongto = v_surveyid and sc.ISTEMPLATE=0
            ) LOOP
  pkg_audit.sp_set_surveyauditreportmap
  (v_auditid,v_surveyid,v_surveytitle,i.studyid, null, v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  end loop;
  ELSE
  pkg_audit.sp_set_surveyauditreportmap
  (v_auditid,v_surveyid,v_surveytitle,NULL, null, v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  END IF;
  end if;

    pkg_audit.sp_set_audit
  (v_surveyid,'TBL_SURVEY','PLANNEDCLOSEDDT',:OLD.PLANNEDCLOSEDDT,:NEW.PLANNEDCLOSEDDT,v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

   if v_auditid is not null then
  IF  v_count <> 0 THEN
  FOR i IN (SELECT DISTINCT sc.studyid
            FROM TCSIP_CPORTAL.tbl_surveysipassociation sc
            WHERE sc.belongto = v_surveyid and sc.ISTEMPLATE=0
            ) LOOP
  pkg_audit.sp_set_surveyauditreportmap
  (v_auditid,v_surveyid,v_surveytitle,i.studyid, null, v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  end loop;
  ELSE
  pkg_audit.sp_set_surveyauditreportmap
  (v_auditid,v_surveyid,v_surveytitle,NULL, null, v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  END IF;
  end if;


   --Update Survey Id for ReasonList added for Survey
UPDATE  tbl_surveyauditreportmap tsarm
SET tsarm.surveyid = v_surveyid, tsarm.surveyname = v_surveytitle
WHERE tsarm.surveyid IS NULL
AND tsarm.surveyauditid IN (SELECT ta.auditid
                                                  FROM tbl_audit ta
                                                  WHERE ta.tablename = 'TBL_REASONLIST'
                                                  AND ta.entityrefid = v_reasonlistid);


UPDATE  tbl_surveyauditreportmap tsarm
SET tsarm.surveyid = v_surveyid, tsarm.surveyname = v_surveytitle
WHERE tsarm.surveyid IS NULL
AND tsarm.surveyauditid IN (SELECT ta.auditid
                                                                                                                FROM tbl_audit ta
                            WHERE ta.tablename = 'TBL_REASONS'
                            AND ta.entityrefid IN (select reasonid from tbl_reasons where reasonlistid= v_reasonlistid));



END trg_tbl_survey_audit;
/