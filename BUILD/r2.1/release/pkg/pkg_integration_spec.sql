--Package for SIP Intergration with LMS/CTMS/DOCEX etc. systems 
CREATE OR REPLACE PACKAGE PKG_INTEGRATION AS

gv_createdby                  VARCHAR2(6):='SYSTEM';
gv_rec_limit                  PLS_INTEGER:=100;
gv_operation_addstudycountry  TBL_INTEGRATION.operation%TYPE:= 'add-study-country';
gv_docexsys_liferay           TBL_DOCEXSYSTEM.docexsystemname%TYPE:='liferay';

--Procedure for Study Integration
PROCEDURE SP_SET_STUDY_INT
(
ip_studyid    IN TBL_STUDY.studyid%TYPE,
ip_operation  IN TBL_INTEGRATION.operation%TYPE, 
op_study      OUT SYS_REFCURSOR
);

--Procedure for Create Site Integration
PROCEDURE SP_SET_SITE_INT
(
ip_siteid     IN TBL_SITE.siteid%TYPE,
ip_operation  IN TBL_INTEGRATION.operation%TYPE,
op_site       OUT SYS_REFCURSOR
);

--Procedure for Update Site Integration
PROCEDURE SP_SET_UPDATESITE_INT
(
ip_siteid         IN TBL_SITE.siteid%TYPE,
ip_oldfacilityid  IN TBL_FACILITIES.facilityid%TYPE,
ip_newfacilityid  IN TBL_FACILITIES.facilityid%TYPE,
ip_operation      IN TBL_INTEGRATION.operation%TYPE,
op_site           OUT SYS_REFCURSOR
);

--Procedure for Integration of Site User Deactivation and Access Modification
PROCEDURE SP_SET_USERACCESS_INT
(
ip_userroleid       IN TBL_USERROLEMAP.userroleid%TYPE,
ip_operation        IN TBL_INTEGRATION.operation%TYPE,
op_useraccess       OUT SYS_REFCURSOR
);

--Procedure for Integration of Add/Update of Staff Role for Site User
PROCEDURE SP_SET_STAFFROLE_INT
(
ip_userroleid       IN TBL_USERROLEMAP.userroleid%TYPE,
ip_operation        IN TBL_INTEGRATION.operation%TYPE,
op_staffrole        OUT SYS_REFCURSOR
);

--Procedure for Site User Integration
PROCEDURE SP_SET_SITEUSER_INT
(
ip_userid       IN TBL_USERPROFILES.userid%TYPE,
ip_operation    IN TBL_INTEGRATION.operation%TYPE,
op_siteuser     OUT SYS_REFCURSOR
);

--Procedure for Close Study Integration
PROCEDURE SP_SET_CLOSESTUDY_INT
(
ip_studyid        IN TBL_STUDY.studyid%TYPE,
ip_operation      IN TBL_INTEGRATION.operation%TYPE, 
op_closestudy     OUT SYS_REFCURSOR
);

--Procedure for Close Site Integration
PROCEDURE SP_SET_CLOSESITE_INT
(
ip_siteid     IN TBL_SITE.siteid%TYPE,
ip_operation  IN TBL_INTEGRATION.operation%TYPE,
op_closesite  OUT SYS_REFCURSOR
);

--Procedure for Update Site Reference Integration
PROCEDURE SP_SET_UPDATESITEREF_INT
(
ip_siteid         IN TBL_SITE.siteid%TYPE,
ip_operation      IN TBL_INTEGRATION.operation%TYPE,
op_updatesiteref  OUT SYS_REFCURSOR
);

--Procedure for Site User Document(CV) Integration
PROCEDURE SP_SET_USERDOC_INT
(
ip_documentid     IN TBL_DOCUMENTS.documentid%TYPE,
ip_operation      IN TBL_INTEGRATION.operation%TYPE,
op_userdoc        OUT SYS_REFCURSOR
);

--Procedure for Study Country Integration
PROCEDURE SP_SET_STUDYCOUNTRY_INT
(
ip_studycountryid IN TBL_STUDYCOUNTRYMILESTONE.studycountryid%TYPE,
ip_operation      IN TBL_INTEGRATION.operation%TYPE,
op_studycountry   OUT SYS_REFCURSOR
);

--Procedure for Integration of Sponsor User Deactivation and Access Modification
PROCEDURE SP_SET_SPONSOR_USERACCESS_INT
(
ip_userroleid       IN TBL_USERROLEMAP.userroleid%TYPE,
ip_operation        IN TBL_INTEGRATION.operation%TYPE,
op_useraccess       OUT SYS_REFCURSOR
);

--Procedure for Sponsor User Integration
PROCEDURE SP_SET_SPONSOR_INT
(
ip_transcelerateuserid IN TBL_USERPROFILES.transcelerateuserid%TYPE,
ip_operation           IN TBL_INTEGRATION.operation%TYPE,
op_sponsor             OUT SYS_REFCURSOR
);

--Procedure for Sponsor User Deactivation Integration
PROCEDURE SP_SET_SPONSOR_DEACT_INT
(
ip_userid              IN TBL_USERPROFILES.userid%TYPE,
ip_studyid             IN TBL_STUDY.studyid%TYPE,
ip_siteid              IN TBL_SITE.siteid%TYPE,
ip_operation           IN TBL_INTEGRATION.operation%TYPE,
op_sponsor             OUT SYS_REFCURSOR
);

--Procedure for Integration of User Activation for future dates using Scheduler
PROCEDURE SP_SET_USERACCESS_ACT_INT;

--Procedure for Integration of User Deactivation for future dates using Scheduler
PROCEDURE SP_SET_USERACCESS_DEACT_INT;

--Procedure for Facility Document Integration
PROCEDURE SP_SET_FACDOC_INT
(
ip_facilitydocmetadataid     IN TBL_FACILITYDOCMETADATA.facilitydocmetadataid%TYPE,
ip_operation                 IN TBL_INTEGRATION.operation%TYPE,
op_facdoc                    OUT SYS_REFCURSOR
);

--Procedure for User Training Integration
PROCEDURE SP_SET_USER_TRAINING_INT
(
ip_id           IN TBL_USER_TRAINING_STATUS.id%TYPE,
ip_operation    IN TBL_INTEGRATION.operation%TYPE,
op_usertrng     OUT SYS_REFCURSOR
);

END PKG_INTEGRATION;
/