create or replace PACKAGE BODY pkg_user_deactivation AS

PROCEDURE sp_user_deactivation (p_status_code   OUT NUMBER, CUR_PLAT_SPON_DEACT OUT SYS_REFCURSOR ) AS

v_userdeactivate_out typ_userdeactivate_out;
v_sysdate DATE := SYSDATE;
v_templateid varchar2(100);
v_alertNotificationTypeid varchar2(100);
v_sponsorrole NUMBER;
v_investrole NUMBER;
v_site TBL_SITE%ROWTYPE;

-- This cursor is for users who have not logged into the system as per system config
--Commented as part of R2.1
--CURSOR cur_user_profile
--	IS
-- select
-- USERID,
-- LASTACCESSDT,
-- ISACTIVE,
-- sys_config
-- FROM
--(SELECT up.USERID,up.LASTACCESSDT,up.ISACTIVE,
--(select cv.CONFIGVALUE FROM TBL_SYSTEMCONFIG cv WHERE cv.CONFIGNAME ='DEACTIVATION_NOLOGIN')sys_config
--from TBL_USERPROFILES up
--where
-- up.ISACTIVE='Y'
--AND NOT EXISTS (
--				       SELECT 1
--				         FROM tbl_userdeactivationlog ud
--				        WHERE ud.AFFECTORID = up.UserId
--                AND ud.ISPROCESSED = 'N'
--				AND ud.ISFORDEACTIVATION = 'Y'
--				       )
--)
--where
--trunc(LASTACCESSDT) <= (trunc(sysdate)-sys_config)
--;

-- This cursor is for users who have not modified their profiles for a long time
--Commented as part of R2.1
--CURSOR cur_user_profile_noupdate
--	IS
-- select
-- USERID,
-- modifieddt,
-- ISACTIVE,
-- sys_config
-- FROM
--(SELECT up.USERID,up.modifieddt,up.ISACTIVE,
--(select cv.CONFIGVALUE FROM TBL_SYSTEMCONFIG cv WHERE cv.CONFIGNAME ='USERPROFILE_NOUPDATE') sys_config
--from TBL_USERPROFILES up
--where
-- up.ISACTIVE='Y'
--  and up.issponsor = 'N'
--  and trunc(up.modifieddt) <= (trunc(sysdate)-(select cv.CONFIGVALUE FROM TBL_SYSTEMCONFIG cv WHERE cv.CONFIGNAME ='USERPROFILE_NOUPDATE')))
--  ;


-- This cursor is for Sponsor users for whom request is raised for Sponsor deactivation
CURSOR cur_user_deactivation_spons
IS
SELECT ud.USERDEACTIVATIONID,ud.REQUESTERID,ud.AFFECTORID,ud.ISCONFIRMED,ud.SITEID,ud.STUDYID,ud.EFFECTIVEDATE,
ud.ISPROCESSED,ud.ISSTUDYSPECIFIC,ud.ISFORCAUSE,ud.JUSTIFICATIONID,ud.ISSPONSORSYSUPDATED,ud.ISAPPROVALREQ,ud.TASKID,
ud.COMMENTS,ud.REPLACINGPIID,ud.ADMINID,ud.ISFORDEACTIVATION,up.TRANSCELERATEUSERID,up.ISSPONSOR
from TBL_USERDEACTIVATIONLOG ud
join tbl_userprofiles up on ud.AFFECTORID=up.USERID
where
ud.effectivedate<=sysdate
and
ud.ISACTIVE='Y'
and 
ud.ISPROCESSED ='N'
and
ud.ISFORDEACTIVATION = 'Y'
and
up.issponsor='Y'
and 
ud.ROLEID IS NULL;

-- This cursor is for Site users for whom request is raised for Site deactivation
CURSOR cur_user_deactivation_site
IS
SELECT ud.USERDEACTIVATIONID,ud.REQUESTERID,ud.AFFECTORID,ud.ISCONFIRMED,ud.SITEID,ud.STUDYID,ud.EFFECTIVEDATE,
ud.ISPROCESSED,ud.ISSTUDYSPECIFIC,ud.ISFORCAUSE,ud.JUSTIFICATIONID,ud.ISSPONSORSYSUPDATED,ud.ISAPPROVALREQ,ud.TASKID,
ud.COMMENTS,ud.REPLACINGPIID,ud.ADMINID,ud.ISFORDEACTIVATION,up.TRANSCELERATEUSERID,up.ISSPONSOR,ud.ROLEID
from TBL_USERDEACTIVATIONLOG ud
join tbl_userprofiles up on ud.AFFECTORID=up.USERID
where
ud.effectivedate <= sysdate
and
ud.ISACTIVE='Y'
and
ud.ISPROCESSED ='N'
and
ud.ISFORDEACTIVATION = 'Y'
and up.issponsor='N'
and
ud.REPLACINGPIID IS NULL
and ud.ROLEID IS NULL
and
ud.ISCONFIRMED =
  CASE ud.ISAPPROVALREQ
    WHEN 'Y' THEN 'Y'
    WHEN 'N' THEN 'N'
  END;



---- This cursor is for Sponsor users for whom request is raised for Sponsor activation
--CURSOR cur_user_activation_spons
--IS
--SELECT ud.USERDEACTIVATIONID,ud.REQUESTERID,ud.AFFECTORID,ud.ISCONFIRMED,ud.SITEID,ud.STUDYID,ud.EFFECTIVEDATE,ud.CREATEDBY,
--ud.ISPROCESSED,ud.ISSTUDYSPECIFIC,ud.ISFORCAUSE,ud.JUSTIFICATIONID,ud.ISSPONSORSYSUPDATED,ud.ISAPPROVALREQ,ud.TASKID,
--ud.COMMENTS,ud.REPLACINGPIID,ud.ADMINID,ud.ISFORDEACTIVATION,up.TRANSCELERATEUSERID,up.ISSPONSOR
--from TBL_USERDEACTIVATIONLOG ud
--join tbl_userprofiles up on ud.AFFECTORID=up.USERID
--where
--ud.effectivedate<=sysdate
--and
--ud.ISPROCESSED ='N'
--and
--ud.ISFORDEACTIVATION = 'N'
--and
--up.issponsor='Y';

-- This cursor is for returning all the pi needs to be deactivated users on the particular date
CURSOR cur_user_pi_replacement
IS
SELECT ud.USERDEACTIVATIONID,ud.REQUESTERID,ud.AFFECTORID,ud.ISCONFIRMED,ud.SITEID,ud.STUDYID,ud.EFFECTIVEDATE,ud.CREATEDBY,
ud.ISPROCESSED,ud.ISSTUDYSPECIFIC,ud.ISFORCAUSE,ud.JUSTIFICATIONID,ud.ISSPONSORSYSUPDATED,ud.ISAPPROVALREQ,ud.TASKID,
ud.COMMENTS,ud.REPLACINGPIID,ud.ADMINID,ud.ISFORDEACTIVATION,up.TRANSCELERATEUSERID,up.ISSPONSOR
from TBL_USERDEACTIVATIONLOG ud
join tbl_userprofiles up on ud.AFFECTORID=up.USERID
where
ud.effectivedate<=sysdate
and
ud.ISPROCESSED ='N'
and
ud.ISFORDEACTIVATION = 'Y'
and
ud.REPLACINGPIID IS NOT NULL
and
up.issponsor='N'
and
ud.ISCONFIRMED =
 CASE ud.ISAPPROVALREQ
   WHEN 'Y' THEN 'Y'
   WHEN 'N' THEN 'N'
 END;

--Type declarations

TYPE typ_user_pi_replacement IS TABLE OF cur_user_pi_replacement%ROWTYPE;

v_user_pi_replacement typ_user_pi_replacement;

TYPE typ_user_deact_spons_upd IS TABLE OF cur_user_deactivation_spons%ROWTYPE;

 v_user_deact_spons_upd    typ_user_deact_spons_upd;

TYPE typ_user_deact_site_upd IS TABLE OF cur_user_deactivation_site%ROWTYPE;

 v_user_deact_site_upd    typ_user_deact_site_upd;

--TYPE typ_user_profile_upd IS TABLE OF cur_user_profile%ROWTYPE;

 -- v_user_profile_upd    typ_user_profile_upd;

 -- TYPE typ_user_profile_noupd IS TABLE OF cur_user_profile_noupdate%ROWTYPE;

 -- v_user_profile_noupd    typ_user_profile_noupd;

--TYPE typ_user_activate_spons_upd IS TABLE OF cur_user_activation_spons%ROWTYPE;
--
-- v_user_activate_spons_upd    typ_user_activate_spons_upd;



e_dml_errors EXCEPTION;

	PRAGMA EXCEPTION_INIT(e_dml_errors, -24381);

	l_errors   NUMBER;

	l_errno    NUMBER;

	l_msg      VARCHAR2(4000);

  l_idx      NUMBER;


BEGIN
v_userdeactivate_out :=typ_userdeactivate_out();

--Commented Code as per R2.1
-- updating user profile table for last-login as per system-config
--OPEN cur_user_profile;
--    LOOP
--    	FETCH cur_user_profile BULK COLLECT INTO v_user_profile_upd LIMIT 1000;
--        EXIT WHEN v_user_profile_upd.COUNT = 0;
--
--BEGIN
--
--FOR i IN v_user_profile_upd.FIRST..v_user_profile_upd.LAST
--LOOP
--
--UPDATE tbl_userprofiles SET ISACTIVE ='N' WHERE userid = v_user_profile_upd(i).userid;
----v_userdeactivate_out.Extend;
----v_userdeactivate_out(v_userdeactivate_out.COUNT) :=obj_userdeactivate_out(i.ROLETYPEID,REC.ROLETYPE,REC.ROLENAME,REC.PERMISSIONID,REC.PERMISSIONLEVEL,
----REC.PERMISSIONCATEGORY,REC.PERMISSIONCODE,REC.PERMISSIONVALUE);
--
--END LOOP;
--
--FORALL i IN v_user_profile_upd.FIRST..v_user_profile_upd.LAST  SAVE EXCEPTIONS
--
--UPDATE TBL_USERROLEMAP SET EFFECTIVEENDDATE =sysdate,
--ROLECHANGEREASON='DEACTIVATION_NOLOGIN'
--WHERE USERID = v_user_profile_upd(i).USERID
--and ( EFFECTIVEENDDATE is NULL OR trunc(EffectiveEndDate)>=trunc(SYSDATE) ) and ROLECHANGEREASON IS NULL;
--
--EXCEPTION
-- WHEN e_dml_errors THEN
--   l_errors := SQL%bulk_exceptions.count;
--  IF l_errors > 0 THEN
--ROLLBACK;
--END IF;
--END;
--END LOOP;
--CLOSE cur_user_profile;
--COMMIT;

-- updating userRoleMap table for sponsors users
OPEN cur_user_deactivation_spons;
    LOOP
    	FETCH cur_user_deactivation_spons BULK COLLECT INTO v_user_deact_spons_upd LIMIT 1000;
        EXIT WHEN v_user_deact_spons_upd.COUNT = 0;
BEGIN

FOR i IN v_user_deact_spons_upd.FIRST..v_user_deact_spons_upd.LAST
LOOP
IF (v_user_deact_spons_upd(i).ISSTUDYSPECIFIC ='Y' AND v_user_deact_spons_upd(i).STUDYID IS NOT NULL AND v_user_deact_spons_upd(i).SITEID IS NULL)

THEN

UPDATE Tbl_UserRoleMap SET EffectiveEndDate =v_user_deact_spons_upd(i).EFFECTIVEDATE,
RoleChangeReason=(CASE WHEN v_user_deact_spons_upd(i).ISSTUDYSPECIFIC ='Y' AND v_user_deact_spons_upd(i).ISFORCAUSE='N' THEN
'DEACTIVATION_FORSTUDY'
WHEN v_user_deact_spons_upd(i).ISSTUDYSPECIFIC ='Y' AND v_user_deact_spons_upd(i).ISFORCAUSE='Y' THEN
'DEACTIVATION_FORCAUSE'
ELSE NULL
END)
WHERE userid = v_user_deact_spons_upd(i).AFFECTORID
and studyId IS NOT NULL
and studyid= v_user_deact_spons_upd(i).STUDYID
and ( EffectiveEndDate is NULL OR EffectiveEndDate>=SYSDATE) and ROLECHANGEREASON IS NULL;

ELSIF (v_user_deact_spons_upd(i).ISSTUDYSPECIFIC ='Y' AND v_user_deact_spons_upd(i).STUDYID IS NOT NULL AND v_user_deact_spons_upd(i).SITEID IS NOT NULL)
THEN

UPDATE Tbl_UserRoleMap SET EffectiveEndDate =v_user_deact_spons_upd(i).EFFECTIVEDATE,
RoleChangeReason=(CASE WHEN v_user_deact_spons_upd(i).ISSTUDYSPECIFIC ='Y' AND v_user_deact_spons_upd(i).ISFORCAUSE='N' THEN
'DEACTIVATION_FORSTUDY'
WHEN v_user_deact_spons_upd(i).ISSTUDYSPECIFIC ='Y' AND v_user_deact_spons_upd(i).ISFORCAUSE='Y' THEN
'DEACTIVATION_FORCAUSE'
ELSE NULL
END)
WHERE userid = v_user_deact_spons_upd(i).AFFECTORID
and studyid IS NOT NULL
and studyid= v_user_deact_spons_upd(i).STUDYID
and siteid IS NOT NULL
and siteid= v_user_deact_spons_upd(i).SITEID
and (EffectiveEndDate is NULL OR EffectiveEndDate>=SYSDATE) and ROLECHANGEREASON IS NULL;

ELSIF (v_user_deact_spons_upd(i).ISSTUDYSPECIFIC ='N')
THEN

UPDATE Tbl_UserRoleMap SET EffectiveEndDate =v_user_deact_spons_upd(i).EFFECTIVEDATE,
RoleChangeReason=(CASE WHEN v_user_deact_spons_upd(i).ISSTUDYSPECIFIC ='N' AND v_user_deact_spons_upd(i).ISFORCAUSE='N' THEN
'DEACTIVATION_FROMPLATFORM' 
WHEN v_user_deact_spons_upd(i).ISSTUDYSPECIFIC ='Y' AND v_user_deact_spons_upd(i).ISFORCAUSE='Y' THEN
'DEACTIVATION_FORCAUSEPLATFORM'
ELSE NULL
END)
WHERE userid = v_user_deact_spons_upd(i).AFFECTORID
and (EffectiveEndDate is NULL OR EffectiveEndDate>=SYSDATE) and ROLECHANGEREASON IS NULL;

END IF;

END LOOP;

FORALL i IN v_user_deact_spons_upd.FIRST..v_user_deact_spons_upd.LAST  SAVE EXCEPTIONS
UPDATE TBL_USERPROFILES SET ISACTIVE ='N', ACTIVATIONENDDT=v_sysdate, DEACTIVATIONENDREASON = (select distinct JUSTIFICATIONDESC  from TBL_JUSTIFICATION where  JUSTIFICATIONID = v_user_deact_spons_upd(i).JUSTIFICATIONID) 
where userid = v_user_deact_spons_upd(i).AFFECTORID and v_user_deact_spons_upd(i).ISSTUDYSPECIFIC ='N';

FOR i IN v_user_deact_spons_upd.FIRST..v_user_deact_spons_upd.LAST
LOOP
UPDATE TBL_USERDEACTIVATIONLOG SET ISPROCESSED ='Y' WHERE USERDEACTIVATIONID = v_user_deact_spons_upd(i).USERDEACTIVATIONID;
v_userdeactivate_out.Extend;
v_userdeactivate_out(v_userdeactivate_out.COUNT) :=obj_userdeactivate_out(v_user_deact_spons_upd(i).USERDEACTIVATIONID,v_user_deact_spons_upd(i).AFFECTORID,v_user_deact_spons_upd(i).TRANSCELERATEUSERID,v_user_deact_spons_upd(i).REQUESTERID,v_user_deact_spons_upd(i).ADMINID,v_user_deact_spons_upd(i).SITEID,
v_user_deact_spons_upd(i).STUDYID,v_user_deact_spons_upd(i).EFFECTIVEDATE,v_user_deact_spons_upd(i).JUSTIFICATIONID,v_user_deact_spons_upd(i).ISCONFIRMED,v_user_deact_spons_upd(i).ISPROCESSED,v_user_deact_spons_upd(i).ISSPONSORSYSUPDATED,v_user_deact_spons_upd(i).REPLACINGPIID,v_user_deact_spons_upd(i).ISSTUDYSPECIFIC,v_user_deact_spons_upd(i).ISFORCAUSE,v_user_deact_spons_upd(i).COMMENTS,
v_user_deact_spons_upd(i).ISAPPROVALREQ,v_user_deact_spons_upd(i).TASKID,v_user_deact_spons_upd(i).ISFORDEACTIVATION,v_user_deact_spons_upd(i).ISSPONSOR);
END LOOP;

EXCEPTION
 WHEN e_dml_errors THEN
   l_errors := SQL%bulk_exceptions.count;
  IF l_errors > 0 THEN
ROLLBACK;
END IF;
END;

END LOOP;
CLOSE cur_user_deactivation_spons;
COMMIT;

-- updating userRoleMap table for site users
OPEN cur_user_deactivation_site;
    LOOP
    	FETCH cur_user_deactivation_site BULK COLLECT INTO v_user_deact_site_upd LIMIT 1000;
        EXIT WHEN v_user_deact_site_upd.COUNT = 0;
BEGIN

--FORALL i IN v_user_deact_site_upd.FIRST..v_user_deact_site_upd.LAST  SAVE EXCEPTIONS

FOR i IN v_user_deact_site_upd.FIRST..v_user_deact_site_upd.LAST
LOOP
IF(v_user_deact_site_upd(i).ROLEID IS NULL) THEN
UPDATE Tbl_UserRoleMap SET EffectiveEndDate =v_user_deact_site_upd(i).EFFECTIVEDATE,
RoleChangeReason=(CASE WHEN v_user_deact_site_upd(i).ISFORCAUSE='Y' THEN
'DEACTIVATION_FORCAUSE'
WHEN v_user_deact_site_upd(i).ISFORCAUSE='N' THEN
'DEACTIVATION_FORSITE'
ELSE NULL
END)
WHERE userid = v_user_deact_site_upd(i).AFFECTORID
and studyId IS NOT NULL
and studyid=v_user_deact_site_upd(i).STUDYID
and siteid=v_user_deact_site_upd(i).SITEID
and ( EffectiveEndDate is NULL OR EffectiveEndDate>=SYSDATE) and RoleChangeReason IS NULL;
ELSE
UPDATE Tbl_UserRoleMap SET EffectiveEndDate =v_user_deact_site_upd(i).EFFECTIVEDATE,
RoleChangeReason=(CASE WHEN v_user_deact_site_upd(i).ISFORCAUSE='Y' THEN
'DEACTIVATION_FORCAUSE'
WHEN v_user_deact_site_upd(i).ISFORCAUSE='N' THEN
'DEACTIVATION_FORSITE'
ELSE NULL
END)
WHERE userid = v_user_deact_site_upd(i).AFFECTORID
and studyId IS NOT NULL
and studyid=v_user_deact_site_upd(i).STUDYID
and siteid=v_user_deact_site_upd(i).SITEID
and roleid=v_user_deact_site_upd(i).ROLEID
and ( EffectiveEndDate is NULL OR EffectiveEndDate>=SYSDATE) and RoleChangeReason IS NULL;

END IF;
END LOOP;

FOR i IN v_user_deact_site_upd.FIRST..v_user_deact_site_upd.LAST

LOOP
UPDATE Tbl_UserDeactivationLog SET ISPROCESSED ='Y' WHERE USERDEACTIVATIONID = v_user_deact_site_upd(i).USERDEACTIVATIONID;
v_userdeactivate_out.Extend;
v_userdeactivate_out(v_userdeactivate_out.COUNT) :=obj_userdeactivate_out(v_user_deact_site_upd(i).USERDEACTIVATIONID,v_user_deact_site_upd(i).AFFECTORID,v_user_deact_site_upd(i).TRANSCELERATEUSERID,v_user_deact_site_upd(i).REQUESTERID,v_user_deact_site_upd(i).ADMINID,v_user_deact_site_upd(i).SITEID,
v_user_deact_site_upd(i).STUDYID,v_user_deact_site_upd(i).EFFECTIVEDATE,v_user_deact_site_upd(i).JUSTIFICATIONID,v_user_deact_site_upd(i).ISCONFIRMED,v_user_deact_site_upd(i).ISPROCESSED,v_user_deact_site_upd(i).ISSPONSORSYSUPDATED,v_user_deact_site_upd(i).REPLACINGPIID,v_user_deact_site_upd(i).ISSTUDYSPECIFIC,v_user_deact_site_upd(i).ISFORCAUSE,v_user_deact_site_upd(i).COMMENTS,
v_user_deact_site_upd(i).ISAPPROVALREQ,v_user_deact_site_upd(i).TASKID,v_user_deact_site_upd(i).ISFORDEACTIVATION,v_user_deact_site_upd(i).ISSPONSOR);
END LOOP;

EXCEPTION
 WHEN e_dml_errors THEN
   l_errors := SQL%bulk_exceptions.count;
  IF l_errors > 0 THEN
ROLLBACK;
END IF;
END;
END LOOP;
CLOSE cur_user_deactivation_site;
COMMIT;

--Commented as part of R2.1
-- insert in userrolemap for activation of sponsor user

--OPEN cur_user_activation_spons;
--    LOOP
--    	FETCH cur_user_activation_spons BULK COLLECT INTO v_user_activate_spons_upd LIMIT 1000;
--        EXIT WHEN v_user_activate_spons_upd.COUNT = 0;
--BEGIN
--
--select roleid into v_sponsorrole from tbl_roles where rolename ='Study - View Only';
--
--FORALL i IN v_user_activate_spons_upd.FIRST..v_user_activate_spons_upd.LAST  SAVE EXCEPTIONS
--
--INSERT INTO TBL_USERROLEMAP (USERROLEID,USERID,ROLEID,STUDYID,EFFECTIVESTARTDATE,CREATEDBY,CREATEDDT) VALUES
--(SEQ_USERROLEMAP.nextval,v_user_activate_spons_upd(i).AFFECTORID,v_sponsorrole,v_user_activate_spons_upd(i).STUDYID,v_sysdate,v_user_activate_spons_upd(i).CREATEDBY,v_sysdate );
--
--
--FOR i IN v_user_activate_spons_upd.FIRST..v_user_activate_spons_upd.LAST
--LOOP
--UPDATE TBL_USERDEACTIVATIONLOG SET ISPROCESSED ='Y' WHERE USERDEACTIVATIONID = v_user_activate_spons_upd(i).USERDEACTIVATIONID;
--v_userdeactivate_out.Extend;
--v_userdeactivate_out(v_userdeactivate_out.COUNT) :=obj_userdeactivate_out(v_user_activate_spons_upd(i).USERDEACTIVATIONID,v_user_activate_spons_upd(i).AFFECTORID,v_user_activate_spons_upd(i).TRANSCELERATEUSERID,v_user_activate_spons_upd(i).REQUESTERID,v_user_activate_spons_upd(i).ADMINID,v_user_activate_spons_upd(i).SITEID,
--v_user_activate_spons_upd(i).STUDYID,v_user_activate_spons_upd(i).EFFECTIVEDATE,v_user_activate_spons_upd(i).JUSTIFICATIONID,v_user_activate_spons_upd(i).ISCONFIRMED,v_user_activate_spons_upd(i).ISPROCESSED,v_user_activate_spons_upd(i).ISSPONSORSYSUPDATED,v_user_activate_spons_upd(i).REPLACINGPIID,v_user_activate_spons_upd(i).ISSTUDYSPECIFIC,v_user_activate_spons_upd(i).ISFORCAUSE,v_user_activate_spons_upd(i).COMMENTS,
--v_user_activate_spons_upd(i).ISAPPROVALREQ,v_user_activate_spons_upd(i).TASKID,v_user_activate_spons_upd(i).ISFORDEACTIVATION,v_user_activate_spons_upd(i).ISSPONSOR);
--END LOOP;
--
--EXCEPTION
-- WHEN e_dml_errors THEN
--   l_errors := SQL%bulk_exceptions.count;
--  IF l_errors > 0 THEN
--ROLLBACK;
--END IF;
--END;
--END LOOP;
--CLOSE cur_user_activation_spons;
--COMMIT;

----insert for PI replacement

OPEN cur_user_pi_replacement;
    LOOP
    	FETCH cur_user_pi_replacement BULK COLLECT INTO v_user_pi_replacement LIMIT 1000;
        EXIT WHEN v_user_pi_replacement.COUNT = 0;
BEGIN

select roleid into v_investrole from tbl_roles where rolename ='Principal Investigator';

FORALL i IN v_user_pi_replacement.FIRST..v_user_pi_replacement.LAST  SAVE EXCEPTIONS

--Deactivate the affecter from the Study-Site combinations
UPDATE Tbl_UserRoleMap SET EffectiveEndDate =v_user_pi_replacement(i).EFFECTIVEDATE,
RoleChangeReason='PI REPLACEMENT',MODIFIEDDT=v_sysdate,MODIFIEDBY=v_user_pi_replacement(i).AFFECTORID
WHERE userid = v_user_pi_replacement(i).AFFECTORID
and studyId IS NOT NULL
and studyid=v_user_pi_replacement(i).STUDYID
and siteid=v_user_pi_replacement(i).SITEID
and ( EffectiveEndDate is NULL OR EffectiveEndDate>=SYSDATE) and RoleChangeReason IS NULL;

FORALL i IN v_user_pi_replacement.FIRST..v_user_pi_replacement.LAST  SAVE EXCEPTIONS

--Deactivate the replacing Pi from the Study-Sites, from all other role as he is going to become a PI
UPDATE Tbl_UserRoleMap SET EffectiveEndDate =v_user_pi_replacement(i).EFFECTIVEDATE,
RoleChangeReason='PI REPLACEMENT',MODIFIEDDT=v_sysdate,MODIFIEDBY=v_user_pi_replacement(i).AFFECTORID
WHERE userid = v_user_pi_replacement(i).REPLACINGPIID
and studyid=v_user_pi_replacement(i).STUDYID
and siteid=v_user_pi_replacement(i).SITEID
and ( EffectiveEndDate is NULL OR EffectiveEndDate>=SYSDATE) and RoleChangeReason IS NULL;

FORALL i IN v_user_pi_replacement.FIRST..v_user_pi_replacement.LAST  SAVE EXCEPTIONS

INSERT INTO TBL_USERROLEMAP (USERROLEID,USERID,ROLEID,STUDYID,SITEID,EFFECTIVESTARTDATE,CREATEDBY,CREATEDDT) VALUES
(SEQ_USERROLEMAP.nextval,v_user_pi_replacement(i).REPLACINGPIID,v_investrole,v_user_pi_replacement(i).STUDYID,v_user_pi_replacement(i).SITEID,v_sysdate,v_user_pi_replacement(i).CREATEDBY,v_sysdate );

FOR i IN v_user_pi_replacement.FIRST..v_user_pi_replacement.LAST

LOOP

select roleid into v_investrole from tbl_roles where rolename ='Principal Investigator';

UPDATE TBL_SITE SET PIID =v_user_pi_replacement(i).REPLACINGPIID, MODIFIEDDT=v_sysdate,MODIFIEDBY=v_user_pi_replacement(i).AFFECTORID WHERE SITEID = v_user_pi_replacement(i).SITEID;

--Select * into v_site from tbl_site where siteid=v_user_pi_replacement(i).SITEID;

--INSERT INTO TBL_SITE (SITEID,STUDYID,PRINCIPALFACILITYID,PIID,TRANSCELERATESITEID,SITENAME,ISAFFILIATED,CTMSITENUM,INSTITUTIONNAME,CONTACTID,ISACTIVE,CREATEDBY,CREATEDDT)
--VALUES (SEQ_SITE.nextval,v_site.STUDYID,v_site.PRINCIPALFACILITYID,v_user_pi_replacement(i).REPLACINGPIID,v_site.TRANSCELERATESITEID,v_site.SITENAME,v_site.ISAFFILIATED,
--v_site.CTMSITENUM,v_site.INSTITUTIONNAME,v_site.CONTACTID,'Y',v_user_pi_replacement(i).REPLACINGPIID,v_sysdate);

UPDATE TBL_USERDEACTIVATIONLOG SET ISPROCESSED ='Y' WHERE USERDEACTIVATIONID = v_user_pi_replacement(i).USERDEACTIVATIONID;
v_userdeactivate_out.Extend;
v_userdeactivate_out(v_userdeactivate_out.COUNT) :=obj_userdeactivate_out(v_user_pi_replacement(i).USERDEACTIVATIONID,v_user_pi_replacement(i).AFFECTORID,v_user_pi_replacement(i).TRANSCELERATEUSERID,v_user_pi_replacement(i).REQUESTERID,v_user_pi_replacement(i).ADMINID,v_user_pi_replacement(i).SITEID,
v_user_pi_replacement(i).STUDYID,v_user_pi_replacement(i).EFFECTIVEDATE,v_user_pi_replacement(i).JUSTIFICATIONID,v_user_pi_replacement(i).ISCONFIRMED,v_user_pi_replacement(i).ISPROCESSED,v_user_pi_replacement(i).ISSPONSORSYSUPDATED,v_user_pi_replacement(i).REPLACINGPIID,v_user_pi_replacement(i).ISSTUDYSPECIFIC,v_user_pi_replacement(i).ISFORCAUSE,v_user_pi_replacement(i).COMMENTS,
v_user_pi_replacement(i).ISAPPROVALREQ,v_user_pi_replacement(i).TASKID,v_user_pi_replacement(i).ISFORDEACTIVATION,v_user_pi_replacement(i).ISSPONSOR);
END LOOP;


EXCEPTION
 WHEN e_dml_errors THEN
   l_errors := SQL%bulk_exceptions.count;
  IF l_errors > 0 THEN
ROLLBACK;
END IF;
END;
END LOOP;
CLOSE cur_user_pi_replacement;
COMMIT;


-- Cursor to return the values in v_userdeactivate_out
OPEN CUR_PLAT_SPON_DEACT
for
SELECT * from TABLE ( CAST (v_userdeactivate_out as typ_userdeactivate_out));



EXCEPTION
	WHEN OTHERS THEN
  raise_application_error(-20001,'An error was encountered while processing User-deactivation data.- '||SQLCODE||' -ERROR- '||SQLERRM || ' AT : '||DBMS_UTILITY.format_error_backtrace());
	ROLLBACK;

END sp_user_deactivation;

END pkg_user_deactivation;
/