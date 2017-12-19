CREATE OR REPLACE TRIGGER TCSIP_CPORTAL.TRG_TBL_SURVEYTEMPLATE_AUDIT
AFTER INSERT OR UPDATE OR DELETE ON TCSIP_CPORTAL.TBL_SURVEYTEMPLATE
FOR EACH ROW
DECLARE
v_operation     tbl_audit.operation%TYPE;
v_auditid       tbl_audit.auditid%TYPE;
v_createdby     tbl_audit.createdby%TYPE;
v_createddt     tbl_audit.createddt%TYPE;
v_modifiedby    tbl_audit.modifiedby%TYPE;
v_modifieddt    tbl_audit.modifieddt%TYPE;
v_surveytemptitle  TBL_SURVEYTEMPLATE.TEMPLATETITLE%TYPE;
v_surveyid         TBL_SURVEYTEMPLATE.surveytemplateid%type;
v_sysdate DATE:=SYSDATE;
v_count PLS_INTEGER:=0;
BEGIN
  IF INSERTING THEN
    v_operation := pkg_audit.g_operation_create;
    v_createdby := :NEW.createdby;
    v_createddt := :NEW.createddt;
    v_modifiedby := :NEW.createdby;
    v_modifieddt := :NEW.createddt;
    v_surveytemptitle:= :NEW.TEMPLATETITLE;
    v_surveyid          :=:NEW.SURVEYTEMPLATEID;
  ELSIF UPDATING THEN
    v_operation := pkg_audit.g_operation_update;
    v_createdby := :NEW.modifiedby;
    v_createddt := :NEW.modifieddt;
    v_modifiedby := :NEW.modifiedby;
    v_modifieddt := :NEW.modifieddt;
    v_surveytemptitle:= :NEW.TEMPLATETITLE;
     v_surveyid    :=:NEW.surveytemplateid;
  ELSIF DELETING THEN
    v_operation := pkg_audit.g_operation_update;
    v_createdby := :old.modifiedby;
    v_createddt := v_sysdate;
    v_modifiedby := :old.modifiedby;
    v_modifieddt := v_sysdate;
    v_surveytemptitle:= :old.TEMPLATETITLE;
    v_surveyid          :=:old.surveytemplateid;
  END IF;
  
    SELECT COUNT(1)
  INTO v_count
  FROM TCSIP_CPORTAL.tbl_surveysipassociation sc
  WHERE sc.belongto = v_surveyid and sc.ISTEMPLATE='1';

  pkg_audit.sp_set_audit
  (v_surveyid,'TBL_SURVEYTEMPLATE','SURVEYTEMPLATEID',:OLD.SURVEYTEMPLATEID,:NEW.SURVEYTEMPLATEID,v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

  if v_auditid is not null then
 IF  v_count <> 0 THEN
  FOR i IN (SELECT DISTINCT sc.studyid
            FROM TCSIP_CPORTAL.tbl_surveysipassociation sc
            WHERE sc.belongto = v_surveyid and sc.ISTEMPLATE='1'
            ) LOOP
  pkg_audit.sp_set_surveyauditreportmap
  (v_auditid,v_surveyid,v_surveytemptitle,i.studyid, null, v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  end loop;
  ELSE
  pkg_audit.sp_set_surveyauditreportmap
  (v_auditid,v_surveyid,v_surveytemptitle,NULL, null, v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  END IF;
  end if;
  
pkg_audit.sp_set_audit
  (v_surveyid,'TBL_SURVEYTEMPLATE','TEMPLATETITLE',:OLD.TEMPLATETITLE,:NEW.TEMPLATETITLE,v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

    if v_auditid is not null then
 IF  v_count <> 0 THEN
  FOR i IN (SELECT DISTINCT sc.studyid
            FROM TCSIP_CPORTAL.tbl_surveysipassociation sc
            WHERE sc.belongto = v_surveyid and sc.ISTEMPLATE='1'
            ) LOOP
  pkg_audit.sp_set_surveyauditreportmap
  (v_auditid,v_surveyid,v_surveytemptitle,i.studyid, null, v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  end loop;
  ELSE
  pkg_audit.sp_set_surveyauditreportmap
  (v_auditid,v_surveyid,v_surveytemptitle,NULL, null, v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  END IF;
  end if;

pkg_audit.sp_set_audit
  (v_surveyid,'TBL_SURVEYTEMPLATE','SURVEYID',:OLD.SURVEYID,:NEW.SURVEYID,v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

    if v_auditid is not null then
 IF  v_count <> 0 THEN
  FOR i IN (SELECT DISTINCT sc.studyid
            FROM TCSIP_CPORTAL.tbl_surveysipassociation sc
            WHERE sc.belongto = v_surveyid and sc.ISTEMPLATE='1'
            ) LOOP
  pkg_audit.sp_set_surveyauditreportmap
  (v_auditid,v_surveyid,v_surveytemptitle,i.studyid, null, v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  end loop;
  ELSE
  pkg_audit.sp_set_surveyauditreportmap
  (v_auditid,v_surveyid,v_surveytemptitle,NULL, null, v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  END IF;
  end if;

pkg_audit.sp_set_audit
  (v_surveyid,'TBL_SURVEYTEMPLATE','CREATEDDT',TO_CHAR(:OLD.CREATEDDT, 'DD-MON-YYYY'), TO_CHAR(:NEW.CREATEDDT, 'DD-MON-YYYY'),v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

  if v_auditid is not null then
 IF  v_count <> 0 THEN
  FOR i IN (SELECT DISTINCT sc.studyid
            FROM TCSIP_CPORTAL.tbl_surveysipassociation sc
            WHERE sc.belongto = v_surveyid and sc.ISTEMPLATE='1'
            ) LOOP
  pkg_audit.sp_set_surveyauditreportmap
  (v_auditid,v_surveyid,v_surveytemptitle,i.studyid, null, v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  end loop;
  ELSE
  pkg_audit.sp_set_surveyauditreportmap
  (v_auditid,v_surveyid,v_surveytemptitle,NULL, null, v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  END IF;
  end if;

pkg_audit.sp_set_audit
  (v_surveyid,'TBL_SURVEYTEMPLATE','CREATEDBY',:OLD.CREATEDBY,:NEW.CREATEDBY,v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

   if v_auditid is not null then
 IF  v_count <> 0 THEN
  FOR i IN (SELECT DISTINCT sc.studyid
            FROM TCSIP_CPORTAL.tbl_surveysipassociation sc
            WHERE sc.belongto = v_surveyid and sc.ISTEMPLATE='1'
            ) LOOP
  pkg_audit.sp_set_surveyauditreportmap
  (v_auditid,v_surveyid,v_surveytemptitle,i.studyid, null, v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  end loop;
  ELSE
  pkg_audit.sp_set_surveyauditreportmap
  (v_auditid,v_surveyid,v_surveytemptitle,NULL, null, v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  END IF;
  end if;

pkg_audit.sp_set_audit
  (v_surveyid,'TBL_SURVEYTEMPLATE','MODIFIEDDT',TO_CHAR(:OLD.MODIFIEDDT, 'DD-MON-YYYY'), TO_CHAR(:NEW.MODIFIEDDT, 'DD-MON-YYYY'),v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

   if v_auditid is not null then
 IF  v_count <> 0 THEN
  FOR i IN (SELECT DISTINCT sc.studyid
            FROM TCSIP_CPORTAL.tbl_surveysipassociation sc
            WHERE sc.belongto = v_surveyid and sc.ISTEMPLATE='1'
            ) LOOP
  pkg_audit.sp_set_surveyauditreportmap
  (v_auditid,v_surveyid,v_surveytemptitle,i.studyid, null, v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  end loop;
  ELSE
  pkg_audit.sp_set_surveyauditreportmap
  (v_auditid,v_surveyid,v_surveytemptitle,NULL, null, v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  END IF;
  end if;

pkg_audit.sp_set_audit
  (v_surveyid,'TBL_SURVEYTEMPLATE','MODIFIEDBY',:OLD.MODIFIEDBY,:NEW.MODIFIEDBY,v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

   if v_auditid is not null then
 IF  v_count <> 0 THEN
  FOR i IN (SELECT DISTINCT sc.studyid
            FROM TCSIP_CPORTAL.tbl_surveysipassociation sc
            WHERE sc.belongto = v_surveyid and sc.ISTEMPLATE='1'
            ) LOOP
  pkg_audit.sp_set_surveyauditreportmap
  (v_auditid,v_surveyid,v_surveytemptitle,i.studyid, null, v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  end loop;
  ELSE
  pkg_audit.sp_set_surveyauditreportmap
  (v_auditid,v_surveyid,v_surveytemptitle,NULL, null, v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  END IF;
  end if;

pkg_audit.sp_set_audit
  (v_surveyid,'TBL_SURVEYTEMPLATE','TEMPLATECD',:OLD.TEMPLATECD,:NEW.TEMPLATECD,v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

   if v_auditid is not null then
 IF  v_count <> 0 THEN
  FOR i IN (SELECT DISTINCT sc.studyid
            FROM TCSIP_CPORTAL.tbl_surveysipassociation sc
            WHERE sc.belongto = v_surveyid and sc.ISTEMPLATE='1'
            ) LOOP
  pkg_audit.sp_set_surveyauditreportmap
  (v_auditid,v_surveyid,v_surveytemptitle,i.studyid, null, v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  end loop;
  ELSE
  pkg_audit.sp_set_surveyauditreportmap
  (v_auditid,v_surveyid,v_surveytemptitle,NULL, null, v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  END IF;
  end if;

pkg_audit.sp_set_audit
  (v_surveyid,'TBL_SURVEYTEMPLATE','LANGUAGEID',:OLD.LANGUAGEID,:NEW.LANGUAGEID,v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

  if v_auditid is not null then
 IF  v_count <> 0 THEN
  FOR i IN (SELECT DISTINCT sc.studyid
            FROM TCSIP_CPORTAL.tbl_surveysipassociation sc
            WHERE sc.belongto = v_surveyid and sc.ISTEMPLATE='1'
            ) LOOP
  pkg_audit.sp_set_surveyauditreportmap
  (v_auditid,v_surveyid,v_surveytemptitle,i.studyid, null, v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  end loop;
  ELSE
  pkg_audit.sp_set_surveyauditreportmap
  (v_auditid,v_surveyid,v_surveytemptitle,NULL, null, v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  END IF;
  end if;

pkg_audit.sp_set_audit
  (v_surveyid,'TBL_SURVEYTEMPLATE','COUNTRYID',:OLD.COUNTRYID,:NEW.COUNTRYID,v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

  if v_auditid is not null then
 IF  v_count <> 0 THEN
  FOR i IN (SELECT DISTINCT sc.studyid
            FROM TCSIP_CPORTAL.tbl_surveysipassociation sc
            WHERE sc.belongto = v_surveyid and sc.ISTEMPLATE='1'
            ) LOOP
  pkg_audit.sp_set_surveyauditreportmap
  (v_auditid,v_surveyid,v_surveytemptitle,i.studyid, null, v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  end loop;
  ELSE
  pkg_audit.sp_set_surveyauditreportmap
  (v_auditid,v_surveyid,v_surveytemptitle,NULL, null, v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  END IF;
  end if;

pkg_audit.sp_set_audit
  (v_surveyid,'TBL_SURVEYTEMPLATE','TEMPLATESTATUS',:OLD.TEMPLATESTATUS,:NEW.TEMPLATESTATUS,v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

   if v_auditid is not null then
 IF  v_count <> 0 THEN
  FOR i IN (SELECT DISTINCT sc.studyid
            FROM TCSIP_CPORTAL.tbl_surveysipassociation sc
            WHERE sc.belongto = v_surveyid and sc.ISTEMPLATE='1'
            ) LOOP
  pkg_audit.sp_set_surveyauditreportmap
  (v_auditid,v_surveyid,v_surveytemptitle,i.studyid, null, v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  end loop;
  ELSE
  pkg_audit.sp_set_surveyauditreportmap
  (v_auditid,v_surveyid,v_surveytemptitle,NULL, null, v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  END IF;
  end if;

pkg_audit.sp_set_audit
  (v_surveyid,'TBL_SURVEYTEMPLATE','TEMPLATEDESC',:OLD.TEMPLATEDESC,:NEW.TEMPLATEDESC,v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

   if v_auditid is not null then
 IF  v_count <> 0 THEN
  FOR i IN (SELECT DISTINCT sc.studyid
            FROM TCSIP_CPORTAL.tbl_surveysipassociation sc
            WHERE sc.belongto = v_surveyid and sc.ISTEMPLATE='1'
            ) LOOP
  pkg_audit.sp_set_surveyauditreportmap
  (v_auditid,v_surveyid,v_surveytemptitle,i.studyid, null, v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  end loop;
  ELSE
  pkg_audit.sp_set_surveyauditreportmap
  (v_auditid,v_surveyid,v_surveytemptitle,NULL, null, v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  END IF;
  end if;

pkg_audit.sp_set_audit
  (v_surveyid,'TBL_SURVEYTEMPLATE','RECIPIENTTYPE',(CASE WHEN :OLD.RECIPIENTTYPE=21 THEN 'Site Users' ELSE 'Sponsor User' END),(CASE WHEN :NEW.RECIPIENTTYPE=21 THEN 'Site Users' ELSE 'Sponsor User' END),v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

   if v_auditid is not null then
 IF  v_count <> 0 THEN
  FOR i IN (SELECT DISTINCT sc.studyid
            FROM TCSIP_CPORTAL.tbl_surveysipassociation sc
            WHERE sc.belongto = v_surveyid and sc.ISTEMPLATE='1'
            ) LOOP
  pkg_audit.sp_set_surveyauditreportmap
  (v_auditid,v_surveyid,v_surveytemptitle,i.studyid, null, v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  end loop;
  ELSE
  pkg_audit.sp_set_surveyauditreportmap
  (v_auditid,v_surveyid,v_surveytemptitle,NULL, null, v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  END IF;
  end if;

pkg_audit.sp_set_audit
  (v_surveyid,'TBL_SURVEYTEMPLATE','SURVEYTYPE',:OLD.SURVEYTYPE,:NEW.SURVEYTYPE,v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

   if v_auditid is not null then
 IF  v_count <> 0 THEN
  FOR i IN (SELECT DISTINCT sc.studyid
            FROM TCSIP_CPORTAL.tbl_surveysipassociation sc
            WHERE sc.belongto = v_surveyid and sc.ISTEMPLATE='1'
            ) LOOP
  pkg_audit.sp_set_surveyauditreportmap
  (v_auditid,v_surveyid,v_surveytemptitle,i.studyid, null, v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  end loop;
  ELSE
  pkg_audit.sp_set_surveyauditreportmap
  (v_auditid,v_surveyid,v_surveytemptitle,NULL, null, v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  END IF;
  end if;
pkg_audit.sp_set_audit
  (v_surveyid,'TBL_SURVEYTEMPLATE','OTHERSURVEYTYPETEXT',:OLD.OTHERSURVEYTYPETEXT,:NEW.OTHERSURVEYTYPETEXT,v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

  if v_auditid is not null then
 IF  v_count <> 0 THEN
  FOR i IN (SELECT DISTINCT sc.studyid
            FROM TCSIP_CPORTAL.tbl_surveysipassociation sc
            WHERE sc.belongto = v_surveyid and sc.ISTEMPLATE='1'
            ) LOOP
  pkg_audit.sp_set_surveyauditreportmap
  (v_auditid,v_surveyid,v_surveytemptitle,i.studyid, null, v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  end loop;
  ELSE
  pkg_audit.sp_set_surveyauditreportmap
  (v_auditid,v_surveyid,v_surveytemptitle,NULL, null, v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  END IF;
  end if;

END TRG_TBL_SURVEYTEMPLATE_AUDIT;
/