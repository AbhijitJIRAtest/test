CREATE OR REPLACE TRIGGER TRG_TBL_ADDLSITELOCATION_AUDIT
AFTER INSERT OR UPDATE OR DELETE ON TBL_ADDLSITELOCATION
FOR EACH ROW
DECLARE
v_operation     			TBL_AUDIT.operation%TYPE;
v_auditid       			TBL_AUDIT.auditid%TYPE;
v_createdby     			TBL_AUDIT.createdby%TYPE;
v_createddt     			TBL_AUDIT.createddt%TYPE;
v_modifiedby    			TBL_AUDIT.modifiedby%TYPE;
v_modifieddt    			TBL_AUDIT.modifieddt%TYPE;
v_sitelocationid    	    TBL_ADDLSITELOCATION.sitelocationid%TYPE;
v_siteid                    TBL_SITE.SITEID%TYPE;
v_studyid                   TBL_SITE.STUDYID%TYPE;  
v_contactid                 TBL_CONTACT.contactid%TYPE;
v_sysdate       	        DATE:=SYSDATE;
BEGIN
    IF INSERTING THEN
        v_operation := pkg_audit.g_operation_create;
        v_sitelocationid:= :NEW.sitelocationid;
        v_createdby := :NEW.createdby;
        v_createddt := :NEW.createddt;
        v_modifiedby := :NEW.createdby;
        v_modifieddt := :NEW.createddt;
        v_siteid := :NEW.siteid;
        v_contactid := :NEW.contactid;
    ELSIF UPDATING THEN
        IF NVL(:OLD.status,'Y') <> NVL(:NEW.status,'Y') AND :NEW.status = 'D' THEN
          v_operation := pkg_audit.g_operation_delete;
        ELSE    
          v_operation := pkg_audit.g_operation_update;
        END IF;  
        v_sitelocationid:= :NEW.sitelocationid;
        v_createdby := :NEW.modifiedby;
        v_createddt := :NEW.modifieddt;
        v_modifiedby := :NEW.modifiedby;
        v_modifieddt := :NEW.modifieddt;
        v_siteid := :NEW.siteid;
        v_contactid := :NEW.contactid;
	ELSIF DELETING THEN
        v_operation := pkg_audit.g_operation_delete;
        v_sitelocationid:= :OLD.sitelocationid;
        v_createdby := :OLD.modifiedby;
        v_createddt := v_sysdate;
        v_modifiedby := :OLD.modifiedby;
        v_modifieddt := v_sysdate;
        v_siteid := :OLD.siteid;
        v_contactid := :OLD.contactid;
    END IF;
  
    --Get Study ID
    BEGIN
         SELECT studyid
         INTO v_studyid
         FROM tbl_site
         WHERE siteid = v_siteid;
    EXCEPTION
        WHEN OTHERS THEN
             v_studyid:= NULL;
    END;

    pkg_audit.sp_set_audit
    (v_sitelocationid,'TBL_ADDLSITELOCATION','SITELOCATIONID',:OLD.SITELOCATIONID,:NEW.SITELOCATIONID,v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

    IF v_auditid IS NOT NULL THEN
       pkg_audit.sp_set_studyauditreportmap
       (v_auditid,v_studyid,v_siteid,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
    END IF;
   
    pkg_audit.sp_set_audit
    (v_sitelocationid,'TBL_ADDLSITELOCATION','SITEID',:OLD.SITEID,:NEW.SITEID,v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

    IF v_auditid IS NOT NULL THEN
       pkg_audit.sp_set_studyauditreportmap
       (v_auditid,v_studyid,v_siteid,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
    END IF;
    
    pkg_audit.sp_set_audit
    (v_sitelocationid,'TBL_ADDLSITELOCATION','FACILITYID',:OLD.FACILITYID,:NEW.FACILITYID,v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

    IF v_auditid IS NOT NULL THEN
       pkg_audit.sp_set_studyauditreportmap
       (v_auditid,v_studyid,v_siteid,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
    END IF;
    
    pkg_audit.sp_set_audit
    (v_sitelocationid,'TBL_ADDLSITELOCATION','EXTERNALID',:OLD.EXTERNALID,:NEW.EXTERNALID,v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

    IF v_auditid IS NOT NULL THEN
       pkg_audit.sp_set_studyauditreportmap
       (v_auditid,v_studyid,v_siteid,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
    END IF;

    pkg_audit.sp_set_audit
    (v_sitelocationid,'TBL_ADDLSITELOCATION','ISDEPARTMENT',:OLD.ISDEPARTMENT,:NEW.ISDEPARTMENT,v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

    IF v_auditid IS NOT NULL THEN
       pkg_audit.sp_set_studyauditreportmap
       (v_auditid,v_studyid,v_siteid,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
    END IF;
    
    pkg_audit.sp_set_audit
    (v_sitelocationid,'TBL_ADDLSITELOCATION','FACILITYNAME',:OLD.FACILITYNAME,:NEW.FACILITYNAME,v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

    IF v_auditid IS NOT NULL THEN
       pkg_audit.sp_set_studyauditreportmap
       (v_auditid,v_studyid,v_siteid,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
    END IF;

    pkg_audit.sp_set_audit
    (v_sitelocationid,'TBL_ADDLSITELOCATION','DEPARTMENTNAME',:OLD.DEPARTMENTNAME,:NEW.DEPARTMENTNAME,v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

    IF v_auditid IS NOT NULL THEN
       pkg_audit.sp_set_studyauditreportmap
       (v_auditid,v_studyid,v_siteid,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
    END IF;
    
    pkg_audit.sp_set_audit
    (v_sitelocationid,'TBL_ADDLSITELOCATION','FACILITYFORDEPARTMENT',:OLD.FACILITYFORDEPARTMENT,:NEW.FACILITYFORDEPARTMENT,v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

    IF v_auditid IS NOT NULL THEN
       pkg_audit.sp_set_studyauditreportmap
       (v_auditid,v_studyid,v_siteid,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
    END IF;
    
    pkg_audit.sp_set_audit
    (v_sitelocationid,'TBL_ADDLSITELOCATION','CONTACTID',:OLD.CONTACTID,:NEW.CONTACTID,v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

    IF v_auditid IS NOT NULL THEN
       pkg_audit.sp_set_studyauditreportmap
       (v_auditid,v_studyid,v_siteid,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
    END IF;
    
    pkg_audit.sp_set_audit
    (v_sitelocationid,'TBL_ADDLSITELOCATION','STATUS',pkg_audit.fn_get_lov_value(:OLD.STATUS, pkg_audit.g_lov_activeflag),pkg_audit.fn_get_lov_value(:NEW.STATUS, pkg_audit.g_lov_activeflag),v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

    IF v_auditid IS NOT NULL THEN
       pkg_audit.sp_set_studyauditreportmap
       (v_auditid,v_studyid,v_siteid,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
    END IF;

    pkg_audit.sp_set_audit
    (v_sitelocationid,'TBL_ADDLSITELOCATION','STARTDATE',TO_CHAR(:OLD.STARTDATE,'DD-MON-YYYY'),TO_CHAR(:NEW.STARTDATE,'DD-MON-YYYY'),v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

    IF v_auditid IS NOT NULL THEN
       pkg_audit.sp_set_studyauditreportmap
       (v_auditid,v_studyid,v_siteid,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
    END IF;
    
    pkg_audit.sp_set_audit
    (v_sitelocationid,'TBL_ADDLSITELOCATION','ENDDATE',TO_CHAR(:OLD.ENDDATE,'DD-MON-YYYY'),TO_CHAR(:NEW.ENDDATE,'DD-MON-YYYY'),v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

    IF v_auditid IS NOT NULL THEN
       pkg_audit.sp_set_studyauditreportmap
       (v_auditid,v_studyid,v_siteid,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
    END IF;

    pkg_audit.sp_set_audit
    (v_sitelocationid,'TBL_ADDLSITELOCATION','ISINCLUDED1572',:OLD.ISINCLUDED1572,:NEW.ISINCLUDED1572,v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

    IF v_auditid IS NOT NULL THEN
       pkg_audit.sp_set_studyauditreportmap
       (v_auditid,v_studyid,v_siteid,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
    END IF;
    
    pkg_audit.sp_set_audit
    (v_sitelocationid,'TBL_ADDLSITELOCATION','CREATEDBY',:OLD.CREATEDBY,:NEW.CREATEDBY,v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

    IF v_auditid IS NOT NULL THEN
       pkg_audit.sp_set_studyauditreportmap
       (v_auditid,v_studyid,v_siteid,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
    END IF;
    
    pkg_audit.sp_set_audit
    (v_sitelocationid,'TBL_ADDLSITELOCATION','MODIFIEDBY',:OLD.MODIFIEDBY,:NEW.MODIFIEDBY,v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

    IF v_auditid IS NOT NULL THEN
       pkg_audit.sp_set_studyauditreportmap
       (v_auditid,v_studyid,v_siteid,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
    END IF;
    
    pkg_audit.sp_set_audit
    (v_sitelocationid,'TBL_ADDLSITELOCATION','CREATEDDT',TO_CHAR(:OLD.CREATEDDT,'DD-MON-YYYY'),TO_CHAR(:NEW.CREATEDDT,'DD-MON-YYYY'),v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

    IF v_auditid IS NOT NULL THEN
       pkg_audit.sp_set_studyauditreportmap
       (v_auditid,v_studyid,v_siteid,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
    END IF;
    
    pkg_audit.sp_set_audit
    (v_sitelocationid,'TBL_ADDLSITELOCATION','MODIFIEDDT',TO_CHAR(:OLD.MODIFIEDDT,'DD-MON-YYYY'),TO_CHAR(:NEW.MODIFIEDDT,'DD-MON-YYYY'),v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

    IF v_auditid IS NOT NULL THEN
       pkg_audit.sp_set_studyauditreportmap
       (v_auditid,v_studyid,v_siteid,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
    END IF;

    --Update Study Id and Siteid
    UPDATE TBL_STUDYAUDITREPORTMAP tsarm
    SET tsarm.studyid = v_studyid, 
        tsarm.studysiteid = v_siteid
    WHERE tsarm.studyid IS NULL and tsarm.studysiteid IS NULL
    AND tsarm.studyauditid IN (SELECT ta.auditid
                               FROM tbl_audit ta
                               WHERE ta.tablename IN ('TBL_CONTACT')
                               AND ta.entityrefid = v_contactid); 
 
END TRG_TBL_ADDLSITELOCATION_AUDIT;
/