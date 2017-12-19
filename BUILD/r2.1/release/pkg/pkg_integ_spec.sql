--Package for SIP Intergration with External Systems (Veeva, SafeD, GobalTO and CTMS etc.) 
CREATE OR REPLACE PACKAGE PKG_INTEG AS

gv_createdby                    VARCHAR2(6):='SYSTEM';
gv_rec_limit                    PLS_INTEGER:=100;
gv_extsys_veeva                 TBL_EXTERNAL_SYSTEM.external_system_code%TYPE:= 'veeva';
gv_extsys_safed                 TBL_EXTERNAL_SYSTEM.external_system_code%TYPE:= 'safed';
gv_extsys_gobalto               TBL_EXTERNAL_SYSTEM.external_system_code%TYPE:= 'gobalto';
gv_extsys_ctms                  TBL_EXTERNAL_SYSTEM.external_system_code%TYPE:= 'ctms';
gv_event_addusertosite          TBL_SIP_EVENT.eventname%TYPE := 'add-user-to-site-outbound';
gv_eventtype_study              VARCHAR2(25):='study';
gv_eventtype_site               VARCHAR2(25):='site';
gv_eventtype_updatesite         VARCHAR2(25):='updatesite';
gv_eventtype_studycountry       VARCHAR2(25):='studycountry';
gv_eventtype_staffrole          VARCHAR2(25):='staffrole';
gv_eventtype_siteuser           VARCHAR2(25):='siteuser';
gv_eventtype_userdoc            VARCHAR2(25):='userdoc';
gv_eventtype_1572               VARCHAR2(25):='1572';
gv_eventtype_sponsor            VARCHAR2(25):='sponsor';
gv_eventtype_sponsordeact       VARCHAR2(25):='sponsordeact';
gv_eventtype_useraccess         VARCHAR2(25):='useraccess';
gv_eventtype_sponsoraccess      VARCHAR2(25):='sponsoraccess';
gv_eventtype_facdoc             VARCHAR2(25):='facdoc';
gv_eventtype_usertrng           VARCHAR2(25):='usertrng';
gv_eventtype_usercv             VARCHAR2(25):='usercv';
gv_eventtype_sitecontact        VARCHAR2(25):='sitecontact';
gv_eventtype_siteirb            VARCHAR2(25):='siteirb';
gv_eventtype_sitelab            VARCHAR2(25):='sitelab';
gv_eventtype_facility           VARCHAR2(25):='facility';
gv_eventtype_pistatus           VARCHAR2(25):='pistatus';
gv_eventtype_userdeact          VARCHAR2(25):='userdeact';
gv_eventtype_accessmod          VARCHAR2(25):='accessmod';
gv_eventtype_addsiteloc         VARCHAR2(25):='addsiteloc';
gv_eventtype_trngcredit         VARCHAR2(25):='trngcredit';
gv_eventtype_surveyresponse     VARCHAR2(25):='surveyresponse';
gv_eventtype_medlic             VARCHAR2(25):='medlic';
gv_delimiter_attherate          VARCHAR2(1):='@';
gv_keytype_surveyquesans        TBL_INTEG_MULTIVALUE.keytype%TYPE := 'surveyquesans';
gv_keytype_systemaccess         TBL_INTEG_MULTIVALUE.keytype%TYPE := 'systemaccess';
gv_keytype_regnumbody           TBL_INTEG_MULTIVALUE.keytype%TYPE := 'regnumbody';
gv_keytype_accreditation        TBL_INTEG_MULTIVALUE.keytype%TYPE := 'accreditation';
gv_survey_status_received       TBL_SURVEYMETADATA.metadataname%TYPE := 'Response Received';
gv_survey_status_submitted      TBL_SURVEYMETADATA.metadataname%TYPE := 'Response Submitted';
TYPE gtyp_veeva_integ           IS TABLE OF TBL_INTEG_VEEVA_MAP%ROWTYPE;
TYPE gtyp_safed_integ           IS TABLE OF TBL_INTEG_SAFED_MAP%ROWTYPE;
TYPE gtyp_gobalto_integ         IS TABLE OF TBL_INTEG_GOBALTO_MAP%ROWTYPE;
TYPE gtyp_ctms_integ            IS TABLE OF TBL_INTEG_CTMS_MAP%ROWTYPE;

--Procedure for Study Integration
PROCEDURE SP_SET_STUDY_INT
(
ip_studyid      IN TBL_STUDY.studyid%TYPE,
ip_sipeventid   IN TBL_SIP_EVENT.sipeventid%TYPE, 
op_study        OUT SYS_REFCURSOR
);

--Procedure for Create Site Integration
PROCEDURE SP_SET_SITE_INT
(
ip_siteid        IN TBL_SITE.siteid%TYPE,
ip_sipeventid    IN TBL_SIP_EVENT.sipeventid%TYPE,
op_site          OUT SYS_REFCURSOR
);

--Procedure for Update Site Integration
PROCEDURE SP_SET_UPDATESITE_INT
(
ip_siteid         IN TBL_SITE.siteid%TYPE,
ip_oldfacilityid  IN TBL_FACILITIES.facilityid%TYPE,
ip_newfacilityid  IN TBL_FACILITIES.facilityid%TYPE,
ip_sipeventid     IN TBL_SIP_EVENT.sipeventid%TYPE,
op_site           OUT SYS_REFCURSOR
);

--Procedure for Study Country Integration
PROCEDURE SP_SET_STUDYCOUNTRY_INT
(
ip_studycountryid IN TBL_STUDYCOUNTRYMILESTONE.studycountryid%TYPE,
ip_sipeventid     IN TBL_SIP_EVENT.sipeventid%TYPE,
op_studycountry   OUT SYS_REFCURSOR
);

--Procedure for Integration of Add/Update of Staff Role for Site User
PROCEDURE SP_SET_STAFFROLE_INT
(
ip_userroleid       IN TBL_USERROLEMAP.userroleid%TYPE,
ip_sipeventid       IN TBL_SIP_EVENT.sipeventid%TYPE,
op_staffrole        OUT SYS_REFCURSOR
);

--Procedure for Site User Integration
PROCEDURE SP_SET_SITEUSER_INT
(
ip_userid       IN TBL_USERPROFILES.userid%TYPE,
ip_sipeventid   IN TBL_SIP_EVENT.sipeventid%TYPE,
op_siteuser     OUT SYS_REFCURSOR
);

--Procedure for Site User Document(CV) Integration
PROCEDURE SP_SET_USERDOC_INT
(
ip_documentid     IN TBL_DOCUMENTS.documentid%TYPE,
ip_sipeventid     IN TBL_SIP_EVENT.sipeventid%TYPE,
op_userdoc        OUT SYS_REFCURSOR
);

--Procedure for Site 1572 Doc Integration
PROCEDURE SP_SET_1572_INT
(
ip_documentid     IN TBL_DOCUMENTS.documentid%TYPE,
ip_sipeventid     IN TBL_SIP_EVENT.sipeventid%TYPE,
op_1572doc        OUT SYS_REFCURSOR
);

--Procedure for User Medical License Integration
PROCEDURE SP_SET_MEDICAL_LICENSE_INT
(
ip_iruserlicensedocumentmapid    IN TBL_IRUSERLICENSEDOCUMENTMAP.iruserlicensedocumentmapid%TYPE,
ip_sipeventid                    IN TBL_SIP_EVENT.sipeventid%TYPE,
op_medlic                        OUT SYS_REFCURSOR
);

--Procedure for Sponsor User Integration
PROCEDURE SP_SET_SPONSOR_INT
(
ip_transcelerateuserid IN TBL_USERPROFILES.transcelerateuserid%TYPE,
ip_sipeventid          IN TBL_SIP_EVENT.sipeventid%TYPE,
op_sponsor             OUT SYS_REFCURSOR
);

--Procedure for Sponsor User Deactivation Integration
PROCEDURE SP_SET_SPONSOR_DEACT_INT
(
ip_userid              IN TBL_USERPROFILES.userid%TYPE,
ip_studyid             IN TBL_STUDY.studyid%TYPE,
ip_siteid              IN TBL_SITE.siteid%TYPE,
ip_sipeventid          IN TBL_SIP_EVENT.sipeventid%TYPE,
op_sponsor             OUT SYS_REFCURSOR
);

--Procedure for Integration of Site User Deactivation and Access Modification
PROCEDURE SP_SET_USERACCESS_INT
(
ip_userroleid       IN TBL_USERROLEMAP.userroleid%TYPE,
ip_sipeventid       IN TBL_SIP_EVENT.sipeventid%TYPE,
op_useraccess       OUT SYS_REFCURSOR
);

--Procedure for Integration of Sponsor User Deactivation and Access Modification
PROCEDURE SP_SET_SPONSOR_USERACCESS_INT
(
ip_userroleid       IN TBL_USERROLEMAP.userroleid%TYPE,
ip_sipeventid       IN TBL_SIP_EVENT.sipeventid%TYPE,
op_useraccess       OUT SYS_REFCURSOR
);

--Procedure for Facility Document Integration
PROCEDURE SP_SET_FACDOC_INT
(
ip_facilitydocmetadataid    IN TBL_FACILITYDOCMETADATA.facilitydocmetadataid%TYPE,
ip_sipeventid               IN TBL_SIP_EVENT.sipeventid%TYPE,
op_facdoc                   OUT SYS_REFCURSOR
);

--Procedure for User Training Integration
PROCEDURE SP_SET_USER_TRAINING_INT
(
ip_id           IN TBL_USER_TRAINING_STATUS.id%TYPE,
ip_sipeventid   IN TBL_SIP_EVENT.sipeventid%TYPE,
op_usertrng     OUT SYS_REFCURSOR
);

--Procedure for Integration of User Activation for future dates using Scheduler
PROCEDURE SP_SET_USERACCESS_ACT_INT;

--Procedure for Integration of User Deactivation for future dates using Scheduler
PROCEDURE SP_SET_USERACCESS_DEACT_INT;

--Procedure for Site Contact Integration
PROCEDURE SP_SET_SITECONTACT_INT
(
ip_sitecontactid IN TBL_SITECONTACTMAP.sitecontactid%TYPE,
ip_sipeventid    IN TBL_SIP_EVENT.sipeventid%TYPE,
op_sitecontact   OUT SYS_REFCURSOR
);

--Procedure for Site IRB Integration
PROCEDURE SP_SET_SITEIRB_INT
(
ip_siteirbid     IN TBL_SITEIRBMAP.siteirbid%TYPE,
ip_sipeventid    IN TBL_SIP_EVENT.sipeventid%TYPE,
op_siteirb       OUT SYS_REFCURSOR
);

--Procedure for Site LAB Integration
PROCEDURE SP_SET_SITELAB_INT
(
ip_sitelabid     IN TBL_SITELABMAP.sitelabid%TYPE,
ip_sipeventid    IN TBL_SIP_EVENT.sipeventid%TYPE,
op_sitelab       OUT SYS_REFCURSOR
);

--Procedure for Facility Integration
PROCEDURE SP_SET_FACILITY_INT
(
ip_facilityid    IN TBL_FACILITIES.facilityid%TYPE,
ip_sipeventid    IN TBL_SIP_EVENT.sipeventid%TYPE,
op_facility      OUT SYS_REFCURSOR
);

--Procedure for Potential Investigator Integration
PROCEDURE SP_SET_PISTATUS_INT
(
ip_potentialinvfacid    IN TBL_POTENTIALINVFACMAP.potentialinvfacid%TYPE,
ip_sipeventid           IN TBL_SIP_EVENT.sipeventid%TYPE,
op_pistatus             OUT SYS_REFCURSOR
);

--Procedure for User Deactivation Integration
PROCEDURE SP_SET_USERDEACT_INT
(
ip_userdeactivationid   IN TBL_USERDEACTIVATIONLOG.userdeactivationid%TYPE,
ip_sipeventid           IN TBL_SIP_EVENT.sipeventid%TYPE,
op_userdeact            OUT SYS_REFCURSOR
);

--Procedure for Access Modification Integration
PROCEDURE SP_SET_ACCESSMOD_INT
(
ip_acessmodreqid        IN TBL_ACESSMODIFICATIONREQUEST.acessmodreqid%TYPE,
ip_sipeventid           IN TBL_SIP_EVENT.sipeventid%TYPE,
op_accessmod            OUT SYS_REFCURSOR
);

--Procedure for Additional Site Location Integration
PROCEDURE SP_SET_ADDSITELOC_INT
(
ip_sitelocationid       IN TBL_ADDLSITELOCATION.sitelocationid%TYPE,
ip_sipeventid           IN TBL_SIP_EVENT.sipeventid%TYPE,
op_addsiteloc           OUT SYS_REFCURSOR
);

--Procedure for Training Credit Integration
PROCEDURE SP_SET_TRNGCREDIT_INT
(
ip_requestid       IN TBL_TRNGCREDITS.requestid%TYPE,
ip_sipeventid      IN TBL_SIP_EVENT.sipeventid%TYPE,
op_trngcredit      OUT SYS_REFCURSOR
);

--Procedure for Survey Response Integration
PROCEDURE SP_SET_SURVEY_RESPONSE_INT
(
ip_surveyid             IN TBL_SURVEY.surveyid%TYPE,
ip_transcelerateuserid  IN TBL_USERPROFILES.transcelerateuserid%TYPE,
ip_sipeventid           IN TBL_SIP_EVENT.sipeventid%TYPE,
op_surveyresponse       OUT SYS_REFCURSOR
);

--Procedure for SIP Event and Veeva Integration 
PROCEDURE SP_VEEVA_INTEG
(
ip_veeva_integ  IN gtyp_veeva_integ
);

--Procedure for SIP Event and SafeD Integration 
PROCEDURE SP_SAFED_INTEG
(
ip_safed_integ  IN gtyp_safed_integ
);

--Procedure for SIP Event and GobalTO Integration 
PROCEDURE SP_GOBALTO_INTEG
(
ip_gobalto_integ  IN gtyp_gobalto_integ
);

--Procedure for SIP Event and CTMS Integration 
PROCEDURE SP_CTMS_INTEG
(
ip_ctms_integ  IN gtyp_ctms_integ
);

--Procedure for SIP Integration with External Systems
PROCEDURE SP_INTEG
(
ip_integid      IN TBL_INTEG.integid%TYPE,
ip_pkid         IN VARCHAR2,
ip_orgid        IN TBL_ORGANIZATION.orgid%TYPE,
ip_sipeventid   IN TBL_SIP_EVENT.sipeventid%TYPE,
ip_eventtype    IN VARCHAR2
);

--Procedure to make entry into TBL_USERROLE_EXTSYS_MAP for USERROLEID and External System ID Mapping
PROCEDURE SP_USERROLE_EXTSYS
(
ip_userroleid       IN TBL_USERROLEMAP.userroleid%TYPE,
ip_sipeventid       IN TBL_SIP_EVENT.sipeventid%TYPE
);

--Procedure to populate Multiple Value Attributes for Integration
PROCEDURE SP_SET_INTEG_MULTIVALUE
(
ip_integid   IN TBL_INTEG.integid%TYPE,
ip_pk1       IN NUMBER,
ip_pk2       IN VARCHAR2,
ip_keytype   IN TBL_INTEG_MULTIVALUE.keytype%TYPE 
);

END PKG_INTEG;
/