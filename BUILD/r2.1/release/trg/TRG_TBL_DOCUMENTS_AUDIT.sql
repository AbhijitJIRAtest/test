CREATE OR REPLACE TRIGGER TRG_TBL_DOCUMENTS_AUDIT
AFTER INSERT OR UPDATE OR DELETE ON TBL_DOCUMENTS
FOR EACH ROW
DECLARE
v_operation tbl_audit.operation%TYPE;
v_auditid   tbl_audit.auditid%TYPE;
v_createdby tbl_audit.createdby%TYPE;
v_createddt tbl_audit.createddt%TYPE;
v_modifiedby tbl_audit.modifiedby%TYPE;
v_modifieddt tbl_audit.modifieddt%TYPE;
v_documentid  TBL_DOCUMENTS.DOCUMENTID%TYPE;
v_facilityid  TBL_DOCUMENTS.facilityid%TYPE;
v_docuserid TBL_DOCUMENTS.docuserid%TYPE;
v_isforfacility TBL_DOCUMENTS.isforfacility%TYPE;
v_isforuser TBL_DOCUMENTS.isforuser%TYPE;
v_sysdate DATE:=SYSDATE;
v_countusraudit INTEGER:=0;

BEGIN
  IF INSERTING THEN
    v_operation := pkg_audit.g_operation_create;
    v_createdby := :NEW.createdby;
    v_createddt := :NEW.createddt;
    v_modifiedby := :NEW.createdby;
    v_modifieddt := :NEW.createddt;
    v_documentid := :NEW.DOCUMENTID;
    v_facilityid:=:NEW.FACILITYID;
    v_docuserid:=:NEW.DOCUSERID;
    v_isforfacility:=:NEW.ISFORFACILITY;
    v_isforuser:=:NEW.ISFORUSER;

  ELSIF UPDATING THEN
     IF NVL(:OLD.isdeleted,'N') <> NVL(:NEW.isdeleted,'N') AND :NEW.isdeleted = 'Y' THEN
      v_operation := pkg_audit.g_operation_delete;
    ELSE
      v_operation := pkg_audit.g_operation_update;
    END IF;
    v_createdby := :NEW.modifiedby;
    v_createddt := :NEW.modifieddt;
    v_modifiedby := :NEW.modifiedby;
    v_modifieddt := :NEW.modifieddt;
     v_documentid := :NEW.DOCUMENTID;
	 v_facilityid:=:NEW.FACILITYID;
    v_docuserid:=:NEW.DOCUSERID;
    v_isforfacility:=:NEW.ISFORFACILITY;
    v_isforuser:=:NEW.ISFORUSER;

  ELSIF DELETING THEN
    v_operation := pkg_audit.g_operation_delete;
    v_documentid := :OLD.DOCUMENTID;
	v_facilityid:=:OLD.FACILITYID;
    v_docuserid:=:OLD.DOCUSERID;
    v_isforfacility:=:OLD.ISFORFACILITY;
    v_isforuser:=:OLD.ISFORUSER;
	v_createdby := pkg_audit.fn_get_del_createdby('TBL_DOCUMENTS',v_documentid);
    v_createddt := pkg_audit.fn_get_del_createddt('TBL_DOCUMENTS',v_documentid);
    v_modifiedby := pkg_audit.fn_get_del_createdby('TBL_DOCUMENTS',v_documentid);
    v_modifieddt := pkg_audit.fn_get_del_createddt('TBL_DOCUMENTS',v_documentid);
  END IF;

      pkg_audit.sp_set_audit
    (v_documentid,'TBL_DOCUMENTS','DOCUMENTID',:OLD.DOCUMENTID,:NEW.DOCUMENTID,v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

 if v_auditid is not null then
    pkg_audit.SP_SET_DOCAUDITREPORTMAP
    (v_auditid,v_facilityid,v_docuserid,v_isforfacility,v_isforuser,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_documentid);
end if;


  pkg_audit.sp_set_audit
    (v_documentid,'TBL_DOCUMENTS','TITLE',:OLD.TITLE,:NEW.TITLE,v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

 if v_auditid is not null then
    pkg_audit.SP_SET_DOCAUDITREPORTMAP
    (v_auditid,v_facilityid,v_docuserid,v_isforfacility,v_isforuser,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_documentid);
  end if;

      if v_auditid is not null and v_isforuser = 'Y' then
        pkg_audit.sp_set_userauditreportmap
		  (v_auditid,v_docuserid,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
	end if;


    pkg_audit.sp_set_audit
    (v_documentid,'TBL_DOCUMENTS','VERSION',:OLD.VERSION,:NEW.VERSION,v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

 if v_auditid is not null then
    pkg_audit.SP_SET_DOCAUDITREPORTMAP
    (v_auditid,v_facilityid,v_docuserid,v_isforfacility,v_isforuser,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_documentid);
end if;


    pkg_audit.sp_set_audit
    (v_documentid,'TBL_DOCUMENTS','ISFORSTUDY',:OLD.ISFORSTUDY,:NEW.ISFORSTUDY,v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

 if v_auditid is not null then
    pkg_audit.SP_SET_DOCAUDITREPORTMAP
    (v_auditid,v_facilityid,v_docuserid,v_isforfacility,v_isforuser,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_documentid);
end if;


    pkg_audit.sp_set_audit
    (v_documentid,'TBL_DOCUMENTS','ISFORUSER',:OLD.ISFORUSER,:NEW.ISFORUSER,v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

 if v_auditid is not null then
    pkg_audit.SP_SET_DOCAUDITREPORTMAP
    (v_auditid,v_facilityid,v_docuserid,v_isforfacility,v_isforuser,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_documentid);
end if;


    pkg_audit.sp_set_audit
    (v_documentid,'TBL_DOCUMENTS','DOCAUTHORID',pkg_audit.fn_get_lov_value(:OLD.DOCAUTHORID,pkg_audit.g_lov_userprofile_userid_trans),pkg_audit.fn_get_lov_value(:NEW.DOCAUTHORID, pkg_audit.g_lov_userprofile_userid_trans),v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

 if v_auditid is not null then
    pkg_audit.SP_SET_DOCAUDITREPORTMAP
    (v_auditid,v_facilityid,v_docuserid,v_isforfacility,v_isforuser,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_documentid);
end if;


      pkg_audit.sp_set_audit
    (v_documentid,'TBL_DOCUMENTS','DOCUSERID',pkg_audit.fn_get_lov_value(:OLD.DOCUSERID,pkg_audit.g_lov_userprofile_userid_trans),pkg_audit.fn_get_lov_value(:NEW.DOCUSERID, pkg_audit.g_lov_userprofile_userid_trans),v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

 if v_auditid is not null then
    pkg_audit.SP_SET_DOCAUDITREPORTMAP
    (v_auditid,v_facilityid,v_docuserid,v_isforfacility,v_isforuser,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_documentid);
end if;


    pkg_audit.sp_set_audit
    (v_documentid,'TBL_DOCUMENTS','STUDYID',pkg_audit.fn_get_lov_value(:OLD.STUDYID, pkg_audit.g_lov_study),pkg_audit.fn_get_lov_value(:NEW.STUDYID, pkg_audit.g_lov_study),v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

 if v_auditid is not null then
    pkg_audit.SP_SET_DOCAUDITREPORTMAP
    (v_auditid,v_facilityid,v_docuserid,v_isforfacility,v_isforuser,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_documentid);
  end if;


    pkg_audit.sp_set_audit
    (v_documentid,'TBL_DOCUMENTS','DESCRIPTION',:OLD.DESCRIPTION,:NEW.DESCRIPTION,v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

 if v_auditid is not null then
    pkg_audit.SP_SET_DOCAUDITREPORTMAP
    (v_auditid,v_facilityid,v_docuserid,v_isforfacility,v_isforuser,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_documentid);
end if;

       if v_auditid is not null and v_isforuser = 'Y' then
        pkg_audit.sp_set_userauditreportmap
		  (v_auditid,v_docuserid,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
	end if;


    pkg_audit.sp_set_audit
    (v_documentid,'TBL_DOCUMENTS','URL',:OLD.URL,:NEW.URL,v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

 if v_auditid is not null then
    pkg_audit.SP_SET_DOCAUDITREPORTMAP
    (v_auditid,v_facilityid,v_docuserid,v_isforfacility,v_isforuser,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_documentid);
end if;



    pkg_audit.sp_set_audit
    (v_documentid,'TBL_DOCUMENTS','DOCTYPECD',(CASE WHEN :OLD.DOCTYPECD = 1 THEN 'CV' WHEN :OLD.DOCTYPECD = 2 THEN 'Medical License' WHEN :OLD.DOCTYPECD = 3 THEN 'User Attachment' ELSE :OLD.DOCTYPECD END),
    (CASE WHEN :NEW.DOCTYPECD = 1 THEN 'CV' WHEN :NEW.DOCTYPECD = 2 THEN 'Medical License' WHEN :NEW.DOCTYPECD = 3 THEN 'User Attachment' ELSE :NEW.DOCTYPECD END),v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

 if v_auditid is not null then
    pkg_audit.SP_SET_DOCAUDITREPORTMAP
    (v_auditid,v_facilityid,v_docuserid,v_isforfacility,v_isforuser,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_documentid);
end if;


    pkg_audit.sp_set_audit
    (v_documentid,'TBL_DOCUMENTS','ISLATEST',:OLD.ISLATEST,:NEW.ISLATEST,v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

 if v_auditid is not null then
    pkg_audit.SP_SET_DOCAUDITREPORTMAP
    (v_auditid,v_facilityid,v_docuserid,v_isforfacility,v_isforuser,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_documentid);
end if;



    pkg_audit.sp_set_audit
    (v_documentid,'TBL_DOCUMENTS','ISDELETED',:OLD.ISDELETED,:NEW.ISDELETED,v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

 if v_auditid is not null then
    pkg_audit.SP_SET_DOCAUDITREPORTMAP
    (v_auditid,v_facilityid,v_docuserid,v_isforfacility,v_isforuser,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_documentid);
end if;



    pkg_audit.sp_set_audit
    (v_documentid,'TBL_DOCUMENTS','EXPIRATIONDT',TO_CHAR(:OLD.EXPIRATIONDT,'DD-Mon-YYYY'),TO_CHAR(:NEW.EXPIRATIONDT,'DD-Mon-YYYY'),v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

 if v_auditid is not null then
    pkg_audit.SP_SET_DOCAUDITREPORTMAP
    (v_auditid,v_facilityid,v_docuserid,v_isforfacility,v_isforuser,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_documentid);
  end if;



    pkg_audit.sp_set_audit
    (v_documentid,'TBL_DOCUMENTS','CREATEDBY',:OLD.CREATEDBY,:NEW.CREATEDBY,v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

 if v_auditid is not null then
    pkg_audit.SP_SET_DOCAUDITREPORTMAP
    (v_auditid,v_facilityid,v_docuserid,v_isforfacility,v_isforuser,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_documentid);
end if;


    pkg_audit.sp_set_audit
    (v_documentid,'TBL_DOCUMENTS','CREATEDDT',TO_CHAR(:OLD.CREATEDDT,'DD-Mon-YYYY'),TO_CHAR(:NEW.CREATEDDT,'DD-Mon-YYYY'),v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

 if v_auditid is not null then
    pkg_audit.SP_SET_DOCAUDITREPORTMAP
    (v_auditid,v_facilityid,v_docuserid,v_isforfacility,v_isforuser,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_documentid);
end if;


    pkg_audit.sp_set_audit
    (v_documentid,'TBL_DOCUMENTS','MODIFIEDBY',:OLD.MODIFIEDBY,:NEW.MODIFIEDBY,v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

 if v_auditid is not null then
    pkg_audit.SP_SET_DOCAUDITREPORTMAP
    (v_auditid,v_facilityid,v_docuserid,v_isforfacility,v_isforuser,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_documentid);
end if;



    pkg_audit.sp_set_audit
    (v_documentid,'TBL_DOCUMENTS','MODIFIEDDT',TO_CHAR(:OLD.MODIFIEDDT,'DD-Mon-YYYY'),TO_CHAR(:NEW.MODIFIEDDT,'DD-Mon-YYYY'),v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

 if v_auditid is not null then
    pkg_audit.SP_SET_DOCAUDITREPORTMAP
    (v_auditid,v_facilityid,v_docuserid,v_isforfacility,v_isforuser,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_documentid);
end if;



   pkg_audit.sp_set_audit
    (v_documentid,'TBL_DOCUMENTS','ISFORFACILITY',:OLD.ISFORFACILITY,:NEW.ISFORFACILITY,v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

 if v_auditid is not null then
    pkg_audit.SP_SET_DOCAUDITREPORTMAP
    (v_auditid,v_facilityid,v_docuserid,v_isforfacility,v_isforuser,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_documentid);
end if;


    pkg_audit.sp_set_audit
    (v_documentid,'TBL_DOCUMENTS','ISFORADDITIONALFACILITY',:OLD.ISFORADDITIONALFACILITY,:NEW.ISFORADDITIONALFACILITY,v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

  if v_auditid is not null then
    pkg_audit.SP_SET_DOCAUDITREPORTMAP
    (v_auditid,v_facilityid,v_docuserid,v_isforfacility,v_isforuser,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_documentid);
  end if;


    pkg_audit.sp_set_audit
    (v_documentid,'TBL_DOCUMENTS','FACILITYID',:OLD.FACILITYID,:NEW.FACILITYID,v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

  if v_auditid is not null then
    pkg_audit.SP_SET_DOCAUDITREPORTMAP
    (v_auditid,v_facilityid,v_docuserid,v_isforfacility,v_isforuser,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_documentid);
  end if;


    pkg_audit.sp_set_audit
    (v_documentid,'TBL_DOCUMENTS','ADDITIONALFACILITYID',pkg_audit.fn_get_lov_value(:OLD.ADDITIONALFACILITYID, pkg_audit.g_lov_addlfacility),pkg_audit.fn_get_lov_value(:NEW.ADDITIONALFACILITYID, pkg_audit.g_lov_addlfacility),v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);


  if v_auditid is not null then
    pkg_audit.SP_SET_DOCAUDITREPORTMAP
    (v_auditid,v_facilityid,v_docuserid,v_isforfacility,v_isforuser,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_documentid);
	end if;


    pkg_audit.sp_set_audit
    (v_documentid,'TBL_DOCUMENTS','AUTHSIGNATORYUSERID',:OLD.AUTHSIGNATORYUSERID,:NEW.AUTHSIGNATORYUSERID,v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

  if v_auditid is not null then
    pkg_audit.SP_SET_DOCAUDITREPORTMAP
    (v_auditid,v_facilityid,v_docuserid,v_isforfacility,v_isforuser,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_documentid);
end if;


    pkg_audit.sp_set_audit
    (v_documentid,'TBL_DOCUMENTS','SIGNATUREDATE',:OLD.SIGNATUREDATE,:NEW.SIGNATUREDATE,v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

  if v_auditid is not null then
    pkg_audit.SP_SET_DOCAUDITREPORTMAP
    (v_auditid,v_facilityid,v_docuserid,v_isforfacility,v_isforuser,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_documentid);
end if;


      pkg_audit.sp_set_audit
    (v_documentid,'TBL_DOCUMENTS','NATUREOFSIGNATURE',:OLD.NATUREOFSIGNATURE,:NEW.NATUREOFSIGNATURE,v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

  if v_auditid is not null then
    pkg_audit.SP_SET_DOCAUDITREPORTMAP
    (v_auditid,v_facilityid,v_docuserid,v_isforfacility,v_isforuser,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_documentid);
end if;


      pkg_audit.sp_set_audit
    (v_documentid,'TBL_DOCUMENTS','COMMENTS',:OLD.COMMENTS,:NEW.COMMENTS,v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

  if v_auditid is not null then
    pkg_audit.SP_SET_DOCAUDITREPORTMAP
    (v_auditid,v_facilityid,v_docuserid,v_isforfacility,v_isforuser,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_documentid);
end if;

     if v_auditid is not null and v_isforuser = 'Y' then
        pkg_audit.sp_set_userauditreportmap
		  (v_auditid,v_docuserid,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
	end if;


pkg_audit.sp_del_deletedrecords('TBL_DOCUMENTS',v_documentid);

END trg_tbl_documents_audit;
/