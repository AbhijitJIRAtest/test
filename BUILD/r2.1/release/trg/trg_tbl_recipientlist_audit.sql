CREATE OR REPLACE TRIGGER "TCSIP_CPORTAL"."TRG_TBL_RECIPIENTLIST_AUDIT" 
AFTER INSERT OR UPDATE OR DELETE ON TCSIP_CPORTAL.TBL_RECIPIENTLIST
FOR EACH ROW
DECLARE
v_operation     tbl_audit.operation%TYPE;
v_auditid       tbl_audit.auditid%TYPE;
v_createdby     tbl_audit.createdby%TYPE;
v_createddt     tbl_audit.createddt%TYPE;
v_modifiedby    tbl_audit.modifiedby%TYPE;
v_modifieddt    tbl_audit.modifieddt%TYPE;
v_listid        tbl_recipientlist.listid%TYPE;
v_istemplate  tbl_recipientlist.istemplate%TYPE;
v_belongto  tbl_recipientlist.belongto%TYPE;
v_sysdate DATE:=SYSDATE;
BEGIN
  IF INSERTING THEN
    v_operation := pkg_audit.g_operation_create;
    v_createdby := :NEW.createdby;
    v_createddt := :NEW.createddt;
    v_modifiedby := :NEW.createdby;
    v_modifieddt := :NEW.createddt;
    v_listid:= :NEW.listid;
    v_istemplate:= :NEW.istemplate;
    v_belongto := :NEW.belongto;
  ELSIF UPDATING THEN
    v_operation := pkg_audit.g_operation_update;
    v_createdby := :NEW.modifiedby;
    v_createddt := :NEW.modifieddt;
    v_modifiedby := :NEW.modifiedby;
    v_modifieddt := :NEW.modifieddt;
    v_listid:= :NEW.listid;
    v_istemplate:= :NEW.istemplate;
    v_belongto := :NEW.belongto;
  ELSIF DELETING THEN
    v_operation := pkg_audit.g_operation_delete;
    v_createdby := :OLD.modifiedby;
    v_createddt := v_sysdate;
    v_modifiedby := :OLD.modifiedby;
    v_modifieddt := v_sysdate;
    v_listid:= :OLD.listid;
    v_istemplate:= :OLD.istemplate;
    v_belongto := :OLD.belongto;
  END IF;

  pkg_audit.sp_set_audit
  (v_listid,'TBL_RECIPIENTLIST', 'LISTID',:OLD.listid,:NEW.listid,v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

  if v_auditid is not null then
  FOR i IN (SELECT tssa.belongto surveyid,ts.surveytitle surveyname,tsu.lastname || ', ' || tsu.firstname surveyrecipient,tssa.studyid
            FROM tbl_surveyusermap tsum,
                 tbl_surveysipassociation tssa,
                 tbl_survey ts,
                 tbl_surveyuser tsu
            WHERE tssa.belongto = tsum.belongto
            AND tssa.istemplate = tsum.istemplate
            AND ts.surveyid = tssa.belongto
            AND tsum.surveyuserid = tsu.surveyuserid
            AND tsum.istemplate = 0
            AND tsum.istemplate = v_istemplate
            AND tsum.belongto = v_belongto) LOOP
    pkg_audit.sp_set_surveyauditreportmap
    (v_auditid,i.surveyid,i.surveyname,i.studyid,i.surveyrecipient,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  END LOOP;
  end if;

  pkg_audit.sp_set_audit
  (v_listid,'TBL_RECIPIENTLIST', 'LISTNAME',:OLD.listname,:NEW.listname,v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

  if v_auditid is not null then
  FOR i IN (SELECT tssa.belongto surveyid,ts.surveytitle surveyname,pkg_encrypt.fn_decrypt(tsu.lastname) || ', ' || pkg_encrypt.fn_decrypt(tsu.firstname) surveyrecipient,tssa.studyid
            FROM tbl_surveyusermap tsum,
                 tbl_surveysipassociation tssa,
                 tbl_survey ts,
                 tbl_surveyuser tsu
            WHERE tssa.belongto = tsum.belongto
            AND tssa.istemplate = tsum.istemplate
            AND ts.surveyid = tssa.belongto
            AND tsum.surveyuserid = tsu.surveyuserid
            AND tsum.istemplate = 0
            AND tsum.istemplate = v_istemplate
            AND tsum.belongto = v_belongto) LOOP
    pkg_audit.sp_set_surveyauditreportmap
    (v_auditid,i.surveyid,i.surveyname,i.studyid,i.surveyrecipient,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  END LOOP;
  end if;

  pkg_audit.sp_set_audit
  (v_listid,'TBL_RECIPIENTLIST', 'ISTEMPLATE',:OLD.istemplate,:NEW.istemplate,v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

  if v_auditid is not null then
  FOR i IN (SELECT tssa.belongto surveyid,ts.surveytitle surveyname,tsu.lastname || ', ' || tsu.firstname surveyrecipient,tssa.studyid
            FROM tbl_surveyusermap tsum,
                 tbl_surveysipassociation tssa,
                 tbl_survey ts,
                 tbl_surveyuser tsu
            WHERE tssa.belongto = tsum.belongto
            AND tssa.istemplate = tsum.istemplate
            AND ts.surveyid = tssa.belongto
            AND tsum.surveyuserid = tsu.surveyuserid
            AND tsum.istemplate = 0
            AND tsum.istemplate = v_istemplate
            AND tsum.belongto = v_belongto) LOOP
    pkg_audit.sp_set_surveyauditreportmap
    (v_auditid,i.surveyid,i.surveyname,i.studyid,i.surveyrecipient,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  END LOOP;
  end if;

  pkg_audit.sp_set_audit
  (v_listid,'TBL_RECIPIENTLIST', 'BELONGTO',:OLD.belongto,:NEW.belongto,v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

  if v_auditid is not null then
  FOR i IN (SELECT tssa.belongto surveyid,ts.surveytitle surveyname,tsu.lastname || ', ' || tsu.firstname surveyrecipient,tssa.studyid
            FROM tbl_surveyusermap tsum,
                 tbl_surveysipassociation tssa,
                 tbl_survey ts,
                 tbl_surveyuser tsu
            WHERE tssa.belongto = tsum.belongto
            AND tssa.istemplate = tsum.istemplate
            AND ts.surveyid = tssa.belongto
            AND tsum.surveyuserid = tsu.surveyuserid
            AND tsum.istemplate = 0
            AND tsum.istemplate = v_istemplate
            AND tsum.belongto = v_belongto) LOOP
    pkg_audit.sp_set_surveyauditreportmap
    (v_auditid,i.surveyid,i.surveyname,i.studyid,i.surveyrecipient,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  END LOOP;
  end if;

  pkg_audit.sp_set_audit
  (v_listid,'TBL_RECIPIENTLIST', 'CREATEDDT',TO_CHAR(:OLD.createddt, 'DD-MON-YYYY'), TO_CHAR(:NEW.createddt, 'DD-MON-YYYY'),v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

  if v_auditid is not null then
  FOR i IN (SELECT tssa.belongto surveyid,ts.surveytitle surveyname,tsu.lastname || ', ' || tsu.firstname surveyrecipient,tssa.studyid
            FROM tbl_surveyusermap tsum,
                 tbl_surveysipassociation tssa,
                 tbl_survey ts,
                 tbl_surveyuser tsu
            WHERE tssa.belongto = tsum.belongto
            AND tssa.istemplate = tsum.istemplate
            AND ts.surveyid = tssa.belongto
            AND tsum.surveyuserid = tsu.surveyuserid
            AND tsum.istemplate = 0
            AND tsum.istemplate = v_istemplate
            AND tsum.belongto = v_belongto) LOOP
    pkg_audit.sp_set_surveyauditreportmap
    (v_auditid,i.surveyid,i.surveyname,i.studyid,i.surveyrecipient,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  END LOOP;
  end if;

  pkg_audit.sp_set_audit
  (v_listid,'TBL_RECIPIENTLIST', 'CREATEDBY',:OLD.createdby,:NEW.createdby,v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

  if v_auditid is not null then
  FOR i IN (SELECT tssa.belongto surveyid,ts.surveytitle surveyname,tsu.lastname || ', ' || tsu.firstname surveyrecipient,tssa.studyid
            FROM tbl_surveyusermap tsum,
                 tbl_surveysipassociation tssa,
                 tbl_survey ts,
                 tbl_surveyuser tsu
            WHERE tssa.belongto = tsum.belongto
            AND tssa.istemplate = tsum.istemplate
            AND ts.surveyid = tssa.belongto
            AND tsum.surveyuserid = tsu.surveyuserid
            AND tsum.istemplate = 0
            AND tsum.istemplate = v_istemplate
            AND tsum.belongto = v_belongto) LOOP
    pkg_audit.sp_set_surveyauditreportmap
    (v_auditid,i.surveyid,i.surveyname,i.studyid,i.surveyrecipient,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  END LOOP;
  end if;

  pkg_audit.sp_set_audit
  (v_listid,'TBL_RECIPIENTLIST', 'MODIFIEDDT',TO_CHAR(:OLD.modifieddt, 'DD-MON-YYYY'), TO_CHAR(:NEW.modifieddt, 'DD-MON-YYYY'),v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

  if v_auditid is not null then
  FOR i IN (SELECT tssa.belongto surveyid,ts.surveytitle surveyname,tsu.lastname || ', ' || tsu.firstname surveyrecipient,tssa.studyid
            FROM tbl_surveyusermap tsum,
                 tbl_surveysipassociation tssa,
                 tbl_survey ts,
                 tbl_surveyuser tsu
            WHERE tssa.belongto = tsum.belongto
            AND tssa.istemplate = tsum.istemplate
            AND ts.surveyid = tssa.belongto
            AND tsum.surveyuserid = tsu.surveyuserid
            AND tsum.istemplate = 0
            AND tsum.istemplate = v_istemplate
            AND tsum.belongto = v_belongto) LOOP
    pkg_audit.sp_set_surveyauditreportmap
    (v_auditid,i.surveyid,i.surveyname,i.studyid,i.surveyrecipient,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  END LOOP;
  end if;

  pkg_audit.sp_set_audit
  (v_listid,'TBL_RECIPIENTLIST', 'MODIFIEDBY',:OLD.modifiedby,:NEW.modifiedby,v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

  if v_auditid is not null then
  FOR i IN (SELECT tssa.belongto surveyid,ts.surveytitle surveyname,tsu.lastname || ', ' || tsu.firstname surveyrecipient,tssa.studyid
            FROM tbl_surveyusermap tsum,
                 tbl_surveysipassociation tssa,
                 tbl_survey ts,
                 tbl_surveyuser tsu
            WHERE tssa.belongto = tsum.belongto
            AND tssa.istemplate = tsum.istemplate
            AND ts.surveyid = tssa.belongto
            AND tsum.surveyuserid = tsu.surveyuserid
            AND tsum.istemplate = 0
            AND tsum.istemplate = v_istemplate
            AND tsum.belongto = v_belongto) LOOP
    pkg_audit.sp_set_surveyauditreportmap
    (v_auditid,i.surveyid,i.surveyname,i.studyid,i.surveyrecipient,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  END LOOP;
  end if;

END trg_tbl_recipientlist_audit;
/