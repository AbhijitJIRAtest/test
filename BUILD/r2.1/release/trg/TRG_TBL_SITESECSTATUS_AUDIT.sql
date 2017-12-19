CREATE OR REPLACE TRIGGER TRG_TBL_SITESECSTATUS_AUDIT
AFTER INSERT OR UPDATE OR DELETE ON TBL_SITESECTIONSTATUS
FOR EACH ROW
DECLARE
v_operation     			TBL_AUDIT.operation%TYPE;
v_auditid       			TBL_AUDIT.auditid%TYPE;
v_createdby     			TBL_AUDIT.createdby%TYPE;
v_createddt     			TBL_AUDIT.createddt%TYPE;
v_modifiedby    			TBL_AUDIT.modifiedby%TYPE;
v_modifieddt    			TBL_AUDIT.modifieddt%TYPE;
v_sitesectionstatusid    	TBL_SITESECTIONSTATUS.sitesectionstatusid%TYPE;
v_studyid       			TBL_SITE.studyid%TYPE;
v_siteid       			    TBL_SITESECTIONSTATUS.siteid%TYPE;
v_sysdate       			DATE:=SYSDATE;

BEGIN

    IF INSERTING THEN
        v_operation := pkg_audit.g_operation_create;
        v_sitesectionstatusid:= :NEW.sitesectionstatusid;
        v_siteid := :NEW.siteid;
        v_createdby := :NEW.createdby;
        v_createddt := :NEW.createddt;
        v_modifiedby := :NEW.createdby;
        v_modifieddt := :NEW.createddt;
	ELSIF UPDATING THEN
        v_operation := pkg_audit.g_operation_update;
        v_sitesectionstatusid:= :NEW.sitesectionstatusid;
        v_siteid := :NEW.siteid;
        v_createdby := :NEW.modifiedby;
        v_createddt := :NEW.modifieddt;
        v_modifiedby := :NEW.modifiedby;
        v_modifieddt := :NEW.modifieddt;
	ELSIF DELETING THEN
        v_operation := pkg_audit.g_operation_delete;
        v_sitesectionstatusid:= :OLD.sitesectionstatusid;
        v_siteid := :OLD.siteid;
        v_createdby := :OLD.modifiedby;
        v_createddt := v_sysdate;
        v_modifiedby := :OLD.modifiedby;
        v_modifieddt := v_sysdate;
    END IF;
    
    BEGIN
        SELECT tsi.studyid
        INTO v_studyid
        FROM TBL_SITE tsi
        WHERE tsi.siteid = v_siteid;
    EXCEPTION 
        WHEN OTHERS THEN
            v_studyid := NULL;     
    END;
    
    IF UPDATING THEN
       pkg_audit.sp_set_audit
       (v_sitesectionstatusid,'TBL_SITESECTIONSTATUS','SITESECTIONSTATUSID',:OLD.SITESECTIONSTATUSID,:NEW.SITESECTIONSTATUSID,v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid); 
       
       IF v_auditid IS NOT NULL THEN 
          pkg_audit.sp_set_studyauditreportmap
          (v_auditid,v_studyid,v_siteid,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
       END IF;
       
       pkg_audit.sp_set_audit
       (v_sitesectionstatusid,'TBL_SITESECTIONSTATUS','SECTIONID',:OLD.SECTIONID,:NEW.SECTIONID,v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid); 
       
       IF v_auditid IS NOT NULL THEN 
          pkg_audit.sp_set_studyauditreportmap
          (v_auditid,v_studyid,v_siteid,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
       END IF;
       
       pkg_audit.sp_set_audit
       (v_sitesectionstatusid,'TBL_SITESECTIONSTATUS','SITEID',:OLD.SITEID,:NEW.SITEID,v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid); 
       
       IF v_auditid IS NOT NULL THEN 
          pkg_audit.sp_set_studyauditreportmap
          (v_auditid,v_studyid,v_siteid,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
       END IF;
       
       pkg_audit.sp_set_audit
       (v_sitesectionstatusid,'TBL_SITESECTIONSTATUS','STATUS',:OLD.STATUS,:NEW.STATUS,v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid); 
       
       IF v_auditid IS NOT NULL THEN 
          pkg_audit.sp_set_studyauditreportmap
          (v_auditid,v_studyid,v_siteid,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
       END IF;
       
       pkg_audit.sp_set_audit
       (v_sitesectionstatusid,'TBL_SITESECTIONSTATUS','ISAPPLICABLE',pkg_audit.fn_get_lov_value(:OLD.ISAPPLICABLE, pkg_audit.g_lov_notapplicable),pkg_audit.fn_get_lov_value(:NEW.ISAPPLICABLE, pkg_audit.g_lov_notapplicable),v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid); 
       
       IF v_auditid IS NOT NULL THEN 
          pkg_audit.sp_set_studyauditreportmap
          (v_auditid,v_studyid,v_siteid,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
       END IF;
       
       pkg_audit.sp_set_audit
       (v_sitesectionstatusid,'TBL_SITESECTIONSTATUS','CREATEDBY',:OLD.CREATEDBY,:NEW.CREATEDBY,v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid); 
       
       IF v_auditid IS NOT NULL THEN 
          pkg_audit.sp_set_studyauditreportmap
          (v_auditid,v_studyid,v_siteid,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
       END IF;
       
       pkg_audit.sp_set_audit
       (v_sitesectionstatusid,'TBL_SITESECTIONSTATUS','CREATEDDT',TO_CHAR(:OLD.CREATEDDT,'DD-MON-YYYY'),TO_CHAR(:NEW.CREATEDDT,'DD-MON-YYYY'),v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid); 
       
       IF v_auditid IS NOT NULL THEN 
          pkg_audit.sp_set_studyauditreportmap
          (v_auditid,v_studyid,v_siteid,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
       END IF;
       
       pkg_audit.sp_set_audit
       (v_sitesectionstatusid,'TBL_SITESECTIONSTATUS','MODIFIEDBY',:OLD.MODIFIEDBY,:NEW.MODIFIEDBY,v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid); 
       
       IF v_auditid IS NOT NULL THEN 
          pkg_audit.sp_set_studyauditreportmap
          (v_auditid,v_studyid,v_siteid,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
       END IF;
       
       pkg_audit.sp_set_audit
       (v_sitesectionstatusid,'TBL_SITESECTIONSTATUS','MODIFIEDDT',TO_CHAR(:OLD.MODIFIEDDT,'DD-MON-YYYY'),TO_CHAR(:NEW.MODIFIEDDT,'DD-MON-YYYY'),v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid); 
       
       IF v_auditid IS NOT NULL THEN 
          pkg_audit.sp_set_studyauditreportmap
          (v_auditid,v_studyid,v_siteid,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
       END IF;
       
    END IF;
  
END TRG_TBL_SITESECSTATUS_AUDIT;
/