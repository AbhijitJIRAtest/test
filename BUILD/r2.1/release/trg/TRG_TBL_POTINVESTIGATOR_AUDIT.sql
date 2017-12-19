CREATE OR REPLACE TRIGGER TRG_TBL_POTINVESTIGATOR_AUDIT
AFTER INSERT OR UPDATE OR DELETE ON TBL_POTENTIALINVESTIGATOR
FOR EACH ROW
DECLARE
v_operation tbl_audit.operation%TYPE;
v_auditid   tbl_audit.auditid%TYPE;
v_createdby tbl_audit.createdby%TYPE;
v_createddt tbl_audit.createddt%TYPE;
v_modifiedby tbl_audit.modifiedby%TYPE;
v_modifieddt tbl_audit.modifieddt%TYPE;
v_POTENTIALINVUSERID TBL_POTENTIALINVESTIGATOR.POTENTIALINVUSERID%TYPE;
v_StudyCnt INTEGER;
v_titleid TBL_POTENTIALINVESTIGATOR.titleid%TYPE;
v_sysdate DATE:=SYSDATE;
BEGIN
  IF INSERTING THEN
    v_operation := pkg_audit.g_operation_create;
    v_createdby := :NEW.createdby;
    v_createddt := :NEW.createddt;
    v_modifiedby := :NEW.createdby;
    v_modifieddt := :NEW.createddt;
	 v_POTENTIALINVUSERID := :NEW.POTENTIALINVUSERID;
   v_titleid:=:NEW.TITLEID;

  ELSIF UPDATING THEN
  IF NVL(:OLD.isactive,'Y') <> NVL(:NEW.isactive,'Y') AND :NEW.isactive = 'N' THEN
      v_operation := pkg_audit.g_operation_delete;
    ELSE
      v_operation := pkg_audit.g_operation_update;
    END IF;
    v_createdby := :NEW.modifiedby;
    v_createddt := :NEW.modifieddt;
    v_modifiedby := :NEW.modifiedby;
    v_modifieddt := :NEW.modifieddt;
    v_POTENTIALINVUSERID := :NEW.POTENTIALINVUSERID;
    v_titleid:=:NEW.TITLEID;

  ELSIF DELETING THEN
    v_operation := pkg_audit.g_operation_delete;
    v_createdby := :OLD.modifiedby;
    v_createddt := v_sysdate;
    v_modifiedby := :OLD.modifiedby;
    v_modifieddt := v_sysdate;
    v_POTENTIALINVUSERID := :OLD.POTENTIALINVUSERID;
    v_titleid:=:OLD.TITLEID;
  END IF;

  pkg_audit.sp_set_audit
    (v_POTENTIALINVUSERID,'TBL_POTENTIALINVESTIGATOR','POTENTIALINVUSERID',:OLD.POTENTIALINVUSERID,:NEW.POTENTIALINVUSERID,v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);
   if v_auditid is not null then
  FOR i IN ( Select STUDYID
			 From TBL_POTENTIALINVTITLES
			 Where TITLEID=v_titleid
			 ) LOOP

		  pkg_audit.sp_set_studyauditreportmap
		   (v_auditid,i.studyid,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
	       END LOOP;
end if;


		   pkg_audit.sp_set_audit
    (v_POTENTIALINVUSERID,'TBL_POTENTIALINVESTIGATOR','TRANSCELERATEUSERID',:OLD.TRANSCELERATEUSERID,:NEW.TRANSCELERATEUSERID,v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

   if v_auditid is not null then
  FOR i IN ( Select STUDYID
			 From TBL_POTENTIALINVTITLES
			 Where TITLEID=v_titleid
			 ) LOOP

		  pkg_audit.sp_set_studyauditreportmap
		   (v_auditid,i.studyid,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
	       END LOOP;
		end if;

		   pkg_audit.sp_set_audit
    (v_POTENTIALINVUSERID,'TBL_POTENTIALINVESTIGATOR','TITLEID',pkg_audit.fn_get_lov_value(:OLD.TITLEID, pkg_audit.g_lov_pottitle),pkg_audit.fn_get_lov_value(:NEW.TITLEID, pkg_audit.g_lov_pottitle),v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

   if v_auditid is not null then
  FOR i IN ( Select STUDYID
			 From TBL_POTENTIALINVTITLES
			 Where TITLEID=v_titleid
			 ) LOOP

		  pkg_audit.sp_set_studyauditreportmap
		   (v_auditid,i.studyid,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
	       END LOOP;
		   end if;

		   pkg_audit.sp_set_audit
    (v_POTENTIALINVUSERID,'TBL_POTENTIALINVESTIGATOR','CONTACTID',:OLD.CONTACTID,:NEW.CONTACTID,v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

 if v_auditid is not null then
  FOR i IN ( Select STUDYID
			 From TBL_POTENTIALINVTITLES
			 Where TITLEID=v_titleid
			 ) LOOP

		  pkg_audit.sp_set_studyauditreportmap
		   (v_auditid,i.studyid,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
	       END LOOP;
		 end if;


		   pkg_audit.sp_set_audit
    (v_POTENTIALINVUSERID,'TBL_POTENTIALINVESTIGATOR','FIRSTNAME',:OLD.FIRSTNAME,:NEW.FIRSTNAME,v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

   if v_auditid is not null then
  FOR i IN ( Select STUDYID
			 From TBL_POTENTIALINVTITLES
			 Where TITLEID=v_titleid
			 ) LOOP

		  pkg_audit.sp_set_studyauditreportmap
		   (v_auditid,i.studyid,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
	       END LOOP;

	end if;

		   pkg_audit.sp_set_audit
    (v_POTENTIALINVUSERID,'TBL_POTENTIALINVESTIGATOR','LASTNAME',:OLD.LASTNAME,:NEW.LASTNAME,v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

   if v_auditid is not null then
  FOR i IN ( Select STUDYID
			 From TBL_POTENTIALINVTITLES
			 Where TITLEID=v_titleid
			 ) LOOP

		  pkg_audit.sp_set_studyauditreportmap
		   (v_auditid,i.studyid,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
	       END LOOP;
		   end if;

		   pkg_audit.sp_set_audit
    (v_POTENTIALINVUSERID,'TBL_POTENTIALINVESTIGATOR','ISNOTIFICATIONSEND',:OLD.ISNOTIFICATIONSEND,:NEW.ISNOTIFICATIONSEND,v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

   if v_auditid is not null then
  FOR i IN ( Select STUDYID
			 From TBL_POTENTIALINVTITLES
			 Where TITLEID=v_titleid
			 ) LOOP

		  pkg_audit.sp_set_studyauditreportmap
		   (v_auditid,i.studyid,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
	       END LOOP;
		  end if;


		   pkg_audit.sp_set_audit
    (v_POTENTIALINVUSERID,'TBL_POTENTIALINVESTIGATOR','ISSELECTEDFORPRESTUDYEVAL',:OLD.ISSELECTEDFORPRESTUDYEVAL,:NEW.ISSELECTEDFORPRESTUDYEVAL,v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

 if v_auditid is not null then
  FOR i IN ( Select STUDYID
			 From TBL_POTENTIALINVTITLES
			 Where TITLEID=v_titleid
			 ) LOOP

		  pkg_audit.sp_set_studyauditreportmap
		   (v_auditid,i.studyid,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
	       END LOOP;
		  end if;


		   pkg_audit.sp_set_audit
    (v_POTENTIALINVUSERID,'TBL_POTENTIALINVESTIGATOR','ISCOMMDOCUMENTED',:OLD.ISCOMMDOCUMENTED,:NEW.ISCOMMDOCUMENTED,v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

   if v_auditid is not null then
  FOR i IN ( Select STUDYID
			 From TBL_POTENTIALINVTITLES
			 Where TITLEID=v_titleid
			 ) LOOP

		  pkg_audit.sp_set_studyauditreportmap
		   (v_auditid,i.studyid,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
	       END LOOP;
		   end if;


		   pkg_audit.sp_set_audit
    (v_POTENTIALINVUSERID,'TBL_POTENTIALINVESTIGATOR','COMMUNICATION',:OLD.COMMUNICATION,:NEW.COMMUNICATION,v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

   if v_auditid is not null then
  FOR i IN ( Select STUDYID
			 From TBL_POTENTIALINVTITLES
			 Where TITLEID=v_titleid
			 ) LOOP

		  pkg_audit.sp_set_studyauditreportmap
		   (v_auditid,i.studyid,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
	       END LOOP;
		 end if;


		   pkg_audit.sp_set_audit
    (v_POTENTIALINVUSERID,'TBL_POTENTIALINVESTIGATOR','ISSITEFEASIBILITYSURVEYREQ',:OLD.ISSITEFEASIBILITYSURVEYREQ,:NEW.ISSITEFEASIBILITYSURVEYREQ,v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

   if v_auditid is not null then
  FOR i IN ( Select STUDYID
			 From TBL_POTENTIALINVTITLES
			 Where TITLEID=v_titleid
			 ) LOOP

		  pkg_audit.sp_set_studyauditreportmap
		   (v_auditid,i.studyid,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
	       END LOOP;
		   end if;


		   pkg_audit.sp_set_audit
    (v_POTENTIALINVUSERID,'TBL_POTENTIALINVESTIGATOR','ISINVITATIONSEND',:OLD.ISINVITATIONSEND,:NEW.ISINVITATIONSEND,v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

   if v_auditid is not null then
  FOR i IN ( Select STUDYID
			 From TBL_POTENTIALINVTITLES
			 Where TITLEID=v_titleid
			 ) LOOP

		  pkg_audit.sp_set_studyauditreportmap
		   (v_auditid,i.studyid,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
	       END LOOP;
		   end if;


		   pkg_audit.sp_set_audit
    (v_POTENTIALINVUSERID,'TBL_POTENTIALINVESTIGATOR','HASRESPONDEDTOINVITE',:OLD.HASRESPONDEDTOINVITE,:NEW.HASRESPONDEDTOINVITE,v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

   if v_auditid is not null then
  FOR i IN ( Select STUDYID
			 From TBL_POTENTIALINVTITLES
			 Where TITLEID=v_titleid
			 ) LOOP

		  pkg_audit.sp_set_studyauditreportmap
		   (v_auditid,i.studyid,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
	       END LOOP;

		  end if;

		   pkg_audit.sp_set_audit
    (v_POTENTIALINVUSERID,'TBL_POTENTIALINVESTIGATOR','ISACCEPTED',:OLD.ISACCEPTED,:NEW.ISACCEPTED,v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

   if v_auditid is not null then
  FOR i IN ( Select STUDYID
			 From TBL_POTENTIALINVTITLES
			 Where TITLEID=v_titleid
			 ) LOOP

		  pkg_audit.sp_set_studyauditreportmap
		   (v_auditid,i.studyid,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
	       END LOOP;
		   end if;


		   pkg_audit.sp_set_audit
    (v_POTENTIALINVUSERID,'TBL_POTENTIALINVESTIGATOR','ISREJECTED',:OLD.ISREJECTED,:NEW.ISREJECTED,v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

   if v_auditid is not null then
  FOR i IN ( Select STUDYID
			 From TBL_POTENTIALINVTITLES
			 Where TITLEID=v_titleid
			 ) LOOP

		  pkg_audit.sp_set_studyauditreportmap
		   (v_auditid,i.studyid,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
	       END LOOP;
		   end if;


		   pkg_audit.sp_set_audit
    (v_POTENTIALINVUSERID,'TBL_POTENTIALINVESTIGATOR','ISDISQUALIFIED',:OLD.ISDISQUALIFIED,:NEW.ISDISQUALIFIED,v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

   if v_auditid is not null then
  FOR i IN ( Select STUDYID
			 From TBL_POTENTIALINVTITLES
			 Where TITLEID=v_titleid
			 ) LOOP

		  pkg_audit.sp_set_studyauditreportmap
		   (v_auditid,i.studyid,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
	       END LOOP;
		   end if;


		   pkg_audit.sp_set_audit
    (v_POTENTIALINVUSERID,'TBL_POTENTIALINVESTIGATOR','ISSELECTEDFORSTUDY',:OLD.ISSELECTEDFORSTUDY,:NEW.ISSELECTEDFORSTUDY,v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

   if v_auditid is not null then

  FOR i IN ( Select STUDYID
			 From TBL_POTENTIALINVTITLES
			 Where TITLEID=v_titleid
			 ) LOOP

		  pkg_audit.sp_set_studyauditreportmap
		   (v_auditid,i.studyid,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
	       END LOOP;
		   end if;


		   pkg_audit.sp_set_audit
    (v_POTENTIALINVUSERID,'TBL_POTENTIALINVESTIGATOR','REASON',:OLD.REASON,:NEW.REASON,v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

   if v_auditid is not null then

  FOR i IN ( Select STUDYID
			 From TBL_POTENTIALINVTITLES
			 Where TITLEID=v_titleid
			 ) LOOP

		  pkg_audit.sp_set_studyauditreportmap
		   (v_auditid,i.studyid,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
	       END LOOP;
		end if;


		   pkg_audit.sp_set_audit
    (v_POTENTIALINVUSERID,'TBL_POTENTIALINVESTIGATOR','ZSCORE',:OLD.ZSCORE,:NEW.ZSCORE,v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

   if v_auditid is not null then
  FOR i IN ( Select STUDYID
			 From TBL_POTENTIALINVTITLES
			 Where TITLEID=v_titleid
			 ) LOOP

		  pkg_audit.sp_set_studyauditreportmap
		   (v_auditid,i.studyid,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
	       END LOOP;
		   end if;


		   pkg_audit.sp_set_audit
    (v_POTENTIALINVUSERID,'TBL_POTENTIALINVESTIGATOR','STATUSCD',:OLD.STATUSCD,:NEW.STATUSCD,v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

 if v_auditid is not null then
  FOR i IN ( Select STUDYID
			 From TBL_POTENTIALINVTITLES
			 Where TITLEID=v_titleid
			 ) LOOP

		  pkg_audit.sp_set_studyauditreportmap
		   (v_auditid,i.studyid,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
	       END LOOP;
		 end if;


		   pkg_audit.sp_set_audit
    (v_POTENTIALINVUSERID,'TBL_POTENTIALINVESTIGATOR','ISKEYCONTACT',:OLD.ISKEYCONTACT,:NEW.ISKEYCONTACT,v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

   if v_auditid is not null then
  FOR i IN ( Select STUDYID
			 From TBL_POTENTIALINVTITLES
			 Where TITLEID=v_titleid
			 ) LOOP

		  pkg_audit.sp_set_studyauditreportmap
		   (v_auditid,i.studyid,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
	       END LOOP;
		   end if;

		   pkg_audit.sp_set_audit
    (v_POTENTIALINVUSERID,'TBL_POTENTIALINVESTIGATOR','ISACTIVE',:OLD.ISACTIVE,:NEW.ISACTIVE,v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

 if v_auditid is not null then
  FOR i IN ( Select STUDYID
			 From TBL_POTENTIALINVTITLES
			 Where TITLEID=v_titleid
			 ) LOOP

		  pkg_audit.sp_set_studyauditreportmap
		   (v_auditid,i.studyid,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
	       END LOOP;
		 end if;

		   pkg_audit.sp_set_audit
    (v_POTENTIALINVUSERID,'TBL_POTENTIALINVESTIGATOR','CREATEDBY',:OLD.CREATEDBY,:NEW.CREATEDBY,v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

   if v_auditid is not null then
  FOR i IN ( Select STUDYID
			 From TBL_POTENTIALINVTITLES
			 Where TITLEID=v_titleid
			 ) LOOP

		  pkg_audit.sp_set_studyauditreportmap
		   (v_auditid,i.studyid,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
	       END LOOP;

		   end if;

		   pkg_audit.sp_set_audit
    (v_POTENTIALINVUSERID,'TBL_POTENTIALINVESTIGATOR','CREATEDDT',TO_CHAR(:OLD.CREATEDDT,'DD-Mon-YYYY'),TO_CHAR(:NEW.CREATEDDT,'DD-Mon-YYYY'),v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

   if v_auditid is not null then
  FOR i IN ( Select STUDYID
			 From TBL_POTENTIALINVTITLES
			 Where TITLEID=v_titleid
			 ) LOOP

		  pkg_audit.sp_set_studyauditreportmap
		   (v_auditid,i.studyid,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
	       END LOOP;
		 end if;

		   pkg_audit.sp_set_audit
    (v_POTENTIALINVUSERID,'TBL_POTENTIALINVESTIGATOR','MODIFIEDBY',:OLD.MODIFIEDBY,:NEW.MODIFIEDBY,v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

   if v_auditid is not null then
  FOR i IN ( Select STUDYID
			 From TBL_POTENTIALINVTITLES
			 Where TITLEID=v_titleid
			 ) LOOP

		  pkg_audit.sp_set_studyauditreportmap
		   (v_auditid,i.studyid,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
	       END LOOP;
		   end if;

		   pkg_audit.sp_set_audit
    (v_POTENTIALINVUSERID,'TBL_POTENTIALINVESTIGATOR','MODIFIEDDT',TO_CHAR(:OLD.MODIFIEDDT,'DD-Mon-YYYY'),TO_CHAR(:NEW.MODIFIEDDT,'DD-Mon-YYYY'),v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

   if v_auditid is not null then
  FOR i IN ( Select STUDYID
			 From TBL_POTENTIALINVTITLES
			 Where TITLEID=v_titleid
			 ) LOOP

		  pkg_audit.sp_set_studyauditreportmap
		   (v_auditid,i.studyid,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
	       END LOOP;
		   end if;

		   pkg_audit.sp_set_audit
    (v_POTENTIALINVUSERID,'TBL_POTENTIALINVESTIGATOR','COMMDT',TO_CHAR(:OLD.COMMDT,'DD-Mon-YYYY'),TO_CHAR(:NEW.COMMDT,'DD-Mon-YYYY'),v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

   if v_auditid is not null then
  FOR i IN ( Select STUDYID
			 From TBL_POTENTIALINVTITLES
			 Where TITLEID=v_titleid
			 ) LOOP

		  pkg_audit.sp_set_studyauditreportmap
		   (v_auditid,i.studyid,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
	       END LOOP;
		   end if;

		   pkg_audit.sp_set_audit
    (v_POTENTIALINVUSERID,'TBL_POTENTIALINVESTIGATOR','INVITATIONSENDDT',TO_CHAR(:OLD.INVITATIONSENDDT,'DD-Mon-YYYY'),TO_CHAR(:NEW.INVITATIONSENDDT,'DD-Mon-YYYY'),v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

   if v_auditid is not null then
  FOR i IN ( Select STUDYID
			 From TBL_POTENTIALINVTITLES
			 Where TITLEID=v_titleid
			 ) LOOP

		  pkg_audit.sp_set_studyauditreportmap
		   (v_auditid,i.studyid,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
	       END LOOP;

		   end if;
END TRG_TBL_POTINVESTIGATOR_AUDIT;
/