create or replace TRIGGER TRG_TBL_CONTACT_AUDIT
AFTER INSERT OR UPDATE OR DELETE ON TBL_CONTACT
FOR EACH ROW
DECLARE
v_operation tbl_audit.operation%TYPE;
v_auditid   tbl_audit.auditid%TYPE;
v_createdby tbl_audit.createdby%TYPE;
v_createddt tbl_audit.createddt%TYPE;
v_modifiedby tbl_contact.modifiedby%TYPE;
v_modifieddt tbl_audit.modifieddt%TYPE;
v_contactid  tbl_contact.contactid%TYPE;
v_count INTEGER:=0;
v_countfacaudit INTEGER:=0;
v_addfac  INTEGER:=0;
v_storage  INTEGER:=0;
v_contacttype tbl_contact.contacttype%TYPE;
v_irb_contact           INTEGER:=0;
v_lab_contact           INTEGER:=0; 
v_add_loc               INTEGER:=0; 
v_centralirb_contact    INTEGER:=0;
v_centrallab_contact    INTEGER:=0;
v_studyid       tbl_study.studyid%TYPE;  
v_siteid        tbl_site.siteid%TYPE;
v_sysdate DATE:=SYSDATE;

BEGIN
  IF INSERTING THEN
    v_operation := pkg_audit.g_operation_create;
    v_createdby := :NEW.createdby;
    v_createddt := :NEW.createddt;
    v_modifiedby := :NEW.createdby;
    v_modifieddt := :NEW.createddt;
    v_contactid := :NEW.contactid;
	v_contacttype := :NEW.contacttype;
  ELSIF UPDATING THEN
    IF NVL(:OLD.isactive,'Y') <> NVL(:NEW.isactive,'Y') AND :NEW.isactive = 'N' THEN
      v_operation := pkg_audit.g_operation_delete;
    ELSE
      v_operation := pkg_audit.g_operation_update;
    END IF;
     v_contactid := :NEW.contactid;
	 v_contacttype := :NEW.contacttype;
    v_createdby := :NEW.modifiedby;
    v_createddt := :NEW.modifieddt;
    v_modifiedby := :NEW.modifiedby;
    v_modifieddt := :NEW.modifieddt;
  ELSIF DELETING THEN
    v_operation := pkg_audit.g_operation_delete;
    v_contactid := :OLD.contactid;
	v_contacttype := :OLD.contacttype;
	v_createdby := pkg_audit.fn_get_del_createdby('TBL_CONTACT',v_contactid);
    v_createddt := pkg_audit.fn_get_del_createddt('TBL_CONTACT',v_contactid);
    v_modifiedby := pkg_audit.fn_get_del_createdby('TBL_CONTACT',v_contactid);
    v_modifieddt := pkg_audit.fn_get_del_createddt('TBL_CONTACT',v_contactid);
  END IF;

  --Check if Studyid is associated with Contact
  SELECT COUNT(1)
  INTO v_count
  FROM tbl_sitecontactmap tscm, tbl_site ts
  WHERE tscm.siteid = ts.siteid
  AND (tscm.contactid = v_contactid OR tscm.mastercontactid = v_contactid OR ts.contactid = v_contactid)
  AND ts.isactive = 'Y'
  AND tscm.isactive = 'Y';

  --Check if it is a Facility contact  
  select count(1) 
  INTO v_countfacaudit
  from tbl_facilities fac
  where fac.contactid = v_contactid ;
  
  -- Check if it is Additional Facility
    select count(1) 
  into v_addfac
  from TBL_ADDITIONALFACILITY 
  where MASTERFACILITYTYPECODE = 'IRB' 
  and contactid = v_contactid ;
    
  -- Check if it is Storage Contact
    select count(1) 
  into v_storage
  from TBL_IPSTORAGECONMAP 
  where contactid = v_contactid ;
  
  --Check if IRB/LAB Contact
  SELECT COUNT(1)
  INTO v_irb_contact
  FROM TBL_SITEIRBMAP
  WHERE contactid = v_contactid;
  
  SELECT COUNT(1)
  INTO v_lab_contact
  FROM TBL_SITELABMAP
  WHERE contactid = v_contactid;
  
  --Check if Central IRB/LAB Contact
  SELECT COUNT(1)
  INTO v_centralirb_contact
  FROM TBL_STUDYCENTRALIRB
  WHERE contactid = v_contactid;
  
  SELECT COUNT(1)
  INTO v_centrallab_contact
  FROM TBL_STUDYCENTRALLAB
  WHERE contactid = v_contactid;
  
  --Check if Additional Contact
  SELECT COUNT(1)
  INTO v_add_loc
  FROM TBL_ADDLSITELOCATION
  WHERE contactid = v_contactid;
  
  IF v_irb_contact <> 0 THEN
     SELECT DISTINCT tsi.studyid,tsi.siteid
     INTO v_studyid,v_siteid
     FROM TBL_SITEIRBMAP tsir, TBL_SITE tsi
     WHERE tsir.siteid = tsi.siteid
     AND tsir.contactid = v_contactid;
  ELSIF v_lab_contact <> 0 THEN
     SELECT DISTINCT tsi.studyid,tsi.siteid
     INTO v_studyid,v_siteid
     FROM TBL_SITELABMAP tslb, TBL_SITE tsi
     WHERE tslb.siteid = tsi.siteid
     AND tslb.contactid = v_contactid;
  ELSIF v_centralirb_contact <> 0 THEN
     SELECT tscir.studyid, NULL siteid
     INTO v_studyid,v_siteid
     FROM TBL_STUDYCENTRALIRB tscir
     WHERE tscir.contactid = v_contactid;
  ELSIF v_centrallab_contact <> 0 THEN
     SELECT tsclb.studyid, NULL siteid
     INTO v_studyid,v_siteid
     FROM TBL_STUDYCENTRALLAB tsclb
     WHERE tsclb.contactid = v_contactid;
  ELSIF v_add_loc <> 0 THEN
     SELECT DISTINCT tsi.studyid,tsi.siteid
     INTO v_studyid,v_siteid
     FROM TBL_ADDLSITELOCATION tasl, TBL_SITE tsi
     WHERE tasl.siteid = tsi.siteid
     AND tasl.contactid = v_contactid;
  ELSE
     v_studyid := NULL;
     v_siteid := NULL;
  END IF;
  
  pkg_audit.sp_set_audit
    (v_contactid,(CASE WHEN v_contacttype = 'IRB/Ethics Committee' THEN 'TBL_CONTACT_IRB'
					   ELSE 'TBL_CONTACT' END),'CONTACTID',:OLD.CONTACTID,:NEW.CONTACTID,v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

 
  if v_auditid is not null then
  IF v_count <> 0 THEN
  FOR i IN (SELECT DISTINCT ts.studyid,ts.siteid
            FROM tbl_sitecontactmap tscm, tbl_site ts
            WHERE tscm.siteid = ts.siteid
            AND (tscm.contactid = v_contactid OR tscm.mastercontactid = v_contactid OR ts.contactid = v_contactid)
            AND ts.isactive = 'Y'
            AND tscm.isactive = 'Y') LOOP
    pkg_audit.sp_set_studyauditreportmap
    (v_auditid,i.studyid,i.siteid,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  END LOOP;
     ELSE
    pkg_audit.sp_set_studyauditreportmap
    (v_auditid,v_studyid,v_siteid,v_createddt,v_createdby,v_modifieddt,v_modifiedby);

  END IF;
  end if;

  
    if v_auditid is not null and v_countfacaudit <> 0 then
	 FOR i IN ( select facilityid
  from tbl_facilities fac
  where fac.contactid = v_contactid ) 
		LOOP
        pkg_audit.sp_set_facauditreportmap
		  (v_auditid,i.facilityid,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
		END LOOP;
	end if;
	
  pkg_audit.sp_set_audit
  (v_contactid,(CASE WHEN v_contacttype = 'IRB/Ethics Committee' THEN 'TBL_CONTACT_IRB'
					   ELSE 'TBL_CONTACT' END),'CONTACTENTITY',:OLD.CONTACTENTITY,:NEW.CONTACTENTITY,v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

  if v_auditid is not null then
  IF v_count <> 0 THEN
  FOR i IN (SELECT DISTINCT ts.studyid,ts.siteid
            FROM tbl_sitecontactmap tscm, tbl_site ts
            WHERE tscm.siteid = ts.siteid
            AND (tscm.contactid = v_contactid OR tscm.mastercontactid = v_contactid OR ts.contactid = v_contactid)
            AND ts.isactive = 'Y'
            AND tscm.isactive = 'Y') LOOP
    pkg_audit.sp_set_studyauditreportmap
    (v_auditid,i.studyid,i.siteid,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  END LOOP;
  ELSIF v_storage <> 0 then
	 FOR i IN ( select facilityid
  from TBL_FACIPDETAILS facip
  where facip.ipid = (select ipid from TBL_IPSTORAGECONMAP where contactid = v_contactid )) 
		LOOP
        pkg_audit.sp_set_facauditreportmap
		  (v_auditid,i.facilityid,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
		END LOOP;
    ELSE
    pkg_audit.sp_set_studyauditreportmap
    (v_auditid,v_studyid,v_siteid,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
    pkg_audit.sp_set_facauditreportmap
		  (v_auditid,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  END IF;
  end if;

  
    if v_auditid is not null and v_countfacaudit <> 0 then
	 FOR i IN ( select facilityid
  from tbl_facilities fac
  where fac.contactid = v_contactid ) 
		LOOP
        pkg_audit.sp_set_facauditreportmap
		  (v_auditid,i.facilityid,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
		END LOOP;
	end if;
	
    pkg_audit.sp_set_audit
  (v_contactid,(CASE WHEN v_contacttype = 'IRB/Ethics Committee' THEN 'TBL_CONTACT_IRB'
					   ELSE 'TBL_CONTACT' END),'CONTACTTYPE',:OLD.CONTACTTYPE,:NEW.CONTACTTYPE,v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

  if v_auditid is not null then
  IF v_count <> 0 THEN
  FOR i IN (SELECT DISTINCT ts.studyid,ts.siteid
            FROM tbl_sitecontactmap tscm, tbl_site ts
            WHERE tscm.siteid = ts.siteid
            AND (tscm.contactid = v_contactid OR tscm.mastercontactid = v_contactid OR ts.contactid = v_contactid)
            AND ts.isactive = 'Y'
            AND tscm.isactive = 'Y') LOOP
    pkg_audit.sp_set_studyauditreportmap
    (v_auditid,i.studyid,i.siteid,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  END LOOP;
    ELSE
    pkg_audit.sp_set_studyauditreportmap
    (v_auditid,v_studyid,v_siteid,v_createddt,v_createdby,v_modifieddt,v_modifiedby);

  END IF;
  end if;

  
    if v_auditid is not null and v_countfacaudit <> 0 then
	 FOR i IN ( select facilityid
  from tbl_facilities fac
  where fac.contactid = v_contactid ) 
		LOOP
        pkg_audit.sp_set_facauditreportmap
		  (v_auditid,i.facilityid,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
		END LOOP;
	end if;
	
  pkg_audit.sp_set_audit
  (v_contactid,(CASE WHEN v_contacttype = 'IRB/Ethics Committee' THEN 'TBL_CONTACT_IRB'
					   ELSE 'TBL_CONTACT' END),'REGIONCD',:OLD.REGIONCD,:NEW.REGIONCD,v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

  if v_auditid is not null then
  IF v_count <> 0 THEN
  FOR i IN (SELECT DISTINCT ts.studyid,ts.siteid
            FROM tbl_sitecontactmap tscm, tbl_site ts
            WHERE tscm.siteid = ts.siteid
            AND (tscm.contactid = v_contactid OR tscm.mastercontactid = v_contactid OR ts.contactid = v_contactid)
            AND ts.isactive = 'Y'
            AND tscm.isactive = 'Y') LOOP
    pkg_audit.sp_set_studyauditreportmap
    (v_auditid,i.studyid,i.siteid,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  END LOOP;
  ELSIF v_storage <> 0 then
	 FOR i IN ( select facilityid
  from TBL_FACIPDETAILS facip
  where facip.ipid = (select ipid from TBL_IPSTORAGECONMAP where contactid = v_contactid )) 
		LOOP
        pkg_audit.sp_set_facauditreportmap
		  (v_auditid,i.facilityid,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
		END LOOP;
    ELSE
    pkg_audit.sp_set_studyauditreportmap
    (v_auditid,v_studyid,v_siteid,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
    pkg_audit.sp_set_facauditreportmap
		  (v_auditid,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  END IF;
  end if;

  
    if v_auditid is not null and v_countfacaudit <> 0 then
	 FOR i IN ( select facilityid
  from tbl_facilities fac
  where fac.contactid = v_contactid ) 
		LOOP
        pkg_audit.sp_set_facauditreportmap
		  (v_auditid,i.facilityid,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
		END LOOP;
	end if;
	
    pkg_audit.sp_set_audit
  (v_contactid,(CASE WHEN v_contacttype = 'IRB/Ethics Committee' THEN 'TBL_CONTACT_IRB'
					   ELSE 'TBL_CONTACT' END),'ADDRESSTYPE',:OLD.ADDRESSTYPE,:NEW.ADDRESSTYPE,v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

 
  if v_auditid is not null then
  IF v_count <> 0 THEN
  FOR i IN (SELECT DISTINCT ts.studyid,ts.siteid
            FROM tbl_sitecontactmap tscm, tbl_site ts
            WHERE tscm.siteid = ts.siteid
            AND (tscm.contactid = v_contactid OR tscm.mastercontactid = v_contactid OR ts.contactid = v_contactid)
            AND ts.isactive = 'Y'
            AND tscm.isactive = 'Y') LOOP
    pkg_audit.sp_set_studyauditreportmap
    (v_auditid,i.studyid,i.siteid,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  END LOOP;
  ELSIF v_storage <> 0 then
	 FOR i IN ( select facilityid
  from TBL_FACIPDETAILS facip
  where facip.ipid = (select ipid from TBL_IPSTORAGECONMAP where contactid = v_contactid )) 
		LOOP
        pkg_audit.sp_set_facauditreportmap
		  (v_auditid,i.facilityid,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
		END LOOP;
    ELSE
    pkg_audit.sp_set_studyauditreportmap
    (v_auditid,v_studyid,v_siteid,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
    pkg_audit.sp_set_facauditreportmap
		  (v_auditid,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  END IF;
  end if;

  
    if v_auditid is not null and v_countfacaudit <> 0 then
	 FOR i IN ( select facilityid
  from tbl_facilities fac
  where fac.contactid = v_contactid ) 
		LOOP
        pkg_audit.sp_set_facauditreportmap
		  (v_auditid,i.facilityid,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
		END LOOP;
	end if;
	
  pkg_audit.sp_set_audit
  (v_contactid,(CASE WHEN v_contacttype = 'IRB/Ethics Committee' THEN 'TBL_CONTACT_IRB'
					   ELSE 'TBL_CONTACT' END),'ADDRESS1',:OLD.ADDRESS1,:NEW.ADDRESS1,v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

 
  if v_auditid is not null then
  IF v_count <> 0 THEN
  FOR i IN (SELECT DISTINCT ts.studyid,ts.siteid
            FROM tbl_sitecontactmap tscm, tbl_site ts
            WHERE tscm.siteid = ts.siteid
            AND (tscm.contactid = v_contactid OR tscm.mastercontactid = v_contactid OR ts.contactid = v_contactid)
            AND ts.isactive = 'Y'
            AND tscm.isactive = 'Y') LOOP
    pkg_audit.sp_set_studyauditreportmap
    (v_auditid,i.studyid,i.siteid,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  END LOOP;
  ELSIF v_storage <> 0 then
	 FOR i IN ( select facilityid
  from TBL_FACIPDETAILS facip
  where facip.ipid = (select ipid from TBL_IPSTORAGECONMAP where contactid = v_contactid )) 
		LOOP
        pkg_audit.sp_set_facauditreportmap
		  (v_auditid,i.facilityid,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
		END LOOP;
    ELSE
    pkg_audit.sp_set_studyauditreportmap
    (v_auditid,v_studyid,v_siteid,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
    pkg_audit.sp_set_facauditreportmap
		  (v_auditid,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  END IF;
  end if;

  
    if v_auditid is not null and v_countfacaudit <> 0 then
	 FOR i IN ( select facilityid
  from tbl_facilities fac
  where fac.contactid = v_contactid ) 
		LOOP
        pkg_audit.sp_set_facauditreportmap
		  (v_auditid,i.facilityid,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
		END LOOP;
	end if;
	
  
    pkg_audit.sp_set_audit
  (v_contactid,(CASE WHEN v_contacttype = 'IRB/Ethics Committee' THEN 'TBL_CONTACT_IRB'
					   ELSE 'TBL_CONTACT' END),'ADDRESS2',:OLD.ADDRESS2,:NEW.ADDRESS2,v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

 
  if v_auditid is not null then
  IF v_count <> 0 THEN
  FOR i IN (SELECT DISTINCT ts.studyid,ts.siteid
            FROM tbl_sitecontactmap tscm, tbl_site ts
            WHERE tscm.siteid = ts.siteid
            AND (tscm.contactid = v_contactid OR tscm.mastercontactid = v_contactid OR ts.contactid = v_contactid)
            AND ts.isactive = 'Y'
            AND tscm.isactive = 'Y') LOOP
    pkg_audit.sp_set_studyauditreportmap
    (v_auditid,i.studyid,i.siteid,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  END LOOP;
  ELSIF v_storage <> 0 then
	 FOR i IN ( select facilityid
  from TBL_FACIPDETAILS facip
  where facip.ipid = (select ipid from TBL_IPSTORAGECONMAP where contactid = v_contactid )) 
		LOOP
        pkg_audit.sp_set_facauditreportmap
		  (v_auditid,i.facilityid,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
		END LOOP;
    ELSE
    pkg_audit.sp_set_studyauditreportmap
    (v_auditid,v_studyid,v_siteid,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
    pkg_audit.sp_set_facauditreportmap
		  (v_auditid,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  END IF;
  end if;

  
    if v_auditid is not null and v_countfacaudit <> 0 then
	 FOR i IN ( select facilityid
  from tbl_facilities fac
  where fac.contactid = v_contactid ) 
		LOOP
        pkg_audit.sp_set_facauditreportmap
		  (v_auditid,i.facilityid,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
		END LOOP;
	end if;

  
  pkg_audit.sp_set_audit
  (v_contactid,(CASE WHEN v_contacttype = 'IRB/Ethics Committee' THEN 'TBL_CONTACT_IRB'
					   ELSE 'TBL_CONTACT' END),'ADDRESS3',:OLD.ADDRESS3,:NEW.ADDRESS3,v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

 
  if v_auditid is not null then
  IF v_count <> 0 THEN
  FOR i IN (SELECT DISTINCT ts.studyid,ts.siteid
            FROM tbl_sitecontactmap tscm, tbl_site ts
            WHERE tscm.siteid = ts.siteid
            AND (tscm.contactid = v_contactid OR tscm.mastercontactid = v_contactid OR ts.contactid = v_contactid)
            AND ts.isactive = 'Y'
            AND tscm.isactive = 'Y') LOOP
    pkg_audit.sp_set_studyauditreportmap
    (v_auditid,i.studyid,i.siteid,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  END LOOP;
  ELSIF v_storage <> 0 then
	 FOR i IN ( select facilityid
  from TBL_FACIPDETAILS facip
  where facip.ipid = (select ipid from TBL_IPSTORAGECONMAP where contactid = v_contactid )) 
		LOOP
        pkg_audit.sp_set_facauditreportmap
		  (v_auditid,i.facilityid,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
		END LOOP;
    ELSE
    pkg_audit.sp_set_studyauditreportmap
    (v_auditid,v_studyid,v_siteid,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
    pkg_audit.sp_set_facauditreportmap
		  (v_auditid,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  END IF;
  end if;

  
    if v_auditid is not null and v_countfacaudit <> 0 then
	 FOR i IN ( select facilityid
  from tbl_facilities fac
  where fac.contactid = v_contactid ) 
		LOOP
        pkg_audit.sp_set_facauditreportmap
		  (v_auditid,i.facilityid,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
		END LOOP;
	end if;
	
    pkg_audit.sp_set_audit
  (v_contactid,(CASE WHEN v_contacttype = 'IRB/Ethics Committee' THEN 'TBL_CONTACT_IRB'
					   ELSE 'TBL_CONTACT' END),'CITY',:OLD.CITY,:NEW.CITY,v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

 
  if v_auditid is not null then
  IF v_count <> 0 THEN
  FOR i IN (SELECT DISTINCT ts.studyid,ts.siteid
            FROM tbl_sitecontactmap tscm, tbl_site ts
            WHERE tscm.siteid = ts.siteid
            AND (tscm.contactid = v_contactid OR tscm.mastercontactid = v_contactid OR ts.contactid = v_contactid)
            AND ts.isactive = 'Y'
            AND tscm.isactive = 'Y') LOOP
    pkg_audit.sp_set_studyauditreportmap
    (v_auditid,i.studyid,i.siteid,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  END LOOP;
  ELSIF v_storage <> 0 then
	 FOR i IN ( select facilityid
  from TBL_FACIPDETAILS facip
  where facip.ipid = (select ipid from TBL_IPSTORAGECONMAP where contactid = v_contactid )) 
		LOOP
        pkg_audit.sp_set_facauditreportmap
		  (v_auditid,i.facilityid,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
		END LOOP;
    ELSE
    pkg_audit.sp_set_studyauditreportmap
    (v_auditid,v_studyid,v_siteid,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
    pkg_audit.sp_set_facauditreportmap
		  (v_auditid,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  END IF;
  end if;

  
    if v_auditid is not null and v_countfacaudit <> 0 then
	 FOR i IN ( select facilityid
  from tbl_facilities fac
  where fac.contactid = v_contactid ) 
		LOOP
        pkg_audit.sp_set_facauditreportmap
		  (v_auditid,i.facilityid,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
		END LOOP;
	end if;
	
  pkg_audit.sp_set_audit
  (v_contactid,(CASE WHEN v_contacttype = 'IRB/Ethics Committee' THEN 'TBL_CONTACT_IRB'
					   ELSE 'TBL_CONTACT' END),'STATE',pkg_audit.fn_get_lov_value(:OLD.STATE, pkg_audit.g_lov_state_code),pkg_audit.fn_get_lov_value(:NEW.STATE, pkg_audit.g_lov_state_code),v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

 
  if v_auditid is not null then
  IF v_count <> 0 THEN
  FOR i IN (SELECT DISTINCT ts.studyid,ts.siteid
            FROM tbl_sitecontactmap tscm, tbl_site ts
            WHERE tscm.siteid = ts.siteid
            AND (tscm.contactid = v_contactid OR tscm.mastercontactid = v_contactid OR ts.contactid = v_contactid)
            AND ts.isactive = 'Y'
            AND tscm.isactive = 'Y') LOOP
    pkg_audit.sp_set_studyauditreportmap
    (v_auditid,i.studyid,i.siteid,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  END LOOP;
  ELSIF v_storage <> 0 then
	 FOR i IN ( select facilityid
  from TBL_FACIPDETAILS facip
  where facip.ipid = (select ipid from TBL_IPSTORAGECONMAP where contactid = v_contactid )) 
		LOOP
        pkg_audit.sp_set_facauditreportmap
		  (v_auditid,i.facilityid,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
		END LOOP;
    ELSE
    pkg_audit.sp_set_studyauditreportmap
    (v_auditid,v_studyid,v_siteid,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
    pkg_audit.sp_set_facauditreportmap
		  (v_auditid,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  END IF;
  end if;

  
    if v_auditid is not null and v_countfacaudit <> 0 then
	 FOR i IN ( select facilityid
  from tbl_facilities fac
  where fac.contactid = v_contactid ) 
		LOOP
        pkg_audit.sp_set_facauditreportmap
		  (v_auditid,i.facilityid,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
		END LOOP;
	end if;
	
    pkg_audit.sp_set_audit
  (v_contactid,(CASE WHEN v_contacttype = 'IRB/Ethics Committee' THEN 'TBL_CONTACT_IRB'
					   ELSE 'TBL_CONTACT' END),'COUNTRYCD',pkg_audit.fn_get_lov_value(:OLD.COUNTRYCD, pkg_audit.g_lov_country_code),pkg_audit.fn_get_lov_value(:NEW.COUNTRYCD, pkg_audit.g_lov_country_code),v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);


  if v_auditid is not null then
  IF v_count <> 0 THEN
  FOR i IN (SELECT DISTINCT ts.studyid,ts.siteid
            FROM tbl_sitecontactmap tscm, tbl_site ts
            WHERE tscm.siteid = ts.siteid
            AND (tscm.contactid = v_contactid OR tscm.mastercontactid = v_contactid OR ts.contactid = v_contactid)
            AND ts.isactive = 'Y'
            AND tscm.isactive = 'Y') LOOP
    pkg_audit.sp_set_studyauditreportmap
    (v_auditid,i.studyid,i.siteid,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  END LOOP;
  ELSIF v_storage <> 0 then
	 FOR i IN ( select facilityid
  from TBL_FACIPDETAILS facip
  where facip.ipid = (select ipid from TBL_IPSTORAGECONMAP where contactid = v_contactid )) 
		LOOP
        pkg_audit.sp_set_facauditreportmap
		  (v_auditid,i.facilityid,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
		END LOOP;
    ELSE
    pkg_audit.sp_set_studyauditreportmap
    (v_auditid,v_studyid,v_siteid,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
    pkg_audit.sp_set_facauditreportmap
		  (v_auditid,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  END IF;
  end if;

  
    if v_auditid is not null and v_countfacaudit <> 0 then
	 FOR i IN ( select facilityid
  from tbl_facilities fac
  where fac.contactid = v_contactid ) 
		LOOP
        pkg_audit.sp_set_facauditreportmap
		  (v_auditid,i.facilityid,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
		END LOOP;
	end if;
	
  pkg_audit.sp_set_audit
  (v_contactid,(CASE WHEN v_contacttype = 'IRB/Ethics Committee' THEN 'TBL_CONTACT_IRB'
					   ELSE 'TBL_CONTACT' END),'POSTALCODE',:OLD.POSTALCODE,:NEW.POSTALCODE,v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);


  if v_auditid is not null then
  IF v_count <> 0 THEN
  FOR i IN (SELECT DISTINCT ts.studyid,ts.siteid
            FROM tbl_sitecontactmap tscm, tbl_site ts
            WHERE tscm.siteid = ts.siteid
            AND (tscm.contactid = v_contactid OR tscm.mastercontactid = v_contactid OR ts.contactid = v_contactid)
            AND ts.isactive = 'Y'
            AND tscm.isactive = 'Y') LOOP
    pkg_audit.sp_set_studyauditreportmap
    (v_auditid,i.studyid,i.siteid,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  END LOOP;
  ELSIF v_storage <> 0 then
	 FOR i IN ( select facilityid
  from TBL_FACIPDETAILS facip
  where facip.ipid = (select ipid from TBL_IPSTORAGECONMAP where contactid = v_contactid )) 
		LOOP
        pkg_audit.sp_set_facauditreportmap
		  (v_auditid,i.facilityid,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
		END LOOP;
    ELSE
    pkg_audit.sp_set_studyauditreportmap
    (v_auditid,v_studyid,v_siteid,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
    pkg_audit.sp_set_facauditreportmap
		  (v_auditid,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  END IF;
  end if;

  
    if v_auditid is not null and v_countfacaudit <> 0 then
	 FOR i IN ( select facilityid
  from tbl_facilities fac
  where fac.contactid = v_contactid ) 
		LOOP
        pkg_audit.sp_set_facauditreportmap
		  (v_auditid,i.facilityid,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
		END LOOP;
	end if;
	
    pkg_audit.sp_set_audit
  (v_contactid,(CASE WHEN v_contacttype = 'IRB/Ethics Committee' THEN 'TBL_CONTACT_IRB'
					   ELSE 'TBL_CONTACT' END),'TELECOMADDRESS',:OLD.TELECOMADDRESS,:NEW.TELECOMADDRESS,v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

 
  if v_auditid is not null then
  IF v_count <> 0 THEN
  FOR i IN (SELECT DISTINCT ts.studyid,ts.siteid
            FROM tbl_sitecontactmap tscm, tbl_site ts
            WHERE tscm.siteid = ts.siteid
            AND (tscm.contactid = v_contactid OR tscm.mastercontactid = v_contactid OR ts.contactid = v_contactid)
            AND ts.isactive = 'Y'
            AND tscm.isactive = 'Y') LOOP
    pkg_audit.sp_set_studyauditreportmap
    (v_auditid,i.studyid,i.siteid,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  END LOOP;
  ELSIF v_storage <> 0 then
	 FOR i IN ( select facilityid
  from TBL_FACIPDETAILS facip
  where facip.ipid = (select ipid from TBL_IPSTORAGECONMAP where contactid = v_contactid )) 
		LOOP
        pkg_audit.sp_set_facauditreportmap
		  (v_auditid,i.facilityid,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
		END LOOP;
    ELSE
    pkg_audit.sp_set_studyauditreportmap
    (v_auditid,v_studyid,v_siteid,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
    pkg_audit.sp_set_facauditreportmap
		  (v_auditid,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  END IF;
  end if;

  
    if v_auditid is not null and v_countfacaudit <> 0 then
	 FOR i IN ( select facilityid
  from tbl_facilities fac
  where fac.contactid = v_contactid ) 
		LOOP
        pkg_audit.sp_set_facauditreportmap
		  (v_auditid,i.facilityid,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
		END LOOP;
	end if;
	
      pkg_audit.sp_set_audit
  (v_contactid,(CASE WHEN v_contacttype = 'IRB/Ethics Committee' THEN 'TBL_CONTACT_IRB'
					   ELSE 'TBL_CONTACT' END),'PHONE1',:OLD.PHONE1,:NEW.PHONE1,v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);


  if v_auditid is not null then
  IF v_count <> 0 THEN
  FOR i IN (SELECT DISTINCT ts.studyid,ts.siteid
            FROM tbl_sitecontactmap tscm, tbl_site ts
            WHERE tscm.siteid = ts.siteid
            AND (tscm.contactid = v_contactid OR tscm.mastercontactid = v_contactid OR ts.contactid = v_contactid)
            AND ts.isactive = 'Y'
            AND tscm.isactive = 'Y') LOOP
    pkg_audit.sp_set_studyauditreportmap
    (v_auditid,i.studyid,i.siteid,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  END LOOP;
  ELSIF v_storage <> 0 then
	 FOR i IN ( select facilityid
  from TBL_FACIPDETAILS facip
  where facip.ipid = (select ipid from TBL_IPSTORAGECONMAP where contactid = v_contactid )) 
		LOOP
        pkg_audit.sp_set_facauditreportmap
		  (v_auditid,i.facilityid,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
		END LOOP;
    ELSE
    pkg_audit.sp_set_studyauditreportmap
    (v_auditid,v_studyid,v_siteid,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
    pkg_audit.sp_set_facauditreportmap
		  (v_auditid,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  END IF;
  end if;

  
    if v_auditid is not null and v_countfacaudit <> 0 then
	 FOR i IN ( select facilityid
  from tbl_facilities fac
  where fac.contactid = v_contactid ) 
		LOOP
        pkg_audit.sp_set_facauditreportmap
		  (v_auditid,i.facilityid,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
		END LOOP;
	end if;
	

  pkg_audit.sp_set_audit
  (v_contactid,(CASE WHEN v_contacttype = 'IRB/Ethics Committee' THEN 'TBL_CONTACT_IRB'
					   ELSE 'TBL_CONTACT' END),'PHONE1EXT',:OLD.PHONE1EXT,:NEW.PHONE1EXT,v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

 
  if v_auditid is not null then
  IF v_count <> 0 THEN
  FOR i IN (SELECT DISTINCT ts.studyid,ts.siteid
            FROM tbl_sitecontactmap tscm, tbl_site ts
            WHERE tscm.siteid = ts.siteid
            AND (tscm.contactid = v_contactid OR tscm.mastercontactid = v_contactid OR ts.contactid = v_contactid)
            AND ts.isactive = 'Y'
            AND tscm.isactive = 'Y') LOOP
    pkg_audit.sp_set_studyauditreportmap
    (v_auditid,i.studyid,i.siteid,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  END LOOP;
  ELSIF v_storage <> 0 then
	 FOR i IN ( select facilityid
  from TBL_FACIPDETAILS facip
  where facip.ipid = (select ipid from TBL_IPSTORAGECONMAP where contactid = v_contactid )) 
		LOOP
        pkg_audit.sp_set_facauditreportmap
		  (v_auditid,i.facilityid,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
		END LOOP;
    ELSE
    pkg_audit.sp_set_studyauditreportmap
    (v_auditid,v_studyid,v_siteid,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
    pkg_audit.sp_set_facauditreportmap
		  (v_auditid,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  END IF;
  end if;

  
    if v_auditid is not null and v_countfacaudit <> 0 then
	 FOR i IN ( select facilityid
  from tbl_facilities fac
  where fac.contactid = v_contactid ) 
		LOOP
        pkg_audit.sp_set_facauditreportmap
		  (v_auditid,i.facilityid,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
		END LOOP;
	end if;
	
	
    pkg_audit.sp_set_audit
  (v_contactid,(CASE WHEN v_contacttype = 'IRB/Ethics Committee' THEN 'TBL_CONTACT_IRB'
					   ELSE 'TBL_CONTACT' END),'PHONE2',:OLD.PHONE2,:NEW.PHONE2,v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);


  if v_auditid is not null then
  IF v_count <> 0 THEN
  FOR i IN (SELECT DISTINCT ts.studyid,ts.siteid
            FROM tbl_sitecontactmap tscm, tbl_site ts
            WHERE tscm.siteid = ts.siteid
            AND (tscm.contactid = v_contactid OR tscm.mastercontactid = v_contactid OR ts.contactid = v_contactid)
            AND ts.isactive = 'Y'
            AND tscm.isactive = 'Y') LOOP
    pkg_audit.sp_set_studyauditreportmap
    (v_auditid,i.studyid,i.siteid,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  END LOOP;
  ELSIF v_storage <> 0 then
	 FOR i IN ( select facilityid
  from TBL_FACIPDETAILS facip
  where facip.ipid = (select ipid from TBL_IPSTORAGECONMAP where contactid = v_contactid )) 
		LOOP
        pkg_audit.sp_set_facauditreportmap
		  (v_auditid,i.facilityid,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
		END LOOP;
    ELSE
    pkg_audit.sp_set_studyauditreportmap
    (v_auditid,v_studyid,v_siteid,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
    pkg_audit.sp_set_facauditreportmap
		  (v_auditid,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  END IF;
  end if;

  
    if v_auditid is not null and v_countfacaudit <> 0 then
	 FOR i IN ( select facilityid
  from tbl_facilities fac
  where fac.contactid = v_contactid ) 
		LOOP
        pkg_audit.sp_set_facauditreportmap
		  (v_auditid,i.facilityid,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
		END LOOP;
	end if;
	
  pkg_audit.sp_set_audit
  (v_contactid,(CASE WHEN v_contacttype = 'IRB/Ethics Committee' THEN 'TBL_CONTACT_IRB'
					   ELSE 'TBL_CONTACT' END),'PHONE2EXT',:OLD.PHONE2EXT,:NEW.PHONE2EXT,v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

 
  if v_auditid is not null then
  IF v_count <> 0 THEN
  FOR i IN (SELECT DISTINCT ts.studyid,ts.siteid
            FROM tbl_sitecontactmap tscm, tbl_site ts
            WHERE tscm.siteid = ts.siteid
            AND (tscm.contactid = v_contactid OR tscm.mastercontactid = v_contactid OR ts.contactid = v_contactid)
            AND ts.isactive = 'Y'
            AND tscm.isactive = 'Y') LOOP
    pkg_audit.sp_set_studyauditreportmap
    (v_auditid,i.studyid,i.siteid,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  END LOOP;
  ELSIF v_storage <> 0 then
	 FOR i IN ( select facilityid
  from TBL_FACIPDETAILS facip
  where facip.ipid = (select ipid from TBL_IPSTORAGECONMAP where contactid = v_contactid )) 
		LOOP
        pkg_audit.sp_set_facauditreportmap
		  (v_auditid,i.facilityid,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
		END LOOP;
    ELSE
    pkg_audit.sp_set_studyauditreportmap
    (v_auditid,v_studyid,v_siteid,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
    pkg_audit.sp_set_facauditreportmap
		  (v_auditid,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  END IF;
  end if;

      if v_auditid is not null and v_countfacaudit <> 0 then
	 FOR i IN ( select facilityid
  from tbl_facilities fac
  where fac.contactid = v_contactid ) 
		LOOP
        pkg_audit.sp_set_facauditreportmap
		  (v_auditid,i.facilityid,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
		END LOOP;
	end if;
	
    pkg_audit.sp_set_audit
  (v_contactid,(CASE WHEN v_contacttype = 'IRB/Ethics Committee' THEN 'TBL_CONTACT_IRB'
					   ELSE 'TBL_CONTACT' END),'ASSISTANTPHONE',:OLD.ASSISTANTPHONE,:NEW.ASSISTANTPHONE,v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

 
  if v_auditid is not null then
  IF v_count <> 0 THEN
  FOR i IN (SELECT DISTINCT ts.studyid,ts.siteid
            FROM tbl_sitecontactmap tscm, tbl_site ts
            WHERE tscm.siteid = ts.siteid
            AND (tscm.contactid = v_contactid OR tscm.mastercontactid = v_contactid OR ts.contactid = v_contactid)
            AND ts.isactive = 'Y'
            AND tscm.isactive = 'Y') LOOP
    pkg_audit.sp_set_studyauditreportmap
    (v_auditid,i.studyid,i.siteid,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  END LOOP;
  ELSIF v_storage <> 0 then
	 FOR i IN ( select facilityid
  from TBL_FACIPDETAILS facip
  where facip.ipid = (select ipid from TBL_IPSTORAGECONMAP where contactid = v_contactid )) 
		LOOP
        pkg_audit.sp_set_facauditreportmap
		  (v_auditid,i.facilityid,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
		END LOOP;
    ELSE
    pkg_audit.sp_set_studyauditreportmap
    (v_auditid,v_studyid,v_siteid,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
    pkg_audit.sp_set_facauditreportmap
		  (v_auditid,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  END IF;
  end if;

  
    if v_auditid is not null and v_countfacaudit <> 0 then
	 FOR i IN ( select facilityid
  from tbl_facilities fac
  where fac.contactid = v_contactid ) 
		LOOP
        pkg_audit.sp_set_facauditreportmap
		  (v_auditid,i.facilityid,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
		END LOOP;
	end if;
	
  pkg_audit.sp_set_audit
  (v_contactid,(CASE WHEN v_contacttype = 'IRB/Ethics Committee' THEN 'TBL_CONTACT_IRB'
					   ELSE 'TBL_CONTACT' END),'PAGER',:OLD.PAGER,:NEW.PAGER,v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

 
  if v_auditid is not null then
  IF v_count <> 0 THEN
  FOR i IN (SELECT DISTINCT ts.studyid,ts.siteid
            FROM tbl_sitecontactmap tscm, tbl_site ts
            WHERE tscm.siteid = ts.siteid
            AND (tscm.contactid = v_contactid OR tscm.mastercontactid = v_contactid OR ts.contactid = v_contactid)
            AND ts.isactive = 'Y'
            AND tscm.isactive = 'Y') LOOP
    pkg_audit.sp_set_studyauditreportmap
    (v_auditid,i.studyid,i.siteid,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  END LOOP;
  ELSIF v_storage <> 0 then
	 FOR i IN ( select facilityid
  from TBL_FACIPDETAILS facip
  where facip.ipid = (select ipid from TBL_IPSTORAGECONMAP where contactid = v_contactid )) 
		LOOP
        pkg_audit.sp_set_facauditreportmap
		  (v_auditid,i.facilityid,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
		END LOOP;
    ELSE
    pkg_audit.sp_set_studyauditreportmap
    (v_auditid,v_studyid,v_siteid,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
    pkg_audit.sp_set_facauditreportmap
		  (v_auditid,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  END IF;
  end if;

  
    if v_auditid is not null and v_countfacaudit <> 0 then
	 FOR i IN ( select facilityid
  from tbl_facilities fac
  where fac.contactid = v_contactid ) 
		LOOP
        pkg_audit.sp_set_facauditreportmap
		  (v_auditid,i.facilityid,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
		END LOOP;
	end if;
	
    pkg_audit.sp_set_audit
  (v_contactid,(CASE WHEN v_contacttype = 'IRB/Ethics Committee' THEN 'TBL_CONTACT_IRB'
					   ELSE 'TBL_CONTACT' END),'FAX',:OLD.FAX,:NEW.FAX,v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

 
  if v_auditid is not null then
  IF v_count <> 0 THEN
  FOR i IN (SELECT DISTINCT ts.studyid,ts.siteid
            FROM tbl_sitecontactmap tscm, tbl_site ts
            WHERE tscm.siteid = ts.siteid
            AND (tscm.contactid = v_contactid OR tscm.mastercontactid = v_contactid OR ts.contactid = v_contactid)
            AND ts.isactive = 'Y'
            AND tscm.isactive = 'Y') LOOP
    pkg_audit.sp_set_studyauditreportmap
    (v_auditid,i.studyid,i.siteid,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  END LOOP;
  ELSIF v_storage <> 0 then
	 FOR i IN ( select facilityid
  from TBL_FACIPDETAILS facip
  where facip.ipid = (select ipid from TBL_IPSTORAGECONMAP where contactid = v_contactid )) 
		LOOP
        pkg_audit.sp_set_facauditreportmap
		  (v_auditid,i.facilityid,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
		END LOOP;
    ELSE
    pkg_audit.sp_set_studyauditreportmap
    (v_auditid,v_studyid,v_siteid,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
    pkg_audit.sp_set_facauditreportmap
		  (v_auditid,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  END IF;
  end if;

  
    if v_auditid is not null and v_countfacaudit <> 0 then
	 FOR i IN ( select facilityid
  from tbl_facilities fac
  where fac.contactid = v_contactid ) 
		LOOP
        pkg_audit.sp_set_facauditreportmap
		  (v_auditid,i.facilityid,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
		END LOOP;
	end if;
	
  pkg_audit.sp_set_audit
  (v_contactid,(CASE WHEN v_contacttype = 'IRB/Ethics Committee' THEN 'TBL_CONTACT_IRB'
					   ELSE 'TBL_CONTACT' END),'EMAIL',:OLD.EMAIL,:NEW.EMAIL,v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

 
  if v_auditid is not null then
  IF v_count <> 0 THEN
  FOR i IN (SELECT DISTINCT ts.studyid,ts.siteid
            FROM tbl_sitecontactmap tscm, tbl_site ts
            WHERE tscm.siteid = ts.siteid
            AND (tscm.contactid = v_contactid OR tscm.mastercontactid = v_contactid OR ts.contactid = v_contactid)
            AND ts.isactive = 'Y'
            AND tscm.isactive = 'Y') LOOP
    pkg_audit.sp_set_studyauditreportmap
    (v_auditid,i.studyid,i.siteid,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  END LOOP;
  ELSIF v_storage <> 0 then
	 FOR i IN ( select facilityid
  from TBL_FACIPDETAILS facip
  where facip.ipid = (select ipid from TBL_IPSTORAGECONMAP where contactid = v_contactid )) 
		LOOP
        pkg_audit.sp_set_facauditreportmap
		  (v_auditid,i.facilityid,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
		END LOOP;
    ELSE
    pkg_audit.sp_set_studyauditreportmap
    (v_auditid,v_studyid,v_siteid,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
    pkg_audit.sp_set_facauditreportmap
		  (v_auditid,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  END IF;
  end if;

  
    if v_auditid is not null and v_countfacaudit <> 0 then
	 FOR i IN ( select facilityid
  from tbl_facilities fac
  where fac.contactid = v_contactid ) 
		LOOP
        pkg_audit.sp_set_facauditreportmap
		  (v_auditid,i.facilityid,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
		END LOOP;
	end if;
	
    pkg_audit.sp_set_audit
  (v_contactid,(CASE WHEN v_contacttype = 'IRB/Ethics Committee' THEN 'TBL_CONTACT_IRB'
					   ELSE 'TBL_CONTACT' END),'ISACTIVE',:OLD.ISACTIVE,:NEW.ISACTIVE,v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

 
  if v_auditid is not null then
  IF v_count <> 0 THEN
  FOR i IN (SELECT DISTINCT ts.studyid,ts.siteid
            FROM tbl_sitecontactmap tscm, tbl_site ts
            WHERE tscm.siteid = ts.siteid
            AND (tscm.contactid = v_contactid OR tscm.mastercontactid = v_contactid OR ts.contactid = v_contactid)
            AND ts.isactive = 'Y'
            AND tscm.isactive = 'Y') LOOP
    pkg_audit.sp_set_studyauditreportmap
    (v_auditid,i.studyid,i.siteid,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  END LOOP;
  ELSIF v_storage <> 0 then
	 FOR i IN ( select facilityid
  from TBL_FACIPDETAILS facip
  where facip.ipid = (select ipid from TBL_IPSTORAGECONMAP where contactid = v_contactid )) 
		LOOP
        pkg_audit.sp_set_facauditreportmap
		  (v_auditid,i.facilityid,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
		END LOOP;
    ELSE
    pkg_audit.sp_set_studyauditreportmap
    (v_auditid,v_studyid,v_siteid,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
    pkg_audit.sp_set_facauditreportmap
		  (v_auditid,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  END IF;
  end if;

  
    if v_auditid is not null and v_countfacaudit <> 0 then
	 FOR i IN ( select facilityid
  from tbl_facilities fac
  where fac.contactid = v_contactid ) 
		LOOP
        pkg_audit.sp_set_facauditreportmap
		  (v_auditid,i.facilityid,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
		END LOOP;
	end if;
	
      pkg_audit.sp_set_audit
  (v_contactid,(CASE WHEN v_contacttype = 'IRB/Ethics Committee' THEN 'TBL_CONTACT_IRB'
					   ELSE 'TBL_CONTACT' END),'CREATEDBY',:OLD.CREATEDBY,:NEW.CREATEDBY,v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

 
  if v_auditid is not null then
  IF v_count <> 0 THEN
  FOR i IN (SELECT DISTINCT ts.studyid,ts.siteid
            FROM tbl_sitecontactmap tscm, tbl_site ts
            WHERE tscm.siteid = ts.siteid
            AND (tscm.contactid = v_contactid OR tscm.mastercontactid = v_contactid OR ts.contactid = v_contactid)
            AND ts.isactive = 'Y'
            AND tscm.isactive = 'Y') LOOP
    pkg_audit.sp_set_studyauditreportmap
    (v_auditid,i.studyid,i.siteid,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  END LOOP;
  ELSIF v_storage <> 0 then
	 FOR i IN ( select facilityid
  from TBL_FACIPDETAILS facip
  where facip.ipid = (select ipid from TBL_IPSTORAGECONMAP where contactid = v_contactid )) 
		LOOP
        pkg_audit.sp_set_facauditreportmap
		  (v_auditid,i.facilityid,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
		END LOOP;
    ELSE
    pkg_audit.sp_set_studyauditreportmap
    (v_auditid,v_studyid,v_siteid,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
    pkg_audit.sp_set_facauditreportmap
		  (v_auditid,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  END IF;
  end if;

  
    if v_auditid is not null and v_countfacaudit <> 0 then
	 FOR i IN ( select facilityid
  from tbl_facilities fac
  where fac.contactid = v_contactid ) 
		LOOP
        pkg_audit.sp_set_facauditreportmap
		  (v_auditid,i.facilityid,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
		END LOOP;
	end if;
	
	
  pkg_audit.sp_set_audit
  (v_contactid,(CASE WHEN v_contacttype = 'IRB/Ethics Committee' THEN 'TBL_CONTACT_IRB'
					   ELSE 'TBL_CONTACT' END),'CREATEDDT',TO_CHAR(:OLD.CREATEDDT,'DD-MON-YYYY'),TO_CHAR(:NEW.CREATEDDT,'DD-MON-YYYY'),v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

 
  if v_auditid is not null then
  IF v_count <> 0 THEN
  FOR i IN (SELECT DISTINCT ts.studyid,ts.siteid
            FROM tbl_sitecontactmap tscm, tbl_site ts
            WHERE tscm.siteid = ts.siteid
            AND (tscm.contactid = v_contactid OR tscm.mastercontactid = v_contactid OR ts.contactid = v_contactid)
            AND ts.isactive = 'Y'
            AND tscm.isactive = 'Y') LOOP
    pkg_audit.sp_set_studyauditreportmap
    (v_auditid,i.studyid,i.siteid,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  END LOOP;
  ELSIF v_storage <> 0 then
	 FOR i IN ( select facilityid
  from TBL_FACIPDETAILS facip
  where facip.ipid = (select ipid from TBL_IPSTORAGECONMAP where contactid = v_contactid )) 
		LOOP
        pkg_audit.sp_set_facauditreportmap
		  (v_auditid,i.facilityid,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
		END LOOP;
    ELSE
    pkg_audit.sp_set_studyauditreportmap
    (v_auditid,v_studyid,v_siteid,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
    pkg_audit.sp_set_facauditreportmap
		  (v_auditid,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  END IF;
  end if;

  
    if v_auditid is not null and v_countfacaudit <> 0 then
	 FOR i IN ( select facilityid
  from tbl_facilities fac
  where fac.contactid = v_contactid ) 
		LOOP
        pkg_audit.sp_set_facauditreportmap
		  (v_auditid,i.facilityid,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
		END LOOP;
	end if;
	
    pkg_audit.sp_set_audit
  (v_contactid,(CASE WHEN v_contacttype = 'IRB/Ethics Committee' THEN 'TBL_CONTACT_IRB'
					   ELSE 'TBL_CONTACT' END),'MODIFIEDBY',:OLD.MODIFIEDBY,:NEW.MODIFIEDBY,v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);


  if v_auditid is not null then
  IF v_count <> 0 THEN
  FOR i IN (SELECT DISTINCT ts.studyid,ts.siteid
            FROM tbl_sitecontactmap tscm, tbl_site ts
            WHERE tscm.siteid = ts.siteid
            AND (tscm.contactid = v_contactid OR tscm.mastercontactid = v_contactid OR ts.contactid = v_contactid)
            AND ts.isactive = 'Y'
            AND tscm.isactive = 'Y') LOOP
    pkg_audit.sp_set_studyauditreportmap
    (v_auditid,i.studyid,i.siteid,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  END LOOP;
  ELSIF v_storage <> 0 then
	 FOR i IN ( select facilityid
  from TBL_FACIPDETAILS facip
  where facip.ipid = (select ipid from TBL_IPSTORAGECONMAP where contactid = v_contactid )) 
		LOOP
        pkg_audit.sp_set_facauditreportmap
		  (v_auditid,i.facilityid,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
		END LOOP;
    ELSE
    pkg_audit.sp_set_studyauditreportmap
    (v_auditid,v_studyid,v_siteid,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
    pkg_audit.sp_set_facauditreportmap
		  (v_auditid,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  END IF;
  end if;

  
    if v_auditid is not null and v_countfacaudit <> 0 then
	 FOR i IN ( select facilityid
  from tbl_facilities fac
  where fac.contactid = v_contactid ) 
		LOOP
        pkg_audit.sp_set_facauditreportmap
		  (v_auditid,i.facilityid,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
		END LOOP;
	end if;
	
  pkg_audit.sp_set_audit
  (v_contactid,(CASE WHEN v_contacttype = 'IRB/Ethics Committee' THEN 'TBL_CONTACT_IRB'
					   ELSE 'TBL_CONTACT' END),'MODIFIEDDT',TO_CHAR(:OLD.MODIFIEDDT,'DD-MON-YYYY'),TO_CHAR(:NEW.MODIFIEDDT,'DD-MON-YYYY'),v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);


  if v_auditid is not null then
  IF v_count <> 0 THEN
  FOR i IN (SELECT DISTINCT ts.studyid,ts.siteid
            FROM tbl_sitecontactmap tscm, tbl_site ts
            WHERE tscm.siteid = ts.siteid
            AND (tscm.contactid = v_contactid OR tscm.mastercontactid = v_contactid OR ts.contactid = v_contactid)
            AND ts.isactive = 'Y'
            AND tscm.isactive = 'Y') LOOP
    pkg_audit.sp_set_studyauditreportmap
    (v_auditid,i.studyid,i.siteid,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  END LOOP;
  ELSIF v_storage <> 0 then
	 FOR i IN ( select facilityid
  from TBL_FACIPDETAILS facip
  where facip.ipid = (select ipid from TBL_IPSTORAGECONMAP where contactid = v_contactid )) 
		LOOP
        pkg_audit.sp_set_facauditreportmap
		  (v_auditid,i.facilityid,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
		END LOOP;
    ELSE
    pkg_audit.sp_set_studyauditreportmap
    (v_auditid,v_studyid,v_siteid,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
    pkg_audit.sp_set_facauditreportmap
		  (v_auditid,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  END IF;
  end if;

  
    if v_auditid is not null and v_countfacaudit <> 0 then
	 FOR i IN ( select facilityid
  from tbl_facilities fac
  where fac.contactid = v_contactid ) 
		LOOP
        pkg_audit.sp_set_facauditreportmap
		  (v_auditid,i.facilityid,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
		END LOOP;
	end if;
	
 pkg_audit.sp_set_audit
  (v_contactid,(CASE WHEN v_contacttype = 'IRB/Ethics Committee' THEN 'TBL_CONTACT_IRB'
					   ELSE 'TBL_CONTACT' END),'ADDRESSIRID',:OLD.ADDRESSIRID,:NEW.ADDRESSIRID,v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

 
  if v_auditid is not null then
  IF v_count <> 0 THEN
  FOR i IN (SELECT DISTINCT ts.studyid,ts.siteid
            FROM tbl_sitecontactmap tscm, tbl_site ts
            WHERE tscm.siteid = ts.siteid
            AND (tscm.contactid = v_contactid OR tscm.mastercontactid = v_contactid OR ts.contactid = v_contactid)
            AND ts.isactive = 'Y'
            AND tscm.isactive = 'Y') LOOP
    pkg_audit.sp_set_studyauditreportmap
    (v_auditid,i.studyid,i.siteid,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  END LOOP;
  ELSIF v_storage <> 0 then
	 FOR i IN ( select facilityid
  from TBL_FACIPDETAILS facip
  where facip.ipid = (select ipid from TBL_IPSTORAGECONMAP where contactid = v_contactid )) 
		LOOP
        pkg_audit.sp_set_facauditreportmap
		  (v_auditid,i.facilityid,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
		END LOOP;
    ELSE
    pkg_audit.sp_set_studyauditreportmap
    (v_auditid,v_studyid,v_siteid,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
    pkg_audit.sp_set_facauditreportmap
		  (v_auditid,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  END IF;
  end if;

  
    if v_auditid is not null and v_countfacaudit <> 0 then
	 FOR i IN ( select facilityid
  from tbl_facilities fac
  where fac.contactid = v_contactid ) 
		LOOP
        pkg_audit.sp_set_facauditreportmap
		  (v_auditid,i.facilityid,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
		END LOOP;
	end if;
	
 pkg_audit.sp_set_audit
  (v_contactid,(CASE WHEN v_contacttype = 'IRB/Ethics Committee' THEN 'TBL_CONTACT_IRB'
					   ELSE 'TBL_CONTACT' END),'CONTACTIRID',:OLD.CONTACTIRID,:NEW.CONTACTIRID,v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

 
  if v_auditid is not null then
  IF v_count <> 0 THEN
  FOR i IN (SELECT DISTINCT ts.studyid,ts.siteid
            FROM tbl_sitecontactmap tscm, tbl_site ts
            WHERE tscm.siteid = ts.siteid
            AND (tscm.contactid = v_contactid OR tscm.mastercontactid = v_contactid OR ts.contactid = v_contactid)
            AND ts.isactive = 'Y'
            AND tscm.isactive = 'Y') LOOP
    pkg_audit.sp_set_studyauditreportmap
    (v_auditid,i.studyid,i.siteid,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  END LOOP;
  ELSIF v_storage <> 0 then
	 FOR i IN ( select facilityid
  from TBL_FACIPDETAILS facip
  where facip.ipid = (select ipid from TBL_IPSTORAGECONMAP where contactid = v_contactid )) 
		LOOP
        pkg_audit.sp_set_facauditreportmap
		  (v_auditid,i.facilityid,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
		END LOOP;
    ELSE
    pkg_audit.sp_set_studyauditreportmap
    (v_auditid,v_studyid,v_siteid,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
    pkg_audit.sp_set_facauditreportmap
		  (v_auditid,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  END IF;
  end if;

  
    if v_auditid is not null and v_countfacaudit <> 0 then
	 FOR i IN ( select facilityid
  from tbl_facilities fac
  where fac.contactid = v_contactid ) 
		LOOP
        pkg_audit.sp_set_facauditreportmap
		  (v_auditid,i.facilityid,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
		END LOOP;
	end if;
	
  pkg_audit.sp_set_audit
  (v_contactid,(CASE WHEN v_contacttype = 'IRB/Ethics Committee' THEN 'TBL_CONTACT_IRB'
					   ELSE 'TBL_CONTACT' END),'INSTITUTION',:OLD.INSTITUTION,:NEW.INSTITUTION,v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

 
  if v_auditid is not null then
  IF v_count <> 0 THEN
  FOR i IN (SELECT DISTINCT ts.studyid,ts.siteid
            FROM tbl_sitecontactmap tscm, tbl_site ts
            WHERE tscm.siteid = ts.siteid
            AND (tscm.contactid = v_contactid OR tscm.mastercontactid = v_contactid OR ts.contactid = v_contactid)
            AND ts.isactive = 'Y'
            AND tscm.isactive = 'Y') LOOP
    pkg_audit.sp_set_studyauditreportmap
    (v_auditid,i.studyid,i.siteid,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  END LOOP;
  ELSIF v_storage <> 0 then
	 FOR i IN ( select facilityid
  from TBL_FACIPDETAILS facip
  where facip.ipid = (select ipid from TBL_IPSTORAGECONMAP where contactid = v_contactid )) 
		LOOP
        pkg_audit.sp_set_facauditreportmap
		  (v_auditid,i.facilityid,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
		END LOOP;
    ELSE
    pkg_audit.sp_set_studyauditreportmap
    (v_auditid,v_studyid,v_siteid,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
    pkg_audit.sp_set_facauditreportmap
		  (v_auditid,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
  END IF;
  end if;

  
    if v_auditid is not null and v_countfacaudit <> 0 then
	 FOR i IN ( select facilityid
  from tbl_facilities fac
  where fac.contactid = v_contactid ) 
		LOOP
        pkg_audit.sp_set_facauditreportmap
		  (v_auditid,i.facilityid,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
		END LOOP;
	end if;
	
  pkg_audit.sp_del_deletedrecords('TBL_CONTACT',v_contactid);

END trg_tbl_contact_audit;
/