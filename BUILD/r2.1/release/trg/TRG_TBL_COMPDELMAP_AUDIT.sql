create or replace TRIGGER "TCSIP_CPORTAL"."TRG_TBL_COMPDELMAP_AUDIT" 
AFTER INSERT OR UPDATE OR DELETE ON TCSIP_CPORTAL.TBL_COMPLETEDELEGATIONMAP
FOR EACH ROW
DECLARE
v_operation           tbl_audit.operation%TYPE;
v_auditid             tbl_audit.auditid%TYPE;
v_completedelegationmapid  TBL_COMPLETEDELEGATIONMAP.COMPLETEDELEGATIONMAPID%TYPE;
v_createdby           tbl_audit.createdby%TYPE;
v_createddt           tbl_audit.createddt%TYPE;
v_modifiedby          tbl_audit.modifiedby%TYPE;
v_modifieddt          tbl_audit.modifieddt%TYPE;
v_belongto            TBL_SURVEYUSERMAP.belongto%TYPE;
v_transid             TBL_COMPLETEDELEGATIONMAP.delegaterecipientid%TYPE;
v_sysdate DATE:=SYSDATE;
 BEGIN
  IF INSERTING THEN
    v_operation := pkg_audit.g_operation_create;
    v_createdby := :NEW.createdby;
    v_createddt := :NEW.createddt;
    v_modifiedby := :NEW.createdby;
    v_modifieddt := :NEW.createddt;
    v_completedelegationmapid:= :NEW.completedelegationmapid;
    --v_belongto:=:NEW.belongto;
    v_transid:=:NEW.delegaterecipientid;
  ELSIF UPDATING THEN
    v_operation := pkg_audit.g_operation_update;
    v_createdby := :NEW.modifiedby;
    v_createddt := :NEW.modifieddt;
    v_modifiedby := :NEW.modifiedby;
    v_modifieddt := :NEW.modifieddt;
    v_completedelegationmapid:= :NEW.completedelegationmapid;
    --v_belongto:=:NEW.v_belongto;
    v_transid:=:NEW.delegaterecipientid;
  ELSIF DELETING THEN
    v_operation := pkg_audit.g_operation_delete;
    v_createdby := pkg_audit.fn_get_del_createdby('TBL_COMPLETEDELEGATIONMAP',v_completedelegationmapid);
    v_createddt := pkg_audit.fn_get_del_createddt('TBL_COMPLETEDELEGATIONMAP',v_completedelegationmapid);
    v_modifiedby := pkg_audit.fn_get_del_createdby('TBL_COMPLETEDELEGATIONMAP',v_completedelegationmapid);
    v_modifieddt := pkg_audit.fn_get_del_createddt('TBL_COMPLETEDELEGATIONMAP',v_completedelegationmapid);
    --v_belongto:=:OLD.v_belongto;
    v_completedelegationmapid:= :OLD.completedelegationmapid;
    v_transid:=:OLD.delegaterecipientid;
  END IF;

  pkg_audit.sp_set_audit
  (v_completedelegationmapid,'TBL_COMPLETEDELEGATIONMAP', 'COMPLETEDELEGATIONMAPID',:OLD.COMPLETEDELEGATIONMAPID,:NEW.COMPLETEDELEGATIONMAPID,v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

  if v_auditid is not null then
  FOR i IN (SELECT tssa.belongto,ts.surveytitle,tssa.studyid
            FROM TCSIP_CPORTAL.TBL_SURVEY ts,
             TCSIP_CPORTAL.TBL_SURVEYSIPASSOCIATION tssa,
             TCSIP_CPORTAL.TBL_SURVEYUSERMAP su
            WHERE ts.surveyid = tssa.belongto
           AND    ts.surveyid =su.belongto
           AND tssa.istemplate = 0
           AND su.delegatetransid =v_transid
           AND ts.surveyid = v_belongto		   ) LOOP
    pkg_audit.sp_set_surveyauditreportmap
    (v_auditid,i.belongto,i.surveytitle,i.studyid, null, v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  END LOOP;
  end if;


  pkg_audit.sp_set_audit
  (v_completedelegationmapid,'TBL_COMPLETEDELEGATIONMAP', 'PRINCIPALINVESTIGATORID',:OLD.PRINCIPALINVESTIGATORID,:NEW.PRINCIPALINVESTIGATORID,v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

  if v_auditid is not null then
  FOR i IN (SELECT tssa.belongto,ts.surveytitle,tssa.studyid
            FROM TCSIP_CPORTAL.TBL_SURVEY ts,
             TCSIP_CPORTAL.TBL_SURVEYSIPASSOCIATION tssa,
             TCSIP_CPORTAL.TBL_SURVEYUSERMAP su
            WHERE ts.surveyid = tssa.belongto
           AND    ts.surveyid =su.belongto
           AND tssa.istemplate = 0
           AND su.delegatetransid =v_transid
           AND ts.surveyid = v_belongto		   ) LOOP
    pkg_audit.sp_set_surveyauditreportmap
    (v_auditid,i.belongto,i.surveytitle,i.studyid, null, v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  END LOOP;
  end if;

    pkg_audit.sp_set_audit
  (v_completedelegationmapid,'TBL_COMPLETEDELEGATIONMAP', 'DELEGATERECIPIENTID', :OLD.DELEGATERECIPIENTID, :NEW.DELEGATERECIPIENTID,v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

  if v_auditid is not null then
  FOR i IN (SELECT tssa.belongto,ts.surveytitle,tssa.studyid
            FROM TCSIP_CPORTAL.TBL_SURVEY ts,
             TCSIP_CPORTAL.TBL_SURVEYSIPASSOCIATION tssa,
             TCSIP_CPORTAL.TBL_SURVEYUSERMAP su
            WHERE ts.surveyid = tssa.belongto
           AND    ts.surveyid =su.belongto
           AND tssa.istemplate = 0
           AND su.delegatetransid =v_transid
           AND ts.surveyid = v_belongto		   ) LOOP
    pkg_audit.sp_set_surveyauditreportmap
    (v_auditid,i.belongto,i.surveytitle,i.studyid, null, v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  END LOOP;
  end if;

  pkg_audit.sp_set_audit
  (v_completedelegationmapid,'TBL_COMPLETEDELEGATIONMAP', 'ISACTIVE',:OLD.ISACTIVE,:NEW.ISACTIVE,v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

  if v_auditid is not null then
  FOR i IN (SELECT tssa.belongto,ts.surveytitle,tssa.studyid
            FROM TCSIP_CPORTAL.TBL_SURVEY ts,
             TCSIP_CPORTAL.TBL_SURVEYSIPASSOCIATION tssa,
             TCSIP_CPORTAL.TBL_SURVEYUSERMAP su
            WHERE ts.surveyid = tssa.belongto
           AND    ts.surveyid =su.belongto
           AND tssa.istemplate = 0
           AND su.delegatetransid =v_transid
           AND ts.surveyid = v_belongto		   ) LOOP
    pkg_audit.sp_set_surveyauditreportmap
    (v_auditid,i.belongto,i.surveytitle,i.studyid, null, v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  END LOOP;
  end if;

  pkg_audit.sp_set_audit
  (v_completedelegationmapid,'TBL_COMPLETEDELEGATIONMAP', 'CREATEDBY',:OLD.CREATEDBY,:NEW.CREATEDBY,v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);


  if v_auditid is not null then
  FOR i IN (SELECT tssa.belongto,ts.surveytitle,tssa.studyid
            FROM TCSIP_CPORTAL.TBL_SURVEY ts,
             TCSIP_CPORTAL.TBL_SURVEYSIPASSOCIATION tssa,
             TCSIP_CPORTAL.TBL_SURVEYUSERMAP su
            WHERE ts.surveyid = tssa.belongto
           AND    ts.surveyid =su.belongto
           AND tssa.istemplate = 0
           AND su.delegatetransid =v_transid
           AND ts.surveyid = v_belongto		   ) LOOP
    pkg_audit.sp_set_surveyauditreportmap
    (v_auditid,i.belongto,i.surveytitle,i.studyid, null, v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  END LOOP;
  end if;
  
  pkg_audit.sp_set_audit
  (v_completedelegationmapid,'TBL_COMPLETEDELEGATIONMAP', 'CREATEDDT',TO_CHAR(:OLD.CREATEDDT, 'DD-MON-YYYY'), TO_CHAR(:NEW.CREATEDDT, 'DD-MON-YYYY'),v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

 if v_auditid is not null then
  FOR i IN (SELECT tssa.belongto,ts.surveytitle,tssa.studyid
            FROM TCSIP_CPORTAL.TBL_SURVEY ts,
             TCSIP_CPORTAL.TBL_SURVEYSIPASSOCIATION tssa,
             TCSIP_CPORTAL.TBL_SURVEYUSERMAP su
            WHERE ts.surveyid = tssa.belongto
           AND    ts.surveyid =su.belongto
           AND tssa.istemplate = 0
           AND su.delegatetransid =v_transid
           AND ts.surveyid = v_belongto		   ) LOOP
    pkg_audit.sp_set_surveyauditreportmap
    (v_auditid,i.belongto,i.surveytitle,i.studyid, null, v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  END LOOP;
  end if;

  pkg_audit.sp_set_audit
  (v_completedelegationmapid,'TBL_COMPLETEDELEGATIONMAP', 'MODIFIEDBY',:OLD.MODIFIEDBY,:NEW.MODIFIEDBY,v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);


  if v_auditid is not null then
  FOR i IN (SELECT tssa.belongto,ts.surveytitle,tssa.studyid
            FROM TCSIP_CPORTAL.TBL_SURVEY ts,
             TCSIP_CPORTAL.TBL_SURVEYSIPASSOCIATION tssa,
             TCSIP_CPORTAL.TBL_SURVEYUSERMAP su
            WHERE ts.surveyid = tssa.belongto
           AND    ts.surveyid =su.belongto
           AND tssa.istemplate = 0
           AND su.delegatetransid =v_transid
           AND ts.surveyid = v_belongto		   ) LOOP
    pkg_audit.sp_set_surveyauditreportmap
    (v_auditid,i.belongto,i.surveytitle,i.studyid, null, v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  END LOOP;
  end if;
  
  pkg_audit.sp_set_audit
  (v_completedelegationmapid,'TBL_COMPLETEDELEGATIONMAP', 'MODIFIEDDT',TO_CHAR(:OLD.MODIFIEDDT, 'DD-MON-YYYY'), TO_CHAR(:NEW.MODIFIEDDT, 'DD-MON-YYYY'),v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

 

  pkg_audit.sp_del_deletedrecords('TBL_COMPLETEDELEGATIONMAP',v_completedelegationmapid);


END TRG_TBL_COMPDELMAP_AUDIT;
/