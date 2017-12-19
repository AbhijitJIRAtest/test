create or replace TRIGGER TCSIP_CPORTAL.TRG_TBL_RESPONSEMNGRMAP_AUDIT
AFTER INSERT OR UPDATE OR DELETE ON TCSIP_CPORTAL.TBL_RESPONSEMANAGERMAP
FOR EACH ROW
DECLARE
v_operation           tbl_audit.operation%TYPE;
v_auditid             tbl_audit.auditid%TYPE;  
v_responsemapid       tbl_responsemanagermap.responsemapid%TYPE;
v_responsemanagerid       tbl_responsemanagermap.responsemanagerid%TYPE;
v_createdby           tbl_audit.createdby%TYPE;
v_createddt           tbl_audit.createddt%TYPE;
v_modifiedby          tbl_audit.modifiedby%TYPE;
v_modifieddt          tbl_audit.modifieddt%TYPE;
v_istemplate          tbl_responsemanagermap.istemplate%TYPE;
v_belongto              tbl_responsemanagermap.belongto%TYPE;
v_sysdate DATE:=SYSDATE;
v_surveytitle           TBL_SURVEY.SURVEYTITLE%TYPE;
BEGIN

  IF INSERTING THEN
    v_operation := pkg_audit.g_operation_create;
  	v_createdby := :NEW.createdby;
    v_createddt := :NEW.createddt;
    v_modifiedby := :NEW.createdby;
    v_modifieddt := :NEW.createddt;
    v_responsemapid:= :NEW.responsemapid;
    v_istemplate:=:NEW.istemplate;
    v_belongto:=:NEW.belongto;
	v_responsemanagerid:=:NEW.responsemanagerid;
  ELSIF UPDATING THEN
    v_operation := pkg_audit.g_operation_update;
  	v_createdby := :NEW.modifiedby;
    v_createddt := :NEW.modifieddt;
    v_modifiedby := :NEW.modifiedby;
    v_modifieddt := :NEW.modifieddt;
    v_responsemapid:= :NEW.responsemapid;
    v_istemplate:=:NEW.istemplate;
    v_belongto:=:NEW.belongto;
	v_responsemanagerid:=:NEW.responsemanagerid;
  ELSIF DELETING THEN
    v_operation := pkg_audit.g_operation_delete;
    v_responsemapid:= :OLD.responsemapid;
    v_istemplate:=:OLD.istemplate;
    v_belongto:=:OLD.belongto;
	v_responsemanagerid:=:OLD.responsemanagerid;
	v_createdby := pkg_audit.fn_get_del_createdby('TBL_RESPONSEMANAGERMAP',v_responsemapid);
	v_createddt := pkg_audit.fn_get_del_createddt('TBL_RESPONSEMANAGERMAP',v_responsemapid);
	v_modifiedby := pkg_audit.fn_get_del_createdby('TBL_RESPONSEMANAGERMAP',v_responsemapid);
	v_modifieddt := pkg_audit.fn_get_del_createddt('TBL_RESPONSEMANAGERMAP',v_responsemapid);
  END IF;
  
  select surveytitle
  into v_surveytitle from tbl_survey
  where surveyid=v_belongto;
  
  pkg_audit.sp_set_audit
  (v_responsemapid,'TBL_RESPONSEMANAGERMAP', 'RESPONSEMAPID',:OLD.responsemapid,:NEW.responsemapid,v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);
  
  if v_auditid is not null then
  FOR i IN (SELECT tssa.belongto surveyid,ts.surveytitle surveyname,NULL surveyrecipient,tssa.studyid FROM tbl_surveysipassociation tssa,
			tbl_survey ts
			WHERE tssa.belongto = ts.surveyid
			AND  tssa.belongto = v_belongto ) LOOP
    pkg_audit.sp_set_surveyauditreportmap
    (v_auditid,i.surveyid,i.surveyname,i.studyid, i.surveyrecipient, v_createddt,v_createdby,v_modifieddt,v_modifiedby);  
  END LOOP;
  end if;
  
  pkg_audit.sp_set_audit
  (v_responsemapid,'TBL_RESPONSEMANAGERMAP', 'RESPONSEMANAGERID',pkg_encrypt.fn_decrypt(pkg_audit.fn_get_lov_value(:OLD.RESPONSEMANAGERID, pkg_audit.g_lov_responsemanager)),pkg_encrypt.fn_encrypt(pkg_audit.fn_get_lov_value(:NEW.RESPONSEMANAGERID, pkg_audit.g_lov_responsemanager)),v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);
  
  if v_auditid is not null then
  FOR i IN (SELECT tssa.belongto surveyid,ts.surveytitle surveyname,NULL surveyrecipient,tssa.studyid FROM tbl_surveysipassociation tssa,
			tbl_survey ts
			WHERE tssa.belongto = ts.surveyid
			AND  tssa.belongto = v_belongto) LOOP
    pkg_audit.sp_set_surveyauditreportmap
    (v_auditid,i.surveyid,i.surveyname,i.studyid, i.surveyrecipient, v_createddt,v_createdby,v_modifieddt,v_modifiedby);  
  END LOOP;
  end if;
  
  pkg_audit.sp_set_audit
  (v_responsemapid,'TBL_RESPONSEMANAGERMAP', 'BELONGTO',pkg_audit.fn_get_lov_value(:OLD.BELONGTO, pkg_audit.g_lov_survey_id),pkg_audit.fn_get_lov_value(:NEW.BELONGTO, pkg_audit.g_lov_survey_id),v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

  
  if v_auditid is not null then
  FOR i IN (SELECT tssa.belongto surveyid,ts.surveytitle surveyname,NULL surveyrecipient,tssa.studyid FROM tbl_surveysipassociation tssa,
			tbl_survey ts
			WHERE tssa.belongto = ts.surveyid
			AND  tssa.belongto = v_belongto) LOOP
    pkg_audit.sp_set_surveyauditreportmap
    (v_auditid,i.surveyid,i.surveyname,i.studyid, i.surveyrecipient, v_createddt,v_createdby,v_modifieddt,v_modifiedby);  
  END LOOP;
  end if;
  
  pkg_audit.sp_set_audit
  (v_responsemapid,'TBL_RESPONSEMANAGERMAP', 'ISTEMPLATE',:OLD.istemplate,:NEW.istemplate,v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);
  
  if v_auditid is not null then
  FOR i IN (SELECT tssa.belongto surveyid,ts.surveytitle surveyname,NULL surveyrecipient,tssa.studyid FROM tbl_surveysipassociation tssa,
			tbl_survey ts
			WHERE tssa.belongto = ts.surveyid
			AND  tssa.belongto = v_belongto) LOOP
    pkg_audit.sp_set_surveyauditreportmap
    (v_auditid,i.surveyid,i.surveyname,i.studyid, i.surveyrecipient, v_createddt,v_createdby,v_modifieddt,v_modifiedby);  
  END LOOP;
end if;  
  
  pkg_audit.sp_set_audit
  (v_responsemapid,'TBL_RESPONSEMANAGERMAP', 'REVIEWSTATUS',:OLD.reviewstatus,:NEW.reviewstatus,v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);
  
  if v_auditid is not null then
  FOR i IN (SELECT tssa.belongto surveyid,ts.surveytitle surveyname,NULL surveyrecipient,tssa.studyid FROM tbl_surveysipassociation tssa,
			tbl_survey ts
			WHERE tssa.belongto = ts.surveyid
			AND  tssa.belongto = v_belongto) LOOP
    pkg_audit.sp_set_surveyauditreportmap
    (v_auditid,i.surveyid,i.surveyname,i.studyid, i.surveyrecipient, v_createddt,v_createdby,v_modifieddt,v_modifiedby);  
  END LOOP; 
  end if;
  
  pkg_audit.sp_set_audit
  (v_responsemapid,'TBL_RESPONSEMANAGERMAP', 'SENDDT',TO_CHAR(:OLD.senddt, 'DD-MON-YYYY'), TO_CHAR(:NEW.senddt, 'DD-MON-YYYY'),v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);
  
if v_auditid is not null then 
 FOR i IN (SELECT tssa.belongto surveyid,ts.surveytitle surveyname,NULL surveyrecipient,tssa.studyid FROM tbl_surveysipassociation tssa,
			tbl_survey ts
			WHERE tssa.belongto = ts.surveyid
			AND  tssa.belongto = v_belongto) LOOP
    pkg_audit.sp_set_surveyauditreportmap
    (v_auditid,i.surveyid,i.surveyname,i.studyid, i.surveyrecipient, v_createddt,v_createdby,v_modifieddt,v_modifiedby);  
  END LOOP; 
end if;  
  
  pkg_audit.sp_set_audit
  (v_responsemapid,'TBL_RESPONSEMANAGERMAP', 'RESPONSEDT',TO_CHAR(:OLD.responsedt, 'DD-MON-YYYY'), TO_CHAR(:NEW.responsedt, 'DD-MON-YYYY'),v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);
  
  if v_auditid is not null then
  FOR i IN (SELECT tssa.belongto surveyid,ts.surveytitle surveyname,NULL surveyrecipient,tssa.studyid FROM tbl_surveysipassociation tssa,
			tbl_survey ts
			WHERE tssa.belongto = ts.surveyid
			AND  tssa.belongto = v_belongto) LOOP
    pkg_audit.sp_set_surveyauditreportmap
    (v_auditid,i.surveyid,i.surveyname,i.studyid, i.surveyrecipient, v_createddt,v_createdby,v_modifieddt,v_modifiedby);  
  END LOOP; 
end if;  
  
  pkg_audit.sp_set_audit
  (v_responsemapid,'TBL_RESPONSEMANAGERMAP', 'RECIPIENTCOMMENT',:OLD.recipientcomment,:NEW.recipientcomment,v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);
  
if v_auditid is not null then 
 FOR i IN (SELECT tssa.belongto surveyid,ts.surveytitle surveyname,NULL surveyrecipient,tssa.studyid FROM tbl_surveysipassociation tssa,
			tbl_survey ts
			WHERE tssa.belongto = ts.surveyid
			AND  tssa.belongto = v_belongto) LOOP
    pkg_audit.sp_set_surveyauditreportmap
    (v_auditid,i.surveyid,i.surveyname,i.studyid, i.surveyrecipient, v_createddt,v_createdby,v_modifieddt,v_modifiedby);  
  END LOOP;
end if;  
  
  pkg_audit.sp_set_audit
  (v_responsemapid,'TBL_RESPONSEMANAGERMAP', 'GENERALFEEDBACK',:OLD.generalfeedback,:NEW.generalfeedback,v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);
  
  if v_auditid is not null then
  FOR i IN (SELECT tssa.belongto surveyid,ts.surveytitle surveyname,NULL surveyrecipient,tssa.studyid FROM tbl_surveysipassociation tssa,
			tbl_survey ts
			WHERE tssa.belongto = ts.surveyid
			AND  tssa.belongto = v_belongto) LOOP
    pkg_audit.sp_set_surveyauditreportmap
    (v_auditid,i.surveyid,i.surveyname,i.studyid, i.surveyrecipient, v_createddt,v_createdby,v_modifieddt,v_modifiedby);  
  END LOOP;  
  end if;
  
 
  pkg_audit.sp_set_audit
  (v_responsemapid,'TBL_RESPONSEMANAGERMAP', 'CREATEDDT',TO_CHAR(:OLD.createddt, 'DD-MON-YYYY'), TO_CHAR(:NEW.createddt, 'DD-MON-YYYY'),v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);
  
  if v_auditid is not null then
  FOR i IN (SELECT tssa.belongto surveyid,ts.surveytitle surveyname,NULL surveyrecipient,tssa.studyid FROM tbl_surveysipassociation tssa,
			tbl_survey ts
			WHERE tssa.belongto = ts.surveyid
			AND  tssa.belongto = v_belongto) LOOP
    pkg_audit.sp_set_surveyauditreportmap
    (v_auditid,i.surveyid,i.surveyname,i.studyid, i.surveyrecipient, v_createddt,v_createdby,v_modifieddt,v_modifiedby);  
  END LOOP; 
end if;  
  
  pkg_audit.sp_set_audit
  (v_responsemapid,'TBL_RESPONSEMANAGERMAP', 'CREATEDBY',:OLD.createdby,:NEW.createdby,v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);
  
  if v_auditid is not null then
  FOR i IN (SELECT tssa.belongto surveyid,ts.surveytitle surveyname,NULL surveyrecipient,tssa.studyid FROM tbl_surveysipassociation tssa,
			tbl_survey ts
			WHERE tssa.belongto = ts.surveyid
			AND  tssa.belongto = v_belongto) LOOP
    pkg_audit.sp_set_surveyauditreportmap
    (v_auditid,i.surveyid,i.surveyname,i.studyid, i.surveyrecipient, v_createddt,v_createdby,v_modifieddt,v_modifiedby);  
  END LOOP;  
  end if;

  pkg_audit.sp_set_audit
  (v_responsemapid,'TBL_RESPONSEMANAGERMAP', 'MODIFIEDDT',TO_CHAR(:OLD.modifieddt, 'DD-MON-YYYY'), TO_CHAR(:NEW.modifieddt, 'DD-MON-YYYY'),v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);
  
  if v_auditid is not null then
  FOR i IN (SELECT tssa.belongto surveyid,ts.surveytitle surveyname,NULL surveyrecipient,tssa.studyid FROM tbl_surveysipassociation tssa,
			tbl_survey ts
			WHERE tssa.belongto = ts.surveyid
			AND  tssa.belongto = v_belongto) LOOP
    pkg_audit.sp_set_surveyauditreportmap
    (v_auditid,i.surveyid,i.surveyname,i.studyid, i.surveyrecipient, v_createddt,v_createdby,v_modifieddt,v_modifiedby);  
  END LOOP; 
end if;  
  
  pkg_audit.sp_set_audit
  (v_responsemapid,'TBL_RESPONSEMANAGERMAP', 'MODIFIEDBY',:OLD.modifiedby,:NEW.modifiedby,v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);
  
if v_auditid is not null then 
 FOR i IN (SELECT tssa.belongto surveyid,ts.surveytitle surveyname,NULL surveyrecipient,tssa.studyid FROM tbl_surveysipassociation tssa,
			tbl_survey ts
			WHERE tssa.belongto = ts.surveyid
			AND  tssa.belongto = v_belongto) LOOP
    pkg_audit.sp_set_surveyauditreportmap
    (v_auditid,i.surveyid,i.surveyname,i.studyid, i.surveyrecipient, v_createddt,v_createdby,v_modifieddt,v_modifiedby);  
  END LOOP;  
end if;

 --Update Survey Id for Response manager added for Survey
UPDATE  tbl_surveyauditreportmap tsarm
SET tsarm.surveyid = v_belongto, tsarm.surveyname = v_surveytitle
WHERE tsarm.surveyid IS NULL
AND tsarm.surveyauditid IN (SELECT ta.auditid
                                                  FROM tbl_audit ta
                                                  WHERE ta.tablename = 'TBL_RESPONSEMANAGER'
                                                  AND ta.entityrefid = v_responsemanagerid);
  
  
pkg_audit.sp_del_deletedrecords('TBL_RESPONSEMANAGERMAP',v_responsemapid);


END trg_tbl_responsemngrmap_audit;
/