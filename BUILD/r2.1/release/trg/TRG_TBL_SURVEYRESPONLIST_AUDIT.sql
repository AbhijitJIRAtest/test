CREATE OR REPLACE TRIGGER "TCSIP_CPORTAL"."TRG_TBL_SURVEYRESPONLIST_AUDIT" 
AFTER INSERT OR UPDATE OR DELETE ON TCSIP_CPORTAL.TBL_SURVEYRESPONSELIST
FOR EACH ROW
DECLARE
v_operation tbl_audit.operation%TYPE;
v_auditid   tbl_audit.auditid%TYPE;
v_createdby tbl_audit.createdby%TYPE;
v_createddt tbl_audit.createddt%TYPE;
v_modifiedby tbl_audit.modifiedby%TYPE;
v_modifieddt tbl_audit.modifieddt%TYPE;
v_responselistid tbl_surveyresponselist.responselistid%TYPE;
v_surveyid tbl_surveyresponselist.SURVEYID%TYPE;
v_sysdate DATE:=SYSDATE;
BEGIN
  IF INSERTING THEN
    v_operation := pkg_audit.g_operation_create;
    v_createdby := :NEW.createdby;
    v_createddt := :NEW.createddt;
    v_modifiedby := :NEW.createdby;
    v_modifieddt := :NEW.createddt;
	v_responselistid:=:NEW.responselistid;
  v_surveyid:=:NEW.SURVEYID;

  ELSIF UPDATING THEN
      v_operation := pkg_audit.g_operation_update;
    v_createdby := :NEW.modifiedby;
    v_createddt := :NEW.modifieddt;
    v_modifiedby := :NEW.modifiedby;
    v_modifieddt := :NEW.modifieddt;
	v_responselistid:=:NEW.responselistid;
  v_surveyid:=:NEW.SURVEYID;
  ELSIF DELETING THEN
    v_operation := pkg_audit.g_operation_delete;
    v_createdby := :OLD.modifiedby;
    v_createddt := v_sysdate;
    v_modifiedby := :OLD.modifiedby;
    v_modifieddt := v_sysdate;
	v_responselistid:=:OLD.responselistid;
  v_surveyid:=:OLD.SURVEYID;
  END IF;

  pkg_audit.sp_set_audit
    (v_responselistid,'TBL_SURVEYRESPONSELIST','RESPONSELISTID',:OLD.RESPONSELISTID,:NEW.RESPONSELISTID,v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

   if v_auditid is not null then
   FOR i IN (SELECT DISTINCT sr.surveyid,sr.surveytitle,sc.studyid
            FROM tbl_surveysipassociation sc,
			tbl_survey sr
			WHERE sc.belongto =sr.surveyid
			AND sc.istemplate = 0
            AND sr.SURVEYID = v_surveyid
            ) LOOP
  pkg_audit.sp_set_surveyauditreportmap
   (v_auditid,i.surveyid,i.surveytitle,i.studyid, null, v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  end loop;
  end if;

  pkg_audit.sp_set_audit
  (v_responselistid,'TBL_SURVEYRESPONSELIST','SURVEYID',pkg_audit.fn_get_lov_value(:OLD.SURVEYID, pkg_audit.g_lov_surveycd),pkg_audit.fn_get_lov_value(:NEW.SURVEYID, pkg_audit.g_lov_surveycd),v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

   if v_auditid is not null then
   FOR i IN (SELECT DISTINCT sr.surveyid,sr.surveytitle,sc.studyid
            FROM tbl_surveysipassociation sc,
			tbl_survey sr
			WHERE sc.belongto =sr.surveyid
			AND sc.istemplate = 0
            AND sr.SURVEYID = v_surveyid
            ) LOOP
  pkg_audit.sp_set_surveyauditreportmap
    (v_auditid,i.surveyid,i.surveytitle,i.studyid, null, v_createddt,v_createdby,v_modifieddt,v_modifiedby);
   end loop;
   end if;

    pkg_audit.sp_set_audit
  (v_responselistid,'TBL_SURVEYRESPONSELIST','LISTNAME',:OLD.LISTNAME,:NEW.LISTNAME,v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

   if v_auditid is not null then
   FOR i IN (SELECT DISTINCT sr.surveyid,sr.surveytitle,sc.studyid
            FROM tbl_surveysipassociation sc,
			tbl_survey sr
			WHERE sc.belongto =sr.surveyid
			AND sc.istemplate = 0
            AND sr.SURVEYID = v_surveyid
            ) LOOP
  pkg_audit.sp_set_surveyauditreportmap
    (v_auditid,i.surveyid,i.surveytitle,i.studyid, null, v_createddt,v_createdby,v_modifieddt,v_modifiedby);

   end loop;
   end if;

     pkg_audit.sp_set_audit
  (v_responselistid,'TBL_SURVEYRESPONSELIST','SURVEYDUEDATE',TO_CHAR(:OLD.SURVEYDUEDATE, 'DD-MON-YYYY'), TO_CHAR(:NEW.SURVEYDUEDATE, 'DD-MON-YYYY'),v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);


 if v_auditid is not null then
 FOR i IN (SELECT DISTINCT sr.surveyid,sr.surveytitle,sc.studyid
            FROM tbl_surveysipassociation sc,
			tbl_survey sr
			WHERE sc.belongto =sr.surveyid
			AND sc.istemplate = 0
            AND sr.SURVEYID = v_surveyid
            ) LOOP
  pkg_audit.sp_set_surveyauditreportmap
    (v_auditid,i.surveyid,i.surveytitle,i.studyid, null, v_createddt,v_createdby,v_modifieddt,v_modifiedby);

   end loop;
   end if;



     pkg_audit.sp_set_audit
  (v_responselistid,'TBL_SURVEYRESPONSELIST','SURVEYSENDDATE',TO_CHAR(:OLD.SURVEYSENDDATE, 'DD-MON-YYYY'), TO_CHAR(:NEW.SURVEYSENDDATE, 'DD-MON-YYYY'),v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);


 if v_auditid is not null then
 FOR i IN (SELECT DISTINCT sr.surveyid,sr.surveytitle,sc.studyid
            FROM tbl_surveysipassociation sc,
			tbl_survey sr
			WHERE sc.belongto =sr.surveyid
			AND sc.istemplate = 0
            AND sr.SURVEYID = v_surveyid
            ) LOOP
  pkg_audit.sp_set_surveyauditreportmap
    (v_auditid,i.surveyid,i.surveytitle,i.studyid, null, v_createddt,v_createdby,v_modifieddt,v_modifiedby);

   end loop;
   end if;

     pkg_audit.sp_set_audit
  (v_responselistid,'TBL_SURVEYRESPONSELIST','STATUS',:OLD.STATUS,:NEW.STATUS,v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

 if v_auditid is not null then
 FOR i IN (SELECT DISTINCT sr.surveyid,sr.surveytitle,sc.studyid
            FROM tbl_surveysipassociation sc,
			tbl_survey sr
			WHERE sc.belongto =sr.surveyid
			AND sc.istemplate = 0
            AND sr.SURVEYID = v_surveyid
            ) LOOP
  pkg_audit.sp_set_surveyauditreportmap
    (v_auditid,i.surveyid,i.surveytitle,i.studyid, null, v_createddt,v_createdby,v_modifieddt,v_modifiedby);

   end loop;
   end if;


     pkg_audit.sp_set_audit
  (v_responselistid,'TBL_SURVEYRESPONSELIST','ADDEDBY',:OLD.ADDEDBY,:NEW.ADDEDBY,v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

 if v_auditid is not null then
 FOR i IN (SELECT DISTINCT sr.surveyid,sr.surveytitle,sc.studyid
            FROM tbl_surveysipassociation sc,
			tbl_survey sr
			WHERE sc.belongto =sr.surveyid
			AND sc.istemplate = 0
            AND sr.SURVEYID = v_surveyid
            ) LOOP
  pkg_audit.sp_set_surveyauditreportmap
    (v_auditid,i.surveyid,i.surveytitle,i.studyid, null, v_createddt,v_createdby,v_modifieddt,v_modifiedby);

   end loop;
   end if;

     pkg_audit.sp_set_audit
  (v_responselistid,'TBL_SURVEYRESPONSELIST','CREATEDDT',TO_CHAR(:OLD.createddt, 'DD-MON-YYYY'), TO_CHAR(:NEW.createddt, 'DD-MON-YYYY'),v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

   if v_auditid is not null then
   FOR i IN (SELECT DISTINCT sr.surveyid,sr.surveytitle,sc.studyid
            FROM tbl_surveysipassociation sc,
			tbl_survey sr
			WHERE sc.belongto =sr.surveyid
			AND sc.istemplate = 0
            AND sr.SURVEYID = v_surveyid
            ) LOOP
  pkg_audit.sp_set_surveyauditreportmap
    (v_auditid,i.surveyid,i.surveytitle,i.studyid, null, v_createddt,v_createdby,v_modifieddt,v_modifiedby);

   end loop;
   end if;

     pkg_audit.sp_set_audit
  (v_responselistid,'TBL_SURVEYRESPONSELIST','CREATEDBY',:OLD.CREATEDBY,:NEW.CREATEDBY,v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

   if v_auditid is not null then
   FOR i IN (SELECT DISTINCT sr.surveyid,sr.surveytitle,sc.studyid
            FROM tbl_surveysipassociation sc,
			tbl_survey sr
			WHERE sc.belongto =sr.surveyid
			AND sc.istemplate = 0
            AND sr.SURVEYID = v_surveyid
            ) LOOP
  pkg_audit.sp_set_surveyauditreportmap
    (v_auditid,i.surveyid,i.surveytitle,i.studyid, null, v_createddt,v_createdby,v_modifieddt,v_modifiedby);

   end loop;
   end if;

    pkg_audit.sp_set_audit
  (v_responselistid,'TBL_SURVEYRESPONSELIST','MODIFIEDDT',TO_CHAR(:OLD.modifieddt, 'DD-MON-YYYY'), TO_CHAR(:NEW.modifieddt, 'DD-MON-YYYY'),v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

   if v_auditid is not null then
   FOR i IN (SELECT DISTINCT sr.surveyid,sr.surveytitle,sc.studyid
            FROM tbl_surveysipassociation sc,
			tbl_survey sr
			WHERE sc.belongto =sr.surveyid
			AND sc.istemplate = 0
            AND sr.SURVEYID = v_surveyid
            ) LOOP
  pkg_audit.sp_set_surveyauditreportmap
    (v_auditid,i.surveyid,i.surveytitle,i.studyid, null, v_createddt,v_createdby,v_modifieddt,v_modifiedby);

   end loop;
   end if;

    pkg_audit.sp_set_audit
  (v_responselistid,'TBL_SURVEYRESPONSELIST','MODIFIEDBY',:OLD.MODIFIEDBY,:NEW.MODIFIEDBY,v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

   if v_auditid is not null then
   FOR i IN (SELECT DISTINCT sr.surveyid,sr.surveytitle,sc.studyid
            FROM tbl_surveysipassociation sc,
			tbl_survey sr
			WHERE sc.belongto =sr.surveyid
			AND sc.istemplate = 0
            AND sr.SURVEYID = v_surveyid
            ) LOOP
  pkg_audit.sp_set_surveyauditreportmap
    (v_auditid,i.surveyid,i.surveytitle,i.studyid, null, v_createddt,v_createdby,v_modifieddt,v_modifiedby);
 end loop;
 end if;


END TRG_TBL_SURVEYRESPONLIST_AUDIT;
/