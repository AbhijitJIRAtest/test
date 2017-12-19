CREATE OR REPLACE TRIGGER TCSIP_CPORTAL.TRG_TBL_SURVEYUSERMAP_AUDIT
AFTER INSERT OR UPDATE OR DELETE ON TCSIP_CPORTAL.TBL_SURVEYUSERMAP
FOR EACH ROW
DECLARE
v_operation           tbl_audit.operation%TYPE;
v_auditid             tbl_audit.auditid%TYPE;
v_surveyusermapid  TBL_SURVEYUSERMAP.SURVEYUSERMAPID%TYPE;
v_createdby           tbl_audit.createdby%TYPE;
v_createddt           tbl_audit.createddt%TYPE;
v_modifiedby          tbl_audit.modifiedby%TYPE;
v_modifieddt          tbl_audit.modifieddt%TYPE;
 v_belongto          TBL_SURVEYUSERMAP.belongto%TYPE;
v_sysdate DATE:=SYSDATE;
 BEGIN
  IF INSERTING THEN
    v_operation := pkg_audit.g_operation_create;
    v_createdby := :NEW.createdby;
    v_createddt := :NEW.createddt;
    v_modifiedby := :NEW.createdby;
    v_modifieddt := :NEW.createddt;
    v_surveyusermapid:= :NEW.surveyusermapid;
    v_belongto:=:NEW.BELONGTO;
  ELSIF UPDATING THEN
    v_operation := pkg_audit.g_operation_update;
    v_createdby := :NEW.modifiedby;
    v_createddt := :NEW.modifieddt;
    v_modifiedby := :NEW.modifiedby;
    v_modifieddt := :NEW.modifieddt;
    v_surveyusermapid:= :NEW.surveyusermapid;
    v_belongto:=:NEW.BELONGTO;
  ELSIF DELETING THEN
    v_operation := pkg_audit.g_operation_delete;
    v_surveyusermapid:= :OLD.surveyusermapid;
    v_createdby := pkg_audit.fn_get_del_createdby('TBL_SURVEYUSERMAP',v_surveyusermapid);
    v_createddt := pkg_audit.fn_get_del_createddt('TBL_SURVEYUSERMAP',v_surveyusermapid);
    v_modifiedby := pkg_audit.fn_get_del_createdby('TBL_SURVEYUSERMAP',v_surveyusermapid);
    v_modifieddt := pkg_audit.fn_get_del_createddt('TBL_SURVEYUSERMAP',v_surveyusermapid);
    v_belongto:=:OLD.BELONGTO;
  END IF;

  pkg_audit.sp_set_audit
  (v_surveyusermapid,'TBL_SURVEYUSERMAP', 'SURVEYUSERMAPID',:OLD.SURVEYUSERMAPID,:NEW.SURVEYUSERMAPID,v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

  if v_auditid is not null then
  FOR i IN (SELECT tssa.belongto,ts.surveytitle,tssa.studyid
            FROM TCSIP_CPORTAL.TBL_SURVEY ts,
             TCSIP_CPORTAL.TBL_SURVEYSIPASSOCIATION tssa
            WHERE ts.surveyid = tssa.belongto
           AND tssa.istemplate = 0
           AND ts.surveyid = v_belongto) LOOP
    pkg_audit.sp_set_surveyauditreportmap
    (v_auditid,i.belongto,i.surveytitle,i.studyid, null, v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  END LOOP;
  end if;


  pkg_audit.sp_set_audit
  (v_surveyusermapid,'TBL_SURVEYUSERMAP', 'SURVEYUSERID',:OLD.SURVEYUSERID,:NEW.SURVEYUSERID,v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

  if v_auditid is not null then
  FOR i IN (SELECT tssa.belongto,ts.surveytitle,tssa.studyid
            FROM TCSIP_CPORTAL.TBL_SURVEY ts,
             TCSIP_CPORTAL.TBL_SURVEYSIPASSOCIATION tssa
            WHERE ts.surveyid = tssa.belongto
           AND tssa.istemplate = 0
           AND ts.surveyid = v_belongto) LOOP
    pkg_audit.sp_set_surveyauditreportmap
    (v_auditid,i.belongto,i.surveytitle,i.studyid, null, v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  END LOOP;
  end if;

    pkg_audit.sp_set_audit
  (v_surveyusermapid,'TBL_SURVEYUSERMAP', 'TRANECELERATEID', :OLD.TRANECELERATEID, :NEW.TRANECELERATEID,v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

  if v_auditid is not null then
  FOR i IN (SELECT tssa.belongto,ts.surveytitle,tssa.studyid
            FROM TCSIP_CPORTAL.TBL_SURVEY ts,
             TCSIP_CPORTAL.TBL_SURVEYSIPASSOCIATION tssa
            WHERE ts.surveyid = tssa.belongto
           AND tssa.istemplate = 0
           AND ts.surveyid = v_belongto) LOOP
    pkg_audit.sp_set_surveyauditreportmap
    (v_auditid,i.belongto,i.surveytitle,i.studyid, null, v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  END LOOP;
  end if;

  pkg_audit.sp_set_audit
  (v_surveyusermapid,'TBL_SURVEYUSERMAP', 'BELONGTO',pkg_audit.fn_get_lov_value(:OLD.BELONGTO, pkg_audit.g_lov_survey_id),pkg_audit.fn_get_lov_value(:NEW.BELONGTO, pkg_audit.g_lov_survey_id),v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

  if v_auditid is not null then
  FOR i IN (SELECT tssa.belongto,ts.surveytitle,tssa.studyid
            FROM TCSIP_CPORTAL.TBL_SURVEY ts,
             TCSIP_CPORTAL.TBL_SURVEYSIPASSOCIATION tssa
            WHERE ts.surveyid = tssa.belongto
           AND tssa.istemplate = 0
           AND ts.surveyid = v_belongto) LOOP
    pkg_audit.sp_set_surveyauditreportmap
    (v_auditid,i.belongto,i.surveytitle,i.studyid, null, v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  END LOOP;
  end if;


    pkg_audit.sp_set_audit
  (v_surveyusermapid,'TBL_SURVEYUSERMAP', 'ISTEMPLATE',:OLD.ISTEMPLATE,:NEW.ISTEMPLATE,v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

  if v_auditid is not null then
  FOR i IN (SELECT tssa.belongto,ts.surveytitle,tssa.studyid
            FROM TCSIP_CPORTAL.TBL_SURVEY ts,
             TCSIP_CPORTAL.TBL_SURVEYSIPASSOCIATION tssa
            WHERE ts.surveyid = tssa.belongto
           AND tssa.istemplate = 0
           AND ts.surveyid = v_belongto) LOOP
    pkg_audit.sp_set_surveyauditreportmap
    (v_auditid,i.belongto,i.surveytitle,i.studyid, null, v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  END LOOP;
  end if;


  pkg_audit.sp_set_audit
  (v_surveyusermapid,'TBL_SURVEYUSERMAP', 'SURVEYSENTDATE',TO_CHAR(:OLD.SURVEYSENTDATE, 'DD-MON-YYYY'), TO_CHAR(:NEW.SURVEYSENTDATE, 'DD-MON-YYYY'),v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

  if v_auditid is not null then
  FOR i IN (SELECT tssa.belongto,ts.surveytitle,tssa.studyid
            FROM TCSIP_CPORTAL.TBL_SURVEY ts,
             TCSIP_CPORTAL.TBL_SURVEYSIPASSOCIATION tssa
            WHERE ts.surveyid = tssa.belongto
           AND tssa.istemplate = 0
           AND ts.surveyid = v_belongto) LOOP
    pkg_audit.sp_set_surveyauditreportmap
    (v_auditid,i.belongto,i.surveytitle,i.studyid, null, v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  END LOOP;
  end if;


    pkg_audit.sp_set_audit
  (v_surveyusermapid,'TBL_SURVEYUSERMAP', 'SURVEYREMINDERDATE',TO_CHAR(:OLD.SURVEYREMINDERDATE, 'DD-MON-YYYY'), TO_CHAR(:NEW.SURVEYREMINDERDATE, 'DD-MON-YYYY'),v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

  if v_auditid is not null then
  FOR i IN (SELECT tssa.belongto,ts.surveytitle,tssa.studyid
            FROM TCSIP_CPORTAL.TBL_SURVEY ts,
             TCSIP_CPORTAL.TBL_SURVEYSIPASSOCIATION tssa
            WHERE ts.surveyid = tssa.belongto
           AND tssa.istemplate = 0
           AND ts.surveyid = v_belongto) LOOP
    pkg_audit.sp_set_surveyauditreportmap
    (v_auditid,i.belongto,i.surveytitle,i.studyid, null, v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  END LOOP;
  end if;


    pkg_audit.sp_set_audit
  (v_surveyusermapid,'TBL_SURVEYUSERMAP', 'LASTREMINDERDATE',TO_CHAR(:OLD.LASTREMINDERDATE, 'DD-MON-YYYY'), TO_CHAR(:NEW.LASTREMINDERDATE, 'DD-MON-YYYY'),v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

  if v_auditid is not null then
  FOR i IN (SELECT tssa.belongto,ts.surveytitle,tssa.studyid
            FROM TCSIP_CPORTAL.TBL_SURVEY ts,
             TCSIP_CPORTAL.TBL_SURVEYSIPASSOCIATION tssa
            WHERE ts.surveyid = tssa.belongto
           AND tssa.istemplate = 0
           AND ts.surveyid = v_belongto) LOOP
    pkg_audit.sp_set_surveyauditreportmap
    (v_auditid,i.belongto,i.surveytitle,i.studyid, null, v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  END LOOP;
  end if;

  pkg_audit.sp_set_audit
  (v_surveyusermapid,'TBL_SURVEYUSERMAP', 'SURVEYDUEDATE',TO_CHAR(:OLD.SURVEYDUEDATE, 'DD-MON-YYYY'), TO_CHAR(:NEW.SURVEYDUEDATE, 'DD-MON-YYYY'),v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

  if v_auditid is not null then
  FOR i IN (SELECT tssa.belongto,ts.surveytitle,tssa.studyid
            FROM TCSIP_CPORTAL.TBL_SURVEY ts,
             TCSIP_CPORTAL.TBL_SURVEYSIPASSOCIATION tssa
            WHERE ts.surveyid = tssa.belongto
           AND tssa.istemplate = 0
           AND ts.surveyid = v_belongto) LOOP
    pkg_audit.sp_set_surveyauditreportmap
    (v_auditid,i.belongto,i.surveytitle,i.studyid, null, v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  END LOOP;
  end if;

    pkg_audit.sp_set_audit
  (v_surveyusermapid,'TBL_SURVEYUSERMAP', 'SUBMITTEDDATE',TO_CHAR(:OLD.SUBMITTEDDATE, 'DD-MON-YYYY'), TO_CHAR(:NEW.SUBMITTEDDATE, 'DD-MON-YYYY'),v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

  if v_auditid is not null then
  FOR i IN (SELECT tssa.belongto,ts.surveytitle,tssa.studyid
            FROM TCSIP_CPORTAL.TBL_SURVEY ts,
             TCSIP_CPORTAL.TBL_SURVEYSIPASSOCIATION tssa
            WHERE ts.surveyid = tssa.belongto
           AND tssa.istemplate = 0
           AND ts.surveyid = v_belongto) LOOP
    pkg_audit.sp_set_surveyauditreportmap
    (v_auditid,i.belongto,i.surveytitle,i.studyid, null, v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  END LOOP;
  end if;

  pkg_audit.sp_set_audit
  (v_surveyusermapid,'TBL_SURVEYUSERMAP', 'SURVEYSTATUS',pkg_audit.fn_get_lov_value(:OLD.SURVEYSTATUS, pkg_audit.g_lov_surveystatus),pkg_audit.fn_get_lov_value(:NEW.SURVEYSTATUS, pkg_audit.g_lov_surveystatus),v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

  if v_auditid is not null then
  FOR i IN (SELECT tssa.belongto,ts.surveytitle,tssa.studyid
            FROM TCSIP_CPORTAL.TBL_SURVEY ts,
             TCSIP_CPORTAL.TBL_SURVEYSIPASSOCIATION tssa
            WHERE ts.surveyid = tssa.belongto
           AND tssa.istemplate = 0
           AND ts.surveyid = v_belongto) LOOP
    pkg_audit.sp_set_surveyauditreportmap
    (v_auditid,i.belongto,i.surveytitle,i.studyid, null, v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  END LOOP;
  end if;


    pkg_audit.sp_set_audit
  (v_surveyusermapid,'TBL_SURVEYUSERMAP', 'RESPONSEMANAGERID',:OLD.RESPONSEMANAGERID,:NEW.RESPONSEMANAGERID,v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

  if v_auditid is not null then
  FOR i IN (SELECT tssa.belongto,ts.surveytitle,tssa.studyid
            FROM TCSIP_CPORTAL.TBL_SURVEY ts,
             TCSIP_CPORTAL.TBL_SURVEYSIPASSOCIATION tssa
            WHERE ts.surveyid = tssa.belongto
           AND tssa.istemplate = 0
           AND ts.surveyid = v_belongto) LOOP
    pkg_audit.sp_set_surveyauditreportmap
    (v_auditid,i.belongto,i.surveytitle,i.studyid, null, v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  END LOOP;
  end if;


  pkg_audit.sp_set_audit
  (v_surveyusermapid,'TBL_SURVEYUSERMAP', 'ISDELEGATED',:OLD.ISDELEGATED,:NEW.ISDELEGATED,v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

  if v_auditid is not null then
  FOR i IN (SELECT tssa.belongto,ts.surveytitle,tssa.studyid
            FROM TCSIP_CPORTAL.TBL_SURVEY ts,
             TCSIP_CPORTAL.TBL_SURVEYSIPASSOCIATION tssa
            WHERE ts.surveyid = tssa.belongto
           AND tssa.istemplate = 0
           AND ts.surveyid = v_belongto) LOOP
    pkg_audit.sp_set_surveyauditreportmap
    (v_auditid,i.belongto,i.surveytitle,i.studyid, null, v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  END LOOP;
  end if;


    pkg_audit.sp_set_audit
  (v_surveyusermapid,'TBL_SURVEYUSERMAP', 'SURVEYNOTIFICATIONLINK',:OLD.SURVEYNOTIFICATIONLINK,:NEW.SURVEYNOTIFICATIONLINK,v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

  if v_auditid is not null then
  FOR i IN (SELECT tssa.belongto,ts.surveytitle,tssa.studyid
            FROM TCSIP_CPORTAL.TBL_SURVEY ts,
             TCSIP_CPORTAL.TBL_SURVEYSIPASSOCIATION tssa
            WHERE ts.surveyid = tssa.belongto
           AND tssa.istemplate = 0
           AND ts.surveyid = v_belongto) LOOP
    pkg_audit.sp_set_surveyauditreportmap
    (v_auditid,i.belongto,i.surveytitle,i.studyid, null, v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  END LOOP;
  end if;

      pkg_audit.sp_set_audit
  (v_surveyusermapid,'TBL_SURVEYUSERMAP', 'SURVEYDELIVERYDATE',TO_CHAR(:OLD.SURVEYDELIVERYDATE, 'DD-MON-YYYY'), TO_CHAR(:NEW.SURVEYDELIVERYDATE, 'DD-MON-YYYY'),v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

  if v_auditid is not null then
  FOR i IN (SELECT tssa.belongto,ts.surveytitle,tssa.studyid
            FROM TCSIP_CPORTAL.TBL_SURVEY ts,
             TCSIP_CPORTAL.TBL_SURVEYSIPASSOCIATION tssa
            WHERE ts.surveyid = tssa.belongto
           AND tssa.istemplate = 0
           AND ts.surveyid = v_belongto) LOOP
    pkg_audit.sp_set_surveyauditreportmap
    (v_auditid,i.belongto,i.surveytitle,i.studyid, null, v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  END LOOP;
  end if;

  pkg_audit.sp_set_audit
  (v_surveyusermapid,'TBL_SURVEYUSERMAP', 'SURVEYNOTIFICATIONTITLE',:OLD.SURVEYNOTIFICATIONTITLE,:NEW.SURVEYNOTIFICATIONTITLE,v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

  if v_auditid is not null then
  FOR i IN (SELECT tssa.belongto,ts.surveytitle,tssa.studyid
            FROM TCSIP_CPORTAL.TBL_SURVEY ts,
             TCSIP_CPORTAL.TBL_SURVEYSIPASSOCIATION tssa
            WHERE ts.surveyid = tssa.belongto
           AND tssa.istemplate = 0
           AND ts.surveyid = v_belongto) LOOP
    pkg_audit.sp_set_surveyauditreportmap
    (v_auditid,i.belongto,i.surveytitle,i.studyid, null, v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  END LOOP;
  end if;

    pkg_audit.sp_set_audit
  (v_surveyusermapid,'TBL_SURVEYUSERMAP', 'SURVEYNOTIFICATIONBODY',:OLD.SURVEYNOTIFICATIONBODY,:NEW.SURVEYNOTIFICATIONBODY,v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

  if v_auditid is not null then
  FOR i IN (SELECT tssa.belongto,ts.surveytitle,tssa.studyid
            FROM TCSIP_CPORTAL.TBL_SURVEY ts,
             TCSIP_CPORTAL.TBL_SURVEYSIPASSOCIATION tssa
            WHERE ts.surveyid = tssa.belongto
           AND tssa.istemplate = 0
           AND ts.surveyid = v_belongto) LOOP
    pkg_audit.sp_set_surveyauditreportmap
    (v_auditid,i.belongto,i.surveytitle,i.studyid, null, v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  END LOOP;
  end if;


  pkg_audit.sp_set_audit
  (v_surveyusermapid,'TBL_SURVEYUSERMAP', 'REASONID',pkg_audit.fn_get_lov_value(:OLD.REASONID, pkg_audit.g_lov_reasons),pkg_audit.fn_get_lov_value(:NEW.REASONID, pkg_audit.g_lov_reasons),v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

  if v_auditid is not null then
  FOR i IN (SELECT tssa.belongto,ts.surveytitle,tssa.studyid
            FROM TCSIP_CPORTAL.TBL_SURVEY ts,
             TCSIP_CPORTAL.TBL_SURVEYSIPASSOCIATION tssa
            WHERE ts.surveyid = tssa.belongto
           AND tssa.istemplate = 0
           AND ts.surveyid = v_belongto) LOOP
    pkg_audit.sp_set_surveyauditreportmap
    (v_auditid,i.belongto,i.surveytitle,i.studyid, null, v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  END LOOP;
  end if;

    pkg_audit.sp_set_audit
  (v_surveyusermapid,'TBL_SURVEYUSERMAP', 'OTHERTEXT',:OLD.OTHERTEXT,:NEW.OTHERTEXT,v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

  if v_auditid is not null then
  FOR i IN (SELECT tssa.belongto,ts.surveytitle,tssa.studyid
            FROM TCSIP_CPORTAL.TBL_SURVEY ts,
             TCSIP_CPORTAL.TBL_SURVEYSIPASSOCIATION tssa
            WHERE ts.surveyid = tssa.belongto
           AND tssa.istemplate = 0
           AND ts.surveyid = v_belongto) LOOP
    pkg_audit.sp_set_surveyauditreportmap
    (v_auditid,i.belongto,i.surveytitle,i.studyid, null, v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  END LOOP;
  end if;

  pkg_audit.sp_set_audit
  (v_surveyusermapid,'TBL_SURVEYUSERMAP', 'CREATEDDT',TO_CHAR(:OLD.createddt, 'DD-MON-YYYY'), TO_CHAR(:NEW.createddt, 'DD-MON-YYYY'),v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

  if v_auditid is not null then
  FOR i IN (SELECT tssa.belongto,ts.surveytitle,tssa.studyid
            FROM TCSIP_CPORTAL.TBL_SURVEY ts,
             TCSIP_CPORTAL.TBL_SURVEYSIPASSOCIATION tssa
            WHERE ts.surveyid = tssa.belongto
           AND tssa.istemplate = 0
           AND ts.surveyid = v_belongto) LOOP
    pkg_audit.sp_set_surveyauditreportmap
    (v_auditid,i.belongto,i.surveytitle,i.studyid, null, v_createddt,v_createdby,v_modifieddt,v_modifiedby);
   END LOOP;
   end if;


  pkg_audit.sp_set_audit
  (v_surveyusermapid,'TBL_SURVEYUSERMAP', 'CREATEDBY',:OLD.createdby,:NEW.createdby,v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

  if v_auditid is not null then
  FOR i IN (SELECT tssa.belongto,ts.surveytitle,tssa.studyid
            FROM TCSIP_CPORTAL.TBL_SURVEY ts,
             TCSIP_CPORTAL.TBL_SURVEYSIPASSOCIATION tssa
            WHERE ts.surveyid = tssa.belongto
           AND tssa.istemplate = 0
           AND ts.surveyid = v_belongto) LOOP
    pkg_audit.sp_set_surveyauditreportmap
    (v_auditid,i.belongto,i.surveytitle,i.studyid, null, v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  END LOOP;
  end if;



  pkg_audit.sp_set_audit
  (v_surveyusermapid,'TBL_SURVEYUSERMAP', 'MODIFIEDDT',TO_CHAR(:OLD.modifieddt, 'DD-MON-YYYY'), TO_CHAR(:NEW.modifieddt, 'DD-MON-YYYY'),v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

  if v_auditid is not null then
  FOR i IN (SELECT tssa.belongto,ts.surveytitle,tssa.studyid
            FROM TCSIP_CPORTAL.TBL_SURVEY ts,
             TCSIP_CPORTAL.TBL_SURVEYSIPASSOCIATION tssa
            WHERE ts.surveyid = tssa.belongto
           AND tssa.istemplate = 0
           AND ts.surveyid = v_belongto) LOOP
    pkg_audit.sp_set_surveyauditreportmap
    (v_auditid,i.belongto,i.surveytitle,i.studyid, null, v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  END LOOP;
  end if;


  pkg_audit.sp_set_audit
  (v_surveyusermapid,'TBL_SURVEYUSERMAP', 'MODIFIEDBY',:OLD.modifiedby,:NEW.modifiedby,v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

  if v_auditid is not null then
  FOR i IN (SELECT tssa.belongto,ts.surveytitle,tssa.studyid
            FROM TCSIP_CPORTAL.TBL_SURVEY ts,
             TCSIP_CPORTAL.TBL_SURVEYSIPASSOCIATION tssa
            WHERE ts.surveyid = tssa.belongto
           AND tssa.istemplate = 0
           AND ts.surveyid = v_belongto) LOOP
    pkg_audit.sp_set_surveyauditreportmap
    (v_auditid,i.belongto,i.surveytitle,i.studyid, null, v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  END LOOP;
  end if;

    pkg_audit.sp_set_audit
  (v_surveyusermapid,'TBL_SURVEYUSERMAP', 'REFERENCECODE',:OLD.referencecode,:NEW.referencecode,v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

  if v_auditid is not null then
  FOR i IN (SELECT tssa.belongto,ts.surveytitle,tssa.studyid
            FROM TCSIP_CPORTAL.TBL_SURVEY ts,
             TCSIP_CPORTAL.TBL_SURVEYSIPASSOCIATION tssa
            WHERE ts.surveyid = tssa.belongto
           AND tssa.istemplate = 0
           AND ts.surveyid = v_belongto) LOOP
    pkg_audit.sp_set_surveyauditreportmap
    (v_auditid,i.belongto,i.surveytitle,i.studyid, null, v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  END LOOP;
  end if;

    pkg_audit.sp_set_audit
  (v_surveyusermapid,'TBL_SURVEYUSERMAP', 'ISDELIVERED',:OLD.isdelivered,:NEW.isdelivered,v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

  if v_auditid is not null then
  FOR i IN (SELECT tssa.belongto,ts.surveytitle,tssa.studyid
            FROM TCSIP_CPORTAL.TBL_SURVEY ts,
             TCSIP_CPORTAL.TBL_SURVEYSIPASSOCIATION tssa
            WHERE ts.surveyid = tssa.belongto
           AND tssa.istemplate = 0
           AND ts.surveyid = v_belongto) LOOP
    pkg_audit.sp_set_surveyauditreportmap
    (v_auditid,i.belongto,i.surveytitle,i.studyid, null, v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  END LOOP;
  end if;

    pkg_audit.sp_set_audit
  (v_surveyusermapid,'TBL_SURVEYUSERMAP', 'DELEGATETRANSID',:OLD.DELEGATETRANSID,:NEW.DELEGATETRANSID,v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

  if v_auditid is not null then
  FOR i IN (SELECT tssa.belongto,ts.surveytitle,tssa.studyid
            FROM TCSIP_CPORTAL.TBL_SURVEY ts,
             TCSIP_CPORTAL.TBL_SURVEYSIPASSOCIATION tssa
            WHERE ts.surveyid = tssa.belongto
           AND tssa.istemplate = 0
           AND ts.surveyid = v_belongto) LOOP
    pkg_audit.sp_set_surveyauditreportmap
    (v_auditid,i.belongto,i.surveytitle,i.studyid, null, v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  END LOOP;
  end if;
  
   pkg_audit.sp_set_audit
  (v_surveyusermapid,'TBL_SURVEYUSERMAP', 'RECIPIENTSTATUS',pkg_audit.fn_get_lov_value(:OLD.RECIPIENTSTATUS, pkg_audit.g_lov_recptstatus),pkg_audit.fn_get_lov_value(:NEW.RECIPIENTSTATUS, pkg_audit.g_lov_recptstatus),v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

  if v_auditid is not null then
  FOR i IN (SELECT tssa.belongto,ts.surveytitle,tssa.studyid
            FROM TCSIP_CPORTAL.TBL_SURVEY ts,
             TCSIP_CPORTAL.TBL_SURVEYSIPASSOCIATION tssa
            WHERE ts.surveyid = tssa.belongto
           AND tssa.istemplate = 0
           AND ts.surveyid = v_belongto) LOOP
    pkg_audit.sp_set_surveyauditreportmap
    (v_auditid,i.belongto,i.surveytitle,i.studyid, null, v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  END LOOP;
  end if;

  pkg_audit.sp_del_deletedrecords('TBL_SURVEYUSERMAP',v_surveyusermapid);


END TRG_TBL_SURVEYUSERMAP_AUDIT;
/