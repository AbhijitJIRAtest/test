CREATE OR REPLACE TRIGGER TCSIP_CPORTAL.TRG_TBL_SIPASSOCIATION_AUDIT
AFTER INSERT OR UPDATE OR DELETE ON TCSIP_CPORTAL.TBL_SURVEYSIPASSOCIATION
FOR EACH ROW
DECLARE
v_operation tbl_audit.operation%TYPE;
v_auditid   tbl_audit.auditid%TYPE;
v_createdby tbl_audit.createdby%TYPE;
v_createddt tbl_audit.createddt%TYPE;
v_modifiedby tbl_audit.modifiedby%TYPE;
v_modifieddt tbl_audit.modifieddt%TYPE;
v_surveysipassociationid   TBL_SURVEYSIPASSOCIATION.surveysipassociationid%TYPE;
v_belongto TBL_SURVEYSIPASSOCIATION.belongto%TYPE;
v_studyid TBL_SURVEYSIPASSOCIATION.studyid%TYPE;
v_sysdate DATE:=SYSDATE;
BEGIN
  IF INSERTING THEN
    v_operation := pkg_audit.g_operation_create;
    v_createdby := :NEW.createdby;
    v_createddt := :NEW.createddt;
    v_modifiedby := :NEW.createdby;
    v_modifieddt := :NEW.createddt;
    v_surveysipassociationid := :NEW.surveysipassociationid;
   v_belongto := :NEW.BELONGTO;
   v_studyid:=:NEW.STUDYID;

  ELSIF UPDATING THEN
      v_operation := pkg_audit.g_operation_update;
    v_createdby := :NEW.modifiedby;
    v_createddt := :NEW.modifieddt;
    v_modifiedby := :NEW.modifiedby;
    v_modifieddt := :NEW.modifieddt;
    v_surveysipassociationid := :NEW.surveysipassociationid;
    v_belongto := :NEW.BELONGTO;
    v_studyid:=:NEW.STUDYID;

  ELSIF DELETING THEN
    v_operation := pkg_audit.g_operation_delete;
    v_createdby := :OLD.modifiedby;
    v_createddt := v_sysdate;
    v_modifiedby := :OLD.modifiedby;
    v_modifieddt := v_sysdate;
    v_surveysipassociationid := :OLD.surveysipassociationid;
    v_belongto := :OLD.BELONGTO;
    v_studyid:=:OLD.STUDYID;

  END IF;

  pkg_audit.sp_set_audit
    (v_surveysipassociationid,'TBL_SURVEYSIPASSOCIATION','SURVEYSIPASSOCIATIONID',:OLD.SURVEYSIPASSOCIATIONID,:NEW.SURVEYSIPASSOCIATIONID,v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

   if v_auditid is not null then
   FOR i IN (SELECT DISTINCT SURVEYTITLE FROM TCSIP_CPORTAL.TBL_SURVEY WHERE SURVEYID = v_belongto
            ) LOOP
  pkg_audit.sp_set_surveyauditreportmap
  (v_auditid,v_belongto,i.SURVEYTITLE,v_studyid, null, v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  end loop;
  end if;

  pkg_audit.sp_set_audit
  (v_surveysipassociationid,'TBL_SURVEYSIPASSOCIATION','SPONSORORGANIZAIONID',pkg_audit.fn_get_lov_value(:OLD.SPONSORORGANIZAIONID, pkg_audit.g_lov_organization),pkg_audit.fn_get_lov_value(:NEW.SPONSORORGANIZAIONID, pkg_audit.g_lov_organization),v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

   if v_auditid is not null then
   FOR i IN (SELECT DISTINCT SURVEYTITLE FROM TCSIP_CPORTAL.TBL_SURVEY WHERE SURVEYID = v_belongto
            ) LOOP
  pkg_audit.sp_set_surveyauditreportmap
  (v_auditid,v_belongto,i.SURVEYTITLE,v_studyid, null, v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  end loop;
  end if;


    pkg_audit.sp_set_audit
  (v_surveysipassociationid,'TBL_SURVEYSIPASSOCIATION','ISTEMPLATE',:OLD.ISTEMPLATE,:NEW.ISTEMPLATE,v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

   if v_auditid is not null then
   FOR i IN (SELECT DISTINCT SURVEYTITLE FROM TCSIP_CPORTAL.TBL_SURVEY WHERE SURVEYID = v_belongto
            ) LOOP
  pkg_audit.sp_set_surveyauditreportmap
  (v_auditid,v_belongto,i.SURVEYTITLE,v_studyid, null, v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  end loop;
  end if;

    pkg_audit.sp_set_audit
    (v_surveysipassociationid,'TBL_SURVEYSIPASSOCIATION','BELONGTO',:OLD.BELONGTO,:NEW.BELONGTO,v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

   if v_auditid is not null then
   FOR i IN (SELECT DISTINCT SURVEYTITLE FROM TCSIP_CPORTAL.TBL_SURVEY WHERE SURVEYID = v_belongto
            ) LOOP
  pkg_audit.sp_set_surveyauditreportmap
  (v_auditid,v_belongto,i.SURVEYTITLE,v_studyid, null, v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  end loop;
  end if;

  pkg_audit.sp_set_audit
  (v_surveysipassociationid,'TBL_SURVEYSIPASSOCIATION','STUDYID',pkg_audit.fn_get_lov_value(:OLD.STUDYID, pkg_audit.g_lov_study),pkg_audit.fn_get_lov_value(:NEW.STUDYID, pkg_audit.g_lov_study),v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

   if v_auditid is not null then
   FOR i IN (SELECT DISTINCT SURVEYTITLE FROM TCSIP_CPORTAL.TBL_SURVEY WHERE SURVEYID = v_belongto
            ) LOOP
  pkg_audit.sp_set_surveyauditreportmap
  (v_auditid,v_belongto,i.SURVEYTITLE,v_studyid, null, v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  end loop;
  end if;


    pkg_audit.sp_set_audit
  (v_surveysipassociationid,'TBL_SURVEYSIPASSOCIATION','THEREAPUTICAREAID',pkg_audit.fn_get_lov_value(:OLD.THEREAPUTICAREAID, pkg_audit.g_lov_therapeuticarea),pkg_audit.fn_get_lov_value(:NEW.THEREAPUTICAREAID, pkg_audit.g_lov_therapeuticarea),v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

   if v_auditid is not null then
   FOR i IN (SELECT DISTINCT SURVEYTITLE FROM TCSIP_CPORTAL.TBL_SURVEY WHERE SURVEYID = v_belongto
            ) LOOP
  pkg_audit.sp_set_surveyauditreportmap
  (v_auditid,v_belongto,i.SURVEYTITLE,v_studyid, null, v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  end loop;
  end if;

    pkg_audit.sp_set_audit
    (v_surveysipassociationid,'TBL_SURVEYSIPASSOCIATION','COMPOUNDID',pkg_audit.fn_get_lov_value(:OLD.COMPOUNDID, pkg_audit.g_lov_compound),pkg_audit.fn_get_lov_value(:NEW.COMPOUNDID, pkg_audit.g_lov_compound),v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

   if v_auditid is not null then
   FOR i IN (SELECT DISTINCT SURVEYTITLE FROM TCSIP_CPORTAL.TBL_SURVEY WHERE SURVEYID = v_belongto
            ) LOOP
  pkg_audit.sp_set_surveyauditreportmap
  (v_auditid,v_belongto,i.SURVEYTITLE,v_studyid, null, v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  end loop;
  end if;

  pkg_audit.sp_set_audit
  (v_surveysipassociationid,'TBL_SURVEYSIPASSOCIATION','PROGRAMID',pkg_audit.fn_get_lov_value(:OLD.PROGRAMID, pkg_audit.g_lov_program),pkg_audit.fn_get_lov_value(:NEW.PROGRAMID, pkg_audit.g_lov_program),v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

   if v_auditid is not null then
   FOR i IN (SELECT DISTINCT SURVEYTITLE FROM TCSIP_CPORTAL.TBL_SURVEY WHERE SURVEYID = v_belongto
            ) LOOP
  pkg_audit.sp_set_surveyauditreportmap
  (v_auditid,v_belongto,i.SURVEYTITLE,v_studyid, null, v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  end loop;
  end if;


    pkg_audit.sp_set_audit
  (v_surveysipassociationid,'TBL_SURVEYSIPASSOCIATION','DISEASEID',pkg_audit.fn_get_lov_value(:OLD.DISEASEID, pkg_audit.g_lov_disease),pkg_audit.fn_get_lov_value(:NEW.DISEASEID, pkg_audit.g_lov_disease),v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

   if v_auditid is not null then
   FOR i IN (SELECT DISTINCT SURVEYTITLE FROM TCSIP_CPORTAL.TBL_SURVEY WHERE SURVEYID = v_belongto
            ) LOOP
  pkg_audit.sp_set_surveyauditreportmap
  (v_auditid,v_belongto,i.SURVEYTITLE,v_studyid, null, v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  end loop;
  end if;


    pkg_audit.sp_set_audit
    (v_surveysipassociationid,'TBL_SURVEYSIPASSOCIATION','INDICATIONID',pkg_audit.fn_get_lov_value(:OLD.INDICATIONID, pkg_audit.g_lov_indication),pkg_audit.fn_get_lov_value(:NEW.INDICATIONID, pkg_audit.g_lov_indication),v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

   if v_auditid is not null then
   FOR i IN (SELECT DISTINCT SURVEYTITLE FROM TCSIP_CPORTAL.TBL_SURVEY WHERE SURVEYID = v_belongto
            ) LOOP
  pkg_audit.sp_set_surveyauditreportmap
  (v_auditid,v_belongto,i.SURVEYTITLE,v_studyid, null, v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  end loop;
  end if;

  pkg_audit.sp_set_audit
  (v_surveysipassociationid,'TBL_SURVEYSIPASSOCIATION','CREATEDDT',TO_CHAR(:OLD.createddt, 'DD-MON-YYYY'), TO_CHAR(:NEW.createddt, 'DD-MON-YYYY'),v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

   if v_auditid is not null then
   FOR i IN (SELECT DISTINCT SURVEYTITLE FROM TCSIP_CPORTAL.TBL_SURVEY WHERE SURVEYID = v_belongto
            ) LOOP
  pkg_audit.sp_set_surveyauditreportmap
  (v_auditid,v_belongto,i.SURVEYTITLE,v_studyid, null, v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  end loop;
  end if;


    pkg_audit.sp_set_audit
  (v_surveysipassociationid,'TBL_SURVEYSIPASSOCIATION','CREATEDBY',pkg_audit.fn_get_lov_value(:OLD.CREATEDBY,pkg_audit.g_lov_surveycreator),pkg_audit.fn_get_lov_value(:NEW.CREATEDBY, pkg_audit.g_lov_surveycreator),v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

   if v_auditid is not null then
   FOR i IN (SELECT DISTINCT SURVEYTITLE FROM TCSIP_CPORTAL.TBL_SURVEY WHERE SURVEYID = v_belongto
            ) LOOP
  pkg_audit.sp_set_surveyauditreportmap
  (v_auditid,v_belongto,i.SURVEYTITLE,v_studyid, null, v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  end loop;
  end if;


    pkg_audit.sp_set_audit
    (v_surveysipassociationid,'TBL_SURVEYSIPASSOCIATION','MODIFIEDDT',TO_CHAR(:OLD.modifieddt, 'DD-MON-YYYY'), TO_CHAR(:NEW.modifieddt, 'DD-MON-YYYY'),v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

   if v_auditid is not null then
   FOR i IN (SELECT DISTINCT SURVEYTITLE FROM TCSIP_CPORTAL.TBL_SURVEY WHERE SURVEYID = v_belongto
            ) LOOP
  pkg_audit.sp_set_surveyauditreportmap
  (v_auditid,v_belongto,i.SURVEYTITLE,v_studyid, null, v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  end loop;
  end if;

  pkg_audit.sp_set_audit
  (v_surveysipassociationid,'TBL_SURVEYSIPASSOCIATION','MODIFIEDBY',:OLD.MODIFIEDBY,:NEW.MODIFIEDBY,v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

   if v_auditid is not null then
   FOR i IN (SELECT DISTINCT SURVEYTITLE FROM TCSIP_CPORTAL.TBL_SURVEY WHERE SURVEYID = v_belongto
            ) LOOP
  pkg_audit.sp_set_surveyauditreportmap
  (v_auditid,v_belongto,i.SURVEYTITLE,v_studyid, null, v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  end loop;
  end if;

    pkg_audit.sp_set_audit
  (v_surveysipassociationid,'TBL_SURVEYSIPASSOCIATION','ISSTUDYSKIPPED',(CASE WHEN :OLD.ISSTUDYSKIPPED=1 THEN 'Y' ELSE 'N' END),(CASE WHEN :NEW.ISSTUDYSKIPPED=1 THEN'Y' ELSE 'N' END),v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

   if v_auditid is not null then
   FOR i IN (SELECT DISTINCT SURVEYTITLE FROM TCSIP_CPORTAL.TBL_SURVEY WHERE SURVEYID = v_belongto
            ) LOOP
  pkg_audit.sp_set_surveyauditreportmap
  (v_auditid,v_belongto,i.SURVEYTITLE,v_studyid, null, v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  end loop;
  end if;

END trg_Tbl_sIPAssociation_audit;
/