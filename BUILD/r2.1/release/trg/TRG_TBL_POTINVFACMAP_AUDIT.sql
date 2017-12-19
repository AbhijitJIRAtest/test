create or replace TRIGGER TRG_TBL_POTINVFACMAP_AUDIT
AFTER INSERT OR UPDATE OR DELETE ON TBL_POTENTIALINVFACMAP
FOR EACH ROW
DECLARE
v_operation tbl_audit.operation%TYPE;
v_auditid   tbl_audit.auditid%TYPE;
v_createdby tbl_audit.createdby%TYPE;
v_createddt tbl_audit.createddt%TYPE;
v_modifiedby tbl_audit.modifiedby%TYPE;
v_modifieddt tbl_audit.modifieddt%TYPE;
v_studyid tbl_docstudymap.studyid%TYPE;
v_PotentialInvFacId TBL_POTENTIALINVFACMAP.PotentialInvFacId%TYPE;
v_PotentialInvUserId TBL_POTENTIALINVFACMAP.PotentialInvUserId%TYPE;
v_sysdate DATE:=SYSDATE;
BEGIN
  IF INSERTING THEN
    v_operation := pkg_audit.g_operation_create;
    v_createdby := :NEW.createdby;
    v_createddt := :NEW.createddt;
    v_modifiedby := :NEW.createdby;
    v_modifieddt := :NEW.createddt;
    --v_studyid:=:NEW.studyid;
    v_PotentialInvFacId:=:NEW.PotentialInvFacId;
    v_PotentialInvUserId:= :NEW.PotentialInvUserId;
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
    --v_studyid:=:NEW.studyid;
    v_PotentialInvFacId:=:NEW.PotentialInvFacId;
    v_PotentialInvUserId:= :NEW.PotentialInvUserId;
  ELSIF DELETING THEN
    v_operation := pkg_audit.g_operation_delete;
    v_createdby := :OLD.modifiedby;
    v_createddt := v_sysdate;
    v_modifiedby := :OLD.modifiedby;
    v_modifieddt := v_sysdate;
    --v_studyid:=:OLD.studyid;
    v_PotentialInvFacId:=:OLD.PotentialInvFacId;
    v_PotentialInvUserId:= :OLD.PotentialInvUserId;
  END IF;

  pkg_audit.sp_set_audit
    (:NEW.POTENTIALINVFACID,'TBL_POTENTIALINVFACMAP','POTENTIALINVFACID',:OLD.POTENTIALINVFACID,:NEW.POTENTIALINVFACID,v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

  if v_auditid is not null then

    FOR i IN ( Select StudyId From TBL_POTENTIALINVTITLES
                Where TitleId= (Select TitleId From Tbl_PotentialInvestigator Where PotentialInvUserId=
                v_PotentialInvUserId)
             ) LOOP

          pkg_audit.sp_set_studyauditreportmap
              (v_auditid,i.studyid,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
          END LOOP;

end if;


  pkg_audit.sp_set_audit
    (:NEW.POTENTIALINVFACID,'TBL_POTENTIALINVFACMAP','FACILITYID',pkg_audit.fn_get_lov_value(:OLD.FACILITYID, pkg_audit.g_lov_facility) ,pkg_audit.fn_get_lov_value(:NEW.FACILITYID, pkg_audit.g_lov_facility),v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

  if v_auditid is not null then

    FOR i IN ( Select StudyId From TBL_POTENTIALINVTITLES
                Where TitleId= (Select TitleId From Tbl_PotentialInvestigator Where PotentialInvUserId=
                v_PotentialInvUserId)
             ) LOOP

          pkg_audit.sp_set_studyauditreportmap
              (v_auditid,i.studyid,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
          END LOOP;

end if;

  pkg_audit.sp_set_audit
    (:NEW.POTENTIALINVFACID,'TBL_POTENTIALINVFACMAP','POTENTIALINVUSERID',pkg_encrypt.fn_encrypt(pkg_audit.fn_get_lov_value(:OLD.POTENTIALINVUSERID, pkg_audit.g_lov_potinv)),pkg_encrypt.fn_encrypt(pkg_audit.fn_get_lov_value(:NEW.POTENTIALINVUSERID, pkg_audit.g_lov_potinv)) ,v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

  if v_auditid is not null then

    FOR i IN ( Select StudyId From TBL_POTENTIALINVTITLES
                Where TitleId= (Select TitleId From Tbl_PotentialInvestigator Where PotentialInvUserId=
                v_PotentialInvUserId)
             ) LOOP

          pkg_audit.sp_set_studyauditreportmap
              (v_auditid,i.studyid,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
          END LOOP;

end if;

pkg_audit.sp_set_audit
    (:NEW.POTENTIALINVFACID,'TBL_POTENTIALINVFACMAP','CREATEDBY',:OLD.CREATEDBY,:NEW.CREATEDBY ,v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

  if v_auditid is not null then

    FOR i IN ( Select StudyId From TBL_POTENTIALINVTITLES
                Where TitleId= (Select TitleId From Tbl_PotentialInvestigator Where PotentialInvUserId=
                v_PotentialInvUserId)
             ) LOOP

          pkg_audit.sp_set_studyauditreportmap
              (v_auditid,i.studyid,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
          END LOOP;

end if;

pkg_audit.sp_set_audit
    (:NEW.POTENTIALINVFACID,'TBL_POTENTIALINVFACMAP','CREATEDDT',TO_CHAR(:OLD.CREATEDDT,'DD-MON-YYYY'),TO_CHAR(:NEW.CREATEDDT,'DD-MON-YYYY') ,v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

  if v_auditid is not null then

    FOR i IN ( Select StudyId From TBL_POTENTIALINVTITLES
                Where TitleId= (Select TitleId From Tbl_PotentialInvestigator Where PotentialInvUserId=
                v_PotentialInvUserId)
             ) LOOP

          pkg_audit.sp_set_studyauditreportmap
              (v_auditid,i.studyid,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
          END LOOP;

end if;

pkg_audit.sp_set_audit
    (:NEW.POTENTIALINVFACID,'TBL_POTENTIALINVFACMAP','MODIFIEDBY',:OLD.MODIFIEDBY ,:NEW.MODIFIEDBY ,v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

  if v_auditid is not null then

    FOR i IN ( Select StudyId From TBL_POTENTIALINVTITLES
                Where TitleId= (Select TitleId From Tbl_PotentialInvestigator Where PotentialInvUserId=
                v_PotentialInvUserId)
             ) LOOP

          pkg_audit.sp_set_studyauditreportmap
              (v_auditid,i.studyid,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
          END LOOP;

end if;

pkg_audit.sp_set_audit
    (:NEW.POTENTIALINVFACID,'TBL_POTENTIALINVFACMAP','MODIFIEDDT',TO_CHAR(:OLD.MODIFIEDDT,'DD-MON-YYYY'),TO_CHAR(:NEW.MODIFIEDDT,'DD-MON-YYYY') ,v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

  if v_auditid is not null then

    FOR i IN ( Select StudyId From TBL_POTENTIALINVTITLES
                Where TitleId= (Select TitleId From Tbl_PotentialInvestigator Where PotentialInvUserId=
                v_PotentialInvUserId)
             ) LOOP

          pkg_audit.sp_set_studyauditreportmap
              (v_auditid,i.studyid,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
          END LOOP;

end if;

pkg_audit.sp_set_audit
    (:NEW.POTENTIALINVFACID,'TBL_POTENTIALINVFACMAP','ISNOTIFICATIONSEND ',:OLD.ISNOTIFICATIONSEND ,:NEW.ISNOTIFICATIONSEND ,v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

  if v_auditid is not null then

    FOR i IN ( Select StudyId From TBL_POTENTIALINVTITLES
                Where TitleId= (Select TitleId From Tbl_PotentialInvestigator Where PotentialInvUserId=
                v_PotentialInvUserId)
             ) LOOP

          pkg_audit.sp_set_studyauditreportmap
              (v_auditid,i.studyid,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
          END LOOP;

end if;

pkg_audit.sp_set_audit
    (:NEW.POTENTIALINVFACID,'TBL_POTENTIALINVFACMAP','ISSELECTEDFORPRESTUDYEVAL ',:OLD.ISSELECTEDFORPRESTUDYEVAL ,:NEW.ISSELECTEDFORPRESTUDYEVAL ,v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

  if v_auditid is not null then

    FOR i IN ( Select StudyId From TBL_POTENTIALINVTITLES
                Where TitleId= (Select TitleId From Tbl_PotentialInvestigator Where PotentialInvUserId=
                v_PotentialInvUserId)
             ) LOOP

          pkg_audit.sp_set_studyauditreportmap
              (v_auditid,i.studyid,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
          END LOOP;

end if;

pkg_audit.sp_set_audit
    (:NEW.POTENTIALINVFACID,'TBL_POTENTIALINVFACMAP','ISSELECTEDFORPRESTUDYEVAL ',:OLD.ISSELECTEDFORPRESTUDYEVAL ,:NEW.ISSELECTEDFORPRESTUDYEVAL ,v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

  if v_auditid is not null then

    FOR i IN ( Select StudyId From TBL_POTENTIALINVTITLES
                Where TitleId= (Select TitleId From Tbl_PotentialInvestigator Where PotentialInvUserId=
                v_PotentialInvUserId)
             ) LOOP

          pkg_audit.sp_set_studyauditreportmap
              (v_auditid,i.studyid,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
          END LOOP;

end if;

pkg_audit.sp_set_audit
    (:NEW.POTENTIALINVFACID,'TBL_POTENTIALINVFACMAP','ISINVITATIONSEND ',:OLD.ISINVITATIONSEND ,:NEW.ISINVITATIONSEND ,v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

  if v_auditid is not null then

    FOR i IN ( Select StudyId From TBL_POTENTIALINVTITLES
                Where TitleId= (Select TitleId From Tbl_PotentialInvestigator Where PotentialInvUserId=
                v_PotentialInvUserId)
             ) LOOP

          pkg_audit.sp_set_studyauditreportmap
              (v_auditid,i.studyid,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
          END LOOP;

end if;

pkg_audit.sp_set_audit
    (:NEW.POTENTIALINVFACID,'TBL_POTENTIALINVFACMAP','HASRESPONDEDTOINVITE ',:OLD.HASRESPONDEDTOINVITE ,:NEW.HASRESPONDEDTOINVITE ,v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

  if v_auditid is not null then

    FOR i IN ( Select StudyId From TBL_POTENTIALINVTITLES
                Where TitleId= (Select TitleId From Tbl_PotentialInvestigator Where PotentialInvUserId=
                v_PotentialInvUserId)
             ) LOOP

          pkg_audit.sp_set_studyauditreportmap
              (v_auditid,i.studyid,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
          END LOOP;

end if;

pkg_audit.sp_set_audit
    (:NEW.POTENTIALINVFACID,'TBL_POTENTIALINVFACMAP','ISACCEPTED ',:OLD.ISACCEPTED ,:NEW.ISACCEPTED ,v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

  if v_auditid is not null then

    FOR i IN ( Select StudyId From TBL_POTENTIALINVTITLES
                Where TitleId= (Select TitleId From Tbl_PotentialInvestigator Where PotentialInvUserId=
                v_PotentialInvUserId)
             ) LOOP

          pkg_audit.sp_set_studyauditreportmap
              (v_auditid,i.studyid,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
          END LOOP;

end if;


pkg_audit.sp_set_audit
    (:NEW.POTENTIALINVFACID,'TBL_POTENTIALINVFACMAP','ISREJECTED ',:OLD.ISREJECTED ,:NEW.ISREJECTED ,v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

  if v_auditid is not null then

    FOR i IN ( Select StudyId From TBL_POTENTIALINVTITLES
                Where TitleId= (Select TitleId From Tbl_PotentialInvestigator Where PotentialInvUserId=
                v_PotentialInvUserId)
             ) LOOP

          pkg_audit.sp_set_studyauditreportmap
              (v_auditid,i.studyid,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
          END LOOP;

end if;

pkg_audit.sp_set_audit
    (:NEW.POTENTIALINVFACID,'TBL_POTENTIALINVFACMAP','ISDISQUALIFIED',:OLD.ISDISQUALIFIED ,:NEW.ISDISQUALIFIED ,v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

  if v_auditid is not null then

    FOR i IN ( Select StudyId From TBL_POTENTIALINVTITLES
                Where TitleId= (Select TitleId From Tbl_PotentialInvestigator Where PotentialInvUserId=
                v_PotentialInvUserId)
             ) LOOP

          pkg_audit.sp_set_studyauditreportmap
              (v_auditid,i.studyid,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
          END LOOP;

end if;

pkg_audit.sp_set_audit
    (:NEW.POTENTIALINVFACID,'TBL_POTENTIALINVFACMAP','ISSELECTEDFORSTUDY',:OLD.ISSELECTEDFORSTUDY ,:NEW.ISSELECTEDFORSTUDY ,v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

  if v_auditid is not null then

    FOR i IN ( Select StudyId From TBL_POTENTIALINVTITLES
                Where TitleId= (Select TitleId From Tbl_PotentialInvestigator Where PotentialInvUserId=
                v_PotentialInvUserId)
             ) LOOP

          pkg_audit.sp_set_studyauditreportmap
              (v_auditid,i.studyid,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
          END LOOP;

end if;

pkg_audit.sp_set_audit
    (:NEW.POTENTIALINVFACID,'TBL_POTENTIALINVFACMAP','ISKEYCONTACT',:OLD.ISKEYCONTACT ,:NEW.ISKEYCONTACT ,v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

  if v_auditid is not null then

    FOR i IN ( Select StudyId From TBL_POTENTIALINVTITLES
                Where TitleId= (Select TitleId From Tbl_PotentialInvestigator Where PotentialInvUserId=
                v_PotentialInvUserId)
             ) LOOP

          pkg_audit.sp_set_studyauditreportmap
              (v_auditid,i.studyid,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
          END LOOP;

end if;

pkg_audit.sp_set_audit
    (:NEW.POTENTIALINVFACID,'TBL_POTENTIALINVFACMAP','INVITATIONSENDDT',:OLD.INVITATIONSENDDT ,:NEW.INVITATIONSENDDT ,v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

  if v_auditid is not null then

    FOR i IN ( Select StudyId From TBL_POTENTIALINVTITLES
                Where TitleId= (Select TitleId From Tbl_PotentialInvestigator Where PotentialInvUserId=
                v_PotentialInvUserId)
             ) LOOP

          pkg_audit.sp_set_studyauditreportmap
              (v_auditid,i.studyid,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
          END LOOP;

end if;

pkg_audit.sp_set_audit
    (:NEW.POTENTIALINVFACID,'TBL_POTENTIALINVFACMAP','ISACTIVE',:OLD.ISACTIVE ,:NEW.ISACTIVE ,v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

  if v_auditid is not null then

    FOR i IN ( Select StudyId From TBL_POTENTIALINVTITLES
                Where TitleId= (Select TitleId From Tbl_PotentialInvestigator Where PotentialInvUserId=
                v_PotentialInvUserId)
             ) LOOP

          pkg_audit.sp_set_studyauditreportmap
              (v_auditid,i.studyid,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
          END LOOP;

end if;

pkg_audit.sp_set_audit
    (:NEW.POTENTIALINVFACID,'TBL_POTENTIALINVFACMAP','STATUSCD',pkg_audit.fn_get_lov_value(:OLD.STATUSCD, pkg_audit.g_lov_statuscd) ,pkg_audit.fn_get_lov_value(:NEW.STATUSCD, pkg_audit.g_lov_statuscd) ,v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

  if v_auditid is not null then

    FOR i IN ( Select StudyId From TBL_POTENTIALINVTITLES
                Where TitleId= (Select TitleId From Tbl_PotentialInvestigator Where PotentialInvUserId=
                v_PotentialInvUserId)
             ) LOOP

          pkg_audit.sp_set_studyauditreportmap
              (v_auditid,i.studyid,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
          END LOOP;

end if;

if :OLD.ZSCORE is null AND :NEW.ZSCORE is not null then
	pkg_audit.sp_set_audit(:NEW.POTENTIALINVFACID,'TBL_POTENTIALINVFACMAP','ZSCORE',:OLD.ZSCORE ,:NEW.ZSCORE ,pkg_audit.g_operation_create,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);
else
	pkg_audit.sp_set_audit(:NEW.POTENTIALINVFACID,'TBL_POTENTIALINVFACMAP','ZSCORE',:OLD.ZSCORE ,:NEW.ZSCORE ,v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);
end if;

  if v_auditid is not null then

    FOR i IN ( Select StudyId From TBL_POTENTIALINVTITLES
                Where TitleId= (Select TitleId From Tbl_PotentialInvestigator Where PotentialInvUserId=
                v_PotentialInvUserId)
             ) LOOP

          pkg_audit.sp_set_studyauditreportmap
              (v_auditid,i.studyid,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
          END LOOP;

end if;

pkg_audit.sp_set_audit
    (:NEW.POTENTIALINVFACID,'TBL_POTENTIALINVFACMAP','REASON',:OLD.REASON ,:NEW.REASON ,v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

  if v_auditid is not null then

    FOR i IN ( Select StudyId From TBL_POTENTIALINVTITLES
                Where TitleId= (Select TitleId From Tbl_PotentialInvestigator Where PotentialInvUserId=
                v_PotentialInvUserId)
             ) LOOP

          pkg_audit.sp_set_studyauditreportmap
              (v_auditid,i.studyid,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
          END LOOP;

end if;

pkg_audit.sp_set_audit
    (:NEW.POTENTIALINVFACID,'TBL_POTENTIALINVFACMAP','ISCOMMDOCUMENTED',:OLD.ISCOMMDOCUMENTED ,:NEW.ISCOMMDOCUMENTED ,v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);

  if v_auditid is not null then

    FOR i IN ( Select StudyId From TBL_POTENTIALINVTITLES
                Where TitleId= (Select TitleId From Tbl_PotentialInvestigator Where PotentialInvUserId= v_PotentialInvUserId)
             ) LOOP

          pkg_audit.sp_set_studyauditreportmap
              (v_auditid,i.studyid,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
          END LOOP;

end if;

if :OLD.PRESELECTSITENAME is null AND :NEW.PRESELECTSITENAME is not null then
	pkg_audit.sp_set_audit(:NEW.POTENTIALINVFACID,'TBL_POTENTIALINVFACMAP','PRESELECTSITENAME',:OLD.PRESELECTSITENAME ,:NEW.PRESELECTSITENAME ,pkg_audit.g_operation_create,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);
else
	pkg_audit.sp_set_audit(:NEW.POTENTIALINVFACID,'TBL_POTENTIALINVFACMAP','PRESELECTSITENAME',:OLD.PRESELECTSITENAME ,:NEW.PRESELECTSITENAME ,v_operation,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby,v_auditid);
end if;

  if v_auditid is not null then

    FOR i IN ( Select StudyId From TBL_POTENTIALINVTITLES
                Where TitleId= (Select TitleId From Tbl_PotentialInvestigator Where PotentialInvUserId= v_PotentialInvUserId)
             ) LOOP

          pkg_audit.sp_set_studyauditreportmap
              (v_auditid,i.studyid,NULL,v_createddt,v_createdby,v_modifieddt,v_modifiedby);
          END LOOP;

end if;
END TRG_TBL_POTINVFACMAP_AUDIT;
/