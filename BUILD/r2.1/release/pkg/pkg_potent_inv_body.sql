CREATE OR REPLACE PACKAGE BODY pkg_potent_inv
AS
  PROCEDURE SP_POTENTIAL_INV(
      P_PILIST IN typ_potentialInv_list,
      CUR_PILISTOUT OUT SYS_REFCURSOR,
      P_STUDYID IN NUMBER  )
  AS
    V_POTENTIAL_INV TBL_POTENTIALINVESTIGATOR%ROWTYPE;
    V_POTFACMAP TBL_POTENTIALINVFACMAP%ROWTYPE;
    V_PILISTOUT typ_potentialInv_list;
    V_PIID        NUMBER;
    V_PIFACID     NUMBER;
    V_FACMAP_NULL NUMBER;
    V_PI_TITLE_CHECK NUMBER;
    V_PI_TITLE_CONTACT NUMBER;
    V_CONTACT_ID NUMBER;
    V_CONTACT_INFO NUMBER;
    V_CONTACTID NUMBER;
  BEGIN
    V_PILISTOUT :=typ_potentialInv_list();
    IF (P_PILIST IS NOT NULL) THEN
      FOR i IN P_PILIST.first .. P_PILIST.last
      LOOP
        --first IF
        IF (P_PILIST(i).v_transcelerateUserId IS NOT NULL AND P_PILIST(i).v_titleId !=0) THEN
          --outer Begin
          IF (P_PILIST(i).v_facilityId > 0) THEN
       SELECT COUNT(FMAP.POTENTIALINVUSERID) INTO V_PI_TITLE_CHECK from TBL_POTENTIALINVFACMAP FMAP
              JOIN TBL_POTENTIALINVESTIGATOR PI ON PI.POTENTIALINVUSERID=FMAP.POTENTIALINVUSERID
              JOIN TBL_POTENTIALINVTITLES PT ON PT.TITLEID = PI.TITLEID
              WHERE PT.STUDYID =P_STUDYID
              AND FMAP.ISACTIVE ='Y'
              AND PI.TRANSCELERATEUSERID=P_PILIST(i).v_transcelerateUserId
              AND FMAP.FACILITYID =P_PILIST(i).v_facilityId;
         ELSE
      SELECT COUNT(FMAP.POTENTIALINVUSERID) INTO V_PI_TITLE_CHECK from TBL_POTENTIALINVFACMAP FMAP
              JOIN TBL_POTENTIALINVESTIGATOR PI ON PI.POTENTIALINVUSERID=FMAP.POTENTIALINVUSERID
              JOIN TBL_POTENTIALINVTITLES PT ON PT.TITLEID = PI.TITLEID
              WHERE PT.STUDYID =P_STUDYID
              AND FMAP.ISACTIVE ='Y'
              AND PI.TRANSCELERATEUSERID=P_PILIST(i).v_transcelerateUserId;
      END IF;
IF (V_PI_TITLE_CHECK =0) THEN

 BEGIN
            SELECT *
            INTO V_POTENTIAL_INV
            FROM TBL_POTENTIALINVESTIGATOR
            WHERE TRANSCELERATEUSERID = P_PILIST(i).v_transcelerateUserId
            AND TITLEID               =P_PILIST(i).v_titleId
            AND ISACTIVE              ='Y';
            --Inner Begin for exiting user in PI list
            BEGIN
              SELECT *
              INTO V_POTFACMAP
              FROM TBL_POTENTIALINVFACMAP
              WHERE FACILITYID      = P_PILIST(i).v_facilityId
              AND POTENTIALINVUSERID=V_POTENTIAL_INV.POTENTIALINVUSERID
              AND ISACTIVE          ='Y';
              V_PILISTOUT.Extend;
              V_PILISTOUT(V_PILISTOUT.COUNT) :=obj_potentialInv_list(V_POTENTIAL_INV.TRANSCELERATEUSERID,V_POTENTIAL_INV.TITLEID,V_POTENTIAL_INV.POTENTIALINVUSERID,V_POTENTIAL_INV.CONTACTID,V_POTENTIAL_INV.FIRSTNAME,V_POTENTIAL_INV.LASTNAME, V_POTFACMAP.ISCOMMDOCUMENTED,V_POTENTIAL_INV.CREATEDBY,V_POTENTIAL_INV.CREATEDDT,V_POTENTIAL_INV.MODIFIEDBY,V_POTENTIAL_INV.MODIFIEDDT,V_POTFACMAP.FACILITYID,V_POTFACMAP.ISNOTIFICATIONSEND,V_POTFACMAP.ISSELECTEDFORPRESTUDYEVAL, V_POTFACMAP.ISSITEFEASIBILITYSURVEYREQ,V_POTFACMAP.ISINVITATIONSEND,V_POTFACMAP.HASRESPONDEDTOINVITE,V_POTFACMAP.ISACCEPTED, V_POTFACMAP.ISREJECTED,V_POTFACMAP.ISDISQUALIFIED,V_POTFACMAP.ISSELECTEDFORSTUDY,V_POTFACMAP.ISKEYCONTACT,V_POTENTIAL_INV.ISACTIVE, V_POTFACMAP.STATUSCD,V_POTFACMAP.REASON,V_POTFACMAP.ZSCORE,P_PILIST(i).v_email,P_PILIST(i).v_countrycd);
            EXCEPTION
            WHEN NO_DATA_FOUND THEN
              SELECT COUNT(POTENTIALINVUSERID)
              INTO V_FACMAP_NULL
              FROM TBL_POTENTIALINVFACMAP
              WHERE FACILITYID     IS NULL
              AND POTENTIALINVUSERID=V_POTENTIAL_INV.POTENTIALINVUSERID
              AND ISACTIVE          ='Y';
              IF (V_FACMAP_NULL     =0 AND P_PILIST(i).v_facilityId > 0 ) THEN
                INSERT
                INTO TBL_POTENTIALINVFACMAP
                  (
                    POTENTIALINVFACID,
                    FACILITYID,
                    POTENTIALINVUSERID,
                    CREATEDBY,
                    CREATEDDT,
                    ISNOTIFICATIONSEND,
                    ISSELECTEDFORPRESTUDYEVAL,
                    ISSITEFEASIBILITYSURVEYREQ,
                    ISINVITATIONSEND,
                    HASRESPONDEDTOINVITE,
                    ISACCEPTED,
                    ISREJECTED,
                    ISDISQUALIFIED,
                    ISSELECTEDFORSTUDY,
                    ISKEYCONTACT,
                    ISACTIVE,
                    STATUSCD,
                    ISCOMMDOCUMENTED
                  )
                  VALUES
                  (
                    SEQ_POTENTIALINVFACMAP.nextval,
                    P_PILIST(i).v_facilityId,
                    V_POTENTIAL_INV.POTENTIALINVUSERID,
                    P_PILIST(i).v_createdBy,
                    sysdate,
                    'N',
                    'N',
                    'N',
                    'N',
                    'N',
                    'N',
                    'N',
                    'N',
                    'N',
                    'N',
                    'Y',
                    'statusCd1',
                    'N'
                  );
              ELSIF (V_FACMAP_NULL =0 AND P_PILIST(i).v_facilityId < 0 ) THEN
                INSERT
                INTO TBL_POTENTIALINVFACMAP
                  (
                    POTENTIALINVFACID,
                    FACILITYID,
                    POTENTIALINVUSERID,
                    CREATEDBY,
                    CREATEDDT,
                    ISNOTIFICATIONSEND,
                    ISSELECTEDFORPRESTUDYEVAL,
                    ISSITEFEASIBILITYSURVEYREQ,
                    ISINVITATIONSEND,
                    HASRESPONDEDTOINVITE,
                    ISACCEPTED,
                    ISREJECTED,
                    ISDISQUALIFIED,
                    ISSELECTEDFORSTUDY,
                    ISKEYCONTACT,
                    ISACTIVE,
                    STATUSCD,
                    ISCOMMDOCUMENTED
                  )
                  VALUES
                  (
                    SEQ_POTENTIALINVFACMAP.nextval,
                    NULL,
                    V_POTENTIAL_INV.POTENTIALINVUSERID,
                    P_PILIST(i).v_createdBy,
                    sysdate,
                    'N',
                    'N',
                    'N',
                    'N',
                    'N',
                    'N',
                    'N',
                    'N',
                    'N',
                    'N',
                    'Y',
                    'statusCd1',
                    'N'
                  );
              ELSIF (V_FACMAP_NULL !=0 AND P_PILIST(i).v_facilityId > 0 ) THEN
                UPDATE TBL_POTENTIALINVFACMAP
                SET FACILITYID        =P_PILIST(i).v_facilityId,
                  MODIFIEDBY          =P_PILIST(i).v_createdBy,
                  MODIFIEDDT          =sysdate
                WHERE FACILITYID     IS NULL
                AND POTENTIALINVUSERID=V_POTENTIAL_INV.POTENTIALINVUSERID;
              END IF;
              V_PILISTOUT.Extend;
              V_PILISTOUT(V_PILISTOUT.COUNT) :=obj_potentialInv_list(V_POTENTIAL_INV.TRANSCELERATEUSERID,V_POTENTIAL_INV.TITLEID,V_POTENTIAL_INV.POTENTIALINVUSERID,V_POTENTIAL_INV.CONTACTID,V_POTENTIAL_INV.FIRSTNAME,V_POTENTIAL_INV.LASTNAME, 'N',V_POTENTIAL_INV.CREATEDBY,V_POTENTIAL_INV.CREATEDDT,V_POTENTIAL_INV.MODIFIEDBY,V_POTENTIAL_INV.MODIFIEDDT,P_PILIST(i).v_facilityId,'N','N','N','N','N','N','N','N','N','N',V_POTENTIAL_INV.ISACTIVE,'statusCd1',NULL,NULL,P_PILIST(i).v_email,P_PILIST(i).v_countrycd);
            END;
            --Inner begin ends
          EXCEPTION
          WHEN NO_DATA_FOUND THEN
            INSERT
            INTO TBL_POTENTIALINVESTIGATOR
              (
                POTENTIALINVUSERID,
                TRANSCELERATEUSERID,
                TITLEID,
                CONTACTID,
                FIRSTNAME,
                LASTNAME,
                STATUSCD,
                ISCOMMDOCUMENTED,
                CREATEDBY,
                CREATEDDT,
                ISACTIVE
              )
              VALUES
              (
                SEQ_POTENTIALINVESTIGATOR.nextval,
                P_PILIST(i).v_transcelerateUserId,
                P_PILIST(i).v_titleId,
                P_PILIST(i).v_contactid,
                P_PILIST(i).v_firstname,
                P_PILIST(i).v_lastname,
                'statusCd1',
                'N',
                P_PILIST(i).v_createdBy,
                sysdate,
                'Y'
              );
            --1
            SELECT SEQ_POTENTIALINVESTIGATOR.currval INTO V_PIID FROM DUAL;
            IF (P_PILIST(i).v_facilityId !=0) THEN
              INSERT
              INTO TBL_POTENTIALINVFACMAP
                (
                  POTENTIALINVFACID,
                  FACILITYID,
                  POTENTIALINVUSERID,
                  CREATEDBY,
                  CREATEDDT,
                  ISNOTIFICATIONSEND,
                  ISSELECTEDFORPRESTUDYEVAL,
                  ISSITEFEASIBILITYSURVEYREQ,
                  ISINVITATIONSEND,
                  HASRESPONDEDTOINVITE,
                  ISACCEPTED,
                  ISREJECTED,
                  ISDISQUALIFIED,
                  ISSELECTEDFORSTUDY,
                  ISKEYCONTACT,
                  ISACTIVE,
                  STATUSCD,
                  ISCOMMDOCUMENTED
                )
                VALUES
                (
                  SEQ_POTENTIALINVFACMAP.nextval,
                  P_PILIST(i).v_facilityId,
                  SEQ_POTENTIALINVESTIGATOR.currval,
                  P_PILIST(i).v_createdBy,
                  sysdate,
                  'N',
                  'N',
                  'N',
                  'N',
                  'N',
                  'N',
                  'N',
                  'N',
                  'N',
                  'N',
                  'Y',
                  'statusCd1',
                  'N'
                );
            ELSE
              INSERT
              INTO TBL_POTENTIALINVFACMAP
                (
                  POTENTIALINVFACID,
                  FACILITYID,
                  POTENTIALINVUSERID,
                  CREATEDBY,
                  CREATEDDT,
                  ISNOTIFICATIONSEND,
                  ISSELECTEDFORPRESTUDYEVAL,
                  ISSITEFEASIBILITYSURVEYREQ,
                  ISINVITATIONSEND,
                  HASRESPONDEDTOINVITE,
                  ISACCEPTED,
                  ISREJECTED,
                  ISDISQUALIFIED,
                  ISSELECTEDFORSTUDY,
                  ISKEYCONTACT,
                  ISACTIVE,
                  STATUSCD,
                  ISCOMMDOCUMENTED
                )
                VALUES
                (
                  SEQ_POTENTIALINVFACMAP.nextval,
                  NULL,
                  SEQ_POTENTIALINVESTIGATOR.currval,
                  P_PILIST(i).v_createdBy,
                  sysdate,
                  'N',
                  'N',
                  'N',
                  'N',
                  'N',
                  'N',
                  'N',
                  'N',
                  'N',
                  'N',
                  'Y',
                  'statusCd1',
                  'N'
                );
            END IF;--1
            --need to change facility variables and pi list
            V_PILISTOUT.Extend;
            V_PILISTOUT(V_PILISTOUT.COUNT) :=obj_potentialInv_list(P_PILIST(i).v_transcelerateUserId,P_PILIST(i).v_titleId,V_PIID,P_PILIST(i).v_contactid,P_PILIST(i).v_firstname,P_PILIST(i).v_lastname, 'N',P_PILIST(i).v_createdBy,P_PILIST(i).v_createdDate,P_PILIST(i).v_modifiedBy,P_PILIST(i).v_modifiedDate,P_PILIST(i).v_facilityId,'N','N','N','N','N','N','N','N','N','N','Y','statusCd1',P_PILIST(i).v_reason,P_PILIST(i).v_zscore,P_PILIST(i).v_email,P_PILIST(i).v_countrycd);
          END;
          --Outer Begin ends
ELSE
 --Do nothing return same object Need to update object
V_PILISTOUT.Extend;
V_PILISTOUT(V_PILISTOUT.COUNT) :=obj_potentialInv_list(P_PILIST(i).v_transcelerateUserId,P_PILIST(i).v_titleId,P_PILIST(i).v_potInvid,P_PILIST(i).v_contactid,P_PILIST(i).v_firstname,P_PILIST(i).v_lastname, P_PILIST(i).v_communicationDocumented,P_PILIST(i).v_createdBy,P_PILIST(i).v_createdDate,P_PILIST(i).v_modifiedBy,P_PILIST(i).v_modifiedDate,P_PILIST(i).v_facilityId,P_PILIST(i).v_isNotificationSend,P_PILIST(i).v_selectedForPreStudyEval,P_PILIST(i).v_siteFeasibilitySurveyReq, P_PILIST(i).v_invitationSend,P_PILIST(i).v_respondedToInvite,P_PILIST(i).v_accepted,P_PILIST(i).v_rejected,P_PILIST(i).v_disqualified,P_PILIST(i).v_selectedForStudy,P_PILIST(i).v_keyContact,P_PILIST(i).v_active,P_PILIST(i).v_statusCode,P_PILIST(i).v_reason,P_PILIST(i).v_zscore,P_PILIST(i).v_email,P_PILIST(i).v_countrycd);

END IF;

ELSIF (P_PILIST(i).v_transcelerateUserId IS NULL AND P_PILIST(i).v_titleId !=0 ) THEN

SELECT COUNT(*) INTO V_CONTACT_ID from tbl_contact where pkg_encrypt.fn_decrypt(EMAIL)=P_PILIST(i).v_email and isactive='Y';
IF(V_CONTACT_ID !=0) THEN
SELECT CONTACTID INTO V_CONTACT_INFO from tbl_contact where pkg_encrypt.fn_decrypt(EMAIL)=P_PILIST(i).v_email and isactive='Y';

---here we need to add implement changes for contact
 SELECT COUNT(FMAP.POTENTIALINVUSERID) INTO V_PI_TITLE_CONTACT from TBL_POTENTIALINVFACMAP FMAP
              JOIN TBL_POTENTIALINVESTIGATOR PI ON PI.POTENTIALINVUSERID=FMAP.POTENTIALINVUSERID
              JOIN TBL_POTENTIALINVTITLES PT ON PT.TITLEID = PI.TITLEID
              WHERE PT.STUDYID =P_STUDYID
              AND FMAP.ISACTIVE ='Y'
              AND PI.CONTACTID=V_CONTACT_INFO;

IF  (V_PI_TITLE_CONTACT =0) THEN

   BEGIN
            SELECT *
            INTO V_POTENTIAL_INV
            FROM TBL_POTENTIALINVESTIGATOR
            WHERE TITLEID = P_PILIST(i).v_titleId
            AND CONTACTID =V_CONTACT_INFO
            AND ISACTIVE  ='Y';

		UPDATE TBL_POTENTIALINVESTIGATOR
			SET
                TRANSCELERATEUSERID =P_PILIST(i).v_transcelerateUserId,
                FIRSTNAME =P_PILIST(i).v_firstname,
                LASTNAME =P_PILIST(i).v_lastname,
                MODIFIEDBY =P_PILIST(i).v_createdBy,
                MODIFIEDDT= sysdate
			  WHERE POTENTIALINVUSERID=V_POTENTIAL_INV.POTENTIALINVUSERID;
 --Need to change facility variables
            V_PILISTOUT.Extend;
            V_PILISTOUT(V_PILISTOUT.COUNT) :=obj_potentialInv_list(V_POTENTIAL_INV.TRANSCELERATEUSERID,V_POTENTIAL_INV.TITLEID,V_POTENTIAL_INV.POTENTIALINVUSERID,V_POTENTIAL_INV.CONTACTID,V_POTENTIAL_INV.FIRSTNAME,V_POTENTIAL_INV.LASTNAME, P_PILIST(i).v_communicationDocumented,V_POTENTIAL_INV.CREATEDBY,V_POTENTIAL_INV.CREATEDDT,V_POTENTIAL_INV.MODIFIEDBY,V_POTENTIAL_INV.MODIFIEDDT,P_PILIST(i).v_facilityId,P_PILIST(i).v_isNotificationSend,P_PILIST(i).v_selectedForPreStudyEval,P_PILIST(i).v_siteFeasibilitySurveyReq, P_PILIST(i).v_invitationSend,P_PILIST(i).v_respondedToInvite,P_PILIST(i).v_accepted,P_PILIST(i).v_rejected,P_PILIST(i).v_disqualified,P_PILIST(i).v_selectedForStudy,P_PILIST(i).v_keyContact,P_PILIST(i).v_active,P_PILIST(i).v_statusCode,P_PILIST(i).v_reason,P_PILIST(i).v_zscore,P_PILIST(i).v_email,P_PILIST(i).v_countrycd);
          EXCEPTION
          WHEN NO_DATA_FOUND THEN
            INSERT
            INTO TBL_POTENTIALINVESTIGATOR
              (
                POTENTIALINVUSERID,
                TRANSCELERATEUSERID,
                TITLEID,
                CONTACTID,
                FIRSTNAME,
                LASTNAME,
                STATUSCD,
                ISCOMMDOCUMENTED,
                CREATEDBY,
                CREATEDDT,
                ISACTIVE
              )
              VALUES
              (
                SEQ_POTENTIALINVESTIGATOR.nextval,
                P_PILIST(i).v_transcelerateUserId,
                P_PILIST(i).v_titleId,
                V_CONTACT_INFO,
                P_PILIST(i).v_firstname,
                P_PILIST(i).v_lastname,
                'statusCd1',
                'N',
                P_PILIST(i).v_createdBy,
                sysdate,
                'Y'
              );
            SELECT SEQ_POTENTIALINVESTIGATOR.currval INTO V_PIID FROM DUAL;
            INSERT
            INTO TBL_POTENTIALINVFACMAP
              (
                POTENTIALINVFACID,
                FACILITYID,
                POTENTIALINVUSERID,
                CREATEDBY,
                CREATEDDT,
                ISNOTIFICATIONSEND,
                ISSELECTEDFORPRESTUDYEVAL,
                ISSITEFEASIBILITYSURVEYREQ,
                ISINVITATIONSEND,
                HASRESPONDEDTOINVITE,
                ISACCEPTED,
                ISREJECTED,
                ISDISQUALIFIED,
                ISSELECTEDFORSTUDY,
                ISKEYCONTACT,
                ISACTIVE,
                STATUSCD,
                ISCOMMDOCUMENTED
              )
              VALUES
              (
                SEQ_POTENTIALINVFACMAP.nextval,
                NULL,
                SEQ_POTENTIALINVESTIGATOR.currval,
                P_PILIST(i).v_createdBy,
                sysdate,
                'N',
                'N',
                'N',
                'N',
                'N',
                'N',
                'N',
                'N',
                'N',
                'N',
                'Y',
                'statusCd1',
                'N'
              );
            --need to change facility and pi list variables
            V_PILISTOUT.Extend;
            V_PILISTOUT(V_PILISTOUT.COUNT) :=obj_potentialInv_list(P_PILIST(i).v_transcelerateUserId,P_PILIST(i).v_titleId,V_PIID,P_PILIST(i).v_contactid,P_PILIST(i).v_firstname,P_PILIST(i).v_lastname, P_PILIST(i).v_communicationDocumented,P_PILIST(i).v_createdBy,P_PILIST(i).v_createdDate,P_PILIST(i).v_modifiedBy,P_PILIST(i).v_modifiedDate,P_PILIST(i).v_facilityId,P_PILIST(i).v_isNotificationSend,P_PILIST(i).v_selectedForPreStudyEval,P_PILIST(i).v_siteFeasibilitySurveyReq, P_PILIST(i).v_invitationSend,P_PILIST(i).v_respondedToInvite,P_PILIST(i).v_accepted,P_PILIST(i).v_rejected,P_PILIST(i).v_disqualified,P_PILIST(i).v_selectedForStudy,P_PILIST(i).v_keyContact,P_PILIST(i).v_active,'statusCd1',P_PILIST(i).v_reason,P_PILIST(i).v_zscore,P_PILIST(i).v_email,P_PILIST(i).v_countrycd);
          END;
        END IF;
ELSE
V_CONTACTID := SEQ_CONTACT.NEXTVAL;
INSERT INTO TBL_CONTACT (
CONTACTID,
EMAIL,
COUNTRYCD,
ISACTIVE,
CREATEDBY,
CREATEDDT
)
VALUES
(V_CONTACTID,
P_PILIST(i).v_email,
P_PILIST(i).v_countrycd,
'Y',
P_PILIST(i).v_createdBy,
SYSDATE
);
            INSERT
            INTO TBL_POTENTIALINVESTIGATOR
              (
                POTENTIALINVUSERID,
                TRANSCELERATEUSERID,
                TITLEID,
                CONTACTID,
                FIRSTNAME,
                LASTNAME,
                STATUSCD,
                ISCOMMDOCUMENTED,
                CREATEDBY,
                CREATEDDT,
                ISACTIVE
              )
              VALUES
              (
                SEQ_POTENTIALINVESTIGATOR.nextval,
                P_PILIST(i).v_transcelerateUserId,
                P_PILIST(i).v_titleId,
                V_CONTACTID,
                P_PILIST(i).v_firstname,
                P_PILIST(i).v_lastname,
                'statusCd1',
                'N',
                P_PILIST(i).v_createdBy,
                sysdate,
                'Y'
              );
            SELECT SEQ_POTENTIALINVESTIGATOR.currval INTO V_PIID FROM DUAL;
            INSERT
            INTO TBL_POTENTIALINVFACMAP
              (
                POTENTIALINVFACID,
                FACILITYID,
                POTENTIALINVUSERID,
                CREATEDBY,
                CREATEDDT,
                ISNOTIFICATIONSEND,
                ISSELECTEDFORPRESTUDYEVAL,
                ISSITEFEASIBILITYSURVEYREQ,
                ISINVITATIONSEND,
                HASRESPONDEDTOINVITE,
                ISACCEPTED,
                ISREJECTED,
                ISDISQUALIFIED,
                ISSELECTEDFORSTUDY,
                ISKEYCONTACT,
                ISACTIVE,
                STATUSCD,
                ISCOMMDOCUMENTED
              )
              VALUES
              (
                SEQ_POTENTIALINVFACMAP.nextval,
                NULL,
                SEQ_POTENTIALINVESTIGATOR.currval,
                P_PILIST(i).v_createdBy,
                sysdate,
                'N',
                'N',
                'N',
                'N',
                'N',
                'N',
                'N',
                'N',
                'N',
                'N',
                'Y',
                'statusCd1',
                'N'
              );
            --need to change facility and pi list variables
            V_PILISTOUT.Extend;
            V_PILISTOUT(V_PILISTOUT.COUNT) :=obj_potentialInv_list(P_PILIST(i).v_transcelerateUserId,P_PILIST(i).v_titleId,V_PIID,P_PILIST(i).v_contactid,P_PILIST(i).v_firstname,P_PILIST(i).v_lastname, P_PILIST(i).v_communicationDocumented,P_PILIST(i).v_createdBy,P_PILIST(i).v_createdDate,P_PILIST(i).v_modifiedBy,P_PILIST(i).v_modifiedDate,P_PILIST(i).v_facilityId,P_PILIST(i).v_isNotificationSend,P_PILIST(i).v_selectedForPreStudyEval,P_PILIST(i).v_siteFeasibilitySurveyReq, P_PILIST(i).v_invitationSend,P_PILIST(i).v_respondedToInvite,P_PILIST(i).v_accepted,P_PILIST(i).v_rejected,P_PILIST(i).v_disqualified,P_PILIST(i).v_selectedForStudy,P_PILIST(i).v_keyContact,P_PILIST(i).v_active,'statusCd1',P_PILIST(i).v_reason,P_PILIST(i).v_zscore,P_PILIST(i).v_email,P_PILIST(i).v_countrycd);

END IF;
ELSE
--Do nothing return same value update return values
V_PILISTOUT.Extend;
            V_PILISTOUT(V_PILISTOUT.COUNT) :=obj_potentialInv_list(P_PILIST(i).v_transcelerateUserId,P_PILIST(i).v_titleId,P_PILIST(i).v_potInvid,P_PILIST(i).v_contactid,P_PILIST(i).v_firstname,P_PILIST(i).v_lastname, P_PILIST(i).v_communicationDocumented,P_PILIST(i).v_createdBy,P_PILIST(i).v_createdDate,P_PILIST(i).v_modifiedBy,P_PILIST(i).v_modifiedDate,P_PILIST(i).v_facilityId,P_PILIST(i).v_isNotificationSend,P_PILIST(i).v_selectedForPreStudyEval,P_PILIST(i).v_siteFeasibilitySurveyReq, P_PILIST(i).v_invitationSend,P_PILIST(i).v_respondedToInvite,P_PILIST(i).v_accepted,P_PILIST(i).v_rejected,P_PILIST(i).v_disqualified,P_PILIST(i).v_selectedForStudy,P_PILIST(i).v_keyContact,P_PILIST(i).v_active,P_PILIST(i).v_statusCode,P_PILIST(i).v_reason,P_PILIST(i).v_zscore,P_PILIST(i).v_email,P_PILIST(i).v_countrycd);
END IF;
END LOOP;
END IF;
    OPEN CUR_PILISTOUT FOR SELECT * FROM TABLE
    (
      CAST (V_PILISTOUT AS typ_potentialInv_list)
    )
    ;
  END SP_POTENTIAL_INV;
/* Added on 9-May-16 */
PROCEDURE PROC_POPULATE_POTENTIALINV
    (
      TITLE_ARRAY   IN NUM_ARRAY ,
      V_NEW_TITLEID IN NUMBER,
      V_CREATEDBY   IN VARCHAR2,
      V_CREATEDDATE DATE,
      V_STATUS_FLAG OUT NUMBER,
      CUR_PILISTOUT OUT SYS_REFCURSOR
    )
  AS
    /* Variables */
   V_MSG           VARCHAR2(500);
  V_POTINV_FLAG   NUMBER(1);
  V_POTINVUSERID  NUMBER(38,0);
  V_NEW_ID        NUMBER(38,0);
  V_STATUSCDVAL   VARCHAR2(100);
  V_FACMAP_COUNT  NUMBER(38);
  V_POTINV_COUNT  NUMBER(38);
  V_SELECT_CLAUSE VARCHAR2(500);
  V_WHERE_CLAUSE  VARCHAR2(500);
  V_STUDYID NUMBER(38);
  V_PI_TITLE_CHECK NUMBER(38);
  V_POTINVUSERIDCOUNT NUMBER(38);
  V_PI_TITLE_FAC NUMBER(38);
  V_PI_TITLE_CONTACT NUMBER(38);
  V_RETURN_QUERY  VARCHAR2(32767);

  TYPE POTENTIALINVESTIGATOR_TYPE
IS
  RECORD
  (
    POTENTIALINVUSERID TBL_POTENTIALINVESTIGATOR.POTENTIALINVUSERID%TYPE ,
    TRANSCELERATEUSERID TBL_POTENTIALINVESTIGATOR.TRANSCELERATEUSERID%TYPE ,
    TITLEID TBL_POTENTIALINVESTIGATOR.TITLEID%TYPE ,
    CONTACTID TBL_POTENTIALINVESTIGATOR.CONTACTID%TYPE ,
    FIRSTNAME TBL_POTENTIALINVESTIGATOR.FIRSTNAME%TYPE ,
    LASTNAME TBL_POTENTIALINVESTIGATOR.LASTNAME%TYPE );
TYPE POTENTIALINVESTIGATOR_REC_TYPE
IS
  TABLE OF POTENTIALINVESTIGATOR_TYPE;
  POTENTIALINVESTIGATOR_REC POTENTIALINVESTIGATOR_REC_TYPE := POTENTIALINVESTIGATOR_REC_TYPE();
TYPE POTENTIALINVFACMAP_TYPE
IS
  RECORD
  (
    POTENTIALINVFACID TBL_POTENTIALINVFACMAP.POTENTIALINVFACID%TYPE ,
    FACILITYID TBL_POTENTIALINVFACMAP.FACILITYID%TYPE ,
    POTENTIALINVUSERID TBL_POTENTIALINVFACMAP.POTENTIALINVUSERID%TYPE ,
    ISACTIVE TBL_POTENTIALINVFACMAP.ISACTIVE%TYPE,
    STATUSCD TBL_POTENTIALINVFACMAP.STATUSCD%TYPE,
    ISCOMMDOCUMENTED TBL_POTENTIALINVESTIGATOR.ISCOMMDOCUMENTED%TYPE,
    ZSCORE TBL_POTENTIALINVFACMAP.ZSCORE%TYPE );
TYPE POTENTIALINVFACMAP_REC_TYPE
IS
  TABLE OF POTENTIALINVFACMAP_TYPE;
  POTENTIALINVFACMAP_REC POTENTIALINVFACMAP_REC_TYPE := POTENTIALINVFACMAP_REC_TYPE();
BEGIN
  SELECT CODENAME
  INTO V_STATUSCDVAL
  FROM TBL_CODE
  WHERE CODETABLE ='TBL_POTENTIALINVFACMAP'
  AND CODEFIELD   ='STATUSCD'
  AND CODEVALUE   ='Potential Investigator'
  AND ISACTIVE    ='Y';

 SELECT STUDYID INTO V_STUDYID FROM TBL_POTENTIALINVTITLES WHERE TITLEID=V_NEW_TITLEID;
  IF(TITLE_ARRAY IS NOT NULL) THEN
    FOR I IN 1 ..TITLE_ARRAY.COUNT
    LOOP
      DBMS_OUTPUT.PUT_LINE('I IS : '|| I);
      --Select PI records for title
      SELECT DISTINCT POTENTIALINVUSERID,
        TRANSCELERATEUSERID,
        TITLEID,
        CONTACTID,
        FIRSTNAME,
        LASTNAME BULK COLLECT
      INTO POTENTIALINVESTIGATOR_REC
      FROM
        (SELECT PI.POTENTIALINVUSERID,
          PI.TRANSCELERATEUSERID,
          PI.TITLEID,
          PI.CONTACTID,
          pkg_encrypt.fn_decrypt(PI.FIRSTNAME)AS FIRSTNAME,
          pkg_encrypt.fn_decrypt(PI.LASTNAME) AS LASTNAME
        FROM TBL_POTENTIALINVESTIGATOR PI
        WHERE PI.TITLEID  = TITLE_ARRAY(I)
        AND (PI.ISACTIVE IS NULL
        OR PI.ISACTIVE    = 'Y')
        );
      FOR J IN 1..POTENTIALINVESTIGATOR_REC.COUNT
      LOOP
        V_POTINV_FLAG  := 0;
        V_POTINVUSERID := 0;
    --    DBMS_OUTPUT.PUT_LINE('J IS : '|| J);
    --    DBMS_OUTPUT.PUT_LINE('TITILEID : ' || POTENTIALINVESTIGATOR_REC(J).TITLEID);
     --   DBMS_OUTPUT.PUT_LINE('POTENTIALINVUSERID : ' ||POTENTIALINVESTIGATOR_REC(J).POTENTIALINVUSERID);
        BEGIN
          IF(POTENTIALINVESTIGATOR_REC(J).TRANSCELERATEUSERID IS NOT NULL) THEN
          --Checking title id present in any titleid of the study -- V_PI_TITLE_CHECK
             SELECT COUNT(FMAP.POTENTIALINVUSERID) INTO V_PI_TITLE_CHECK from TBL_POTENTIALINVFACMAP FMAP
              JOIN TBL_POTENTIALINVESTIGATOR PI ON PI.POTENTIALINVUSERID=FMAP.POTENTIALINVUSERID
              JOIN TBL_POTENTIALINVTITLES PT ON PT.TITLEID = PI.TITLEID
              WHERE PT.STUDYID =V_STUDYID
              AND FMAP.ISACTIVE ='Y'
              AND PI.TRANSCELERATEUSERID=POTENTIALINVESTIGATOR_REC(J).TRANSCELERATEUSERID;
       IF (V_PI_TITLE_CHECK =0) THEN

          V_NEW_ID      := SEQ_POTENTIALINVESTIGATOR.NEXTVAL;
        INSERT
          INTO TBL_POTENTIALINVESTIGATOR
            (
              POTENTIALINVUSERID,
              TRANSCELERATEUSERID,
              TITLEID,
              CONTACTID,
              FIRSTNAME,
              LASTNAME,
              ISNOTIFICATIONSEND,
              ISSELECTEDFORPRESTUDYEVAL,
              ISCOMMDOCUMENTED,
              COMMUNICATION,
              ISSITEFEASIBILITYSURVEYREQ,
              ISINVITATIONSEND,
              HASRESPONDEDTOINVITE,
              ISACCEPTED,
              ISREJECTED,
              ISDISQUALIFIED,
              ISSELECTEDFORSTUDY,
              REASON,
              ZSCORE,
              STATUSCD,
              ISKEYCONTACT,
              ISACTIVE,
              CREATEDBY,
              CREATEDDT,
              MODIFIEDBY,
              MODIFIEDDT,
              COMMDT
            )
            VALUES
            (
              V_NEW_ID,
              POTENTIALINVESTIGATOR_REC(J).TRANSCELERATEUSERID,
              V_NEW_TITLEID,
              POTENTIALINVESTIGATOR_REC(J).CONTACTID,
              POTENTIALINVESTIGATOR_REC(J).FIRSTNAME,
              POTENTIALINVESTIGATOR_REC(J).LASTNAME,
              NULL, -- ISNOTIFICATIONSEND,
              NULL, --ISSELECTEDFORPRESTUDYEVAL,
              NULL, --ISCOMMDOCUMENTED,
              NULL, --COMMUNICATION,
              NULL, --ISSITEFEASIBILITYSURVEYREQ,
              NULL, --ISINVITATIONSEND,
              NULL, --HASRESPONDEDTOINVITE,
              NULL, --ISACCEPTED,
              NULL, --ISREJECTED,
              NULL, --ISDISQUALIFIED,
              NULL, --ISSELECTEDFORSTUDY,
              NULL, --REASON,
              NULL, --ZSCORE
              NULL, --STATUSCD,
              NULL, --ISKEYCONTACT,
              'Y',  --ISACTIVE,
              V_CREATEDBY,
              SYSDATE,
              NULL, --MODIFIEDBY,
              NULL, --MODIFIEDDT
              NULL  --COMMDT
            );

          ELSE
          --Check present in new List
          SELECT COUNT(POTENTIALINVUSERID)
            INTO V_POTINVUSERIDCOUNT
            FROM TBL_POTENTIALINVESTIGATOR
            WHERE TRANSCELERATEUSERID = POTENTIALINVESTIGATOR_REC(J).TRANSCELERATEUSERID
            AND TITLEID               = V_NEW_TITLEID
            AND (ISACTIVE            IS NULL
            OR ISACTIVE               = 'Y');

        IF (V_POTINVUSERIDCOUNT >0) THEN

            SELECT POTENTIALINVUSERID
            INTO V_POTINVUSERID
            FROM TBL_POTENTIALINVESTIGATOR
            WHERE TRANSCELERATEUSERID = POTENTIALINVESTIGATOR_REC(J).TRANSCELERATEUSERID
            AND TITLEID               = V_NEW_TITLEID
            AND (ISACTIVE            IS NULL
            OR ISACTIVE               = 'Y');

           V_NEW_ID :=V_POTINVUSERID;

           END IF;
           END IF;
     ---Selecting potential fac map for all the investigators
    SELECT POTENTIALINVFACID,
            FACILITYID,
            POTENTIALINVUSERID,
            ISACTIVE,
            STATUSCD,
            ISCOMMDOCUMENTED,
            ZSCORE BULK COLLECT
          INTO POTENTIALINVFACMAP_REC
          FROM
            (SELECT POTENTIALINVFACID,
              FACILITYID,
              POTENTIALINVUSERID,
              ISACTIVE,
              STATUSCD,
              ISCOMMDOCUMENTED,
              ZSCORE
            FROM TBL_POTENTIALINVFACMAP
            WHERE UPPER(ISACTIVE)  = 'Y'
            AND POTENTIALINVUSERID = POTENTIALINVESTIGATOR_REC(J).POTENTIALINVUSERID
            );
    FOR K IN 1..POTENTIALINVFACMAP_REC.COUNT
  LOOP

 IF(V_PI_TITLE_CHECK =0) THEN
          ---entering data into potential facility map need to check facility is null or not
          INSERT
          INTO TBL_POTENTIALINVFACMAP
            (
              POTENTIALINVFACID,
              FACILITYID,
              POTENTIALINVUSERID,
              CREATEDBY ,
              CREATEDDT ,
              MODIFIEDBY ,
              MODIFIEDDT ,
              ISNOTIFICATIONSEND ,
              ISSELECTEDFORPRESTUDYEVAL ,
              ISSITEFEASIBILITYSURVEYREQ ,
              ISINVITATIONSEND ,
              HASRESPONDEDTOINVITE ,
              ISACCEPTED ,
              ISREJECTED ,
              ISDISQUALIFIED ,
              ISSELECTEDFORSTUDY ,
              ISKEYCONTACT ,
              ISACTIVE ,
              STATUSCD ,
              ZSCORE ,
              REASON,
              ISCOMMDOCUMENTED
            )
            VALUES
            (
              SEQ_POTENTIALINVFACMAP.NEXTVAL,
              POTENTIALINVFACMAP_REC(K).FACILITYID,
              V_NEW_ID,
              V_CREATEDBY,
              SYSDATE ,
              '' ,           --MODIFIEDBY
              '' ,           --MODIFIEDDT
              NULL ,         --ISNOTIFICATIONSEND
              NULL ,         --ISSELECTEDFORPRESTUDYEVAL
              NULL ,         --ISSITEFEASIBILITYSURVEYREQ
              NULL ,         --ISINVITATIONSEND
              NULL ,         --HASRESPONDEDTOINVITE
              NULL ,         --ISACCEPTED
              NULL ,         --ISREJECTED
              NULL ,         --ISDISQUALIFIED
              NULL ,         --ISSELECTEDFORSTUDY
              NULL ,         --ISKEYCONTACT
              'Y',           --ISACTIVE
              V_STATUSCDVAL, --STATUSCD
              NULL,          --ZSCORE
              NULL,          --REASON
              'N'            --ISCOMMDOCUMENTED
            );
   END IF;

   --Checking if user and facility combination is present in any list of study
 SELECT COUNT(FMAP.POTENTIALINVUSERID) INTO V_PI_TITLE_FAC from TBL_POTENTIALINVFACMAP FMAP
              JOIN TBL_POTENTIALINVESTIGATOR PI ON PI.POTENTIALINVUSERID=FMAP.POTENTIALINVUSERID
              JOIN TBL_POTENTIALINVTITLES PT ON PT.TITLEID = PI.TITLEID
              WHERE PT.STUDYID =V_STUDYID
              AND FMAP.ISACTIVE ='Y'
              AND PI.TRANSCELERATEUSERID=POTENTIALINVESTIGATOR_REC(J).TRANSCELERATEUSERID
              AND (FMAP.FACILITYID=POTENTIALINVFACMAP_REC(K).FACILITYID OR FMAP.FACILITYID is null);

 IF (V_PI_TITLE_CHECK !=0 AND V_POTINVUSERIDCOUNT !=0 AND V_PI_TITLE_FAC =0) THEN
   --Inside this means present in current list
  --inside this means this facility and user combination not present in any title
    INSERT
          INTO TBL_POTENTIALINVFACMAP
            (
              POTENTIALINVFACID,
              FACILITYID,
              POTENTIALINVUSERID,
              CREATEDBY ,
              CREATEDDT ,
              MODIFIEDBY ,
              MODIFIEDDT ,
              ISNOTIFICATIONSEND ,
              ISSELECTEDFORPRESTUDYEVAL ,
              ISSITEFEASIBILITYSURVEYREQ ,
              ISINVITATIONSEND ,
              HASRESPONDEDTOINVITE ,
              ISACCEPTED ,
              ISREJECTED ,
              ISDISQUALIFIED ,
              ISSELECTEDFORSTUDY ,
              ISKEYCONTACT ,
              ISACTIVE ,
              STATUSCD ,
              ZSCORE ,
              REASON,
              ISCOMMDOCUMENTED
            )
            VALUES
            (
              SEQ_POTENTIALINVFACMAP.NEXTVAL,
              POTENTIALINVFACMAP_REC(K).FACILITYID,
              V_NEW_ID,
              V_CREATEDBY,
              SYSDATE ,
              '' ,           --MODIFIEDBY
              '' ,           --MODIFIEDDT
              NULL ,         --ISNOTIFICATIONSEND
              NULL ,         --ISSELECTEDFORPRESTUDYEVAL
              NULL ,         --ISSITEFEASIBILITYSURVEYREQ
              NULL ,         --ISINVITATIONSEND
              NULL ,         --HASRESPONDEDTOINVITE
              NULL ,         --ISACCEPTED
              NULL ,         --ISREJECTED
              NULL ,         --ISDISQUALIFIED
              NULL ,         --ISSELECTEDFORSTUDY
              NULL ,         --ISKEYCONTACT
              'Y',           --ISACTIVE
              V_STATUSCDVAL, --STATUSCD
              NULL,          --ZSCORE
              NULL,          --REASON
              'N'            --ISCOMMDOCUMENTED
            );

 ELSIF(V_POTINVUSERIDCOUNT=0 AND V_PI_TITLE_CHECK !=0 AND V_PI_TITLE_FAC =0) THEN
     -- Inside this means not present in current list and facility and user combination not present in any title
   V_NEW_ID      := SEQ_POTENTIALINVESTIGATOR.NEXTVAL;
        INSERT
          INTO TBL_POTENTIALINVESTIGATOR
            (
              POTENTIALINVUSERID,
              TRANSCELERATEUSERID,
              TITLEID,
              CONTACTID,
              FIRSTNAME,
              LASTNAME,
              ISNOTIFICATIONSEND,
              ISSELECTEDFORPRESTUDYEVAL,
              ISCOMMDOCUMENTED,
              COMMUNICATION,
              ISSITEFEASIBILITYSURVEYREQ,
              ISINVITATIONSEND,
              HASRESPONDEDTOINVITE,
              ISACCEPTED,
              ISREJECTED,
              ISDISQUALIFIED,
              ISSELECTEDFORSTUDY,
              REASON,
              ZSCORE,
              STATUSCD,
              ISKEYCONTACT,
              ISACTIVE,
              CREATEDBY,
              CREATEDDT,
              MODIFIEDBY,
              MODIFIEDDT,
              COMMDT
            )
            VALUES
            (
              V_NEW_ID,
              POTENTIALINVESTIGATOR_REC(J).TRANSCELERATEUSERID,
              V_NEW_TITLEID,
              POTENTIALINVESTIGATOR_REC(J).CONTACTID,
              POTENTIALINVESTIGATOR_REC(J).FIRSTNAME,
              POTENTIALINVESTIGATOR_REC(J).LASTNAME,
              NULL, -- ISNOTIFICATIONSEND,
              NULL, --ISSELECTEDFORPRESTUDYEVAL,
              NULL, --ISCOMMDOCUMENTED,
              NULL, --COMMUNICATION,
              NULL, --ISSITEFEASIBILITYSURVEYREQ,
              NULL, --ISINVITATIONSEND,
              NULL, --HASRESPONDEDTOINVITE,
              NULL, --ISACCEPTED,
              NULL, --ISREJECTED,
              NULL, --ISDISQUALIFIED,
              NULL, --ISSELECTEDFORSTUDY,
              NULL, --REASON,
              NULL, --ZSCORE
              NULL, --STATUSCD,
              NULL, --ISKEYCONTACT,
              'Y',  --ISACTIVE,
              V_CREATEDBY,
              SYSDATE,
              NULL, --MODIFIEDBY,
              NULL, --MODIFIEDDT
              NULL  --COMMDT
            );

 INSERT
          INTO TBL_POTENTIALINVFACMAP
            (
              POTENTIALINVFACID,
              FACILITYID,
              POTENTIALINVUSERID,
              CREATEDBY ,
              CREATEDDT ,
              MODIFIEDBY ,
              MODIFIEDDT ,
              ISNOTIFICATIONSEND ,
              ISSELECTEDFORPRESTUDYEVAL ,
              ISSITEFEASIBILITYSURVEYREQ ,
              ISINVITATIONSEND ,
              HASRESPONDEDTOINVITE ,
              ISACCEPTED ,
              ISREJECTED ,
              ISDISQUALIFIED ,
              ISSELECTEDFORSTUDY ,
              ISKEYCONTACT ,
              ISACTIVE ,
              STATUSCD ,
              ZSCORE ,
              REASON,
              ISCOMMDOCUMENTED
            )
            VALUES
            (
              SEQ_POTENTIALINVFACMAP.NEXTVAL,
              POTENTIALINVFACMAP_REC(K).FACILITYID,
              V_NEW_ID,
              V_CREATEDBY,
              SYSDATE ,
              '' ,           --MODIFIEDBY
              '' ,           --MODIFIEDDT
              NULL ,         --ISNOTIFICATIONSEND
              NULL ,         --ISSELECTEDFORPRESTUDYEVAL
              NULL ,         --ISSITEFEASIBILITYSURVEYREQ
              NULL ,         --ISINVITATIONSEND
              NULL ,         --HASRESPONDEDTOINVITE
              NULL ,         --ISACCEPTED
              NULL ,         --ISREJECTED
              NULL ,         --ISDISQUALIFIED
              NULL ,         --ISSELECTEDFORSTUDY
              NULL ,         --ISKEYCONTACT
              'Y',           --ISACTIVE
              V_STATUSCDVAL, --STATUSCD
              NULL,          --ZSCORE
              NULL,          --REASON
              'N'            --ISCOMMDOCUMENTED
            );

 END IF;
END LOOP;
ELSE
SELECT COUNT(FMAP.POTENTIALINVUSERID) INTO V_PI_TITLE_CONTACT from TBL_POTENTIALINVFACMAP FMAP
              JOIN TBL_POTENTIALINVESTIGATOR PI ON PI.POTENTIALINVUSERID=FMAP.POTENTIALINVUSERID
              JOIN TBL_POTENTIALINVTITLES PT ON PT.TITLEID = PI.TITLEID
              WHERE PT.STUDYID =V_STUDYID
              AND FMAP.ISACTIVE ='Y'
              AND PI.CONTACTID=POTENTIALINVESTIGATOR_REC(J).CONTACTID;
IF (V_PI_TITLE_CONTACT =0) THEN

   V_NEW_ID      := SEQ_POTENTIALINVESTIGATOR.NEXTVAL;
        INSERT
          INTO TBL_POTENTIALINVESTIGATOR
            (
              POTENTIALINVUSERID,
              TRANSCELERATEUSERID,
              TITLEID,
              CONTACTID,
              FIRSTNAME,
              LASTNAME,
              ISNOTIFICATIONSEND,
              ISSELECTEDFORPRESTUDYEVAL,
              ISCOMMDOCUMENTED,
              COMMUNICATION,
              ISSITEFEASIBILITYSURVEYREQ,
              ISINVITATIONSEND,
              HASRESPONDEDTOINVITE,
              ISACCEPTED,
              ISREJECTED,
              ISDISQUALIFIED,
              ISSELECTEDFORSTUDY,
              REASON,
              ZSCORE,
              STATUSCD,
              ISKEYCONTACT,
              ISACTIVE,
              CREATEDBY,
              CREATEDDT,
              MODIFIEDBY,
              MODIFIEDDT,
              COMMDT
            )
            VALUES
            (
              V_NEW_ID,
              POTENTIALINVESTIGATOR_REC(J).TRANSCELERATEUSERID,
              V_NEW_TITLEID,
              POTENTIALINVESTIGATOR_REC(J).CONTACTID,
              POTENTIALINVESTIGATOR_REC(J).FIRSTNAME,
              POTENTIALINVESTIGATOR_REC(J).LASTNAME,
              NULL, -- ISNOTIFICATIONSEND,
              NULL, --ISSELECTEDFORPRESTUDYEVAL,
              NULL, --ISCOMMDOCUMENTED,
              NULL, --COMMUNICATION,
              NULL, --ISSITEFEASIBILITYSURVEYREQ,
              NULL, --ISINVITATIONSEND,
              NULL, --HASRESPONDEDTOINVITE,
              NULL, --ISACCEPTED,
              NULL, --ISREJECTED,
              NULL, --ISDISQUALIFIED,
              NULL, --ISSELECTEDFORSTUDY,
              NULL, --REASON,
              NULL, --ZSCORE
              NULL, --STATUSCD,
              NULL, --ISKEYCONTACT,
              'Y',  --ISACTIVE,
              V_CREATEDBY,
              SYSDATE,
              NULL, --MODIFIEDBY,
              NULL, --MODIFIEDDT
              NULL  --COMMDT
            );

 INSERT
          INTO TBL_POTENTIALINVFACMAP
            (
              POTENTIALINVFACID,
              FACILITYID,
              POTENTIALINVUSERID,
              CREATEDBY ,
              CREATEDDT ,
              MODIFIEDBY ,
              MODIFIEDDT ,
              ISNOTIFICATIONSEND ,
              ISSELECTEDFORPRESTUDYEVAL ,
              ISSITEFEASIBILITYSURVEYREQ ,
              ISINVITATIONSEND ,
              HASRESPONDEDTOINVITE ,
              ISACCEPTED ,
              ISREJECTED ,
              ISDISQUALIFIED ,
              ISSELECTEDFORSTUDY ,
              ISKEYCONTACT ,
              ISACTIVE ,
              STATUSCD ,
              ZSCORE ,
              REASON,
              ISCOMMDOCUMENTED
            )
            VALUES
            (
              SEQ_POTENTIALINVFACMAP.NEXTVAL,
              NULL,
              V_NEW_ID,
              V_CREATEDBY,
              SYSDATE ,
              '' ,           --MODIFIEDBY
              '' ,           --MODIFIEDDT
              NULL ,         --ISNOTIFICATIONSEND
              NULL ,         --ISSELECTEDFORPRESTUDYEVAL
              NULL ,         --ISSITEFEASIBILITYSURVEYREQ
              NULL ,         --ISINVITATIONSEND
              NULL ,         --HASRESPONDEDTOINVITE
              NULL ,         --ISACCEPTED
              NULL ,         --ISREJECTED
              NULL ,         --ISDISQUALIFIED
              NULL ,         --ISSELECTEDFORSTUDY
              NULL ,         --ISKEYCONTACT
              'Y',           --ISACTIVE
              V_STATUSCDVAL, --STATUSCD
              NULL,          --ZSCORE
              NULL,          --REASON
              'N'            --ISCOMMDOCUMENTED
            );
END IF;
END IF;
END;
END LOOP;
END LOOP;
END IF;
COMMIT;
V_STATUS_FLAG := 0 ;
V_RETURN_QUERY :=   ' SELECT DISTINCT CASE WHEN CODE.CODEVALUE IS NOT NULL THEN CODE.CODEVALUE ELSE CODE1.CODEVALUE END AS STATUS, POTINV.TRANSCELERATEUSERID TRANSCELERATEUSERID, CASE WHEN POTINV.TRANSCELERATEUSERID IS NULL THEN pkg_encrypt.fn_decrypt(POTINV.FIRSTNAME)
                          ELSE  CASE WHEN USR.MIDDLENAME is NULL THEN  pkg_encrypt.fn_decrypt(USR.FIRSTNAME)  ELSE pkg_encrypt.fn_decrypt(USR.FIRSTNAME) || '' '' || pkg_encrypt.fn_decrypt(USR.MIDDLENAME) END   END AS FIRSTNAME, CASE WHEN POTINV.TRANSCELERATEUSERID IS NULL
                                THEN pkg_encrypt.fn_decrypt(POTINV.LASTNAME) ELSE pkg_encrypt.fn_decrypt(USR.LASTNAME) END AS LASTNAME, FAC.FACILITYID,
                                CASE WHEN FAC.ISDEPARTMENT = ''Y'' THEN (select FACILITYNAME from TBL_FACILITIES where FACILITYID = FAC.FACILITYFORDEPT)
                          ELSE FAC.FACILITYNAME END AS FACILITYNAME, COUNTRY.COUNTRYNAME COUNTRYNAME, FACMAP.ZSCORE REFCODE, FACMAP.MODIFIEDDT MODIFIEDDT, POTINV.POTENTIALINVUSERID, FACMAP.ISCOMMDOCUMENTED ISCOMMDOCUMENTED, FACMAP.REASON REASON,USR.USERID, SITE.SITEID SITEID,
                                SITE.SITENAME SITENAME, FACMAP.POTENTIALINVFACID, pkg_encrypt.fn_decrypt(CONT.EMAIL) EMAIL, FAC.ISDEPARTMENT, FAC.DEPARTMENTNAME,
                                DEPTTYPE.DEPARTMENTTYPENAME, FAC.FACILITYFORDEPT, pkg_encrypt.fn_decrypt(CONT.PHONE1) PHONE1,
                                POTINV.CREATEDBY,FACMAP.PRESELECTSITENAME,pkg_encrypt.fn_decrypt(UPPER(MIDDLENAME)),
                                COUNTRY1.COUNTRYNAME FACILITYCOUNTRYNAME,FASTATE.STATENAME,  REGI.PILISTID REGINVITEFLAG
                                FROM TBL_POTENTIALINVESTIGATOR POTINV LEFT JOIN TBL_POTENTIALINVTITLES POTINVTITLE ON POTINVTITLE.TITLEID = POTINV.TITLEID
                                LEFT JOIN TBL_POTENTIALINVFACMAP FACMAP ON POTINV.POTENTIALINVUSERID = FACMAP.POTENTIALINVUSERID
                                LEFT JOIN TBL_FACILITIES FAC ON FACMAP.FACILITYID = FAC.FACILITYID LEFT JOIN TBL_DEPARTMENTTYPE DEPTTYPE ON
                                DEPTTYPE.DEPARTMENTTYPEID = FAC.DEPARTMENTTYPEID LEFT JOIN TBL_USERPROFILES USR ON POTINV.TRANSCELERATEUSERID = USR.TRANSCELERATEUSERID
                                LEFT JOIN TBL_CONTACT CONT ON (POTINV.CONTACTID = CONT.CONTACTID) LEFT JOIN TBL_COUNTRIES COUNTRY
                                ON (CONT.COUNTRYCD = COUNTRY.COUNTRYCD)
                                LEFT JOIN TBL_CONTACT FACCONT ON (FAC.CONTACTID = FACCONT.CONTACTID)LEFT JOIN TBL_COUNTRIES COUNTRY1
                                ON (FACCONT.COUNTRYCD = COUNTRY1.COUNTRYCD) LEFT JOIN TBL_REGISTRATIONINVITE REGI
                                ON POTINV.TITLEID  = REGI.PILISTID
                                AND UPPER(pkg_encrypt.FN_DECRYPT(CONT.EMAIL)) = UPPER(pkg_encrypt.FN_DECRYPT(REGI.RECIEPIENTEMAIL)) LEFT JOIN TBL_STATES FASTATE ON (FACCONT.STATE = FASTATE.STATECD)
                                LEFT JOIN TBL_CODE CODE ON FACMAP.STATUSCD = CODE.CODENAME LEFT JOIN TBL_CODE CODE1
                                ON POTINV.STATUSCD = CODE1.CODENAME LEFT JOIN TBL_SITE SITE ON SITE.PRINCIPALFACILITYID = FACMAP.FACILITYID
                                AND USR.USERID = SITE.PIID AND SITE.STUDYID = POTINVTITLE.STUDYID  WHERE (POTINVTITLE.ISACTIVE = ''Y'' OR POTINVTITLE.ISACTIVE IS NULL)
                                AND (FAC.ISACTIVE = ''Y'' OR FAC.ISACTIVE IS NULL) AND (CODE.ISACTIVE = ''Y'' OR CODE.ISACTIVE IS NULL) AND  (USR.ISACTIVE = ''Y'' OR USR.ISACTIVE IS NULL)
                                AND (CONT.ISACTIVE = ''Y'' OR CONT.ISACTIVE IS NULL) AND (FACMAP.ISACTIVE = ''Y'' OR FACMAP.ISACTIVE IS NULL) AND (SITE.ISACTIVE = ''Y'' OR SITE.ISACTIVE IS NULL)
                                AND POTINVTITLE.TITLEID ='|| V_NEW_TITLEID;

OPEN CUR_PILISTOUT FOR V_RETURN_QUERY;
EXCEPTION
  /*when no data found then log exception*/
WHEN NO_DATA_FOUND THEN
  V_MSG := 'NO DATA FOUND';
  DBMS_OUTPUT.PUT_LINE(V_MSG);
  V_STATUS_FLAG := -1 ;
  ROLLBACK;
  RETURN;
  /*if Primary key violation then log exception*/
WHEN DUP_VAL_ON_INDEX THEN
  V_MSG := SQLERRM;
  DBMS_OUTPUT.PUT_LINE(V_MSG);
  V_STATUS_FLAG := -1 ;
  ROLLBACK;
  RETURN;
  /*if other exception then log exception*/
WHEN OTHERS THEN
  V_MSG := SQLERRM;
  DBMS_OUTPUT.PUT_LINE(V_MSG);
  V_STATUS_FLAG := -1 ;
  ROLLBACK;
  RETURN;
END PROC_POPULATE_POTENTIALINV;

FUNCTION FN_SEND_PI_TASK(
    P_USERID IN VARCHAR2, P_TITLE IN VARCHAR2 )
  RETURN INTEGER
IS
  V_STATUS INTEGER;
  V_TASK TBL_TASK%ROWTYPE;
  V_USERID INTEGER;
  V_FIRSTNAME VARCHAR2(32000 char);
  V_LASTNAME VARCHAR2(32000 char);
  V_TRANSID VARCHAR2(32000 char);
  
  V_STUDYNAME VARCHAR2(32000 char);
  CURSOR CUR_FACTASK_REQ
  IS
    SELECT TASKID,
      USERID,
      TASKTYPECODE,
      DESCRIPTION,
      CATEGORYCODE,
      STARTDATE,
      DUEDATE,
      PRIORITY,
      STATUSCODE,
      ASSIGNTO,
      OWNERID,
      OWNERTYPE,
      STUDYID,
      SITEID,
      ISDELETED,
      CREATEDDT,
      CREATEDBY,
      MODIFIEDDT,
      MODIFIEDBY,
      COMPLETIONDATE,
      TASKCD,
      FACILITYID,
      DOCEXTASKID,
      VEEVATASKID,
      TASKTYPEID,
      REASON,
      COMMENTS,
      TASKDATA
    FROM TBL_TASK
    WHERE CATEGORYCODE LIKE 'associate_facility_request'
    AND ASSIGNTO= P_USERID;
BEGIN
  V_STATUS :=1;
  OPEN CUR_FACTASK_REQ;
  LOOP
    FETCH CUR_FACTASK_REQ INTO V_TASK ;
    EXIT
  WHEN CUR_FACTASK_REQ%NOTFOUND;
    SELECT USERID, PKG_ENCRYPT.FN_DECRYPT(FIRSTNAME), PKG_ENCRYPT.FN_DECRYPT(LASTNAME)
    INTO V_USERID, V_FIRSTNAME, V_LASTNAME
    FROM tbl_userprofiles
    WHERE TRANSCELERATEUSERID =V_TASK.ASSIGNTO;
    
    SELECT TRANSCELERATEUSERID
    INTO V_TRANSID
    FROM tbl_userprofiles
    WHERE USERID =V_TASK.USERID;
    
    SELECT STUDYNAME
    INTO V_STUDYNAME
    FROM TBL_STUDY
    WHERE STUDYID =V_TASK.STUDYID;
    
    INSERT
    INTO TBL_TASK
      (
        TASKID,
        USERID,
        TASKTYPECODE,
        DESCRIPTION,
        CATEGORYCODE,
        STARTDATE,
        DUEDATE,
        PRIORITY,
        STATUSCODE,
        ASSIGNTO,
        OWNERID,
        OWNERTYPE,
        TASKDATA,
        STUDYID,
        ISDELETED,
        CREATEDDT,
        CREATEDBY,
        TASKTYPEID,
        REASON,
        COMMENTS
      )
      VALUES
      (
        SEQ_TASK.nextval,
        V_USERID,
        'GLOBAL',
        V_FIRSTNAME || ' ' || V_LASTNAME || ' has added a facility to their User Profile in Shared Investigator Platform (SIP). Please review the Investigator and Facility/Department combinations for this user that have been added to the potential investigator list ' || P_TITLE || ' for '  ||   V_STUDYNAME, 
        'associate_facility_PiList',
        sysdate,
        sysdate+7,
        1,
        'Pending',
        V_TRANSID,
        0,
        V_TASK.OWNERTYPE,
        V_TASK.TASKDATA,
        V_TASK.STUDYID,
        V_TASK.ISDELETED,
        sysdate,
        V_TRANSID,
        V_TASK.TASKTYPEID,
        V_TASK.REASON,
        V_TASK.COMMENTS
      );
  END LOOP;
  CLOSE CUR_FACTASK_REQ;
  COMMIT;
  RETURN V_STATUS;
END FN_SEND_PI_TASK;
PROCEDURE PROC_POPULATE_POTINVFACMAP
  (
    V_STATUS_FLAG OUT NUMBER
  )
AS
  V_TRANSID VARCHAR2
  (
    200
  )
  ;
  V_FACMAP_COUNT      NUMBER (38);
  V_STATUSCDVAL       VARCHAR2(100);
  V_MSG               VARCHAR2(500);
  V_USERID            INTEGER;
  V_TASK_STATUS       INTEGER;
  V_FACMAP_COUNT_TASK NUMBER(38);
  V_FACMAP_NULL       NUMBER (38);
  V_POT_DEL           NUMBER (38);
  V_FACMAP_COUNT_STATUS      NUMBER (38);
  V_STATUSPRESEL      VARCHAR2(100);
  V_STATUSPREIN       VARCHAR2(100);
  V_STATUSPREDEC      VARCHAR2(100);
  V_STATUSSTDIN       VARCHAR2(100);
  V_STATUSSTDDEC      VARCHAR2(100);
  V_FACMAP_COUNT_ALLSTATUS NUMBER(38);
  V_FACMAP_ALLCOUNT   NUMBER(38);
  V_FACMAP_COUNT_TOTAL NUMBER(38);
  V_TITLENAME VARCHAR2(32000 char);
  -- This cursor is to fetch users whom facility association record is created in table TBL_FACASSOCIATION_REQ and having ISPROCESSED AS 'N'
  CURSOR CUR_FACASSOCIATION_REQ
  IS
    SELECT ASSREQID,
      SITEUSERID,
      FACILITYID,
      ISACTIVE,
      CREATEDBY
    FROM TBL_FACASSOCIATION_REQ
    WHERE ISPROCESSED IS NULL
    OR ISPROCESSED     = 'N' ORDER BY ASSREQID ASC;
TYPE POTENTIALINVESTIGATOR_TYPE
IS
  RECORD
  (
    POTENTIALINVUSERID TBL_POTENTIALINVESTIGATOR.POTENTIALINVUSERID%TYPE ,
    TRANSCELERATEUSERID TBL_POTENTIALINVESTIGATOR.TRANSCELERATEUSERID%TYPE ,
    TITLEID TBL_POTENTIALINVESTIGATOR.TITLEID%TYPE ,
    CONTACTID TBL_POTENTIALINVESTIGATOR.CONTACTID%TYPE ,
    FIRSTNAME TBL_POTENTIALINVESTIGATOR.FIRSTNAME%TYPE ,
    CREATEDBY TBL_POTENTIALINVESTIGATOR.CREATEDBY%TYPE ,
    MODIFIEDBY TBL_POTENTIALINVESTIGATOR.MODIFIEDBY%TYPE ,
    LASTNAME TBL_POTENTIALINVESTIGATOR.LASTNAME%TYPE );
TYPE TYP_FACASSOCIATION_REQ_UPD
IS
  TABLE OF CUR_FACASSOCIATION_REQ%ROWTYPE;
  V_FACASSOCIATION_REQ_UPD TYP_FACASSOCIATION_REQ_UPD;
TYPE POTENTIALINVESTIGATOR_REC_TYPE
IS
  TABLE OF POTENTIALINVESTIGATOR_TYPE;
  POTENTIALINVESTIGATOR_REC POTENTIALINVESTIGATOR_REC_TYPE := POTENTIALINVESTIGATOR_REC_TYPE();
BEGIN
  SELECT CODENAME
  INTO V_STATUSCDVAL
  FROM TBL_CODE
  WHERE CODETABLE='TBL_POTENTIALINVFACMAP'
  AND CODEFIELD  ='STATUSCD'
  AND CODEVALUE  ='Potential Investigator'
  AND ISACTIVE   ='Y';
  V_USERID      :=0;

  SELECT CODENAME
  INTO V_STATUSPRESEL
  FROM TBL_CODE
  WHERE CODETABLE='TBL_POTENTIALINVFACMAP'
  AND CODEFIELD  ='STATUSCD'
  AND CODEVALUE  ='Selected for Pre-Study'
  AND ISACTIVE   ='Y';

  SELECT CODENAME
  INTO V_STATUSPREIN
  FROM TBL_CODE
  WHERE CODETABLE='TBL_POTENTIALINVFACMAP'
  AND CODEFIELD  ='STATUSCD'
  AND CODEVALUE  ='Pre-Study Invitation Sent'
  AND ISACTIVE   ='Y';

  SELECT CODENAME
  INTO V_STATUSPREDEC
  FROM TBL_CODE
  WHERE CODETABLE='TBL_POTENTIALINVFACMAP'
  AND CODEFIELD  ='STATUSCD'
  AND CODEVALUE  ='Pre-Study Invitation Declined'
  AND ISACTIVE   ='Y';

  SELECT CODENAME
  INTO V_STATUSSTDIN
  FROM TBL_CODE
  WHERE CODETABLE='TBL_POTENTIALINVFACMAP'
  AND CODEFIELD  ='STATUSCD'
  AND CODEVALUE  ='Selected for Study - Invitation Sent'
  AND ISACTIVE   ='Y';

  SELECT CODENAME
  INTO V_STATUSSTDDEC
  FROM TBL_CODE
  WHERE CODETABLE='TBL_POTENTIALINVFACMAP'
  AND CODEFIELD  ='STATUSCD'
  AND CODEVALUE  ='Declined Study Participation'
  AND ISACTIVE   ='Y';
  
  OPEN CUR_FACASSOCIATION_REQ;
  LOOP
    FETCH CUR_FACASSOCIATION_REQ BULK COLLECT
    INTO V_FACASSOCIATION_REQ_UPD LIMIT 1000;
    EXIT
  WHEN V_FACASSOCIATION_REQ_UPD.COUNT = 0;
    BEGIN
      FOR I IN V_FACASSOCIATION_REQ_UPD.FIRST..V_FACASSOCIATION_REQ_UPD.LAST
      LOOP
       -- DBMS_OUTPUT.PUT_LINE('USER ID : ' || V_FACASSOCIATION_REQ_UPD(I).SITEUSERID);
        SELECT TRANSCELERATEUSERID
        INTO V_TRANSID
        FROM TBL_USERPROFILES
        WHERE USERID = V_FACASSOCIATION_REQ_UPD(I).SITEUSERID;
       -- DBMS_OUTPUT.PUT_LINE('TRANSCELERATE ID : ' || V_TRANSID);
        SELECT DISTINCT POTENTIALINVUSERID,
          TRANSCELERATEUSERID,
          TITLEID,
          CONTACTID,
          FIRSTNAME,
          CREATEDBY,
          MODIFIEDBY,
          LASTNAME BULK COLLECT
        INTO POTENTIALINVESTIGATOR_REC
        FROM
          (SELECT PI.POTENTIALINVUSERID,
            PI.TRANSCELERATEUSERID,
            PI.TITLEID,
            PI.CONTACTID,
            pkg_encrypt.fn_decrypt (PI.FIRSTNAME) AS FIRSTNAME,
            PI.CREATEDBY,
            PI.MODIFIEDBY,
            pkg_encrypt.fn_decrypt(PI.LASTNAME) AS LASTNAME
          FROM TBL_POTENTIALINVESTIGATOR PI,TBL_POTENTIALINVTITLES TITLES, TBL_STUDY STUDY
          WHERE PI.TRANSCELERATEUSERID = V_TRANSID
          AND (PI.ISACTIVE            IS NULL
          OR PI.ISACTIVE               = 'Y')
		  AND TITLES.TITLEID = PI.TITLEID
          AND TITLES.STUDYID = STUDY.STUDYID
          AND STUDY.ISACTIVE = 'Y'
          );
        FOR J IN 1..POTENTIALINVESTIGATOR_REC.COUNT
        LOOP
          --DBMS_OUTPUT.PUT_LINE('J IS : '|| J);
          --DBMS_OUTPUT.PUT_LINE('POTENTIALINVUSERID : ' || POTENTIALINVESTIGATOR_REC(J).POTENTIALINVUSERID);
		  SELECT COUNT(*)
          INTO V_FACMAP_COUNT_TOTAL
          FROM TBL_POTENTIALINVFACMAP
          WHERE POTENTIALINVUSERID = POTENTIALINVESTIGATOR_REC(J).POTENTIALINVUSERID
          AND (ISACTIVE           IS NULL
          OR ISACTIVE              = 'Y');

          SELECT COUNT(*)
          INTO V_FACMAP_COUNT_STATUS
          FROM TBL_POTENTIALINVFACMAP
          WHERE POTENTIALINVUSERID = POTENTIALINVESTIGATOR_REC(J).POTENTIALINVUSERID
          AND STATUSCD !=V_STATUSCDVAL
          AND (ISACTIVE           IS NULL
          OR ISACTIVE              = 'Y'); -- where status is anything other than pot

         SELECT COUNT(*)
          INTO V_FACMAP_COUNT_ALLSTATUS
          FROM TBL_POTENTIALINVFACMAP
          WHERE POTENTIALINVUSERID = POTENTIALINVESTIGATOR_REC(J).POTENTIALINVUSERID
          AND STATUSCD IN (V_STATUSCDVAL,V_STATUSSTDDEC,V_STATUSSTDIN,V_STATUSPREDEC,V_STATUSPREIN,V_STATUSPRESEL)
          AND (ISACTIVE           IS NULL
          OR ISACTIVE              = 'Y');

          IF (V_FACMAP_COUNT_STATUS =0) THEN
          SELECT COUNT(*)
          INTO V_FACMAP_COUNT
          FROM TBL_POTENTIALINVFACMAP
          WHERE POTENTIALINVUSERID = POTENTIALINVESTIGATOR_REC(J).POTENTIALINVUSERID
          AND FACILITYID           = V_FACASSOCIATION_REQ_UPD(I).FACILITYID
          AND (ISACTIVE           IS NULL
          OR ISACTIVE              = 'Y');

        IF (V_FACMAP_COUNT_ALLSTATUS !=0) THEN
          SELECT COUNT(*)
          INTO V_FACMAP_ALLCOUNT
          FROM TBL_POTENTIALINVFACMAP
          WHERE POTENTIALINVUSERID = POTENTIALINVESTIGATOR_REC(J).POTENTIALINVUSERID
          AND FACILITYID           = V_FACASSOCIATION_REQ_UPD(I).FACILITYID
          AND (ISACTIVE           IS NULL
          OR ISACTIVE              = 'Y');
       END IF;
          SELECT COUNT(*)
          INTO V_FACMAP_NULL
          FROM TBL_POTENTIALINVFACMAP
          WHERE POTENTIALINVUSERID = POTENTIALINVESTIGATOR_REC(J).POTENTIALINVUSERID
          AND FACILITYID          IS NULL
          AND (ISACTIVE           IS NULL
          OR ISACTIVE              = 'Y');

          SELECT COUNT(*)
          INTO V_FACMAP_COUNT_TASK
          FROM TBL_POTENTIALINVFACMAP
          WHERE POTENTIALINVUSERID = POTENTIALINVESTIGATOR_REC(J).POTENTIALINVUSERID
          AND (ISACTIVE           IS NULL
          OR ISACTIVE              = 'Y')
          AND FACILITYID          IS NOT NULL;

          IF (V_FACMAP_COUNT_TOTAL !=0 AND V_FACMAP_COUNT_STATUS=0 AND V_FACMAP_COUNT = 0 AND V_FACASSOCIATION_REQ_UPD(I).ISACTIVE ='Y' AND V_FACMAP_NULL =0) THEN
            INSERT
            INTO TBL_POTENTIALINVFACMAP
              (
                POTENTIALINVFACID,
                FACILITYID,
                POTENTIALINVUSERID,
                CREATEDBY ,
                CREATEDDT ,
                MODIFIEDBY ,
                MODIFIEDDT ,
                ISNOTIFICATIONSEND ,
                ISSELECTEDFORPRESTUDYEVAL ,
                ISSITEFEASIBILITYSURVEYREQ ,
                ISINVITATIONSEND ,
                HASRESPONDEDTOINVITE ,
                ISACCEPTED ,
                ISREJECTED ,
                ISDISQUALIFIED ,
                ISSELECTEDFORSTUDY ,
                ISKEYCONTACT ,
                ISACTIVE ,
                STATUSCD ,
                ZSCORE ,
                REASON,
                ISCOMMDOCUMENTED
              )
              VALUES
              (
                SEQ_POTENTIALINVFACMAP.NEXTVAL,
                V_FACASSOCIATION_REQ_UPD(I).FACILITYID,
                POTENTIALINVESTIGATOR_REC(J).POTENTIALINVUSERID,
                POTENTIALINVESTIGATOR_REC(J).CREATEDBY,
                SYSDATE,
                '' ,           --MODIFIEDBY
                '' ,           --MODIFIEDDT
                NULL ,         --ISNOTIFICATIONSEND
                NULL ,         --ISSELECTEDFORPRESTUDYEVAL
                NULL ,         --ISSITEFEASIBILITYSURVEYREQ
                NULL ,         --ISINVITATIONSEND
                NULL ,         --HASRESPONDEDTOINVITE
                NULL ,         --ISACCEPTED
                NULL ,         --ISREJECTED
                NULL ,         --ISDISQUALIFIED
                NULL ,         --ISSELECTEDFORSTUDY
                NULL ,         --ISKEYCONTACT
                'Y',           --ISACTIVE
                V_STATUSCDVAL, --STATUSCD
                NULL,          --ZSCORE
                NULL,          --REASON
                'N'            --ISCOMMDOCUMENTED
              );
          ELSIF(V_FACMAP_COUNT_TOTAL !=0 AND V_FACMAP_COUNT_STATUS=0 AND V_FACASSOCIATION_REQ_UPD(I).ISACTIVE ='Y' AND V_FACMAP_NULL !=0 AND V_FACMAP_COUNT = 0) THEN
            UPDATE TBL_POTENTIALINVFACMAP
            SET FACILITYID          =V_FACASSOCIATION_REQ_UPD(I).FACILITYID,
              MODIFIEDDT            =sysdate,
              MODIFIEDBY            =POTENTIALINVESTIGATOR_REC(J).CREATEDBY
            WHERE FACILITYID       IS NULL
            AND POTENTIALINVUSERID  = POTENTIALINVESTIGATOR_REC(J).POTENTIALINVUSERID;
            
            SELECT TITLENAME 
            INTO V_TITLENAME 
            FROM TBL_POTENTIALINVESTIGATOR, TBL_POTENTIALINVTITLES 
            WHERE TBL_POTENTIALINVESTIGATOR.TITLEID = TBL_POTENTIALINVTITLES.TITLEID 
            AND TBL_POTENTIALINVESTIGATOR.POTENTIALINVUSERID = POTENTIALINVESTIGATOR_REC(J).POTENTIALINVUSERID; 
            
            IF (V_FACMAP_COUNT_TASK =0) THEN
              V_TASK_STATUS        := FN_SEND_PI_TASK(V_TRANSID, V_TITLENAME);
            END IF;
          ELSIF (V_FACMAP_ALLCOUNT > 0 AND V_FACASSOCIATION_REQ_UPD(I).ISACTIVE ='N' AND V_FACMAP_NULL =0) THEN
            UPDATE TBL_POTENTIALINVFACMAP
            SET ISACTIVE           ='N',
              MODIFIEDBY           =V_FACASSOCIATION_REQ_UPD(I).CREATEDBY,
              MODIFIEDDT           =sysdate,
              REASON               ='Disassociated Facility'
            WHERE FACILITYID       =V_FACASSOCIATION_REQ_UPD(I).FACILITYID
            AND POTENTIALINVUSERID = POTENTIALINVESTIGATOR_REC(J).POTENTIALINVUSERID;
            SELECT COUNT(POTENTIALINVUSERID)
            INTO V_POT_DEL
            FROM TBL_POTENTIALINVFACMAP
            WHERE POTENTIALINVUSERID = POTENTIALINVESTIGATOR_REC(J).POTENTIALINVUSERID
            AND ISACTIVE             ='Y';
            IF (V_POT_DEL            =0) THEN
              UPDATE TBL_POTENTIALINVESTIGATOR
              SET ISACTIVE             ='N',
                MODIFIEDBY             =POTENTIALINVESTIGATOR_REC(J).CREATEDBY,
                MODIFIEDDT             =sysdate
              WHERE POTENTIALINVUSERID = V_POT_DEL;
            END IF;
          ---Updating the task in the case where pre-study and participation is taking place
              UPDATE TBL_TASK SET ISDELETED='Y',
              MODIFIEDDT= sysdate,
              MODIFIEDBY= V_FACASSOCIATION_REQ_UPD(I).CREATEDBY
              WHERE
              ASSIGNTO =POTENTIALINVESTIGATOR_REC(J).TRANSCELERATEUSERID
              AND STATUSCODE ='Pending'
              AND CATEGORYCODE IN ('study_site_participation','pre_study_invitation')
              AND ISDELETED ='N'
              AND FACILITYID = V_FACASSOCIATION_REQ_UPD(I).FACILITYID;
          END IF;
          END IF;
        END LOOP;
        UPDATE TBL_FACASSOCIATION_REQ
        SET ISPROCESSED = 'Y',
          MODIFIEDDT    =sysdate
        WHERE ASSREQID  = V_FACASSOCIATION_REQ_UPD(I).ASSREQID;
      END LOOP;
    END LOOP;
  END LOOP;
  COMMIT;
  V_STATUS_FLAG := 0 ;
EXCEPTION
  /*when no data found then log exception*/
WHEN NO_DATA_FOUND THEN
  V_MSG := 'NO DATA FOUND';
  DBMS_OUTPUT.PUT_LINE(V_MSG);
  IF V_USERID      <0 THEN
    V_STATUS_FLAG := 0 ;
  ELSE
    V_STATUS_FLAG := -1 ;
    ROLLBACK;
  END IF;
  RETURN;
  /*if Primary key violation then log exception*/
WHEN DUP_VAL_ON_INDEX THEN
  V_MSG := SQLERRM;
  DBMS_OUTPUT.PUT_LINE(V_MSG);
  V_STATUS_FLAG := -1 ;
  ROLLBACK;
  RETURN;
  /*if other exception then log exception*/
WHEN OTHERS THEN
  V_MSG := SQLERRM;
  DBMS_OUTPUT.PUT_LINE(V_MSG);
  V_STATUS_FLAG := -1 ;
  ROLLBACK;
  RETURN;
END PROC_POPULATE_POTINVFACMAP;

----Procedure for merging survey List
PROCEDURE PROC_MERGE_POTENTIALINV
    (
      P_SURVEYLIST  IN typ_survey_list,
      V_NEW_TITLEID IN NUMBER,
      V_CREATEDBY   IN VARCHAR2,
      V_CREATEDDATE DATE,
      V_STATUS_FLAG OUT NUMBER
    )
  AS
    /* Variables */
    V_MSG VARCHAR2
    (
      500
    )
    ;
    V_POTINVUSERID  NUMBER(38,0);
    V_POTINVFACID  NUMBER(38,0);
    V_NEW_ID        NUMBER(38,0);
    V_STATUSCDVAL   VARCHAR2(100);
    V_FACMAP_COUNT  NUMBER(38);
    V_POTINV_COUNT  NUMBER(38);
    V_SELECT_CLAUSE VARCHAR2(500);
    V_WHERE_CLAUSE  VARCHAR2(500);
    V_FACMAP_NULL   NUMBER(38);
  V_CONTACTID   NUMBER(38);
  V_CONTACTIDCOUNT  NUMBER(38);
  V_POTENTIALCOUNT NUMBER(38);
  V_TRANSCELERATEID VARCHAR2(100);
  V_TRANSCELERATEIDCOUNT NUMBER(38);
  V_STUDYID NUMBER(38);
  V_PI_TITLE_CHECK NUMBER;
  V_PI_TITLE_CONTACT NUMBER;

BEGIN

  V_CONTACTIDCOUNT :=0;
  SELECT CODENAME
  INTO V_STATUSCDVAL
  FROM TBL_CODE
  WHERE CODETABLE ='TBL_POTENTIALINVFACMAP'
  AND CODEFIELD   ='STATUSCD'
  AND CODEVALUE   ='Potential Investigator'
  AND ISACTIVE    ='Y';
  IF(P_SURVEYLIST IS NOT NULL) THEN

SELECT STUDYID INTO V_STUDYID FROM TBL_POTENTIALINVTITLES WHERE TITLEID=V_NEW_TITLEID;

FOR i IN P_SURVEYLIST.first .. P_SURVEYLIST.last
LOOP
        --first IF
IF (P_SURVEYLIST(i).v_transcelerateUserId IS NOT NULL) THEN

     IF (P_SURVEYLIST(i).v_facilityId > 0) THEN
       SELECT COUNT(FMAP.POTENTIALINVUSERID) INTO V_PI_TITLE_CHECK from TBL_POTENTIALINVFACMAP FMAP
              JOIN TBL_POTENTIALINVESTIGATOR PI ON PI.POTENTIALINVUSERID=FMAP.POTENTIALINVUSERID
              JOIN TBL_POTENTIALINVTITLES PT ON PT.TITLEID = PI.TITLEID
              WHERE PT.STUDYID =V_STUDYID
              AND FMAP.ISACTIVE ='Y'
              AND PI.TRANSCELERATEUSERID=P_SURVEYLIST(i).v_transcelerateUserId
              AND FMAP.FACILITYID =P_SURVEYLIST(i).v_facilityId;
         ELSE
      SELECT COUNT(FMAP.POTENTIALINVUSERID) INTO V_PI_TITLE_CHECK from TBL_POTENTIALINVFACMAP FMAP
              JOIN TBL_POTENTIALINVESTIGATOR PI ON PI.POTENTIALINVUSERID=FMAP.POTENTIALINVUSERID
              JOIN TBL_POTENTIALINVTITLES PT ON PT.TITLEID = PI.TITLEID
              WHERE PT.STUDYID =V_STUDYID
              AND FMAP.ISACTIVE ='Y'
              AND PI.TRANSCELERATEUSERID=P_SURVEYLIST(i).v_transcelerateUserId;
      END IF;
IF (V_PI_TITLE_CHECK = 0) THEN
---checking in potential table  for transcelerateId
   SELECT COUNT(POTENTIALINVUSERID) INTO V_POTENTIALCOUNT FROM TBL_POTENTIALINVESTIGATOR PI
    WHERE PI.TRANSCELERATEUSERID  = P_SURVEYLIST(i).v_transcelerateUserId
    AND PI.TITLEID = V_NEW_TITLEID
      AND (PI.ISACTIVE IS NULL
      OR PI.ISACTIVE    = 'Y');
 --- if count greator than 0
IF (V_POTENTIALCOUNT != 0) THEN
      SELECT DISTINCT POTENTIALINVUSERID
      INTO V_POTINVUSERID
      FROM TBL_POTENTIALINVESTIGATOR PI
      WHERE PI.TRANSCELERATEUSERID  = P_SURVEYLIST(i).v_transcelerateUserId
    AND PI.TITLEID = V_NEW_TITLEID
      AND (PI.ISACTIVE IS NULL
      OR PI.ISACTIVE    = 'Y');

  -- check any null entry count present
    SELECT COUNT(POTENTIALINVFACID) INTO V_FACMAP_NULL FROM TBL_POTENTIALINVFACMAP PI
    WHERE PI.POTENTIALINVUSERID  = V_POTINVUSERID
    AND PI.FACILITYID IS NULL
    AND (PI.ISACTIVE IS NULL
      OR PI.ISACTIVE    = 'Y');

  IF(P_SURVEYLIST(i).v_facilityId > 0) THEN
   ---check count in fac map for facility
    SELECT COUNT(POTENTIALINVFACID) INTO V_FACMAP_COUNT FROM TBL_POTENTIALINVFACMAP PI
    WHERE PI.POTENTIALINVUSERID  = V_POTINVUSERID
    AND PI.FACILITYID = P_SURVEYLIST(i).v_facilityId
    AND (PI.ISACTIVE IS NULL
      OR PI.ISACTIVE    = 'Y');

   IF (V_FACMAP_COUNT = 0 AND V_FACMAP_NULL =0) THEN

 ---entering data into potential facility map when no null present
          INSERT
          INTO TBL_POTENTIALINVFACMAP
            (
              POTENTIALINVFACID,
              FACILITYID,
              POTENTIALINVUSERID,
              CREATEDBY ,
              CREATEDDT ,
              MODIFIEDBY ,
              MODIFIEDDT ,
              ISNOTIFICATIONSEND ,
              ISSELECTEDFORPRESTUDYEVAL ,
              ISSITEFEASIBILITYSURVEYREQ ,
              ISINVITATIONSEND ,
              HASRESPONDEDTOINVITE ,
              ISACCEPTED ,
              ISREJECTED ,
              ISDISQUALIFIED ,
              ISSELECTEDFORSTUDY ,
              ISKEYCONTACT ,
              ISACTIVE ,
              STATUSCD ,
              ZSCORE ,
              REASON,
              ISCOMMDOCUMENTED
            )
            VALUES
            (
              SEQ_POTENTIALINVFACMAP.NEXTVAL,
              P_SURVEYLIST(i).v_facilityId,
              V_POTINVUSERID,
              V_CREATEDBY,
              SYSDATE ,
              '' ,           --MODIFIEDBY
              '' ,           --MODIFIEDDT
              NULL ,         --ISNOTIFICATIONSEND
              NULL ,         --ISSELECTEDFORPRESTUDYEVAL
              NULL ,         --ISSITEFEASIBILITYSURVEYREQ
              NULL ,         --ISINVITATIONSEND
              NULL ,         --HASRESPONDEDTOINVITE
              NULL ,         --ISACCEPTED
              NULL ,         --ISREJECTED
              NULL ,         --ISDISQUALIFIED
              NULL ,         --ISSELECTEDFORSTUDY
              NULL ,         --ISKEYCONTACT
              'Y',           --ISACTIVE
              V_STATUSCDVAL, --STATUSCD
              NULL,          --ZSCORE
              NULL,          --REASON
              'N'            --ISCOMMDOCUMENTED
            );
    ELSIF(V_FACMAP_COUNT = 0 AND V_FACMAP_NULL !=0) THEN
  ---updating data into potential facility map when null present
   UPDATE TBL_POTENTIALINVFACMAP
            SET FACILITYID         =P_SURVEYLIST(i).v_facilityId,
              MODIFIEDDT           =SYSDATE,
              MODIFIEDBY           =V_CREATEDBY
            WHERE FACILITYID      IS NULL
            AND POTENTIALINVUSERID = V_POTINVUSERID
            AND (ISACTIVE         IS NULL
            OR ISACTIVE            = 'Y');
 END IF;
END IF;

ELSE
-- when no record for transcelerate id present in PI list
V_NEW_ID      := SEQ_POTENTIALINVESTIGATOR.NEXTVAL;
SELECT CONTACTID INTO V_CONTACTID FROM TBL_USERPROFILES WHERE TRANSCELERATEUSERID=P_SURVEYLIST(i).v_transcelerateUserId AND ISACTIVE='Y';

INSERT
          INTO TBL_POTENTIALINVESTIGATOR
            (
              POTENTIALINVUSERID,
              TRANSCELERATEUSERID,
              TITLEID,
              CONTACTID,
              FIRSTNAME,
              LASTNAME,
              ISNOTIFICATIONSEND,
              ISSELECTEDFORPRESTUDYEVAL,
              ISCOMMDOCUMENTED,
              COMMUNICATION,
              ISSITEFEASIBILITYSURVEYREQ,
              ISINVITATIONSEND,
              HASRESPONDEDTOINVITE,
              ISACCEPTED,
              ISREJECTED,
              ISDISQUALIFIED,
              ISSELECTEDFORSTUDY,
              REASON,
              ZSCORE,
              STATUSCD,
              ISKEYCONTACT,
              ISACTIVE,
              CREATEDBY,
              CREATEDDT,
              MODIFIEDBY,
              MODIFIEDDT,
              COMMDT
            )
            VALUES
            (
              V_NEW_ID,
              P_SURVEYLIST(i).v_transcelerateUserId,
              V_NEW_TITLEID,
              V_CONTACTID,
              P_SURVEYLIST(i).v_firstname,
              P_SURVEYLIST(i).v_lastname,
              NULL, -- ISNOTIFICATIONSEND,
              NULL, --ISSELECTEDFORPRESTUDYEVAL,
              NULL, --ISCOMMDOCUMENTED,
              NULL, --COMMUNICATION,
              NULL, --ISSITEFEASIBILITYSURVEYREQ,
              NULL, --ISINVITATIONSEND,
              NULL, --HASRESPONDEDTOINVITE,
              NULL, --ISACCEPTED,
              NULL, --ISREJECTED,
              NULL, --ISDISQUALIFIED,
              NULL, --ISSELECTEDFORSTUDY,
              NULL, --REASON,
              NULL, --ZSCORE
              NULL, --STATUSCD,
              NULL, --ISKEYCONTACT,
              'Y',  --ISACTIVE,
              V_CREATEDBY,
              SYSDATE,
              NULL, --MODIFIEDBY,
              NULL, --MODIFIEDDT
              NULL  --COMMDT
            );
---checking if survey has facility record
IF(P_SURVEYLIST(i).v_facilityId > 0) THEN

INSERT
          INTO TBL_POTENTIALINVFACMAP
            (
              POTENTIALINVFACID,
              FACILITYID,
              POTENTIALINVUSERID,
              CREATEDBY ,
              CREATEDDT ,
              MODIFIEDBY ,
              MODIFIEDDT ,
              ISNOTIFICATIONSEND ,
              ISSELECTEDFORPRESTUDYEVAL ,
              ISSITEFEASIBILITYSURVEYREQ ,
              ISINVITATIONSEND ,
              HASRESPONDEDTOINVITE ,
              ISACCEPTED ,
              ISREJECTED ,
              ISDISQUALIFIED ,
              ISSELECTEDFORSTUDY ,
              ISKEYCONTACT ,
              ISACTIVE ,
              STATUSCD ,
              ZSCORE ,
              REASON,
              ISCOMMDOCUMENTED
            )
            VALUES
            (
              SEQ_POTENTIALINVFACMAP.NEXTVAL,
              P_SURVEYLIST(i).v_facilityId,
              V_NEW_ID,
              V_CREATEDBY,
              SYSDATE ,
              '' ,           --MODIFIEDBY
              '' ,           --MODIFIEDDT
              NULL ,         --ISNOTIFICATIONSEND
              NULL ,         --ISSELECTEDFORPRESTUDYEVAL
              NULL ,         --ISSITEFEASIBILITYSURVEYREQ
              NULL ,         --ISINVITATIONSEND
              NULL ,         --HASRESPONDEDTOINVITE
              NULL ,         --ISACCEPTED
              NULL ,         --ISREJECTED
              NULL ,         --ISDISQUALIFIED
              NULL ,         --ISSELECTEDFORSTUDY
              NULL ,         --ISKEYCONTACT
              'Y',           --ISACTIVE
              V_STATUSCDVAL, --STATUSCD
              NULL,          --ZSCORE
              NULL,          --REASON
              'N'            --ISCOMMDOCUMENTED
            );

ELSE

INSERT
          INTO TBL_POTENTIALINVFACMAP
            (
              POTENTIALINVFACID,
              FACILITYID,
              POTENTIALINVUSERID,
              CREATEDBY ,
              CREATEDDT ,
              MODIFIEDBY ,
              MODIFIEDDT ,
              ISNOTIFICATIONSEND ,
              ISSELECTEDFORPRESTUDYEVAL ,
              ISSITEFEASIBILITYSURVEYREQ ,
              ISINVITATIONSEND ,
              HASRESPONDEDTOINVITE ,
              ISACCEPTED ,
              ISREJECTED ,
              ISDISQUALIFIED ,
              ISSELECTEDFORSTUDY ,
              ISKEYCONTACT ,
              ISACTIVE ,
              STATUSCD ,
              ZSCORE ,
              REASON,
              ISCOMMDOCUMENTED
            )
            VALUES
            (
              SEQ_POTENTIALINVFACMAP.NEXTVAL,
              NULL,
              V_NEW_ID,
              V_CREATEDBY,
              SYSDATE ,
              '' ,           --MODIFIEDBY
              '' ,           --MODIFIEDDT
              NULL ,         --ISNOTIFICATIONSEND
              NULL ,         --ISSELECTEDFORPRESTUDYEVAL
              NULL ,         --ISSITEFEASIBILITYSURVEYREQ
              NULL ,         --ISINVITATIONSEND
              NULL ,         --HASRESPONDEDTOINVITE
              NULL ,         --ISACCEPTED
              NULL ,         --ISREJECTED
              NULL ,         --ISDISQUALIFIED
              NULL ,         --ISSELECTEDFORSTUDY
              NULL ,         --ISKEYCONTACT
              'Y',           --ISACTIVE
              V_STATUSCDVAL, --STATUSCD
              NULL,          --ZSCORE
              NULL,          --REASON
              'N'            --ISCOMMDOCUMENTED
            );

END IF;
END IF;
END IF;
-- else for no transcelerate Id
ELSE

SELECT count(CONTACTID) INTO V_CONTACTIDCOUNT FROM TBL_CONTACT WHERE pkg_encrypt.fn_decrypt(EMAIL)=P_SURVEYLIST(i).v_email AND ISACTIVE='Y';
IF (V_CONTACTIDCOUNT !=0) THEN
SELECT CONTACTID INTO V_CONTACTID FROM TBL_CONTACT WHERE pkg_encrypt.fn_decrypt(EMAIL)=P_SURVEYLIST(i).v_email AND ISACTIVE='Y';

SELECT COUNT(TRANSCELERATEUSERID) INTO V_TRANSCELERATEIDCOUNT FROM TBL_USERPROFILES WHERE CONTACTID =V_CONTACTID AND ISACTIVE='Y' AND ISSPONSOR='N';
IF (V_TRANSCELERATEIDCOUNT !=0)THEN
SELECT TRANSCELERATEUSERID INTO V_TRANSCELERATEID FROM TBL_USERPROFILES WHERE CONTACTID =V_CONTACTID AND ISACTIVE='Y' AND ISSPONSOR='N';
END IF;
ELSE
V_CONTACTID := SEQ_CONTACT.NEXTVAL;
INSERT INTO TBL_CONTACT (
CONTACTID,
EMAIL,
COUNTRYCD,
CITY,
PHONE1,
ISACTIVE,
CREATEDBY,
CREATEDDT
)
VALUES
(V_CONTACTID,
P_SURVEYLIST(i).v_email,
P_SURVEYLIST(i).v_country,
P_SURVEYLIST(i).v_city,
P_SURVEYLIST(i).v_phone,
'Y',
V_CREATEDBY,
SYSDATE
);
END IF;

SELECT COUNT(FMAP.POTENTIALINVUSERID) INTO V_PI_TITLE_CONTACT from TBL_POTENTIALINVFACMAP FMAP
              JOIN TBL_POTENTIALINVESTIGATOR PI ON PI.POTENTIALINVUSERID=FMAP.POTENTIALINVUSERID
              JOIN TBL_POTENTIALINVTITLES PT ON PT.TITLEID = PI.TITLEID
              WHERE PT.STUDYID =V_STUDYID
              AND FMAP.ISACTIVE ='Y'
              AND PI.CONTACTID=V_CONTACTID;
IF (V_PI_TITLE_CONTACT =0) THEN
SELECT COUNT(POTENTIALINVUSERID) INTO V_POTENTIALCOUNT FROM TBL_POTENTIALINVESTIGATOR PI WHERE
       PI.CONTACTID  = V_CONTACTID
    AND PI.TITLEID = V_NEW_TITLEID
      AND (PI.ISACTIVE IS NULL
      OR PI.ISACTIVE    = 'Y');

IF (V_POTENTIALCOUNT = 0) THEN
-- when no record for transcelerate id present in PI list
V_NEW_ID      := SEQ_POTENTIALINVESTIGATOR.NEXTVAL;
--insert into pi list if contact not present in list
   INSERT
          INTO TBL_POTENTIALINVESTIGATOR
            (
              POTENTIALINVUSERID,
              TRANSCELERATEUSERID,
              TITLEID,
              CONTACTID,
              FIRSTNAME,
              LASTNAME,
              ISNOTIFICATIONSEND,
              ISSELECTEDFORPRESTUDYEVAL,
              ISCOMMDOCUMENTED,
              COMMUNICATION,
              ISSITEFEASIBILITYSURVEYREQ,
              ISINVITATIONSEND,
              HASRESPONDEDTOINVITE,
              ISACCEPTED,
              ISREJECTED,
              ISDISQUALIFIED,
              ISSELECTEDFORSTUDY,
              REASON,
              ZSCORE,
              STATUSCD,
              ISKEYCONTACT,
              ISACTIVE,
              CREATEDBY,
              CREATEDDT,
              MODIFIEDBY,
              MODIFIEDDT,
              COMMDT
            )
            VALUES
            (
              V_NEW_ID,
              V_TRANSCELERATEID,
              V_NEW_TITLEID,
              V_CONTACTID,
              P_SURVEYLIST(i).v_firstname,
              P_SURVEYLIST(i).v_lastname,
              NULL, -- ISNOTIFICATIONSEND,
              NULL, --ISSELECTEDFORPRESTUDYEVAL,
              NULL, --ISCOMMDOCUMENTED,
              NULL, --COMMUNICATION,
              NULL, --ISSITEFEASIBILITYSURVEYREQ,
              NULL, --ISINVITATIONSEND,
              NULL, --HASRESPONDEDTOINVITE,
              NULL, --ISACCEPTED,
              NULL, --ISREJECTED,
              NULL, --ISDISQUALIFIED,
              NULL, --ISSELECTEDFORSTUDY,
              NULL, --REASON,
              NULL, --ZSCORE
              NULL, --STATUSCD,
              NULL, --ISKEYCONTACT,
              'Y',  --ISACTIVE,
              V_CREATEDBY,
              SYSDATE,
              NULL, --MODIFIEDBY,
              NULL, --MODIFIEDDT
              NULL  --COMMDT
            );
INSERT
          INTO TBL_POTENTIALINVFACMAP
            (
              POTENTIALINVFACID,
              FACILITYID,
              POTENTIALINVUSERID,
              CREATEDBY ,
              CREATEDDT ,
              MODIFIEDBY ,
              MODIFIEDDT ,
              ISNOTIFICATIONSEND ,
              ISSELECTEDFORPRESTUDYEVAL ,
              ISSITEFEASIBILITYSURVEYREQ ,
              ISINVITATIONSEND ,
              HASRESPONDEDTOINVITE ,
              ISACCEPTED ,
              ISREJECTED ,
              ISDISQUALIFIED ,
              ISSELECTEDFORSTUDY ,
              ISKEYCONTACT ,
              ISACTIVE ,
              STATUSCD ,
              ZSCORE ,
              REASON,
              ISCOMMDOCUMENTED
            )
            VALUES
            (
              SEQ_POTENTIALINVFACMAP.NEXTVAL,
              NULL,
              V_NEW_ID,
              V_CREATEDBY,
              SYSDATE ,
              '' ,           --MODIFIEDBY
              '' ,           --MODIFIEDDT
              NULL ,         --ISNOTIFICATIONSEND
              NULL ,         --ISSELECTEDFORPRESTUDYEVAL
              NULL ,         --ISSITEFEASIBILITYSURVEYREQ
              NULL ,         --ISINVITATIONSEND
              NULL ,         --HASRESPONDEDTOINVITE
              NULL ,         --ISACCEPTED
              NULL ,         --ISREJECTED
              NULL ,         --ISDISQUALIFIED
              NULL ,         --ISSELECTEDFORSTUDY
              NULL ,         --ISKEYCONTACT
              'Y',           --ISACTIVE
              V_STATUSCDVAL, --STATUSCD
              NULL,          --ZSCORE
              NULL,          --REASON
              'N'            --ISCOMMDOCUMENTED
            );
END IF;
END IF;
END IF;
END LOOP;
END IF;
COMMIT;
V_STATUS_FLAG := 0 ;
EXCEPTION
  /*when no data found then log exception*/
WHEN NO_DATA_FOUND THEN
  V_MSG := 'NO DATA FOUND';
  DBMS_OUTPUT.PUT_LINE(V_MSG);
  V_STATUS_FLAG := -1 ;
  ROLLBACK;
  RETURN;
  /*if Primary key violation then log exception*/
WHEN DUP_VAL_ON_INDEX THEN
  V_MSG := SQLERRM;
  DBMS_OUTPUT.PUT_LINE(V_MSG);
  V_STATUS_FLAG := -1 ;
  ROLLBACK;
    RETURN;
  /*if other exception then log exception*/
WHEN OTHERS THEN
  V_MSG := SQLERRM;
--  DBMS_OUTPUT.PUT_LINE(V_MSG);
  V_STATUS_FLAG := -1 ;
  ROLLBACK;
  RETURN;
END PROC_MERGE_POTENTIALINV;
END pkg_potent_inv;
/